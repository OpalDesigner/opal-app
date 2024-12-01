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
    @Published var isCameraVisible: Bool = false
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
            
            // Load the Camera model from the Reality Content bundle
            guard let camera = try? await Entity(named: "Camera", in: realityKitContentBundle)
            else { fatalError("Unable to load Camera)") }
            let boxSize = SIMD3<Float>(0.2, 0.5, 0.2)
            //let debugMesh = ModelComponent(mesh: .generateBox(size: boxSize), materials: [UnlitMaterial(color: .red)])
            camera.components[CollisionComponent.self] = CollisionComponent(
                shapes: [.generateBox(size: boxSize)],
                mode: .default,
                filter: .init(group: .default, mask: .all)
            )
            //camera.components.set(debugMesh)
            camera.scale = SIMD3<Float>(repeating: 0.5)
            camera.transform.rotation = simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0))
            camera.transform.translation = SIMD3<Float>(0.2, 1.35, -0.5)
            navigationData.cameraEntity = camera
            content.add(camera)
            
            // Add Animation to the 3D model
            if(model.availableAnimations.count > 0){
                let anim = model.availableAnimations[0]
                model.playAnimation(anim.repeat())
            }
            
            // Collision Detection between Model Bound and the Camera
            content.subscribe(to: CollisionEvents.Began.self) { event in
                let modelBoundary = model.children.first?.children.first
                let hasCollision = (event.entityA == camera && event.entityB == modelBoundary) ||
                                  (event.entityA == modelBoundary && event.entityB == camera)
                print(hasCollision ? "Collision began between perspective camera and model" : "No Collision detected")
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
            if let scene = content.entities.first {
                updateCameraTransform(scene)
            }
            
            if(navigationData.isCameraVisible) {
                navigationData.cameraEntity.components.set(OpacityComponent(opacity: 1.0))
            } else {
                navigationData.cameraEntity.components.set(OpacityComponent(opacity: 0))
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
