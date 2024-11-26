//
//  RealityView.swift
//  TestApp
//
//  Created by Vik Parth on 10/18/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

//This code creates the a small tabletop view of your set
struct RealityModelView: View {
    // Function parameters
    let id = UUID()
    let modelName: String
    let initialPosition: SIMD3<Float>
    let initialScale: Float
    
    // Environment variables
    @Environment(\.realityKitScene) var scene

    // State variables
    @State private var model = Entity()
    @State private var modelChildEntity: Entity?
    @State private var modelCenter: SIMD3<Float> = .zero
    @State private var modelPivot: SIMD3<Float> = .zero
    @State private var modelRotation: Double = 0.0
    @State private var currentScale: Float = 1.0
    @State private var isRotating = false
    @State private var isAnimating = false
    @State private var hasCameraEntity: Bool = false
    
    // Notifications setup
    private let notificationPublisher = NotificationCenter.default.publisher(for: Notification.Name("RealityKit.NotificationTrigger"))

    var body: some View {
        Spacer()
        RealityView { content in
            // Load 3D model
            guard let rootEntity = try? await Entity(named: modelName, in: realityKitContentBundle)
            else {fatalError("Unable to load scene model: \(modelName)")}
            content.add(rootEntity)
                        
            print("\n\(modelName) Debug Information:")
            print("Initial Position:     \(initialPosition)")
            print("Initial Scale:        \(initialScale)")
            print("Root Position:        \(rootEntity.transform.translation)")
            print("Root Scale:           \(rootEntity.transform.scale)")
            
            // Set initial transform
            model = rootEntity
            model.transform.translation = initialPosition
            model.transform.scale = SIMD3<Float>(repeating: initialScale)
            currentScale = initialScale
            
            print("\n\(modelName) Final Position and Scale:")
            print("Model Positon:       \(model.transform.translation)")
            print("Model Scale:         \(model.transform.scale)")
            
            // Obtain model geometric center and pivot point World Coordinates
            let bounds = model.visualBounds(relativeTo: rootEntity)
            let localCenter = (bounds.min + bounds.max) * 0.5
            modelCenter = model.convert(position: localCenter, to: nil)
            modelPivot = model.convert(position: .zero, to: nil)
       
            print("\n\(modelName) Before translating geometric center to pivot point:")
            print("Model Center:        \(modelCenter)")
            print("Model Pivot:         \(modelPivot)")
            
            /*
            // Debug for placing a sphere at modelPivot location
            let bubble = model.findEntity(named: "Bubble")!
            let centerSphere = ModelEntity(mesh: .generateSphere(radius: 0.02))
            centerSphere.model?.materials = [SimpleMaterial(color: .orange, isMetallic: true)]
            centerSphere.position = modelPivot
            content.add(centerSphere)
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
            
            print("\n\(modelName) After translating geometric center to pivot point:")
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
            
            // Find and store model's child entity specifically
            if let modelChild = model.findEntity(named: modelName) {
                modelChildEntity = modelChild
            }
            
            // Check if Model has a virtual camera
            hasCameraEntity = model.findEntity(named: "Camera") != nil
            
        }
        .onReceive(notificationPublisher) { output in
            guard let notificationName = output.userInfo?["RealityKit.NotificationTrigger.Identifier"] as? String
            else {return}
            
            switch notificationName {
                case "cameraFlythroughComplete":
                    print("\n\(modelName) Camera Animation Finished")
                    isAnimating.toggle()
                    modelChildEntity?.components.set(OpacityComponent(opacity: 1.0))
                default:
                    return
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
                    
                    // Print scale percentage
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
            // Toolbar button for Auto-Rotating the model
            ToolbarItem(placement: .bottomOrnament) {
                Button {
                    isRotating.toggle()
                    if isRotating {
                        Task {
                            while isRotating {
                                modelRotation += 0.15
                                try? await Task.sleep(nanoseconds: 16_000_000)
                            }
                        }
                    }
                } label: {
                    Label("", systemImage: isRotating ? "arrow.clockwise.circle.fill" : "arrow.clockwise.circle")
                        .foregroundColor(isRotating ? .green : .primary)
                }
            }
            // Toolbar button for Camera Flythrough
            if(hasCameraEntity){
                ToolbarItem(placement: .bottomOrnament){
                    Button {
                        isAnimating.toggle()
                        if isAnimating, let currentScene = scene {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("RealityKit.NotificationTrigger"),
                                object: nil,
                                userInfo: [
                                    "RealityKit.NotificationTrigger.Scene": currentScene,
                                    "RealityKit.NotificationTrigger.Identifier": "startCameraFlythrough"
                                ]
                            )
                            print("\n\(modelName) Camera Animation Started")
                            
                            // Adjust opacity of scene to see the Camera better
                            modelChildEntity?.components.set(OpacityComponent(opacity: 0.65))
                        }
                    } label: {
                        Label("",systemImage: isAnimating ? "video.fill" : "video")
                            .foregroundColor(isAnimating ? .red : .primary)
                    }
                    .disabled(isAnimating)
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
