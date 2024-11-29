//
//  ImmersiveModelView.swift
//  TestApp
//
//  Created by Vik Parth on 10/18/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

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
                print("Child:           \(child.name)")
                print("Position:        \(child.position),       Scale: \(child.scale)")
                
                // Print grandchildren if any
                for grandchild in child.children {
                    print("Grandchild:  \(grandchild.name)")
                    print("Position:    \(grandchild.position),  Scale: \(grandchild.scale)")
                }
            }
            
            // Create a Perspective Camera to navigate Immersive View
            let perspectiveCamera = Entity()
            let boxSize: SIMD3<Float> = [0.2, 1.5, 0.2]
            let collisionShape = ShapeResource.generateBox(size: boxSize)
            let debugMesh = ModelComponent(mesh: .generateBox(size: boxSize), materials: [UnlitMaterial(color: .red)])
            perspectiveCamera.components[CollisionComponent.self] = CollisionComponent(
                shapes: [collisionShape],
                mode: .default,
                filter: CollisionFilter(group: .default, mask: .all)
            )
            perspectiveCamera.components.set(debugMesh)
            perspectiveCamera.position = SIMD3<Float>(0, 1, 0)
            content.add(perspectiveCamera)
            updateCameraTransform(perspectiveCamera)
            print("\nPerspective Camera Position:      \(perspectiveCamera.position)")
            
            // Listen for Collisions between Perspective Camera and Model Boundaries
            let collisionSubscription = content.subscribe(to: CollisionEvents.Began.self) { event in
                if (event.entityA == perspectiveCamera && event.entityB == model.children.first?.children.first) ||
                   (event.entityA == model.children.first?.children.first  && event.entityB == perspectiveCamera) {
                    print("Collision began between perspective camera and model")
                } else {
                    print("No Collision detected")
                }
            }
            
            // Add Animation to the 3D model
            if(model.availableAnimations.count > 0){
                let anim = model.availableAnimations[0]
                model.playAnimation(anim.repeat())
            }
            
            /*
            // Lighting: RealityKit can carry up to 6 lights
            // Spotlight Component: https://developer.apple.com/documentation/realitykit/spotlightcomponent
            // Pointlight Component: https://developer.apple.com/documentation/realitykit/pointlight
            // DirectionalLight Component: https://developer.apple.com/documentation/realitykit/directionallightcomponent
            let testSphere = ModelEntity(mesh: .generateSphere(radius: 0.05), materials: [SimpleMaterial(color: .white, isMetallic: false)])
            content.add(testSphere)
            testSphere.position = SIMD3<Float>(0, 1.5, -0.5)
            let pointLight = PointLight()
            pointLight.light.color = .red
            pointLight.light.intensity = 1000
            pointLight.light.attenuationRadius = 10
            content.add(pointLight)
            pointLight.position = SIMD3<Float>(0, 1.5, -0.5)
             */
            
        } update: { content in
            if let perspectiveCamera = content.entities.first {
                updateCameraTransform(perspectiveCamera)
            }
        }
    }
    
    private func updateCameraTransform(_ camera: Entity) {
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
        camera.transform.matrix = transform
    }
    
}

//Test Sample Preview on Xcode Preview Window
#Preview {
    ImmersiveModelView(
        navigationData: NavigationData(),
        modelName: "Planets"
    )
}
