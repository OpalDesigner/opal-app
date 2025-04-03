//
//  ImmersiveControlView.swift
//  TestApp
//
//  Created by Vik Parth on 10/21/24.
//

import SwiftUI
import RealityKit

class NavigationData: ObservableObject {
    @Published var cameraPosition: SIMD3<Float> = SIMD3<Float>(0, 0, 0)
    @Published var cameraRotation: Float = 0
    
    // New properties for immersive view
    @Published var cameraEntity = Entity()
    @Published var spotlightEntity = Entity()
    @Published var lightSource = ModelEntity()
    @Published var isCameraVisible: Bool = false
    @Published var isSpotLightVisible: Bool = false
    
    // New properties for splat
    @Published var splatRotationAxis = SIMD3<Float>(0, 1, 0)    // X is pitch, Y is yaw, Z is roll
    @Published var splatRotationAmount = Angle(degrees: 0)
    @Published var splatRotationPerSecond = Angle(degrees: 0)
    @Published var splatScale: Float = 1
    
    // New properties for model placement
    @Published var rootEntity: Entity? = nil
    @Published var loadedEntity: Entity? = nil
    @Published var gridEntity = Entity()
    @Published var modelToPlace: (model: ModelInfo, category: ModelCategory)? = nil
    @Published var placementPosition: SIMD3<Float>? = nil
}

struct NavigationControl: View {
    // Access shared data
    @ObservedObject var navigationData: NavigationData
    @ObservedObject var tabSelection: TabSelection
    
    //State variables
    @State private var isBuildReady = false
    
    // Environment Variables
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    func moveForward(_ meters: Float) async {
        // (0,0,1) represents moving moveForward vector
        let baseVector = SIMD3<Float>(0, 0, 1)
        let c = cos(navigationData.cameraRotation)
        let s = sin(navigationData.cameraRotation)
        let rotatedVector = SIMD3<Float>(
            baseVector.x * c - baseVector.z * s,
            baseVector.y,
            baseVector.x * s + baseVector.z * c
        )
        navigationData.cameraPosition += rotatedVector * meters
    }

    func moveBackward(_ meters: Float) async {
        // (0,0,1) represents moving moveForward vector, but since we are subtracting in below for() loop we moveBackward
        let baseVector = SIMD3<Float>(0, 0, 1)
        let c = cos(navigationData.cameraRotation)
        let s = sin(navigationData.cameraRotation)
        let rotatedVector = SIMD3<Float>(
             baseVector.x * c - baseVector.z * s,
             baseVector.y,
             baseVector.x * s + baseVector.z * c
        )
        navigationData.cameraPosition -= rotatedVector * meters
    }
    
    func moveLeft(_ meters: Float) async {
        // (1,0,0) represents moving moveLeft vector
        let baseVector = SIMD3<Float>(1, 0, 0)
        let c = cos(navigationData.cameraRotation)
        let s = sin(navigationData.cameraRotation)
        let rotatedVector = SIMD3<Float>(
            baseVector.x * c - baseVector.z * s,
            baseVector.y,
            baseVector.x * s + baseVector.z * c
        )
        navigationData.cameraPosition += rotatedVector * meters
    }

    func moveRight(_ meters: Float) async {
        // (1,0,0) represents moving moveLeft vector, but since we are subtracting in for() loop we moveRight
        let baseVector = SIMD3<Float>(1, 0, 0)
        let c = cos(navigationData.cameraRotation)
        let s = sin(navigationData.cameraRotation)
        let rotatedVector = SIMD3<Float>(
            baseVector.x * c - baseVector.z * s,
            baseVector.y,
            baseVector.x * s + baseVector.z * c
        )
        navigationData.cameraPosition -= rotatedVector * meters
    }

    func turnLeft() async {
        let modelRotationStep = Float(45) * .pi / 180
        navigationData.cameraRotation -= modelRotationStep
    }
     
