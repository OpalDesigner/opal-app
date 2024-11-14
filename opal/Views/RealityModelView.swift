//
//  RealityView.swift
//  TestApp
//
//  Created by Vik Parth on 10/18/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import AVFoundation

//This code creates the a small tabletop view of your set
struct RealityModelView: View {
    // Model properties
    let id = UUID()
    let modelName: String
    let initialPosition: SIMD3<Float>
    let initialScale: Float

    // State variables
    @State private var object = Entity()
    
    // Add state for tracking the model's center
    @State private var modelCenter: SIMD3<Float> = .zero
    @State private var modelPivot: SIMD3<Float> = .zero
    
    // State variables for the gestures
    @State private var currentScale: Float = 1.0
    @State private var currentRotationY: Float = 0.0
    @GestureState private var rotationAngle: Float = 0.0
    
    // State variables for the toolbar buttons
    @State private var modelRotation: Double = 0.0
    @State private var modelAnimation: Float = 0.0
    @State private var isPlaying = false

    var body: some View {
        Spacer()
        RealityView { content in
            //Load your 3D model
            guard let model = try? await Entity(named: modelName, in: realityKitContentBundle)
            else {fatalError("Unable to load scene model: \(modelName)")}
            content.add(model)

            // Find the specific object, initialize position and scale, and store it for gestures
            guard let object = model.findEntity(named: modelName)
            else {fatalError("Unable to find entity in scene model: \(modelName)")}
            object.position = initialPosition
            object.scale = SIMD3<Float>(repeating: initialScale)
            currentScale = initialScale
            self.object = object
            
            // Obtain model geometric center and pivot point World Coordinates
            let bounds = object.visualBounds(relativeTo: object)
            let localCenter = (bounds.min + bounds.max) * 0.5
            modelCenter = object.convert(position: localCenter, to: nil)
            modelPivot = object.convert(position: .zero, to: nil)
            
            // Translate geometric center to pivot point using transform
            var transform = object.transform
            transform.translation = modelPivot - modelCenter
            object.transform = transform
            
            // Add Physics to the 3D model
            model.components.set(InputTargetComponent(allowedInputTypes: .indirect))
            model.generateCollisionShapes(recursive: true)
            model.components.set(GroundingShadowComponent(castsShadow: true))
            
            // Add Animation to the 3D model
            if(model.availableAnimations.count > 0){
                let anim = model.availableAnimations[0]
                model.playAnimation(anim.repeat())
            }
            
            // Debug statements
            /*
            #if DEBUG
              let centerSphere = ModelEntity(mesh: .generateSphere(radius: 0.01))
              centerSphere.model?.materials = [SimpleMaterial(color: .orange, isMetallic: true)]
              centerSphere.position = modelPivot
              content.add(centerSphere)
            #endif
             */
            print("\n\(modelName) Debug Information:")
            print("Object Position:                         \(object.position)")
            print("Object Scale:                            \(object.scale)")
            print("Object Orientation:                      \(object.orientation)")
            
        }
        .rotation3DEffect(Angle(degrees: modelRotation), axis: (x: 0.0, y: 1.0, z: 0.0))
        .animation(.easeInOut(duration: 1), value: modelRotation)
        .gesture(
            //Enable Rotation and Magnification
            SimultaneousGesture(
                RotateGesture()
                    .updating($rotationAngle) { value, _, _ in
                        let currentRotation = Float(value.rotation.degrees)
                        let totalRotation = currentRotationY + currentRotation
                        object.orientation = simd_quatf(angle: totalRotation * .pi / 180, axis: SIMD3<Float>(0, 1, 0))
                                                 
                        // Print values during gesture
                        let rotationDegrees = Int(totalRotation.truncatingRemainder(dividingBy: 360))
                        print("\(modelName) Current Rotation: \(rotationDegrees)°")
                    }
                    .onEnded { value in
                        // Update the current rotation and normalize the value
                        currentRotationY += Float(value.rotation.degrees)
                        currentRotationY = currentRotationY.truncatingRemainder(dividingBy: 360)
                    },
                MagnificationGesture()
                    .onChanged { value in
                        // Calculate new scale based on current gesture value
                        let newScale = currentScale * Float(value)
                        let minScale = initialScale * 0.5
                        let maxScale = initialScale * 1.5
                        let clampedScale = max(minScale, min(newScale, maxScale))
                        object.scale = SIMD3<Float>(repeating: clampedScale)
                        
                        // Print values during gesture
                        let scalePercentage = Int((clampedScale / initialScale) * 100)
                        print("\(modelName) Current Scale: \(scalePercentage)%")
                    }
                    .onEnded { value in
                        // Save the new scale
                        let newScale = currentScale * Float(value)
                        let minScale = initialScale  * 0.5
                        let maxScale = initialScale  * 1.5
                        currentScale = max(minScale, min(newScale, maxScale))
                        object.scale = SIMD3<Float>(repeating: currentScale)
                    }
            )
        )
        .toolbar {
            ToolbarItem(placement: .bottomOrnament) {
                Button {
                    modelRotation += 45
                } label: {
                    Label("Side View", systemImage: "arrow.triangle.2.circlepath.circle")
                }
            }
            ToolbarItem(placement: .bottomOrnament) {
                Button {
                    isPlaying.toggle()
                    if isPlaying {
                        Task {
                            while isPlaying {
                                modelAnimation += 0.005
                                object.orientation = simd_quatf(angle: Float(modelAnimation), axis: SIMD3<Float>(0, 1, 0))
                                await Task.sleep(16_000_000)
                            }
                        }
                    }
                } label: {
                    Label(isPlaying ? "Pause" : "Play", systemImage: isPlaying ? "pause.circle" : "play.circle")
                }
            }
            ToolbarItem(placement: .bottomOrnament){
                Button{
                } label:{
                    Label("Lighting", systemImage: "sun.max")
                }
            }
            ToolbarItem(placement: .bottomOrnament){
                Button{
                } label:{
                    Label("Weather", systemImage: "cloud.rain")
                }
            }
            ToolbarItem(placement: .bottomOrnament){
                Button{
                } label:{
                    Label("Terrain", systemImage: "snow")
                }
            }
        }
        .frame(height: 400)
    }
}

//Test Sample Preview on Xcode Preview Window
#Preview {
    RealityModelView(
        modelName: "Coffee_Shop",
        initialPosition: SIMD3<Float>(0, 0, 0),
        initialScale: 0.001
    )
}
