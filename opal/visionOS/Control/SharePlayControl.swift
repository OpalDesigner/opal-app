//
//  SharePlayControl.swift
//  opal
//
//  Created by Vik Parth on 2/6/25.
//

import SwiftUI
import GroupActivities

struct ExploreActivity: GroupActivity {
    static let activityIdentifier = "com.example.explore-together.activity"
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Explore Spaces Together"
        metadata.type = .generic  //or .listenTogether, .watchTogether, .learnTogether, etc
        metadata.sceneAssociationBehavior = .content(ExploreActivity.activityIdentifier)
        return metadata
    }
}

func startSharePlay() async {
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

/*
// Documentation: https://developer.apple.com/videos/play/wwdc2023/10087
func configureGroupSession() async {
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
        configuration.spatialTemplatePreference = .sideBySide //.surround, .sideBySide, .sideBySide.contentExtent(200)
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
    }
}
*/
