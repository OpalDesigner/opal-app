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
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.type = .generic  //or .listenTogether, .watchTogether, .learnTogether, etc
        return metadata
    }
}

struct HomeMenu: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    @State private var titleText: String = ""
    @State private var finalTitle: String = "Welcome to Scene Designer"
    @State private var descriptionText: String = "Scene Designer is an immersive simulation tool that combines realistic graphics with playful animation."
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
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
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
                .frame(width: 400, height: 250)
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
    
    // Documentation: https://developer.apple.com/videos/play/wwdc2023/10087
    private func configureGroupSession() async {
        // Sets up SharePlay virtual room configuration
        print("\n🔄 Starting group session configuration...")
        for await session in ExploreActivity.sessions() {
            guard let systemCoordinator = await session.systemCoordinator else {
                print("⚠️ Failed to get system coordinator")
                continue
            }
            
            // Setup Spatial Template Configuration
            var configuration = SystemCoordinator.Configuration()
            configuration.supportsGroupImmersiveSpace = true
            configuration.spatialTemplatePreference = .conversational //.surround, .sideBySide, .sideBySide.contentExtent(200)
            systemCoordinator.configuration = configuration
            print("📱 System coordinator configured")
            
            session.join()
            print("🎉 Joined session successfully")
            
            // Observe the Active Participants
            Task {
                for await participants in session.$activeParticipants.values {
                    print("👥 Participants update: \(participants.count) active")
                    for participant in participants {
                        print("  - Participant ID: \(participant.id)")
                    }
                    // If you have more than one participant, ready for interaction
                    if participants.count > 1 {
                        print("🎮 Multiple participants detected - ready for interaction!")
                    }
                }
            }
            
            // Observe the SystemCoordinator -> Local participant State
            Task.detached {
                for await localParticipantState in systemCoordinator.localParticipantStates {
                    if localParticipantState.isSpatial {
                        // Start syncing scroll position
                    } else {
                        // Stop syncing scroll position
                    }
                }
            }
            
            // Observe SystemCoordinator -> Group Immersion Style changes
            Task {
                for await immersionStyle in systemCoordinator.groupImmersionStyle {
                    print("🌍 Immersion style changed: \(String(describing: immersionStyle))")
                    if immersionStyle != nil {
                        print("✨ Group is ready for immersive experience")
                        // await openImmersiveSpace(id: "HandTrackingView")
                    } else {
                        // await dismissImmersiveSpace()
                    }
                }
            }
            
            /*
            Task.detached {
                for await immersionStyle in systemCoordinator.groupImmersionStyle {
                    print("🌍 Immersion style changed: \(String(describing: immersionStyle))")
                    switch immersionStyle {
                        case .full:
                            // Transition to a Full Space only if the participant
                            // gives permission to do so.
                            break
                                
                        case .mixed:
                            // Open or transition to a mixed style immersive space automatically.
                            break
                                
                        case .progressive:
                            // Open or transition to a progressive style immersive space automatically
                            break
                                
                        default:
                            // Dismiss the immersive space completely.
                            break
                    }
                }
            }
             */
        }
    }
    
    private func startSharePlay() {
        Task {
            let activity = ExploreActivity()
            switch await activity.prepareForActivation() {
            case .activationPreferred:
                do {
                    let activated = try await activity.activate()
                    print("✅ SharePlay session activated: \(activated)")
                } catch {
                    print("❌ SharePlay activation failed: \(error.localizedDescription)")
                }
            case .activationDisabled:
                print("⚠️ SharePlay activation disabled - check FaceTime status")
            case .cancelled:
                print("🚫 SharePlay activation cancelled by user")
            @unknown default:
                print("❓ Unknown SharePlay activation state")
            }
        }
    }
}

#Preview {
    HomeMenu()
}
