//
//  SessionController.swift
//  opal
//
//  Created by Brian Corrieri on 21/03/2025.
//


import GroupActivities
import Observation

@Observable @MainActor
final class SessionController {
    
    var appModel: AppModel
    
    let session: GroupSession<ExploreActivity>
    let messenger: GroupSessionMessenger
    let systemCoordinator: SystemCoordinator
    
    var message: SharePlayMessage?
    var immersiveSpaceUpdate: ImmersiveSpaceUpdate?
    
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
        
        Task {
            for await immersionStyle in systemCoordinator.groupImmersionStyle {
                if let immersionStyle {
                    appModel.immersionStyle = immersionStyle
                }
            }
        }
    }
    
    func observeRemoteParticipantUpdates() {
        observeSharePlayMessageUpdates()
    }
    
    func observeSharePlayMessageUpdates() {
        Task {
            for await (message, context) in messenger.messages(of: ImmersiveSpaceUpdate.self) {
//                let senderID = context.source.id
                immersiveSpaceUpdate = message
            }
        }
    }
    
}
