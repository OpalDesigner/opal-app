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
            
            //Add Physics to the 3D model
            model.components.set(InputTargetComponent(allowedInputTypes: .indirect))
            model.generateCollisionShapes(recursive: true)
            model.components.set(GroundingShadowComponent(castsShadow: true))
            
            //Add Animation to the 3D model
            if(model.availableAnimations.count > 0){
                let anim = model.availableAnimations[0]
                model.playAnimation(anim.repeat())
            }
            
            //Add Lighting to the 3D model
            //model.components.set(ImageBasedLightComponent(source: .single(environment), intensityExponent: 3))
            //model.components.set(ImageBasedLightReceiverComponent(imageBasedLight: model))
            
            //Add Audio to the 3D model
            //guard let audioResource = try? AudioFileResource.load(named: "your_audio_file.wav", in: realityKitContentBundle)
            //model.playAudio(audioResource)
            //if let audioPlaybackController = model.components[AudioPlaybackController.self] {
            //    audioPlaybackController.play()
            //}
            
            // Find the specific object
            guard let object = model.findEntity(named: modelName)
            else {fatalError("Unable to find entity in scene model: \(modelName)")}
            
            // Apply position and scale to the specific object
            object.position = initialPosition
            object.scale = SIMD3<Float>(repeating: initialScale)
            self.object = object
            
            // Update local variables
            currentScale = object.scale.x
            
            // Print values
            print("\(modelName) Object Position:    \(object.position)")
            print("\(modelName) Object Scale:       \(object.scale)")
        }
        .rotation3DEffect(Angle(degrees: modelRotation), axis: (x: 0.0, y: 1.0, z: 0.0))
        .animation(.easeInOut(duration: 1), value: modelRotation)
        .gesture(
            SimultaneousGesture(
                //Drag gesture to move the 3D model
                DragGesture()
                    .targetedToEntity(object)
                    .onChanged { value in
                        object.position = value.convert(value.location3D, from: .local, to: object.parent!)
                    }
                    .onEnded { _ in
                        // Print final position with decimal places
                        print("\(modelName) Final Position: x:\(String(format: "%.3f", object.position.x)), y:\(String(format: "%.3f", object.position.y)), z:\(String(format: "%.3f", object.position.z))")
                    },
                
                //Rotation and Scale can happen together
                SimultaneousGesture(
                    // Rotation gesture
                    RotateGesture()
                        .updating($rotationAngle) { value, state, _ in
                            let rotation = Float(value.rotation.degrees)
                            state = rotation
                            
                            // Calculate total rotation by adding current rotation and new gesture rotation
                            let totalRotation = currentRotationY + rotation
                            object.orientation = simd_quatf(angle: totalRotation * .pi / 180, axis: SIMD3<Float>(0, 1, 0))
                                                    
                            // Print values during gesture
                            /*
                            let rotationDegrees = Int(totalRotation.truncatingRemainder(dividingBy: 360))
                            print("\(modelName) Rotation: \(rotationDegrees)°")
                            */
                        }
                        .onEnded { value in
                            // Update the current rotation when gesture ends
                            currentRotationY += Float(value.rotation.degrees)
                            
                            // Normalize the rotation angle
                            currentRotationY = currentRotationY.truncatingRemainder(dividingBy: 360)
                            
                            // Print final rotation
                            print("\(modelName) Final Rotation: \(Int(currentRotationY))°")
                        },
                    MagnificationGesture()
                        .onChanged { value in
                            // Calculate new scale based on gesture value
                            let newScale = currentScale * Float(value)
                            
                            // Apply limits (25% to 150% of original scale)
                            let minScale = initialScale * 0.5
                            let maxScale = initialScale * 1.5
                            let clampedScale = max(minScale, min(newScale, maxScale))
                            
                            // Apply the scale
                            object.scale = SIMD3<Float>(repeating: clampedScale)
                            
                            // Print values during gesture
                            /*
                            let scalePercentage = Int((clampedScale / initialScale) * 100)
                            print("\(modelName) Object Current Scale: \(scalePercentage)%")
                            */
                        }
                        .onEnded { value in
                            // Save the new scale
                            let newScale = currentScale * Float(value)
                            let minScale = initialScale  * 0.5
                            let maxScale = initialScale  * 1.5
                            currentScale = max(minScale, min(newScale, maxScale))
                            
                            // Ensure final scale is set
                            object.scale = SIMD3<Float>(repeating: currentScale)
                            
                            // Print final values
                            let finalPercentage = Int((currentScale / initialScale) * 100)
                            print("\(modelName) Object Final Scale: \(finalPercentage)%")
                        }
                )
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
