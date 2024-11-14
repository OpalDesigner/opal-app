//
//  ImmersiveControlView.swift
//  TestApp
//
//  Created by Vik Parth on 10/21/24.
//

/*
 Direction Vectors
 When rotating 0 degrees (facing forward):
 When moving forward,   X = 0 , Z = +1
 When moving backward,  X = 0 , Z = -1
 When moving left,      X = +1 , Z = 0
 When moving right,     X = -1 , Z = 0
 
 When rotating 90 degrees (facing right)
 When moving forward,   X = 1 , Z = 0
 When moving backward,  X = -1 , Z = 0
 When moving left,      X = 0 , Z = +1
 When moving right,     X = 0 , Z = -1
 
 When rotating 180 degrees (facing backward)
 When moving forward,   X = 0 , Z = -1
 When moving backward,  X = 0 , Z = +1
 When moving left,      X = 1 , Z = 0
 When moving right,     X = -1, Z = 0
 
 When rotating 270 degrees (facing left)
 When moving forward,   X = -1 , Z = 0
 When moving backward,  X = +1 , Z = 0
 When moving left,      X = 0 , Z = -1
 When moving right,     X = 0, Z = +1
 */

import SwiftUI

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
    
    func normalizeRotation(_ rotation: Float) -> Float {
        // Convert any angle to a positive value between 0 and 2π
        var normalized = rotation.truncatingRemainder(dividingBy: 2 * .pi)
        if normalized < 0 {
            normalized += 2 * .pi
        }
        return normalized
    }
    
    func moveForward(_ meters: Float) async {
        let stepSize: Float = 0.05
        let steps = Int(meters / stepSize)
        let angle = normalizeRotation(modelControlData.cameraRotation)
        let degrees = angle * 180 / .pi
        let directionVector: SIMD3<Float>
        //let roundedDegrees = round(degrees / 45) * 45
        switch degrees {
            case 0:
                directionVector = SIMD3<Float>(0, 0, 1)
            case 45:
                directionVector = SIMD3<Float>(0.70710677, 0, 0.7071068)
            case 90:
                directionVector = SIMD3<Float>(1, 0, 0)
            case 135:
                directionVector = SIMD3<Float>(0.70710677, 0, -0.70710677)
            case 180:
                directionVector = SIMD3<Float>(0, 0, -1)
            case 225:
                directionVector = SIMD3<Float>(-0.7071066, 0, -0.707107)
            case 270:
                directionVector = SIMD3<Float>(-1, 0, 0)
            case 315:
                directionVector = SIMD3<Float>(-0.7071066, 0, 0.707107)
            default:
                directionVector = SIMD3<Float>(0, 0, 1)
        }
        
        for _ in 0..<steps {
            modelControlData.cameraPosition += directionVector * stepSize
            try? await Task.sleep(nanoseconds: 16_666_667)
        }
        
        print("Moving Forward")
        print("Rotation: \(degrees)°")
        print("Position: \(modelControlData.cameraPosition)")
        print("Direction: \(directionVector)\n")
    }

    func moveBackward(_ meters: Float) async {
        let stepSize: Float = 0.05
        let steps = Int(meters / stepSize)
        let angle = normalizeRotation(modelControlData.cameraRotation)
        let degrees = angle * 180 / .pi
        let directionVector: SIMD3<Float>
        //let roundedDegrees = round(degrees / 45) * 45
        switch degrees {
            case 0:
                directionVector = SIMD3<Float>(0, 0, 1)
            case 45:
                directionVector = SIMD3<Float>(0.70710677, 0, 0.7071068)
            case 90:
                directionVector = SIMD3<Float>(1, 0, 0)
            case 135:
                directionVector = SIMD3<Float>(0.70710677, 0, -0.70710677)
            case 180:
                directionVector = SIMD3<Float>(0, 0, -1)
            case 225:
                directionVector = SIMD3<Float>(-0.7071066, 0, -0.707107)
            case 270:
                directionVector = SIMD3<Float>(-1, 0, 0)
            //case 315:
            //   directionVector = SIMD3<Float>(-0.7071066, 0, 0.707107)
            default:
                directionVector = SIMD3<Float>(0, 0, 1)
        }
        
        for _ in 0..<steps {
            modelControlData.cameraPosition -= directionVector * stepSize
            try? await Task.sleep(nanoseconds: 16_666_667)
        }
        
        print("Moving Backward")
        print("Rotation: \(degrees)°")
        print("Position: \(modelControlData.cameraPosition)")
        print("Direction: \(directionVector)\n")
    }
    
    func moveLeft(_ meters: Float) async {
        let stepSize: Float = 0.05
        let steps = Int(meters / stepSize)
        let angle = normalizeRotation(modelControlData.cameraRotation)
        let degrees = angle * 180 / .pi
        let directionVector: SIMD3<Float>
        //let roundedDegrees = round(degrees / 45) * 45
        switch degrees {
            case 0:
                directionVector = SIMD3<Float>(1, 0, 0)
            case 45:
                directionVector = SIMD3<Float>(0.70710677, 0, 0.7071068)
            case 90:
                directionVector = SIMD3<Float>(0, 0, 1)
            case 135:
                directionVector = SIMD3<Float>(0.70710677, 0, -0.70710677)
            case 180:
                directionVector = SIMD3<Float>(-1, 0, 0)
            case 225:
                directionVector = SIMD3<Float>(-0.7071066, 0, -0.707107)
            case 270:
                directionVector = SIMD3<Float>(0, 0, -1)
            //case 315:
            //    directionVector = SIMD3<Float>(-0.7071066, 0, 0.707107)
            default:
                directionVector = SIMD3<Float>(1, 0, 0)
        }

        for _ in 0..<steps {
            modelControlData.cameraPosition += directionVector * stepSize
            try? await Task.sleep(nanoseconds: 16_666_667)
        }
        
        print("Moving Left")
        print("Rotation: \(degrees)°")
        print("Position: \(modelControlData.cameraPosition)")
        print("Direction: \(directionVector)\n")
    }

    func moveRight(_ meters: Float) async {
        let stepSize: Float = 0.05
        let steps = Int(meters / stepSize)
        let angle = normalizeRotation(modelControlData.cameraRotation)
        let degrees = angle * 180 / .pi
        let directionVector: SIMD3<Float>
        //let roundedDegrees = round(degrees / 45) * 45
        switch degrees {
            case 0:
                directionVector = SIMD3<Float>(1, 0, 0)
            case 45:
                directionVector = SIMD3<Float>(0.70710677, 0, 0.7071068)
            case 90:
                directionVector = SIMD3<Float>(0, 0, 1)
            case 135:
                directionVector = SIMD3<Float>(0.70710677, 0, -0.70710677)
            case 180:
                directionVector = SIMD3<Float>(-1, 0, 0)
            case 225:
                directionVector = SIMD3<Float>(-0.7071066, 0, -0.707107)
            case 270:
                directionVector = SIMD3<Float>(0, 0, -1)
            //case 315:
            //    directionVector = SIMD3<Float>(-0.7071066, 0, 0.707107)
            default:
                directionVector = SIMD3<Float>(1, 0, 0)
        }

        for _ in 0..<steps {
            modelControlData.cameraPosition -= directionVector * stepSize
            try? await Task.sleep(nanoseconds: 16_666_667)
        }

        print("Moving Right")
        print("Rotation: \(degrees)°")
        print("Position: \(modelControlData.cameraPosition)")
        print("Direction: \(directionVector)\n")
    }
    
    // Helper function to turn left 45 degrees
    func turnLeft() async {
        //let stepSize: Float = 0.5 * .pi / 180 // 0.5 degrees at a time
        //let steps = Int(45 / 0.5)
        let stepSize: Float = 45 * .pi / 180 // 45 degrees at a time
        let steps = Int(45 / 45)
        
        for _ in 0..<steps {
            //modelControlData.cameraRotation -= stepSize  // Update camera rotation
            let newRotation = modelControlData.cameraRotation - stepSize
            modelControlData.cameraRotation = normalizeRotation(newRotation)
            try? await Task.sleep(nanoseconds: 16_666_667)
        }
        
        print("Turn Left")
        print("Rotation: \(normalizeRotation(modelControlData.cameraRotation) * 180 / .pi)°")
        print("Expected direction: X=\(sin(modelControlData.cameraRotation)), Z=\(cos(modelControlData.cameraRotation))\n")
    }
    
    // Helper function to turn right 45 degrees
    func turnRight() async {
        //let stepSize: Float = 0.5 * .pi / 180 // 0.5 degrees at a time
        //let steps = Int(45 / 0.5)
        let stepSize: Float = 45 * .pi / 180 // 45 degrees at a time
        let steps = Int(45 / 45)

        for _ in 0..<steps {
            //modelControlData.cameraRotation += stepSize  // Update camera rotation
            let newRotation = modelControlData.cameraRotation + stepSize
            modelControlData.cameraRotation = normalizeRotation(newRotation)
            try? await Task.sleep(nanoseconds: 16_666_667)
        }
        
        print("Turn Right")
        print("Rotation: \(normalizeRotation(modelControlData.cameraRotation) * 180 / .pi)°")
        print("Expected direction: X=\(sin(modelControlData.cameraRotation)), Z=\(cos(modelControlData.cameraRotation))\n")
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
        isAutomating = false
    }
            
    var body: some View {
        VStack {
            Text("Navigate 3D space")
                .font(.headline) // Add a headline font
                .padding()
            
            HStack {
                Button {
                    dismissWindow(id: "NavigationControlUI")
                } label: {
                    Label("", systemImage: "house.fill")
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

            VStack {
                //MAIN MOVE CONTROLS
                VStack {
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

