//
//  TabletopModelView.swift
//
//  Created by Vik Parth on 10/18/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct PointOfInterestRuntimeComponent: Component {
    let attachmentTag: ObjectIdentifier
}

//This code creates the a small tabletop view of your set
struct TabletopModelView: View {
    // Function parameters
    let modelName: String
    
    // Environment variables
    @Environment(\.realityKitScene) var scene

    // State variables
    @State private var modelCurrent = Entity()
    @State private var weatherEntity = Entity()
    @State private var modelCenter: SIMD3<Float> = .zero
    @State private var modelPivot: SIMD3<Float> = .zero
    @State private var modelRotation: Double = 0.0
    @State private var currentScale: Float = 1.0
    @State private var isRotating = false
    @State private var isAnimating = false
    @State private var isSnowing = false
    @State private var isCameraEnabled: Bool = false
    @State private var isLightingEnabled = false
    @State private var lightSourceEntity = Entity()
    @State private var lightSourcePosition: SIMD3<Float> = SIMD3<Float>(0, 0, 0.35)
    
    // Handle Attachments
    @State private var subscriptions = [EventSubscription]()
    @State private var attachmentsProvider = AttachmentsProvider()
    
    // Handle Notifications
    private let notificationPublisher = NotificationCenter.default.publisher(for: Notification.Name("RealityKit.NotificationTrigger"))

    var body: some View {
        Spacer()
        RealityView { content, attachments in
            guard let entity = await loadRootEntity() else {
                print("Failed to load model: \(modelName)")
                return
            }
            content.add(entity)
            
            // Set initial scale and center model
            modelCurrent = entity
            let autoScale = getAutoScale(entity)
            modelCurrent.transform.scale = SIMD3<Float>(repeating: autoScale)
            currentScale = autoScale
            centerModelAroundPivot(modelCurrent)
            
            // Enable input gestures
            modelCurrent.components.set(InputTargetComponent(allowedInputTypes: .indirect))
            modelCurrent.generateCollisionShapes(recursive: true)
            modelCurrent.components.set(GroundingShadowComponent(castsShadow: true))
            
            // Add Animation
            if(modelCurrent.availableAnimations.count > 0){
                let anim = modelCurrent.availableAnimations[0]
                modelCurrent.playAnimation(anim.repeat())
            }
            
            // Add Weather Entity
            weatherEntity = Entity()
            weatherEntity.position = SIMD3<Float>(modelCenter.x, modelCenter.y + 0.3, modelCenter.z)
            weatherEntity.setScale(.init(x: 4, y: 4, z: 4), relativeTo: nil)
            content.add(weatherEntity)
            
            // Check for DLSR Camera Entity in scene
            isCameraEnabled = modelCurrent.findEntity(named: "Camera") != nil
            
            // Add SpotLight LightSource
            lightSourceEntity = ModelEntity()
            let spotlightComponent = SpotLightComponent(
                color: .green,
                intensity: 5000,          // Default is 6740.94 lumens
                innerAngleInDegrees: 45,  // Default is 45 degrees
                outerAngleInDegrees: 60,  // Default is 60 degrees
                attenuationRadius: 10     // Default is 10 meters
            )
            lightSourceEntity.components.set(spotlightComponent)
            lightSourceEntity.transform.rotation = simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 0, 0))
            lightSourceEntity.transform.translation = lightSourcePosition
            let debugSphere = ModelEntity(
                mesh: .generateSphere(radius: 0.01),
                materials: [SimpleMaterial(color: .green, isMetallic: true)]
            )
            lightSourceEntity.addChild(debugSphere)
            
            // Find all POI entities and create their attachment SwiftUI views
            subscriptions.append(content.subscribe(to: ComponentEvents.DidAdd.self, componentType: PointOfInterestComponent.self, { event in
                createPoiAttachment(for: event.entity)
            }))
            