    func turnRight() async {
        let modelRotationStep = Float(45) * .pi / 180
        navigationData.cameraRotation += modelRotationStep
    }
    
    func moveHigher(_ meters: Float) async {
        navigationData.cameraPosition.y -= meters
    }
    
    // Helper function to move down a specific distance
    func moveLower(_ meters: Float) async {
        navigationData.cameraPosition.y += meters
    }
            
    var body: some View {
        VStack {
            Text("Navigate 3D space")
                .font(.headline)
                .padding()

            // Home, Origin, and Build controls
            HStack {
                Button {
                    dismissWindow(id: "NavigationControl")
//                    dismissWindow(id: "Menu")
                } label: {
                    Label("", systemImage: "house.fill")
                }
                
                Button {
                    navigationData.cameraPosition = SIMD3<Float>(0, 0, 0)
                } label: {
                    Label("", systemImage: "location")
                }
                
                Button {
                    navigationData.isCameraVisible.toggle()
                } label: {
                    Label("", systemImage: "camera.circle.fill")
                        .foregroundColor(navigationData.isCameraVisible ? .red : .primary)
                }
                
                Button {
                    navigationData.isSpotLightVisible.toggle()
                } label: {
                    Label("", systemImage: "light.beacon.max")
                        .foregroundColor(navigationData.isSpotLightVisible ? .yellow : .primary)
                }
                
                Button {
                    isBuildReady.toggle()
                    if isBuildReady {
//                        openWindow(id: "Menu")
                        tabSelection.selectedTab = 1
                        navigationData.gridEntity.isEnabled = true
                    } else {
//                        dismissWindow(id: "Menu")
                        navigationData.gridEntity.isEnabled = false
                    }
                } label: {
                    Label("", systemImage: "plus.circle.fill")
                }
            }
            
            HStack {
                // Action for Rotate Left
                Button {
                    Task {
                        await turnLeft()
                    }
                } label: {
                    Label("", systemImage: "rotate.left")
                }
                
                // Action for Move Forward
                Button {
                    Task {
                        await moveForward(0.5)
                    }
                } label: {
                    Label("", systemImage: "arrow.up")
                }
                
                // Action for Rotate Right
                Button {
                    Task {
                        await turnRight()
                    }
                } label: {
                    Label("", systemImage: "rotate.right")
                }
            }
            
            //Strafing left and right can cause nausea
            HStack {
                // Action for Move Left
                Button {
                    Task {
                        await moveLeft(0.5)
                    }
                } label: {
                    Label("", systemImage: "arrow.left")
                }
                
                // Action for Move Right
                Button {
                    Task {
                        await moveRight(0.5)
                    }
                } label: {
                    Label("", systemImage: "arrow.right")
                }
            }
            
            HStack {
                // Action for Elevate Up
                Button {
                    Task {
                        await moveHigher(0.5)
                    }
                } label: {
                    Label("", systemImage: "arrow.up.to.line")
                }
                
                // Action for Move Backward
                Button {
                    Task {
                        await moveBackward(0.5)
                    }
                } label: {
                    Label("", systemImage: "arrow.down")
                }
                
                // Action for Elevate Down
                Button {
                    Task {
                        await moveLower(0.5)
                    }
                } label: {
                    Label("", systemImage: "arrow.down.to.line")
                }
            }
        }
        .onAppear{
            // Avoid dismissing the Menu window as it is essential to SharePlay session
//            dismissWindow(id: "Menu")
            navigationData.cameraPosition = SIMD3<Float>(0, 0, 0)
            navigationData.cameraRotation = 0
        }
        .onDisappear{
//            openWindow(id: "Menu")
            dismissWindow(id: "ModelRealityView")
            tabSelection.selectedTab = 1
            Task {
                await dismissImmersiveSpace()
            }
        }
        .padding()
    }
}


#Preview {
    NavigationControl(
        navigationData: NavigationData(),
        tabSelection: TabSelection()
        )
}
