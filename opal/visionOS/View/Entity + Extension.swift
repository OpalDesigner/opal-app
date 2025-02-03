//
//  Entity + Extension.swift
//  opal
//
//  Created by Vik Parth on 2/3/25.
//
import RealityKit

extension Entity {
    // To help apply GroundingShadowComponent for USDZ file in TabletopModelView.swift and ImmersiveModelView.swift
    // https://developer.apple.com/forums/thread/733918?answerId=761399022#761399022
    func enumerateHierarchy(_ body: (Entity, UnsafeMutablePointer<Bool>) -> Void) {
        var stop = false
        func enumerate(_ body: (Entity, UnsafeMutablePointer<Bool>) -> Void) {
            guard !stop else {
                return
            }
            body(self, &stop)
            for child in children {
                guard !stop else {
                    break
                }
                child.enumerateHierarchy(body)
            }
        }
        enumerate(body)
    }
}

