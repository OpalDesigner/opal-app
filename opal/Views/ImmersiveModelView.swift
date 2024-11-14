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
            let rotation = simd_quatf(angle: modelControlData.cameraRotation, axis: [0, 1, 0])
            let position = modelControlData.cameraPosition
            cameraEntity.transform = .init(
                scale: .one,
                rotation: rotation,
                translation: position
            )
            content.add(cameraEntity)
        } update: { content in
            if let cameraEntity = content.entities.first {
                let rotation = simd_quatf(angle: modelControlData.cameraRotation, axis: [0, 1, 0])
                let position = modelControlData.cameraPosition
                cameraEntity.transform = .init(
                    scale: .one,
                    rotation: rotation,
                    translation: position
                )
            }
        }
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
