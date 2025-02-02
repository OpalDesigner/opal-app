//
//  HomeMenu.swift
//
//  Created by Vik Parth on 9/30/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import GroupActivities

struct ExploreActivity: GroupActivity {
    //Documentation: https://developer.apple.com/documentation/groupactivities
    //Documentation: https://developer.apple.com/documentation/groupactivities/groupactivitymetadata/activitytype
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "SharePlay Tutorial"
        metadata.subtitle = "Let's play together!"
        metadata.previewImage = UIImage(named: "birdicon")?.cgImage
        metadata.type = .generic //or .listenTogether, .watchTogether, .learnTogether, etc
        //metadata.sceneAssociationBehavior = .default
        return metadata
    }
}

struct HomeMenu: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    @State private var titleText: String = ""
    @State private var finalTitle: String = "Welcome to Scene Designer"
    @State private var descriptionText: String = "Scene Designer is an intuitive simulation tool that combines realistic graphics with playful animation."
    @State private var isTypingFinished: Bool = false
    @State private var isPressed = false
    @State private var modelRotation: Double = 0

    var body: some View {
        ZStack{
            HStack {
                VStack(spacing: 20) {
                    Text(titleText)
                        .font(.largeTitle)
                    Text(descriptionText)
                        .font(.system(size: 20))
                    Button{
                        isPressed.toggle()
                        Task {
                            if isPressed {
                                await openImmersiveSpace(id: "HandTrackingView")
                            } else {
                                await dismissImmersiveSpace()
                            }
                        }
                    }label: {
                        Label("Test Hand Tracking", systemImage: "")
                    }
                    Button{
                        startSharePlay()
                    }label: {
                        Label("Test SharePlay", systemImage: "")
                    }
                }
                .frame(width: 500, height: 200)
                .padding()
                .glassBackgroundEffect()
                .task {
                    for index in finalTitle.indices {
                        titleText = String(finalTitle.prefix(through: index))
                        try? await Task.sleep(for: .milliseconds(100))
                    }
                    isTypingFinished = true
                }
                .task{
                    await configureGroupSession()
                    registerGroupActivity()
                }
                
                NavigationStack {
                    Model3D(named: "tv_retro") { model in model
                            .resizable()
                            .scaledToFit()
                            .rotation3DEffect(.degrees(modelRotation), axis: (x: 0, y: 1, z: 0))
                            .animation(.easeInOut(duration: 1), value: modelRotation)
                            .scaleEffect(0.5)
                            .overlay(alignment: .bottom){
                                VStack{
                                    Button{
                                        modelRotation += 90
                                    }label: {
                                        Label("", systemImage: "arrow.triangle.2.circlepath.circle")
                                    }
                                }
                            }
                    } placeholder: {
                        ProgressView()
                    }
                }
            }
            .padding(.top, 300)
            .background {
                Image("interior-shot")
            }
        }
    }
    
    private func configureGroupSession() async {
        // Sets up SharePlay virtual room configuration
        for await session in ExploreActivity.sessions() {
            guard let systemCoordinator = await session.systemCoordinator else {continue}
            var configuration = SystemCoordinator.Configuration()
            configuration.supportsGroupImmersiveSpace = true
            configuration.spatialTemplatePreference = .conversational //or .sidebyside, .sideBySide.contentExtent(200)
            systemCoordinator.configuration = configuration
            session.join()
            
            /*
            // Receive group immersion style to configure group immersive space
            Task.detached {
                for await immersionStyle in systemCoordinator.groupImmersionStyle {
                    if let immersionStyle {
                        await openImmersiveSpace(id: "HandTrackingView")
                    } else {
                        await dismissImmersiveSpace()
                    }
                }
            }
             */
        }
    }
    
    private func registerGroupActivity(){
        let activity = ExploreActivity()
        let itemProvider = NSItemProvider()
        itemProvider.registerGroupActivity(activity)
        
        // Create the activity items configuration
        let configuration = UIActivityItemsConfiguration(itemProviders: [itemProvider])
        
        // Provide the metadata for the group activity
        configuration.metadataProvider = { key in
            guard key == .linkPresentationMetadata else { return Void.self }
            let metadata = ExploreActivity().metadata
            return metadata
        }
        
        /*
        UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first?
            .rootViewController?
            .activityItemsConfiguration = configuration
         */
    }
    
    func startSharePlay() {
        Task {
            let activity = ExploreActivity()
            switch await activity.prepareForActivation() {
            case .activationPreferred:
                do {
                    _ = try await activity.activate()
                    //groupSession = try await activity.activate()  // Store the session
                    print("SharePlay session activated successfully")
                } catch {
                    print("SharePlay unable to activate the activity: \(error)")
                }
            case .activationDisabled:
                print("SharePlay group activity activation disabled")
            case .cancelled:
                print("SharePlay group activity activation cancelled")
            @unknown default:
                print("SharePlay group activity activation unknown case")
            }
        }
    }

}

#Preview {
    HomeMenu()
}
