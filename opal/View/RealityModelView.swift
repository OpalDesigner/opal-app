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
    @State private var model = Entity()
    @State private var animationController: PlanetAnimationController?

    // Add state for tracking the model properties
    @State private var modelCenter: SIMD3<Float> = .zero
    @State private var modelPivot: SIMD3<Float> = .zero
    @State private var modelRotation: Double = 0.0
    @State private var currentScale: Float = 1.0
    @State private var modelAnimation: Float = 0.0
    @State private var isPlaying = false
    @State private var isAnimating = false

    var body: some View {
        Spacer()
        RealityView { content in
            //Load your 3D model
            guard let rootEntity = try? await Entity(named: modelName, in: realityKitContentBundle)
            else {fatalError("Unable to load scene model: \(modelName)")}
            content.add(rootEntity)
            
            print("\n\(modelName) Debug Information:")
            print("Initial Position:     \(initialPosition)")
            print("Initial Scale:        \(initialScale)")
            print("Root entity children: \(rootEntity.children.map { $0.name })")
            print("Root Position:        \(rootEntity.transform.translation)")
            print("Root Scale:           \(rootEntity.transform.scale)")
            
            // Set initial transform
            model = rootEntity
            model.transform.translation = initialPosition
            model.transform.scale = SIMD3<Float>(repeating: initialScale)
            currentScale = initialScale
            
            print("\nFinal Model Position and Scale:")
            print("Model Positon:       \(model.transform.translation)")
            print("Model Scale:         \(model.transform.scale)")
            
            // Obtain model geometric center and pivot point World Coordinates
            let bounds = model.visualBounds(relativeTo: rootEntity)
            let localCenter = (bounds.min + bounds.max) * 0.5
            modelCenter = model.convert(position: localCenter, to: nil)
            modelPivot = model.convert(position: .zero, to: nil)
       
            print("\nBefore translating geometric center to pivot point:")
            print("Model Center:        \(modelCenter)")
            print("Model Pivot:         \(modelPivot)")
            
            /*
            #if DEBUG
                let centerSphere = ModelEntity(mesh: .generateSphere(radius: 0.02))
                centerSphere.model?.materials = [SimpleMaterial(color: .orange, isMetallic: true)]
                centerSphere.position = modelPivot
                content.add(centerSphere)
            #endif
             */
            
            // Translate geometric center to pivot point using transform
            if(modelCenter != modelPivot){
                var transform = model.transform
                transform.translation = modelPivot - modelCenter
                model.transform = transform
                
                // Recalculate both center and pivot after transform
                let newBounds = model.visualBounds(relativeTo: rootEntity)
                let newLocalCenter = (newBounds.min + newBounds.max) * 0.5
                modelCenter = model.convert(position: newLocalCenter, to: nil)
                modelPivot = model.convert(position: .zero, to: nil)
            }
            
            print("\nAfter translating geometric center to pivot point:")
            print("Model Center:        \(modelCenter)")
            print("Model Pivot:         \(modelPivot)")
            
            // Add Physics to the 3D model
            model.components.set(InputTargetComponent(allowedInputTypes: .indirect))
            model.generateCollisionShapes(recursive: true)
            model.components.set(GroundingShadowComponent(castsShadow: true))
            
            // Add Animation to the 3D model
            if(model.availableAnimations.count > 0){
                let anim = model.availableAnimations[0]
                model.playAnimation(anim.repeat())
            }
            
            //"Planets" has custom animation (once baked into Reality Composer, this script may not be needed)
            if modelName == "Planets" {
                animationController = PlanetAnimationController(model: rootEntity)
            }
        }
        .rotation3DEffect(Angle(degrees: modelRotation), axis: (x: 0.0, y: 1.0, z: 0.0))
        .animation(.easeInOut(duration: 1), value: modelRotation)
        .gesture(
            DragGesture()
                .onEnded { value in
                    modelRotation += 45
                    print("\(modelName) Rotation: \(modelRotation)%")
                }
        )
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    // Calculate new scale based on current gesture value
                    let newScale = currentScale * Float(value)
                    let minScale = initialScale * 0.5
                    let maxScale = initialScale * 1.5
                    let clampedScale = max(minScale, min(newScale, maxScale))
                    model.scale = SIMD3<Float>(repeating: clampedScale)
                    
                    // Print debug information
                    let scalePercentage = Int((clampedScale / initialScale) * 100)
                    print("\(modelName) Scale: \(scalePercentage)%")
                }
                .onEnded { value in
                    // Save the new scale
                    let newScale = currentScale * Float(value)
                    let minScale = initialScale  * 0.5
                    let maxScale = initialScale  * 1.5
                    currentScale = max(minScale, min(newScale, maxScale))
                    model.scale = SIMD3<Float>(repeating: currentScale)
                }
        )
        .toolbar {
            ToolbarItem(placement: .bottomOrnament) {
                Button {
                    isPlaying.toggle()
                    if isPlaying {
                        Task {
                            while isPlaying {
                                modelRotation += 0.15
                                try? await Task.sleep(nanoseconds: 16_000_000)
                            }
                        }
                    }
                } label: {
                    Label(isPlaying ? "Pause" : "Play", systemImage: isPlaying ? "pause.circle" : "play.circle")
                }
            }
            ToolbarItem(placement: .bottomOrnament) {
                if modelName == "Planets" {
                    Button {
                        isAnimating.toggle()
                        if isAnimating {
                            animationController?.startAnimation()
                        }
                    } label: {
                        Label("", systemImage: "sparkles")
                    }
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
