//
//  ImmersiveModelView.swift
//  TestApp
//
//  Created by Vik Parth on 10/18/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveModelView: View {
    // Access shared data in NavigationControlUI.swift
    @ObservedObject var navigationData: NavigationData
    
    // Model properties
    let id = UUID()
    let modelName: String
    let initialPosition: SIMD3<Float>
    let initialScale: Float
    
    // State variables
    @State private var model = Entity()
    
    var body: some View {
        RealityView{ content in
            guard let rootEntity = try? await Entity(named: modelName, in: realityKitContentBundle)
            else { fatalError("Unable to load scene model: \(modelName)") }
            content.add(rootEntity)
            
            print("\n\(modelName) Debug Information:")
            print("Initial Position:     \(initialPosition)")
            print("Initial Scale:        \(initialScale)")
            print("Root entity children: \(rootEntity.children.map { $0.name })")
            print("Root Position:        \(rootEntity.position)")
            print("Root Scale:           \(rootEntity.scale)")
            
            // Find child entity
            guard let model = rootEntity.findEntity(named: modelName)
            else {fatalError("Unable to find entity in scene model: \(modelName)")}
            model.transform.translation = initialPosition
            model.transform.scale = SIMD3<Float>(repeating: initialScale)
            
            // Create a camera entity
            let cameraEntity = Entity()
            updateCameraTransform(cameraEntity)
            content.add(cameraEntity)
            cameraEntity.position = SIMD3<Float>(0, 0, 0)
            
            print("Model Position:       \(model.transform.translation)")
            print("Model Scale:          \(model.transform.scale)")
            print("Camera Position:      \(cameraEntity.position)")
            
            //Add particle effects
            /*
            let entity = Entity()
            entity.name = "SnowEmitter"
            entity.position = .init(x: 0, y: 2, z: 0)
            entity.setScale(.init(x: 20, y: 20, z: 20), relativeTo: nil)
            content.add(entity)
            var emitter = ParticleEmitterComponent.Presets.snow
            emitter.mainEmitter.birthRate = 3000
            entity.components.set(emitter)
             */
            
        } update: { content in
            if let cameraEntity = content.entities.first {
                updateCameraTransform(cameraEntity)
            }
        }
    }
    
    private func updateCameraTransform(_ camera: Entity) {
        let c = cos(navigationData.cameraRotation)
        let s = sin(navigationData.cameraRotation)
        
        // Set camera to only rotate around it's y-axis
        let rotationMatrix = float4x4(columns: (
            SIMD4<Float>(c, 0, -s, 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(s, 0, c, 0),
            SIMD4<Float>(0, 0, 0, 1)
        ))
        
        // Set camera translation matrix
        let pos = navigationData.cameraPosition
        let translationMatrix = float4x4(columns: (
            SIMD4<Float>(1, 0, 0, 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(pos.x, pos.y, pos.z, 1)
        ))
        
        // Multiplication order matters. First rotate, then translate
        let transform = rotationMatrix * translationMatrix
        
        // Apply the combined transform
        camera.transform.matrix = transform
    }
    
}

//Test Sample Preview on Xcode Preview Window
#Preview {
    ImmersiveModelView(
        navigationData: NavigationData(),
        modelName: "Planets",
        initialPosition: SIMD3<Float>(0, 0, 0),
        initialScale: 1
    )
}
