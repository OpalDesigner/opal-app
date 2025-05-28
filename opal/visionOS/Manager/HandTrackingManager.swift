//
//  HandTrackingManager.swift
//  opal
//
//  Created by Brian Corrieri on 27/05/2025.
//


import Foundation
import ARKit
import RealityKit
import QuartzCore
import AVFAudio
import UIKit

@Observable
@MainActor
class HandTrackingManager {
    
    let arkitSession = ARKitSession()
    private let handTracking = HandTrackingProvider()
    private let worldTracking = WorldTrackingProvider()
    
    var appModel: AppModel
    var rootEntity = Entity()
    var wristEntity: Entity
    var wristAccessoryEntity: Entity
    var littleFingerEntity: Entity
    var littleFingerAccessoryEntity: Entity
    var deviceEntity: Entity
    
    var previousWristMatrix: float4x4?
    var previousLittleFingerMatrix: float4x4?
    
    init(appModel: AppModel) {
        self.appModel = appModel
        wristEntity = Entity()
        wristAccessoryEntity = Entity()
        littleFingerEntity = Entity()
        littleFingerAccessoryEntity = Entity()
        deviceEntity = Entity()
        
        wristAccessoryEntity.position.y = -0.06
        wristAccessoryEntity.position.z = 0.15
        wristEntity.addChild(wristAccessoryEntity)
        
        littleFingerAccessoryEntity.position.z = 0.1
        littleFingerEntity.addChild(littleFingerAccessoryEntity)
        
        rootEntity.addChild(wristEntity)
        rootEntity.addChild(littleFingerEntity)
        rootEntity.addChild(deviceEntity)
    }
    
    func reset() {
        wristAccessoryEntity.children.removeAll()
        littleFingerAccessoryEntity.children.removeAll()
    }
    
    func addMenuEntity(_ entity: Entity) {
        wristAccessoryEntity.addChild(entity)
    }
    
    func addMenuBEntity(_ entity: Entity) {
        littleFingerAccessoryEntity.addChild(entity)
    }
        
    func runARKitSession() async {
        do {
            try await arkitSession.run([handTracking, worldTracking])
        } catch {
            print(#function, error)
            return
        }
    }
    
    func processHandUpdates() async {
        for await update in handTracking.anchorUpdates {
            let handAnchor = update.anchor
            
            guard handAnchor.isTracked else { continue }
            
            processHandAnchorUpdate(handAnchor: handAnchor,
                                    chirality: .left,
                                    jointName: .wrist,
                                    jointEntity: wristEntity,
                                    jointAccessoryEntity: wristAccessoryEntity,
                                    previousMatrix: &previousWristMatrix,
                                    checkIsLookingAt: checkIsLookingAtWrist)
            processHandAnchorUpdate(handAnchor: handAnchor,
                                    chirality: .left,
                                    jointName: .littleFingerKnuckle,
                                    jointEntity: littleFingerEntity,
                                    jointAccessoryEntity: littleFingerAccessoryEntity,
                                    previousMatrix: &previousLittleFingerMatrix,
                                    checkIsLookingAt: checkIsLookingAtLittleFinger)
        }
    }
    
    func processHandAnchorUpdate(handAnchor: HandAnchor, chirality: HandAnchor.Chirality, jointName: HandSkeleton.JointName, jointEntity: Entity,
                                 jointAccessoryEntity: Entity, previousMatrix: inout float4x4?, checkIsLookingAt: () -> Void) {
        guard handAnchor.chirality == chirality,
              let joint = handAnchor.handSkeleton?.joint(jointName),
              joint.isTracked
        else { return }
        
        let originFromJoint = handAnchor.originFromAnchorTransform * joint.anchorFromJointTransform
        
        updateHandEntityTransform(originFromJoint, previousMatrix: &previousMatrix, entity: jointEntity)
        lookAtCamera(entity: jointAccessoryEntity.children.first)
        checkIsLookingAt()
    }

    func lookAtCamera(entity: Entity?) {
        guard let entity, let deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) else { return }
        let cameraTransform = Transform(matrix: deviceAnchor.originFromAnchorTransform)
        let translation = entity.transform.translation
        entity.look(at: cameraTransform.translation,
                    from: entity.position(relativeTo: nil),
                    relativeTo: nil,
                    forward: .positiveZ)
        entity.transform.translation = translation
    }

    func updateHandEntityTransform(_ newMatrix: float4x4, previousMatrix: inout float4x4?, entity: Entity) {
        let positionThreshold: Float = 0.008
        let rotationThreshold: Float = 0.08 // radians

        guard let previous = previousMatrix else {
            entity.setTransformMatrix(newMatrix, relativeTo: nil)
            previousMatrix = newMatrix
            return
        }

        let prevPosition = previous.columns.3.xyz
        let newPosition = newMatrix.columns.3.xyz
        let positionDelta = simd_distance(prevPosition, newPosition)

        let prevRotation = simd_quaternion(previous)
        let newRotation = simd_quaternion(newMatrix)
        let rotationDelta = simd_angle(simd_normalize(newRotation * simd_inverse(prevRotation)))

        let positionChanged = positionDelta > positionThreshold
        let rotationChanged = rotationDelta > rotationThreshold
        
        if positionChanged || rotationChanged {
            let transform = Transform(matrix: newMatrix)
            entity.move(to: transform, relativeTo: nil, duration: 0.2)
            previousMatrix = newMatrix
        }
    }
    
    func isHandJointFacingUser(entity: Entity, yAxisDirection: Float) -> Bool {
        guard let deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) else { return false }
        let entityTransform = entity.transformMatrix(relativeTo: nil)
        let headTransform = deviceAnchor.originFromAnchorTransform
        
        let entityPos = entityTransform.columns.3.xyz
        let headPos = headTransform.columns.3.xyz
        
        // Hand Joint orientation
        let yAxis = simd_normalize((entityTransform * SIMD4<Float>(0, yAxisDirection, 0, 0)).xyz)
        let toHead = simd_normalize(headPos - entityPos)
        let jointOrientationThreshold: Float = -0.7
        let facingUser = simd_dot(yAxis, toHead) < jointOrientationThreshold
        
        // Head (device) orientation
        let zAxis = simd_normalize((headTransform * SIMD4<Float>(0, 0, -1, 0)).xyz)
        let toEntity = simd_normalize(entityPos - headPos)
        let headOrientationThreshold: Float = 0.8
        let headLookingAtEntity = simd_dot(zAxis, toEntity) > headOrientationThreshold
        
        return facingUser && headLookingAtEntity
    }
    
    
    func checkIsLookingAtWrist() {
        let isLooking = isHandJointFacingUser(entity: wristAccessoryEntity, yAxisDirection: 1)
        if appModel.openMenu != isLooking {
            playSystemSound(isOn: isLooking)
            appModel.openMenu = isLooking
        }
    }
    
    func checkIsLookingAtLittleFinger() {
        let isLooking = isHandJointFacingUser(entity: littleFingerAccessoryEntity, yAxisDirection: -1)
        if appModel.openMenuB != isLooking {
            playSystemSound(isOn: isLooking)
            appModel.openMenuB = isLooking
        }
    }
    
    func playSystemSound(isOn: Bool) {
        guard isOn else { return }
        let systemSoundID: SystemSoundID = 1124
        AudioServicesPlaySystemSound(systemSoundID)
    }
    
}

extension SIMD4 where Scalar == Float {
    var xyz: SIMD3<Float> { SIMD3(x, y, z) }
}
