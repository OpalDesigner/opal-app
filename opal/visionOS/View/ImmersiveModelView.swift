//
//  ImmersiveModelView.swift
//
//  Created by Vik Parth on 10/18/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

//This code creates an immersive view of your set
struct ImmersiveModelView: View {
    // Function parameters
    @ObservedObject var navigationData: NavigationData
    @Environment(AppModel.self) var appModel
    @Environment(\.realityKitScene) var scene
    var modelName: String { appModel.modelInfo?.modelName ?? "Model"}
    @State var handTrackingManager: HandTrackingManager
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        RealityView { content, attachments in
            guard let model = await Entity.loadRootEntity(named: modelName) else { // Entity+Extension.swift
                print("Failed to load model: \(modelName)")
                return
            }
            model.name = modelName
            content.add(model)
            
            // Hand menu
            content.add(handTrackingManager.rootEntity)
            if let menu = attachments.entity(for: "Menu") {
                handTrackingManager.addMenuEntity(menu)
            }
            if let menu = attachments.entity(for: "MenuB") {
                menu.scale = .init(repeating: 0.8)
                handTrackingManager.addMenuBEntity(menu)
            }
            
            #warning("Should use custom components instead of entity names")
            let tools = model.findEntity(named: "Tools")
            tools?.generateCollisionShapes(recursive: true)
            tools?.components.set(InputTargetComponent())
            
            // Add Animation to the 3D model
            if(model.availableAnimations.count > 0){
                let anim = model.availableAnimations[0]
                model.playAnimation(anim.repeat())
            }
            
            // Add Skybox
            guard let resource = try? await TextureResource(named: "Starfield") else {
                fatalError("Unable to load starfield texture.")
            }
            var material = UnlitMaterial()
            material.color = .init(texture: .init(resource))
            let skyboxEntity = Entity()
            skyboxEntity.components.set(ModelComponent(
                mesh: .generateSphere(radius: 1000),
                materials: [material]
            ))
            skyboxEntity.scale *= .init(x: -1, y: 1, z: 1)
            skyboxEntity.name = "Skybox"
            content.add(skyboxEntity)
            
            /*
            // Add Image Based Light
            if let environment = try? await EnvironmentResource(named: "ImageBasedLighting"){
                model.components.set(ImageBasedLightComponent(
                    source: .single(environment),
                    intensityExponent: 1
                ))
                model.components.set(ImageBasedLightReceiverComponent(
                    imageBasedLight: model
                ))
            }
            
            // Add Grounding Shadow
            // Entity+Extension.swift
            model.enumerateHierarchy { entity, stop in
                if entity is ModelEntity{
                    entity.components.set(GroundingShadowComponent(castsShadow: true))
                }
            }
             */
            
            // Add DSLR Camera USDZ
            guard let camera = try? await Entity(named: "Camera", in: realityKitContentBundle)
            else { fatalError("Unable to load Camera)") }
            camera.scale = SIMD3<Float>(repeating: 0.5)
            camera.transform.rotation = simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0))
            camera.transform.translation = SIMD3<Float>(0.2, 1.35, -0.5)
            navigationData.cameraEntity = camera
            content.add(camera)
            
            // Add Spotlight USDZ
            guard let spotlight = try? await Entity(named: "StudioSpotlight", in: realityKitContentBundle)
            else { fatalError("Unable to load Spotlight)") }
            spotlight.transform.rotation = simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0))
            spotlight.transform.translation = SIMD3<Float>(-0.2, 0, -0.5)
            navigationData.spotlightEntity = spotlight
            content.add(spotlight)
            
            // Add SpotLight LightSource
            let lightSourceEntity = ModelEntity()
            let spotlightComponent = SpotLightComponent(
                color: .green,
                intensity: 100000,        // Default is 6740.94 lumens
                innerAngleInDegrees: 45,  // Default is 45 degrees
                outerAngleInDegrees: 60,  // Default is 60 degrees
                attenuationRadius: 10     // Default is 10 meters
            )
            lightSourceEntity.components.set(spotlightComponent)
            lightSourceEntity.transform.translation = SIMD3<Float>(-0.2, 1.40, -0.75)
            navigationData.lightSource = lightSourceEntity
            content.add(lightSourceEntity)
            
            // Add the grid as a child of Root
            let rootEntity = model.findEntity(named: "Root")
            navigationData.rootEntity = rootEntity
            navigationData.gridEntity = createFloorGrid(attachedTo: model)
            navigationData.gridEntity.isEnabled = false
            rootEntity?.addChild(navigationData.gridEntity)
            
            /*
            print("\n\(modelName) Debug Information:")
            for child in model.children {
                print("Child:       \(child.name)")
                print("Position:    \(child.position),       Scale: \(child.scale)")
                
                // Print grandchildren if any
                for grandchild in child.children {
                    print("Grandchild:  \(grandchild.name)")
                    print("Position:    \(grandchild.position),  Scale: \(grandchild.scale)")
                }
            }
             */
            
        } update: { content, attachments in
            // Update position, orientation in scene
            if let scene = content.entities.first(where: { $0.name == modelName }) {
                updateCameraTransform(scene)
            }
            
            // Update DSLR Camera visibility
            if navigationData.isCameraVisible {
                navigationData.cameraEntity.components.set(OpacityComponent(opacity: 1.0))
            } else {
                navigationData.cameraEntity.components.set(OpacityComponent(opacity: 0))
            }

            // Update Spotlight visibility and intensity
            if navigationData.isSpotLightVisible {
                navigationData.spotlightEntity.components.set(OpacityComponent(opacity: 1.0))
                navigationData.lightSource.components[SpotLightComponent.self]?.intensity = 100000
            } else {
                navigationData.spotlightEntity.components.set(OpacityComponent(opacity: 0))
                navigationData.lightSource.components[SpotLightComponent.self]?.intensity = 0
            }
            
            // Place the loaded entity
            if let loadedEntity = navigationData.loadedEntity,
               let position = navigationData.placementPosition,
               let rootEntity = navigationData.rootEntity {
                loadedEntity.position = position
                loadedEntity.scale = SIMD3<Float>(repeating: 1)
                rootEntity.addChild(loadedEntity)
                navigationData.loadedEntity = nil
            }
            
            handTrackingManager.wristAccessoryEntity.children.first?.position.z = appModel.openMenu ? 0 : -0.1
            handTrackingManager.littleFingerAccessoryEntity.children.first?.position.z = appModel.openMenuB ? 0 : -0.05
            
        } attachments: {
            
//            Attachment(id: "Menu") {
//                NavigationControlMenu(isOpen: appModel.openMenu, navigationData: navigationData)
//            }
            Attachment(id: "MenuB") {
                NavigationControlMenu(isOpen: appModel.openMenuB, navigationData: navigationData)
            }
            
        }
        .task {
            await handTrackingManager.runARKitSession()
        }
        .task {
            await handTrackingManager.processHandUpdates()
        }
        .onChange(of: scenePhase) { _, newValue in
            if scenePhase == .background {
                handTrackingManager.reset()
                navigationData.cameraPosition = SIMD3<Float>(0, 0, 0)
                navigationData.cameraRotation = 0
                appModel.immersionStyle = .full
            }
        }
        .onImmersionChange { _, context in
            #warning("Should use custom components instead of entity names")
            guard [0, 1].contains(context.amount) else { return }
            scene?.findEntity(named: "Operating_Room")?.isEnabled = context.amount == 1
            scene?.findEntity(named: "Skybox")?.isEnabled = context.amount == 1
        }
        .gesture(translationGesture)
        
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    handleTap(on: value.entity)
                }
        )
        .onChange(of: appModel.sessionController?.interactiveObjectUpdate, updateInteractiveObject)
    }
    
    func updateInteractiveObject(
        oldActivityStage: InteractiveObjectUpdate?,
        newActivityStage: InteractiveObjectUpdate?
    ) {
        guard let newActivityStage else { return }
        scene?.findEntity(named: newActivityStage.entityName)?.setPosition(newActivityStage.position, relativeTo: nil)
    }
    
    /// The initial position of the entity.
    @State var initialPosition: SIMD3<Float>? = nil
    
    /// The gesture checks whether there is a root component and adjusts the postion of the entity.
    var translationGesture: some Gesture {
        /// The gesture to move an entity.
        DragGesture()
            .targetedToAnyEntity()
            .onChanged({ value in
                /// The entity that the drag gesture targets.
                let rootEntity = value.entity
                
                // Set `initialPosition` to the position of the entity if it is `nil`.
                if initialPosition == nil {
                    initialPosition = rootEntity.position(relativeTo: nil)
                }
                
                /// The movement that converts a global world space to the scene world space of the entity.
                let movement = value.convert(value.translation3D, from: .global, to: .scene)
                
                // Apply the entity position to match the drag gesture,
                // and set the movement to stay at the ground level.
                let newPosition = (initialPosition ?? .zero) + movement
                rootEntity.setPosition(newPosition, relativeTo: nil)
                Task {
                    try? await appModel.sessionController?.messenger.send(InteractiveObjectUpdate(entityName: rootEntity.name, position: newPosition))
                }
            })
            .onEnded({ _ in
                // Reset the `initialPosition` back to `nil` when the gesture ends.
                initialPosition = nil
            })
    }
    
    // Helper Function
    private func createFloorGrid(attachedTo modelEntity: Entity) -> Entity {
        let gridEntity = Entity()
        let gridSize = 5                    // 5x5 grid
        let tileSize: Float = 1             // 2 meters per tile
        
        // Print model bounds using visualBounds
        let bounds = modelEntity.visualBounds(relativeTo: modelEntity)
        let size = bounds.max - bounds.min
        print("\nModel Visual Bounds:")
        print("Min Y: \(bounds.min.y)")
        print("Max Y: \(bounds.max.y)")
        print("Height: \(size.y)")
        
        for x in -gridSize...gridSize {
            for z in -gridSize...gridSize {
                let tileEntity = ModelEntity(
                    mesh: .generatePlane(width: tileSize, depth: tileSize),
                    materials: [UnlitMaterial(color: .lightGray)]
                )
                // Position each tile at the floor level of the model
                tileEntity.position = SIMD3<Float>(
                    Float(x) * tileSize,
                    -0.01,
                    Float(z) * tileSize
                )
                let placementPoint = ModelEntity(
                     mesh: .generateCone(height: 0.3, radius: 0.05),
                     materials: [SimpleMaterial(color: .lightGray, isMetallic: true)]
                 )
                placementPoint.components.set(InputTargetComponent(allowedInputTypes: .indirect))
                placementPoint.generateCollisionShapes(recursive: true)
                
                // Add label and Rotate the cone 180 degrees around the X-axis to point downward
                placementPoint.name = "placementPoint_\(x)_\(z)"
                placementPoint.transform.rotation = simd_quatf(angle: .pi, axis: SIMD3<Float>(1, 0, 0))
                placementPoint.position = SIMD3<Float>(0, 0.5, 0)
                
                tileEntity.addChild(placementPoint)
                gridEntity.addChild(tileEntity)
            }
        }
        return gridEntity
    }
    
    private func handleTap(on entity: Entity) {
         guard entity.name.starts(with: "placementPoint_"),
               let modelEntity = entity as? ModelEntity else { return }
         let coordinates = entity.name.split(separator: "_")
         guard coordinates.count == 3,
               let x = Int(coordinates[1]),
               let z = Int(coordinates[2]) else { return }
         navigationData.placementPosition = [Float(x), 0.5, Float(z)]
         // Load model if one is selected
         if let modelToPlace = navigationData.modelToPlace {
             let modelURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                 .appendingPathComponent("\(modelToPlace.category.rawValue.lowercased())/\(modelToPlace.model.modelName).usdz")
             Task {
                 navigationData.loadedEntity = try? await Entity.load(contentsOf: modelURL)
             }
         }
         // Highlight the tapped point temporarily
         modelEntity.model?.materials = [SimpleMaterial(color: .orange, isMetallic: true)]
         Task {
             try? await Task.sleep(nanoseconds: 500_000_000)
             modelEntity.model?.materials = [SimpleMaterial(color: .lightGray, isMetallic: true)]
         }
     }
    
    private func updateCameraTransform(_ scene: Entity) {
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
        scene.transform.matrix = transform
    }
}

/*
//Test Sample Preview on Xcode Preview Window
#Preview {
    ImmersiveModelView(
        navigationData: NavigationData(),
        modelName: "Planets"
    )
}
*/
