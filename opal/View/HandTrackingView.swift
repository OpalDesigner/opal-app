//
//  StackingView.swift
//  opal
//
//  Created by Vik Parth on 12/13/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import ARKit

//This code is not yet complete. This is to allow you to place objects on real world surfaces using ARkit and SceneReconstruction (detect planes, surfaces)

func createFingertip() -> ModelEntity{
    let entity = ModelEntity(
        mesh: .generateSphere(radius: 0.01),
        materials: [SimpleMaterial(color: .systemBlue, isMetallic: true)],
        collisionShape: .generateSphere(radius: 0.005),
        mass: 0.0
    )
    entity.transform.translation = SIMD3<Float>(0, 1.45, -0.25)
    entity.components.set(PhysicsBodyComponent(mode: .kinematic))
    entity.components.set(OpacityComponent(opacity: 1.0))
    return entity
}

@MainActor class HandTrackingViewModel: ObservableObject {
    private let session = ARKitSession()
    private let handTracking = HandTrackingProvider()
    private let sceneReconstruction = SceneReconstructionProvider()
    
    private var contentEntity = Entity()
    private var meshEntities = [UUID : ModelEntity]()
    private let fingerEntities: [HandAnchor.Chirality: ModelEntity] = [
        .left: createFingertip(),
        .right: createFingertip()
    ]
    private var lastCubePlacementTime: TimeInterval = 0
    
    func setupContentEntity() -> Entity{
        for entity in fingerEntities.values{
            contentEntity.addChild(entity)
        }
        return contentEntity
    }
    
    func runSession() async{
        var dataProvidersAreSupported: Bool {
            HandTrackingProvider.isSupported && SceneReconstructionProvider.isSupported
        }
        
        var isReadyToRun: Bool {
            handTracking.state == .initialized && sceneReconstruction.state == .initialized
        }
        
        do{
            if dataProvidersAreSupported && isReadyToRun {
                try await session.run([sceneReconstruction, handTracking])
            } else {
                print("Failed to initialze Hand Tracking or Scene Reconstruction")
            }
        } catch {
            print("Failed to start session: \(error)")
        }
    }
    
    func processHandUpdates() async{
        for await update in handTracking.anchorUpdates{
            //Capture Hand being tracked
            let handAnchor = update.anchor
            guard handAnchor.isTracked else{continue}
            
            //Capture Fingertip being tracked
            let fingerTip = handAnchor.handSkeleton?.joint(.indexFingerTip)
            guard ((fingerTip?.isTracked) != nil) else{continue}
            let originFromWrist = handAnchor.originFromAnchorTransform
            let wristFromIndex = fingerTip?.anchorFromJointTransform
            let originFromIndex = originFromWrist * wristFromIndex!
            
            fingerEntities[handAnchor.chirality]?.setTransformMatrix(originFromIndex, relativeTo: nil)
        }
    }
    
    func processReconstructionUpdates() async{
        // Each update contains info about surfaces the AR system has found
        for await update in sceneReconstruction.anchorUpdates {
            // Create a 3D mesh from the detected surface
            guard let shape = try? await ShapeResource.generateStaticMesh(from: update.anchor) else {continue}
            
            switch update.event {
            // New Surface Detected
            case .added:
                let entity = ModelEntity()
                entity.transform = Transform(matrix: update.anchor.originFromAnchorTransform)
                entity.collision = CollisionComponent(shapes: [shape], isStatic: true)
                entity.physicsBody = PhysicsBodyComponent()
                entity.components.set(InputTargetComponent())
                
                meshEntities[update.anchor.id] = entity
                contentEntity.addChild(entity)
            // Existing Surface Changed (to match changes in the real world scene)
            case .updated:
                guard let entity = meshEntities[update.anchor.id] else {fatalError("Fatal Error")}
                entity.transform = Transform(matrix: update.anchor.originFromAnchorTransform)
                entity.collision?.shapes = [shape]
            // Surface Not Detected
            case .removed:
                meshEntities[update.anchor.id]?.removeFromParent()
                meshEntities.removeValue(forKey: update.anchor.id)
            }
        }
    }
    
    func placeCube() async {
        guard let leftFingerPosition = fingerEntities[.left]?.transform.translation else {return}
        
        let placementLocation = leftFingerPosition + SIMD3<Float>(0, -0.05, 0)
        let entity = ModelEntity(mesh: .generateBox(size: 0.1),
                                 materials: [SimpleMaterial(color: .systemBlue, isMetallic: false)],
                                 collisionShape: .generateBox(size: SIMD3<Float>(repeating: 0.1)),
                                 mass: 1.0)
        entity.setPosition(placementLocation, relativeTo: nil)
        entity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        entity.components.set(GroundingShadowComponent(castsShadow: true))
        entity.transform.translation = SIMD3<Float>(0, 1.45, -0.25)
        
        let material = PhysicsMaterialResource.generate(friction: 0.8, restitution: 0.0)
        entity.components.set(PhysicsBodyComponent(shapes: entity.collision!.shapes,
                                                   mass: 1.0,
                                                   material: material,
                                                   mode: .dynamic))
        contentEntity.addChild(entity)
    }
}
    
struct HandTrackingView: View {
    @StateObject private var model = HandTrackingViewModel()

    var body: some View {
        RealityView { content in
            content.add(model.setupContentEntity())
        }.task{
            // run AR kit session
            await model.runSession()
        }.task{
            // proces hand updates
            await model.processHandUpdates()
        }.task{
            // process world reconstruction
            await model.processReconstructionUpdates()
        }
        .gesture(
            SpatialTapGesture().targetedToAnyEntity()
                .onEnded({ value in
                    Task{
                        await model.placeCube()
                    }
                })
        )
    }
}

#Preview {
    HandTrackingView()
}
