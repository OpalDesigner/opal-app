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
    @Published var position: SIMD3<Float> = SIMD3<Float>(0, 0, 0)
    @Published var scale: Float = 0
    @Published var rotation: Float = 0
}

struct ImmersiveModelView: View {
    // Access Shared data in NavigationControlUI.swift
    @ObservedObject var modelControlData: ModelControlData

    // Model properties
    let id = UUID()
    let modelName: String
    let initialPosition: SIMD3<Float>
    let initialScale: Float
    
    // State variables
    @State private var object = Entity()
    
    var body: some View {
        RealityView{ content in
            //Load your 3D model
            guard let model = try? await Entity(named: modelName, in: realityKitContentBundle)
            else{fatalError("Unable to load scene model: \(modelName)")}
            content.add(model)
            
            // Find the specific object
            guard let object = model.findEntity(named: modelName)
            else {fatalError("Unable to find entity in scene model: \(modelName)")}
            
            // Apply scale to the specific object
            object.position = initialPosition
            object.scale = SIMD3<Float>(repeating: initialScale)
            self.object = object
            
            //Update Global Variables
            modelControlData.position = initialPosition
            modelControlData.scale = initialScale
            
        } update: { content in
            object.position = modelControlData.position
            object.orientation = simd_quatf(angle: modelControlData.rotation, axis: SIMD3<Float>(0, 1, 0))
            
            //print values
            print("\(modelName) Immersive Position:         \(object.position)")
            print("\(modelName) Immersive Scale (Object):   \(object.scale)")
            print("\(modelName) Immersive Orientation:      \(String(format: "%.2f", simd_angle(object.orientation) * 180 / .pi))°")
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
