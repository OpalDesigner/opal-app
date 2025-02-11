//
//  Entity + Extension.swift
//  opal
//
//  Created by Vik Parth on 2/3/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

// Model Loading
extension Entity {
    static func loadRootEntity(named modelName: String) async -> Entity? {
        // Try loading from the realityKitContentBundle first
        do {
            return try await Entity(named: modelName, in: realityKitContentBundle)
        } catch {
            // If bundle fails, try loading from documents directory
            let fileManager = FileManager.default
            guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("Error accessing documents directory")
                return nil
            }
            
            // Check all categories defined in ModelCategory
            for category in ModelCategory.allCases {
                let categoryPath = category.rawValue.lowercased()
                let modelURL = documentsDirectory.appendingPathComponent("\(categoryPath)/\(modelName).usdz")
                if fileManager.fileExists(atPath: modelURL.path) {
                    do {
                        print("Loading model from \(categoryPath): \(modelName)")
                        return try await Entity.load(contentsOf: modelURL)
                    } catch {
                        print("Error loading model from \(categoryPath): \(error.localizedDescription)")
                        continue // Try next category if this one fails
                    }
                }
            }
            print("Model not found in any category: \(modelName)")
            return nil
        }
    }
}

// Hierarchy Operations
// To help apply GroundingShadowComponent for USDZ file in TabletopModelView.swift and ImmersiveModelView.swift
// https://developer.apple.com/forums/thread/733918?answerId=761399022#761399022
extension Entity {
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
