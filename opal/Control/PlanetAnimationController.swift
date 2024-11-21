//
//  PlanetAnimationController.swift
//  opal
//
//  Created by Vik Parth on 11/19/24.
//

import RealityKit
import SwiftUI

//Once Timeline views are working in Reality Composer Pro, this Animation Controller may not be needed
class PlanetAnimationController {
    private var model: Entity
    
    init(model: Entity) {
        self.model = model
    }
    
    func startAnimation() {
        guard let sun = model.findEntity(named: "Sun") else { return }
        
        print("Sun position before: \(sun.position)")
        print("Sun orientation before: \(round(sun.orientation.angle * 180/Float.pi)) degrees")

        // Create rotation transform
        let rotation = Transform(
            rotation: simd_quatf(angle: 45 * .pi/180, axis: [0, 1, 0])
        )

        sun.move(
            to: rotation,
            relativeTo: sun,
            duration: 1,
            timingFunction: .easeInOut
        )
        
        print("Sun position after: \(sun.position)")
        print("Sun orientation after: \(round(sun.orientation.angle * 180/Float.pi)) degrees ")
    }
    
    func stopAnimation() {
        model.stopAllAnimations()
    }
}
