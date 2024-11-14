//
//  ImmersiveModelView.swift
//  TestApp
//
//  Created by Vik Parth on 10/18/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

//This code creates the full Immersive view where you are inside of a 3D set
class ModelControlData: ObservableObject {
    @Published var cameraPosition: SIMD3<Float> = SIMD3<Float>(0, 0, 0) // Starting at eye level
    @Published var cameraRotation: Float = 0
}

struct ImmersiveModelView: View {
    // Access shared data in NavigationControlUI.swift
    @ObservedObject var modelControlData: ModelControlData
    
    // State variables
    @State private var object = Entity()

    // Model properties
    let id = UUID()
    let modelName: String
    let initialPosition: SIMD3<Float>
    let initialScale: Float
    
    var body: some View {
        RealityView{ content in
            //Load your 3D model
            guard let model = try? await Entity(named: modelName, in: realityKitContentBundle)
            else{fatalError("Unable to load scene model: \(modelName)")}
            content.add(model)
            
            // initialize position and scale
            guard let object = model.findEntity(named: modelName)
            else {fatalError("Unable to find entity in scene model: \(modelName)")}
            object.position = initialPosition
            object.scale = SIMD3<Float>(repeating: initialScale)
            self.object = object
            
            // Create a camera entity that will be our viewpoint
            let cameraEntity = Entity()
            updateCameraTransform(cameraEntity)
            content.add(cameraEntity)
            
        } update: { content in
            if let cameraEntity = content.entities.first {
                updateCameraTransform(cameraEntity)
            }
        }
    }
    
    private func updateCameraTransform(_ camera: Entity) {
        let c = cos(modelControlData.cameraRotation)
        let s = sin(modelControlData.cameraRotation)
        
        // Set camera rotation matrix around Y axis
        let rotationMatrix = float4x4(columns: (
            SIMD4<Float>(c, 0, -s, 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(s, 0, c, 0),
            SIMD4<Float>(0, 0, 0, 1)
        ))
        
        // Set camera translation matrix
        let pos = modelControlData.cameraPosition
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
        modelControlData: ModelControlData(),
        modelName: "Coffee_Shop",
        initialPosition: SIMD3<Float>(0, 0, 0),
        initialScale: 0.01
    )
}
