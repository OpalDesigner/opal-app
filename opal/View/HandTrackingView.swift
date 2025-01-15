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
        mesh: .generateSphere(radius: 0.005),
        materials: [SimpleMaterial(color: .systemBlue, isMetallic: true)],
        collisionShape: .generateSphere(radius: 0.005),
        mass: 0.0
    )
    //entity.transform.translation = SIMD3<Float>(0, 1.45, -0.25)
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
    
    // Dictionary to store fingertip entities for both hands
    private var fingerEntities: [HandAnchor.Chirality: [HandSkeleton.JointName: ModelEntity]] = [
        .left: [:],
        .right: [:]
    ]
    
    func setupContentEntity() -> Entity {
        // Setup 21 hand points
        let joints: [HandSkeleton.JointName] = [
            .thumbKnuckle,          .thumbIntermediateBase,         .thumbIntermediateTip,          .thumbTip,
            .indexFingerKnuckle,    .indexFingerIntermediateBase,   .indexFingerIntermediateTip,    .indexFingerTip,
            .middleFingerKnuckle,   .middleFingerIntermediateBase,  .middleFingerIntermediateTip,   .middleFingerTip,
            .ringFingerKnuckle,     .ringFingerIntermediateBase,    .ringFingerIntermediateTip,     .ringFingerTip,
            .littleFingerKnuckle,   .littleFingerIntermediateBase,  .littleFingerIntermediateTip,   .littleFingerTip,
            .wrist
        ]
        
        for hand in [HandAnchor.Chirality.left, .right] {
            fingerEntities[hand] = [:]
            for joint in joints {
                let entity = createFingertip()
                fingerEntities[hand]?[joint] = entity
                contentEntity.addChild(entity)
            }
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
    
    func processHandUpdates() async {
            for await update in handTracking.anchorUpdates {
                //Capture Hand being tracked
                let handAnchor = update.anchor
                guard handAnchor.isTracked else { continue }
                
                //Capture Fingertip being tracked
                for (fingerType, entity) in fingerEntities[handAnchor.chirality] ?? [:] {
                    if let fingerTip = handAnchor.handSkeleton?.joint(fingerType),
                       fingerTip.isTracked {
                        let transform = handAnchor.originFromAnchorTransform * fingerTip.anchorFromJointTransform
                        var offsetTransform = transform
                        //offsetTransform.columns.3.x += 0.05
                        //offsetTransform.columns.3.y += 0
                        //offsetTransform.columns.3.z -= 0.15
                        entity.setTransformMatrix(offsetTransform, relativeTo: nil)
                    }
                }
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
        guard let indexFinger = fingerEntities[.right]?[.indexFingerTip] else { return }
        let entity = ModelEntity(
            mesh: .generateBox(size: 0.1),
            materials: [SimpleMaterial(color: .systemBlue, isMetallic: true)],
            collisionShape: .generateBox(size: SIMD3<Float>(repeating: 0.1)),
            mass: 1.0
        )
        entity.transform = indexFinger.transform
        // Add a custom component to track the base scale for this specific entity
        struct ScaleComponent: Component {
            var baseScale: Float = 1.0
        }
        entity.components.set(ScaleComponent())
        entity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        entity.components.set(GroundingShadowComponent(castsShadow: true))
        let material = PhysicsMaterialResource.generate(friction: 1, restitution: 0.0)
        entity.components.set(PhysicsBodyComponent(
            shapes: entity.collision!.shapes,
            mass: 1.0,
            material: material,
            mode: .dynamic
        ))
        contentEntity.addChild(entity)
    }
}
    
struct HandTrackingView: View {
    @StateObject private var model = HandTrackingViewModel()
    @State private var baseScale: Float = 1.0

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
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded({ value in
                    Task{
                        await model.placeCube()
                    }
                })
        )
        // Add grab gesture
        .gesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    value.entity.position = value.convert(value.location3D, from: .local, to: value.entity.parent!)
                }
        )
        // Add pinch-to-scale gesture
        .gesture(MagnifyGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                // Get this specific entity's scale component
                struct ScaleComponent: Component {
                    var baseScale: Float = 1.0
                }
                var scaleComponent = value.entity.components[ScaleComponent.self] ?? ScaleComponent()
                let scale = scaleComponent.baseScale * Float(value.magnification)
                let clampedScale = min(max(scale, 0.5), 2.0)
                value.entity.scale = SIMD3(repeating: clampedScale)
            }
            .onEnded { value in
                // Update the base scale when gesture ends
                struct ScaleComponent: Component {
                    var baseScale: Float = 1.0
                }
                var scaleComponent = value.entity.components[ScaleComponent.self] ?? ScaleComponent()
                scaleComponent.baseScale = length(value.entity.scale)
                value.entity.components.set(scaleComponent)
            }
        )
    }
}

#Preview {
    HandTrackingView()
}
