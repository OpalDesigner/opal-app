//
//  HandTrackingViewModel.swift
//  TestApp
//
//  Created by Vik Parth on 10/23/24.
//

import RealityKit
import RealityKitContent
import SwiftUI
import ARKit

//This code is not yet complete. This is to allow you to place real objects in realworld using ARkit and SceneReconstruction (detect planes, surfaces). HandTrackingViewModel() is called from HandInteractionView.swift

func createFingertip() -> ModelEntity{
    let entity = ModelEntity(
        mesh: .generateSphere(radius: 0.01),
        materials: [UnlitMaterial(color: .cyan)],
        collisionShape: .generateSphere(radius: 0.005),
        mass: 0.0
    )
    
    entity.components.set(PhysicsBodyComponent(mode: .kinematic))
    entity.components.set(OpacityComponent(opacity: 1.0))
    
    return entity
}

@MainActor class HandTrackingViewModel: ObservableObject{
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
        do {
            try await session.run([sceneReconstruction, handTracking])
        } catch{
            print("failed to start session: \(error)")
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
}
