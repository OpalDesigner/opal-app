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
    let modelName: String
    
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
    
    private func createFloorGrid(attachedTo modelEntity: Entity) -> Entity {
        let gridEntity = Entity()
        let gridSize = 5                    // 5x5 grid
        let tileSize: Float = 1             // 2 meters per tile
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
    
    var body: some View {
        RealityView{ content in
            guard let model = await loadRootEntity() else {
                print("Failed to load model: \(modelName)")
                return
            }
            content.add(model)
            
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
            content.add(skyboxEntity)
            
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
            
        } update: { content in
            // Update position, orientation in scene
            if let scene = content.entities.first {
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
        }
        
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    let entity = value.entity
                    let name = entity.name
                    if name.starts(with: "placementPoint_") {
                        // Extract x,z coordinates from the name (format: "placementPoint_x_z")
                        let coordinates = name.split(separator: "_")
                        if coordinates.count == 3,
                           let x = Int(coordinates[1]),
                           let z = Int(coordinates[2]) {
                            navigationData.placementCoordinates = (x: x, z: z)
                            navigationData.isPlacementMode = true
                            print("Tapped grid point: x=\(x), z=\(z)")
                            // Highlight the tapped point
                            if let modelEntity = entity as? ModelEntity {
                                modelEntity.model?.materials = [SimpleMaterial(color: .orange, isMetallic: true)]
                                // Reset color after a short delay
                                Task {
                                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                                    modelEntity.model?.materials = [SimpleMaterial(color: .lightGray, isMetallic: true)]
                                }
                            }
                        }
                    }
                }
        )
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

//Test Sample Preview on Xcode Preview Window
#Preview {
    ImmersiveModelView(
        navigationData: NavigationData(),
        modelName: "Planets"
    )
}
