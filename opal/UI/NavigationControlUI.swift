//
//  ImmersiveControlView.swift
//  TestApp
//
//  Created by Vik Parth on 10/21/24.
//

import SwiftUI
import RealityKit

//This code creates the UI that lets you navigate through the Immersive 3D set
struct NavigationControlUI: View {
    // Access shared data
    @ObservedObject var modelControlData: ModelControlData
    
    // Environment Variables
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    // Add state to track if automation is running
    @State private var isAutomating = false
    
    func moveForward(_ meters: Float) async {
        let stepSize: Float = 0.05
        let steps = Int(meters / stepSize)
        let cameraVector = SIMD3<Float>(0, 0, 1)
        for _ in 0..<steps {
            modelControlData.cameraPosition += cameraVector * stepSize
            try? await Task.sleep(nanoseconds: 16_666_667)
        }
        print("Moving Forward")
        print("Camera Position: \(round(modelControlData.cameraPosition))")
        print("Camera Rotation: \(round(modelControlData.cameraRotation * 180 / .pi))°\n")
    }

    func moveBackward(_ meters: Float) async {
        let stepSize: Float = 0.05
        let steps = Int(meters / stepSize)
        let cameraVector = SIMD3<Float>(0, 0, 1)
        for _ in 0..<steps {
            modelControlData.cameraPosition -= cameraVector * stepSize
            try? await Task.sleep(nanoseconds: 16_666_667)
        }
        print("Moving Backward")
        print("Camera Position: \(round(modelControlData.cameraPosition))")
        print("Camera Rotation: \(round(modelControlData.cameraRotation * 180 / .pi))°\n")
    }
    
    func moveLeft(_ meters: Float) async {
        let stepSize: Float = 0.05
        let steps = Int(meters / stepSize)
        let cameraVector = SIMD3<Float>(1, 0, 0)
        for _ in 0..<steps {
            modelControlData.cameraPosition += cameraVector * stepSize
            try? await Task.sleep(nanoseconds: 16_666_667)
        }
        print("Moving Left")
        print("Camera Position: \(round(modelControlData.cameraPosition))")
        print("Camera Rotation: \(round(modelControlData.cameraRotation * 180 / .pi))°\n")
    }

    func moveRight(_ meters: Float) async {
        let stepSize: Float = 0.05
        let steps = Int(meters / stepSize)
        let cameraVector = SIMD3<Float>(1, 0, 0)
        for _ in 0..<steps {
            modelControlData.cameraPosition -= cameraVector * stepSize
            try? await Task.sleep(nanoseconds: 16_666_667)
        }
        print("Moving Right")
        print("Camera Position: \(round(modelControlData.cameraPosition))")
        print("Camera Rotation: \(round(modelControlData.cameraRotation * 180 / .pi))°\n")
    }
    
    // Helper function to turn left 45 degrees
    func turnLeft() async {
        let stepSize: Float = 45 * .pi / 180 // 45 degrees at a time
        let steps = Int(45 / 45)
        var newRotation = modelControlData.cameraRotation - stepSize
        
        // Normalize between 0 and 2π
        newRotation = newRotation.truncatingRemainder(dividingBy: 2 * .pi)
        if newRotation < 0 {
            newRotation += 2 * .pi
        }
        for _ in 0..<steps {
            modelControlData.cameraRotation = newRotation
            try? await Task.sleep(nanoseconds: 16_666_667)
        }
        print("Turning Left")
        print("Camera Rotation: \(round(modelControlData.cameraRotation * 180 / .pi))°\n")
    }
    
    // Helper function to turn right 45 degrees
    func turnRight() async {
        let stepSize: Float = 45 * .pi / 180 // 45 degrees at a time
        let steps = Int(45 / 45)
        var newRotation = modelControlData.cameraRotation + stepSize
        
        // Normalize between 0 and 2π
        newRotation = newRotation.truncatingRemainder(dividingBy: 2 * .pi)
        if newRotation < 0 {
            newRotation += 2 * .pi
        }
        
        for _ in 0..<steps {
            modelControlData.cameraRotation = newRotation
            try? await Task.sleep(nanoseconds: 16_666_667)
        }
        
        print("Turn Right")
        print("Camera Rotation: \(round(modelControlData.cameraRotation * 180 / .pi))°\n")
    }
    
