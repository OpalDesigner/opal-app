//
//  ImmersiveModelView.swift
//
//  Created by Vik Parth on 10/18/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

class NavigationData: ObservableObject {
    @Published var cameraPosition: SIMD3<Float> = SIMD3<Float>(0, 0, 0)
    @Published var cameraRotation: Float = 0
    @Published var cameraEntity = Entity()
    @Published var spotlightEntity = Entity()
    @Published var lightSource = ModelEntity()
    @Published var isCameraVisible: Bool = false
    @Published var isSpotLightVisible: Bool = false
}

struct ImmersiveModelView: View {
    // Function parameters
    @ObservedObject var navigationData: NavigationData
    let modelName: String
    
    var body: some View {
        RealityView{ content in
            guard let model = try? await Entity(named: modelName, in: realityKitContentBundle)
            else { fatalError("Unable to load scene model: \(modelName)") }
            content.add(model)

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
            
            // Add Animation to the 3D model
            if(model.availableAnimations.count > 0){
                let anim = model.availableAnimations[0]
                model.playAnimation(anim.repeat())
            }
            
            // Load DSLR Camera model USDZ
            guard let camera = try? await Entity(named: "Camera", in: realityKitContentBundle)
            else { fatalError("Unable to load Camera)") }
            let boxSize = SIMD3<Float>(0.2, 0.5, 0.2)
            //let debugMesh = ModelComponent(mesh: .generateBox(size: boxSize), materials: [UnlitMaterial(color: .red)])
            //camera.components.set(debugMesh)
            let collisionComponent = CollisionComponent(
                shapes: [.generateBox(size: boxSize)],
                mode: .default,
                filter: .init(group: .default, mask: .all)
            )
            camera.components.set(collisionComponent)
            camera.scale = SIMD3<Float>(repeating: 0.5)
            camera.transform.rotation = simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0))
            camera.transform.translation = SIMD3<Float>(0.2, 1.35, -0.5)
            navigationData.cameraEntity = camera
            content.add(camera)
            content.subscribe(to: CollisionEvents.Began.self) { event in
                let modelBoundary = model.children.first?.children.first
                let hasCollision = (event.entityA == camera && event.entityB == modelBoundary) ||
                                  (event.entityA == modelBoundary && event.entityB == camera)
                print(hasCollision ? "Collision began between perspective camera and model" : "No Collision detected")
            }
            
            // Spotlight USDZ
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
                        
            /*
            // Add PointLight
            // Default intensity value is 26963.76 lumens.
            // Default attenuation is 10 meters
            let pointLightComponent = PointLightComponent(
                color: .red,
                intensity: 100000,
                attenuationRadius: 1000
             )
            testSphere.components.set(pointLightComponent)
            */

            /*
            // Add DirectionalLight:
            // Default intensity (lumens per square meter = lux) is 2145 lux
            let directionalLightComponent = DirectionalLightComponent(
               color: .red,
               intensity: 10000
            )
            let lightShadowComponent = DirectionalLightComponent.Shadow()
            testSphere.components.set([directionalLightComponent, lightShadowComponent])
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
