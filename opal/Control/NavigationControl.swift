//
//  ImmersiveControlView.swift
//  TestApp
//
//  Created by Vik Parth on 10/21/24.
//

import SwiftUI
import RealityKit

struct NavigationControl: View {
    // Access shared data
    @ObservedObject var navigationData: NavigationData
    
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
    
    func turnLeft(degrees: Float) async {
        let stepSize: Float = degrees * .pi / 180 // 45 degrees at a time
        let steps = Int(degrees / 45)
        var newRotation = navigationData.cameraRotation - stepSize
        
        // Normalize between 0 and 2π
        newRotation = newRotation.truncatingRemainder(dividingBy: 2 * .pi)
        if newRotation < 0 {
            newRotation += 2 * .pi
        }
        for _ in 0..<steps {
            navigationData.cameraRotation = newRotation
            try? await Task.sleep(nanoseconds: 16_666_667)
        }
        /*
        print("Turning Left")
        print("Camera Rotation: \(round(navigationData.cameraRotation * 180 / .pi))°")
         */
    }
    
    func turnRight(degrees: Float) async {
        let stepSize: Float = degrees * .pi / 180 // 45 degrees at a time
        let steps = Int(degrees / 45)
        var newRotation = navigationData.cameraRotation + stepSize
        
        // Normalize between 0 and 2π
        newRotation = newRotation.truncatingRemainder(dividingBy: 2 * .pi)
        if newRotation < 0 {
            newRotation += 2 * .pi
        }
        
        for _ in 0..<steps {
            navigationData.cameraRotation = newRotation
            try? await Task.sleep(nanoseconds: 16_666_667)
        }
        /*
        print("Turn Right")
        print("Camera Rotation: \(round(navigationData.cameraRotation * 180 / .pi))°")
        */
         
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
            
            // Debug Camera Coordinates
            /*
            VStack {
                Text("Camera Position:")
                    .font(.subheadline)
                HStack {
                    Text("X: \(String(format: "%.f", modelControlData.cameraPosition.x))")
                    Text("Y: \(String(format: "%.f", modelControlData.cameraPosition.y))")
                    Text("Z: \(String(format: "%.f", modelControlData.cameraPosition.z))")
                }
            }
             */

            // Home, Origin, and Camera controls
            HStack {
                Button {
                    dismissWindow(id: "NavigationControl")
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
            }
            
            HStack {
                // Action for Rotate Left
                Button {
                    Task {
                        await turnLeft(degrees: 45)
                    }
                } label: {
                    Label("", systemImage: "rotate.left")
                }
                
                // Action for Move Forward
                Button {
                    Task {
                        await moveForward(1)
                    }
                } label: {
                    Label("", systemImage: "arrow.up")
                }
                
                // Action for Rotate Right
                Button {
                    Task {
                        await turnRight(degrees: 45)
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
                        await moveBackward(1)
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
            Task {
                await dismissImmersiveSpace()
            }
        }
        .padding()
        .glassBackgroundEffect()
    }
}

#Preview {
    NavigationControl(navigationData: NavigationData())
}