    // Helper function to move up a specific distance
    func moveHigher(_ meters: Float) async {
        let stepSize: Float = 0.05 // Move in smaller increments for smoothness
        let steps = Int(meters / stepSize)
        for _ in 0..<steps {
            modelControlData.cameraPosition.y -= stepSize
            try? await Task.sleep(nanoseconds: 16_666_667) // ~60fps
        }
    }
    
    // Helper function to move down a specific distance
    func moveLower(_ meters: Float) async {
        let stepSize: Float = 0.05 // Move in smaller increments for smoothness
        let steps = Int(meters / stepSize)
        for _ in 0..<steps {
            modelControlData.cameraPosition.y += stepSize
            try? await Task.sleep(nanoseconds: 16_666_667) // ~60fps
        }
    }
    
    // Function to perform automated movement
    func customMovement() async {
        isAutomating = true
        await moveForward(2)    // Forward 2 meters
        await moveBackward(2)    // Forward 1 meter
        await turnLeft()        // Turn left 90 degrees
        await moveForward(2)    // Forward 2 meters
        await moveBackward(2)    // Forward 1 meter
        await turnLeft()        // Turn left 90 degrees
        await moveForward(2)    // Forward 2 meters
        await moveBackward(2)    // Forward 1 meter
        await turnLeft()        // Turn left 90 degrees
        await moveForward(2)    // Forward 2 meters
        await moveBackward(2)    // Forward 1 meter
        await turnLeft()        // Turn left 90 degrees
        await moveForward(2)    // Forward 2 meters
        await moveBackward(2)    // Forward 1 meter
        await turnLeft()        // Turn left 90 degrees
        await moveForward(2)    // Forward 2 meters
        await moveBackward(2)    // Forward 1 meter
        await turnLeft()        // Turn left 90 degrees
        await moveForward(2)    // Forward 2 meters
        await moveBackward(2)    // Forward 1 meter
        await turnLeft()        // Turn left 90 degrees
        await moveForward(2)    // Forward 2 meters
        await moveBackward(2)    // Forward 1 meter
        await turnLeft()        // Turn left 90 degrees
        isAutomating = false
    }
            
    var body: some View {
        VStack {
            Text("Navigate 3D space")
                .font(.headline)
                .padding()
            
            // Display coordinates
            VStack {
                Text("Camera Position:")
                    .font(.subheadline)
                HStack {
                    Text("X: \(String(format: "%.f", modelControlData.cameraPosition.x))")
                    Text("Y: \(String(format: "%.f", modelControlData.cameraPosition.y))")
                    Text("Z: \(String(format: "%.f", modelControlData.cameraPosition.z))")
                }
            }

            // Move controls
            HStack {
                Button {
                    dismissWindow(id: "NavigationControlUI")
                } label: {
                    Label("", systemImage: "house.fill")
                }
                
                Button {
                    modelControlData.cameraPosition = SIMD3<Float>(0, 0, 0)
                } label: {
                    Label("", systemImage: "location")
                }
                
                Button {
                    Task {
                        await customMovement()
                    }
                } label: {
                    Label("", systemImage: "figure.walk.motion")
                        .foregroundColor(isAutomating ? .gray : .primary)
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
                        await moveForward(1)
                    }
                } label: {
                    Label("", systemImage: "arrow.up")
                        .foregroundColor(.orange)
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
            
            HStack {
                // Action for Move Left
                Button {
                    Task {
                        await moveLeft(1)
                    }
                } label: {
                    Label("", systemImage: "arrow.left")
                        .foregroundColor(.orange)
                }
                // Action for Move Right
                Button {
                    Task {
                        await moveRight(1)
                    }
                } label: {
                    Label("", systemImage: "arrow.right")
                        .foregroundColor(.orange)
                }
            }
            
            HStack {
                // Action for Elevate Up
                Button {
                    Task {
                        await moveHigher(1)
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
                        .foregroundColor(.orange)
                }
                
                // Action for Elevate Down
                Button {
                    Task {
                        await moveLower(1)
                    }
                } label: {
                    Label("", systemImage: "arrow.down.to.line")
                }
            }
        }
        .onAppear{
            //Dismiss the Main Menu when we enter Immersive View
            dismissWindow(id: "Menu")
        }
        .onDisappear{
            //Dismiss current Immersive Space and Open the Main Menu
            openWindow(id: "Menu")
            Task {
                await dismissImmersiveSpace()
            }
        }
        .padding()
        .glassBackgroundEffect()
        .shadow(radius: 5) // More pronounced shadow
    }
}

#Preview {
    NavigationControlUI(modelControlData: ModelControlData())
}