            print("\n\(modelName) Model Parameters:")
            for child in entity.children {
                print("Child:       \(child.name)")
                print("Position:    \(child.position),       Scale: \(child.scale)")
                // Print grandchildren if any
                for grandchild in child.children {
                    print("   Grandchild:  \(grandchild.name)")
                    print("   Position:    \(grandchild.position),  Scale: \(grandchild.scale)")
                }
            }
            
        } update: { content, attachments in
            // Update weather entity
            // (.snow, .fireworks, .rain, .sparks, .impact, .magic)
            if(isSnowing){
                var emitter = ParticleEmitterComponent.Presets.snow
                emitter.mainEmitter.birthRate = 100
                weatherEntity.components.set(emitter)
            } else {
                var emitter = ParticleEmitterComponent.Presets.snow
                emitter.mainEmitter.birthRate = 0
                weatherEntity.components.set(emitter)
            }
            
            // Update lighting entity
            if(isLightingEnabled){
                content.add(lightSourceEntity)
                lightSourceEntity.transform.translation = lightSourcePosition
            } else {
                content.remove(lightSourceEntity)
            }
            
            // Update opacity of model entity if camera is Animating
            if isCameraEnabled {
                if let modelChild = modelCurrent.findEntity(named: modelName) {
                    if isAnimating {
                        modelChild.components.set(OpacityComponent(opacity: 0.65))
                    } else {
                        modelChild.components.set(OpacityComponent(opacity: 1.0))
                    }
                }
            }
        
            // Update Point of Interest entities
            if let poiEntities = scene?.performQuery(EntityQuery(where: .has(PointOfInterestComponent.self))){
                for entity in poiEntities {
                    if let poi = entity.components[PointOfInterestRuntimeComponent.self],
                       let poiEntity = attachments.entity(for: poi.attachmentTag) {
                        if poiEntity.parent == nil {
                            poiEntity.components.set(BillboardComponent())
                            poiEntity.components.set(OpacityComponent(opacity: 1.0))
                            content.add(poiEntity)
                            poiEntity.setPosition([0.0, 2.0, 0.0], relativeTo: entity)
                            print("✅ Successfully attached POI to: \(entity.name)")
                        }
                    }
                }
            }
            
        } attachments: {
            // Add all Attachment SwiftUI views to the tagged entity
            ForEach(attachmentsProvider.sortedTagViewPairs, id: \.tag) { pair in
                Attachment(id: pair.tag) {
                    pair.view
                }
            }
        }
        .onReceive(notificationPublisher) { output in
            guard let notificationName = output.userInfo?["RealityKit.NotificationTrigger.Identifier"] as? String
            else {return}
            switch notificationName {
                case "cameraFlythroughComplete":
                    print("\n\(modelName) Camera Animation Finished")
                    isAnimating.toggle()
                default:
                    return
            }
        }
        .rotation3DEffect(Angle(degrees: modelRotation), axis: (x: 0.0, y: 1.0, z: 0.0))
        .animation(.easeInOut(duration: 0.5), value: modelRotation)
        .gesture(
            //Drag Gesture will allow two actions: lighting or model rotation
            DragGesture()
                .onChanged { value in
                    if isLightingEnabled {
                        let dragScale: Float = 0.00005
                        lightSourcePosition.x += Float(value.translation.width) * dragScale
                        lightSourcePosition.y -= Float(value.translation.height) * dragScale
                    } else{
                        modelRotation += 10
                        print("\(modelName) Rotation: \(modelRotation)%")
                    }
                }
        )
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    // Calculate new scale based on current gesture value
                    let newScale = currentScale * Float(value)
                    let minScale = currentScale * 0.5
                    let maxScale = currentScale * 1.5
                    let clampedScale = max(minScale, min(newScale, maxScale))
                    modelCurrent.scale = SIMD3<Float>(repeating: clampedScale)
                    
                    // Print scale percentage
                    let scalePercentage = Int((clampedScale / currentScale) * 100)
                    print("\(modelName) Scale: \(scalePercentage)%")
                }
                .onEnded { value in
                    // Save the new scale
                    let newScale = currentScale * Float(value)
                    let minScale = currentScale  * 0.5
                    let maxScale = currentScale  * 1.5
                    currentScale = max(minScale, min(newScale, maxScale))
                    modelCurrent.scale = SIMD3<Float>(repeating: currentScale)
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
                        .foregroundColor(isRotating ? .blue : .primary)
                }
            }
            
            // Toolbar button for changing the Weather
            ToolbarItem(placement: .bottomOrnament) {
                Button {
                    isSnowing.toggle()
                } label: {
                    Label("", systemImage: isSnowing ? "cloud.snow.fill" : "cloud.snow")
                        .foregroundColor(isSnowing ? .green : .primary)
                }
            }
            
            // Toolbar button to Light the scene
            ToolbarItem(placement: .bottomOrnament) {
                Button {
                    isLightingEnabled.toggle()
                } label: {
                    Label("", systemImage: isLightingEnabled ? "lightbulb.fill" : "lightbulb")
                        .foregroundColor(isLightingEnabled ? .yellow : .primary)
                }
            }
            
            // Toolbar button for Camera Flythrough
            if(isCameraEnabled){
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
    
    // Helper Function
    private func loadRootEntity() async -> Entity? {
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
    
    private func getAutoScale(_ model: Entity) -> Float {
        let bounds = model.visualBounds(relativeTo: model)
        let size = bounds.max - bounds.min
        let maxWidth: Float = 0.6
        let maxHeight: Float = 0.6
        let maxDepth: Float = 0.6
        // Calculate scale needed for each dimension
        let scaleX = maxWidth / size.x
        let scaleY = maxHeight / size.y
        let scaleZ = maxDepth / size.z
        // Use the smallest scale to ensure all dimensions fit within limits
        let autoScale = min(scaleX, min(scaleY, scaleZ))
        // Print resulting dimensions
        let scaledWidth = size.x * autoScale
        let scaledHeight = size.y * autoScale
        let scaledDepth = size.z * autoScale
        print("\n\(modelName) Auto-Scaling Details:")
        print("   Original dimensions:     width=\(size.x)m, height=\(size.y)m, depth=\(size.z)m")
        print("   Scale factors:           width=\(scaleX), height=\(scaleY), depth=\(scaleZ)")
        print("   Resulting dimensions:    width=\(scaledWidth)m, height=\(scaledHeight)m, depth=\(scaledDepth)m")
        print("   Autoscale: \(autoScale)")
        return autoScale
    }
    
    private func centerModelAroundPivot(_ model: Entity) {
        let bounds = model.visualBounds(relativeTo: model)
        let size = bounds.max - bounds.min
        modelCenter = model.convert(position: (bounds.min + bounds.max) * 0.5, to: nil)
        modelPivot = model.convert(position: .zero, to: nil)
        if modelCenter != modelPivot {
            model.transform.translation = modelPivot - modelCenter
            // Update center and pivot after transform
            let newBounds = model.visualBounds(relativeTo: model)
            modelCenter = model.convert(position: (newBounds.min + newBounds.max) * 0.5, to: nil)
            modelPivot = model.convert(position: .zero, to: nil)
        }
    }
    
    private func createPoiAttachment(for entity: Entity) {
        guard let poi = entity.components[PointOfInterestComponent.self] else {return}
        let tag: ObjectIdentifier = entity.id
        let view = AnyView(VStack {
            Text(poi.title)
                .font(.headline)
                .padding(.bottom, 2)
            
            if let description = poi.description {
                Text(description)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            Button {
                // Add your button action here
            } label: {
                Label("", systemImage: "plus.circle.fill")
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(8))
        // Set RuntimeComponent
        entity.components[PointOfInterestRuntimeComponent.self] = PointOfInterestRuntimeComponent(attachmentTag: tag)
        // Add to attachments
        attachmentsProvider.attachments[tag] = AnyView(view)
        // Debug logging
        print("📦 Attachments Provider Status:")
        print("   Total Attachments: \(attachmentsProvider.attachments.count)")
        print("   Current Attachment Tag: \(tag)")
        print("   Attachment Added: \(attachmentsProvider.attachments.keys.contains(tag))")
    }
}

//Test Sample Preview on Xcode Preview Window
#Preview {
    TabletopModelView(
        modelName: "Coffee_Shop"
    )
}
