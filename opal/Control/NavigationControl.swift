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
    
    @Published var cameraEntity = Entity()
    @Published var spotlightEntity = Entity()
    @Published var lightSource = ModelEntity()
    @Published var isCameraVisible: Bool = false
    @Published var isSpotLightVisible: Bool = false
    
    @Published var splatRotationAxis = SIMD3<Float>(0, 1, 0)           // X is pitch, Y is yaw, Z is roll
    @Published var splatRotationAmount = Angle(degrees: 0)
    @Published var splatRotationPerSecond = Angle(degrees: 0)
    @Published var splatScale: Float = 1
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
        let stepSize: Float = 0.05
        let steps = Int(meters / stepSize)
        
        // (0,0,1) represents moving moveForward vector
        let baseVector = SIMD3<Float>(0, 0, 1)
        let c = cos(navigationData.cameraRotation)
        let s = sin(navigationData.cameraRotation)
        let rotatedVector = SIMD3<Float>(
            baseVector.x * c - baseVector.z * s,
            baseVector.y,
            baseVector.x * s + baseVector.z * c
        )
        for _ in 0..<steps {
            navigationData.cameraPosition += rotatedVector * stepSize
            try? await Task.sleep(nanoseconds: 16_666_667)
        }
    }

    func moveBackward(_ meters: Float) async {
        let stepSize: Float = 0.05
        let steps = Int(meters / stepSize)
        
        // (0,0,1) represents moving moveForward vector, but since we are subtracting in below for() loop we moveBackward
        let baseVector = SIMD3<Float>(0, 0, 1)
        let c = cos(navigationData.cameraRotation)
        let s = sin(navigationData.cameraRotation)
        let rotatedVector = SIMD3<Float>(
             baseVector.x * c - baseVector.z * s,
             baseVector.y,
             baseVector.x * s + baseVector.z * c
        )
        for _ in 0..<steps {
            navigationData.cameraPosition -= rotatedVector * stepSize
            try? await Task.sleep(nanoseconds: 16_666_667)
        }
    }
    
    func moveLeft(_ meters: Float) async {
        let stepSize: Float = 0.05
        let steps = Int(meters / stepSize)
        let baseVector = SIMD3<Float>(1, 0, 0)
        
        // (1,0,0) represents moving moveLeft vector
        let c = cos(navigationData.cameraRotation)
        let s = sin(navigationData.cameraRotation)
        let rotatedVector = SIMD3<Float>(
            baseVector.x * c - baseVector.z * s,
            baseVector.y,
            baseVector.x * s + baseVector.z * c
        )
        for _ in 0..<steps {
            navigationData.cameraPosition += rotatedVector * stepSize
            try? await Task.sleep(nanoseconds: 16_666_667)
        }
    }

    func moveRight(_ meters: Float) async {
        let stepSize: Float = 0.05
        let steps = Int(meters / stepSize)
        let baseVector = SIMD3<Float>(1, 0, 0)
        
        // (1,0,0) represents moving moveLeft vector, but since we are subtracting in for() loop we moveRight
        let c = cos(navigationData.cameraRotation)
        let s = sin(navigationData.cameraRotation)
        let rotatedVector = SIMD3<Float>(
            baseVector.x * c - baseVector.z * s,
            baseVector.y,
            baseVector.x * s + baseVector.z * c
        )
        
        for _ in 0..<steps {
            navigationData.cameraPosition -= rotatedVector * stepSize
            try? await Task.sleep(nanoseconds: 16_666_667)
        }
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
        let stepSize: Float = 0.05 // Move in smaller increments for smoothness
        let steps = Int(meters / stepSize)
        for _ in 0..<steps {
            navigationData.cameraPosition.y -= stepSize
            try? await Task.sleep(nanoseconds: 16_666_667) // ~60fps
        }
    }
    
    // Helper function to move down a specific distance
    func moveLower(_ meters: Float) async {
        let stepSize: Float = 0.05 // Move in smaller increments for smoothness
        let steps = Int(meters / stepSize)
        for _ in 0..<steps {
            navigationData.cameraPosition.y += stepSize
            try? await Task.sleep(nanoseconds: 16_666_667) // ~60fps
        }
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
                    dismissWindow(id: "Menu")
                } label: {
                    Label("", systemImage: "house.fill")
                }
                
                Button {
                    navigationData.cameraPosition = SIMD3<Float>(0, 0, 0)
                } label: {
                    Label("", systemImage: "location")
                }
                
                Button {
                    isBuildReady.toggle()
                    if isBuildReady {
                        openWindow(id: "Menu")
                        tabSelection.selectedTab = 3
                    } else {
                        dismissWindow(id: "Menu")
                    }
                } label: {
                    Label("", systemImage: "plus.circle.fill")
                }
                
                /*
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
                 */
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
            dismissWindow(id: "Menu")
            navigationData.cameraPosition = SIMD3<Float>(0, 0, 0)
            navigationData.cameraRotation = 0
        }
        .onDisappear{
            openWindow(id: "Menu")
            dismissWindow(id: "ModelRealityView")
            tabSelection.selectedTab = 1
            Task {
                await dismissImmersiveSpace()
            }
        }
        .padding()
        .glassBackgroundEffect()
    }
}


#Preview {
    NavigationControl(
        navigationData: NavigationData(),
        tabSelection: TabSelection()
        )
}
