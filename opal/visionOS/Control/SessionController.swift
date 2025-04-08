//
//  SessionController.swift
//  opal
//
//  Created by Brian Corrieri on 21/03/2025.
//


import GroupActivities
import Observation
import Combine
import SwiftUI

@Observable @MainActor
final class SessionController {
    
    var appModel: AppModel
    
    let session: GroupSession<ExploreActivity>
    let messenger: GroupSessionMessenger
    let systemCoordinator: SystemCoordinator
    
    var message: SharePlayMessage?
    var immersiveSpaceUpdate: ImmersiveSpaceUpdate?
    var interactiveTVUpdate: InteractiveTVUpdate?
    var appStateUpdate: AppStateUpdate?
    var interactiveObjectUpdate: InteractiveObjectUpdate?
    
    private var subscriptions = Set<AnyCancellable>()
    
    init?(_ groupSession: GroupSession<ExploreActivity>, appModel: AppModel) async {
        guard let groupSystemCoordinator = await groupSession.systemCoordinator else {
            return nil
        }
        self.appModel = appModel
        session = groupSession

        // Create the group session messenger for the session controller, which it uses to keep the game in sync for all participants.
        messenger = GroupSessionMessenger(session: session)

        systemCoordinator = groupSystemCoordinator
        
        observeRemoteParticipantUpdates()
        configureSystemCoordinator()
        
        session.join()
    }
    
    func configureSystemCoordinator() {
        // Let the system coordinator show each players' spatial Persona in the immersive space.
        systemCoordinator.configuration.supportsGroupImmersiveSpace = true
        systemCoordinator.configuration.spatialTemplatePreference = .conversational
        
        Task {
            for await localParticipantState in systemCoordinator.localParticipantStates {
                
            }
        }
        
        let immersionStyleTask = Task.detached { [weak self] in
            guard let self else { return }
            for await immersionStyle in self.systemCoordinator.groupImmersionStyle {
                if let immersionStyle {
                    await MainActor.run {
                        self.appModel.immersionStyle = immersionStyle
                    }
                }
            }
        }
        subscriptions.insert(.init { immersionStyleTask.cancel() })
    }
    
    func observeRemoteParticipantUpdates() {
        observeSharePlayMessageUpdates()
    }
    
    func observeSharePlayMessageUpdates() {
        
        let immersiveSpaceTask = Task.detached { [weak self] in
            guard let self else { return }
            for await (message, context) in self.messenger.messages(of: ImmersiveSpaceUpdate.self) {
                print(#function, message)
                await MainActor.run {
                    self.immersiveSpaceUpdate = message
                }
            }
        }
        subscriptions.insert(.init { immersiveSpaceTask.cancel() })
        
        
        let tvUpdateTask = Task.detached { [weak self] in
            guard let self else { return }
            for await (message, context) in self.messenger.messages(of: InteractiveTVUpdate.self) {
                print(#function, message)
                await MainActor.run {
                    self.interactiveTVUpdate = message
                }
            }
        }
        subscriptions.insert(.init { tvUpdateTask.cancel() })
        
        let appStateUpdateTask = Task.detached { [weak self] in
            guard let self else { return }
            for await (message, _) in self.messenger.messages(of: AppStateUpdate.self) {
                print(#function, message)
                await MainActor.run {
                    self.appStateUpdate = message
                }
            }
        }
        subscriptions.insert(.init { appStateUpdateTask.cancel() })
        
        let interactiveObjectUpdateTask = Task.detached { [weak self] in
            guard let self else { return }
            for await (message, _) in self.messenger.messages(of: InteractiveObjectUpdate.self) {
                print(#function, message)
                await MainActor.run {
                    self.interactiveObjectUpdate = message
                }
            }
        }
        subscriptions.insert(.init { interactiveObjectUpdateTask.cancel() })
        
    }
    
}
