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
}

struct NavigationControl: View {
    // Access shared data
    @ObservedObject var navigationData: NavigationData
    
    // Environment Variables
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    // Add state to track if walkthrough is running
    @State private var isAutomating = false
    
    func moveForward(_ meters: Float) async {
        let stepSize: Float = 0.05
        let steps = Int(meters / stepSize)
        
        // Rotate the base vector by the camera's rotation
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
        print("Moving Forward")
        print("Camera Position: \(round(navigationData.cameraPosition))")
        print("Camera Rotation: \(round(navigationData.cameraRotation * 180 / .pi))°")
    }

    func moveBackward(_ meters: Float) async {
        let stepSize: Float = 0.05
        let steps = Int(meters / stepSize)
        
        // Rotate the base vector by the camera's rotation
        let baseVector = SIMD3<Float>(0, 0, 1)
        let c = cos(navigationData.cameraRotation)
        let s = sin(navigationData.cameraRotation)
        let rotatedVector = SIMD3<Float>(
             baseVector.x * c - baseVector.z * s,
             baseVector.y,
             baseVector.x * s + baseVector.z * c
        )
        
        for _ in 0..<steps {
            //modelControlData.cameraPosition -= cameraVector * stepSize
            navigationData.cameraPosition -= rotatedVector * stepSize
            try? await Task.sleep(nanoseconds: 16_666_667)
        }
        print("Moving Backward")
        print("Camera Position: \(round(navigationData.cameraPosition))")
        print("Camera Rotation: \(round(navigationData.cameraRotation * 180 / .pi))°")
    }
    
    func moveLeft(_ meters: Float) async {
        let stepSize: Float = 0.05
        let steps = Int(meters / stepSize)
        let baseVector = SIMD3<Float>(1, 0, 0)
        
        // Rotate the base vector by the camera's rotation
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
        print("Moving Left")
        print("Camera Position: \(round(navigationData.cameraPosition))")
        print("Camera Rotation: \(round(navigationData.cameraRotation * 180 / .pi))°")
    }

    func moveRight(_ meters: Float) async {
        let stepSize: Float = 0.05
        let steps = Int(meters / stepSize)
        let baseVector = SIMD3<Float>(1, 0, 0)
        
        // Rotate the base vector by the camera's rotation
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
        print("Moving Right")
        print("Camera Position: \(round(navigationData.cameraPosition))")
        print("Camera Rotation: \(round(navigationData.cameraRotation * 180 / .pi))°")
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
        print("Turning Left")
        print("Camera Rotation: \(round(navigationData.cameraRotation * 180 / .pi))°")
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
        
        print("Turn Right")
        print("Camera Rotation: \(round(navigationData.cameraRotation * 180 / .pi))°")
    }
    
    // Helper function to move up a specific distance
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
    
    // Function to perform automated movement. Will inherit this from the pre-determined waypoints for each model
    func customMovement() async {
        isAutomating = true
        await moveForward(4)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await turnLeft(degrees: 45)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await turnLeft(degrees: 45)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await moveForward(1)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await turnLeft(degrees: 45)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await turnLeft(degrees: 45)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await moveForward(6)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await turnLeft(degrees: 45)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await turnLeft(degrees: 45)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await moveForward(2)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await turnLeft(degrees: 45)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await turnLeft(degrees: 45)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await moveForward(4)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await turnLeft(degrees: 45)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await turnLeft(degrees: 45)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await moveForward(1)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isAutomating = false
    }
            
    var body: some View {
        VStack {
            Text("Navigate 3D space")
                .font(.headline)
                .padding()
            
            // Display coordinates
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

            // Move controls
            HStack {
                Button {
                    dismissWindow(id: "NavigationControl")
                } label: {
                    Label("", systemImage: "house.fill")
                }
                .disabled(isAutomating)
                
                Button {
                    navigationData.cameraPosition = SIMD3<Float>(0, 0, 0)
                } label: {
                    Label("", systemImage: "location")
                }
                .disabled(isAutomating)
                
                /*
                //Animate movement
                Button {
                    Task {
                        await customMovement()
                    }
                } label: {
                    Label("", systemImage: "figure.walk.motion")
                        .foregroundColor(isAutomating ? .gray : .primary)
                }
                 */
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
                .disabled(isAutomating)
                
                // Action for Move Forward
                Button {
                    Task {
                        await moveForward(1)
                    }
                } label: {
                    Label("", systemImage: "arrow.up")
                }
                .disabled(isAutomating)
                
                // Action for Rotate Right
                Button {
                    Task {
                        await turnRight(degrees: 45)
                    }
                } label: {
                    Label("", systemImage: "rotate.right")
                }
                .disabled(isAutomating)
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
                .disabled(isAutomating)
                
                // Action for Move Right
                Button {
                    Task {
                        await moveRight(0.5)
                    }
                } label: {
                    Label("", systemImage: "arrow.right")
                }
                .disabled(isAutomating)
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
                .disabled(isAutomating)
                
                // Action for Move Backward
                Button {
                    Task {
                        await moveBackward(1)
                    }
                } label: {
                    Label("", systemImage: "arrow.down")
                }
                .disabled(isAutomating)
                
                // Action for Elevate Down
                Button {
                    Task {
                        await moveLower(0.5)
                    }
                } label: {
                    Label("", systemImage: "arrow.down.to.line")
                }
                .disabled(isAutomating)
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

