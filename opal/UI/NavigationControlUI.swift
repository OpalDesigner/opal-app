//
//  ImmersiveControlView.swift
//  TestApp
//
//  Created by Vik Parth on 10/21/24.
//


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
        
    // Helper function to move forward a specific distance
    func moveForward(_ meters: Float) async {
        let stepSize: Float = 0.05 // Move in smaller increments for smoothness
        let steps = Int(meters / stepSize)
        for _ in 0..<steps {
            modelControlData.position.z += stepSize
            try? await Task.sleep(nanoseconds: 16_666_667) // ~60fps
        }
    }
    
    // Helper function to move backward a specific distance
    func moveBackward(_ meters: Float) async {
        let stepSize: Float = 0.05 // Move in smaller increments for smoothness
        let steps = Int(meters / stepSize)
        for _ in 0..<steps {
            modelControlData.position.z -= stepSize
            try? await Task.sleep(nanoseconds: 16_666_667) // ~60fps
        }
    }
    
    // Helper function to move up a specific distance
    func moveLeft(_ meters: Float) async {
        let stepSize: Float = 0.05 // Move in smaller increments for smoothness
        let steps = Int(meters / stepSize)
        for _ in 0..<steps {
            modelControlData.position.x += stepSize
            try? await Task.sleep(nanoseconds: 16_666_667) // ~60fps
        }
    }
    
    // Helper function to move down a specific distance
    func moveRight(_ meters: Float) async {
        let stepSize: Float = 0.05 // Move in smaller increments for smoothness
        let steps = Int(meters / stepSize)
        for _ in 0..<steps {
            modelControlData.position.x -= stepSize
            try? await Task.sleep(nanoseconds: 16_666_667) // ~60fps
        }
    }
    
    // Helper function to move up a specific distance
    func moveHigher(_ meters: Float) async {
        let stepSize: Float = 0.05 // Move in smaller increments for smoothness
        let steps = Int(meters / stepSize)
        for _ in 0..<steps {
            modelControlData.position.y -= stepSize
            try? await Task.sleep(nanoseconds: 16_666_667) // ~60fps
        }
    }
    
    // Helper function to move down a specific distance
    func moveLower(_ meters: Float) async {
        let stepSize: Float = 0.05 // Move in smaller increments for smoothness
        let steps = Int(meters / stepSize)
        for _ in 0..<steps {
            modelControlData.position.y += stepSize
            try? await Task.sleep(nanoseconds: 16_666_667) // ~60fps
        }
    }
    
    // Helper function to turn left 45 degrees
    func turnLeft() async {
        let stepSize: Float = 0.5 * .pi / 180 // 5 degrees at a time
        let steps = Int(45 / 0.5)
        let radius: Float = 0 // Since we want to rotate in place
        let currentPosition = modelControlData.position
        
        for _ in 0..<steps {
            modelControlData.rotation -= stepSize
            try? await Task.sleep(nanoseconds: 16_666_667)
        }
    }
    
    // Helper function to turn left 45 degrees
    func turnRight() async {
        let stepSize: Float = 0.5 * .pi / 180 // 5 degrees at a time
        let steps = Int(45 / 0.5)
        for _ in 0..<steps {
            modelControlData.rotation += stepSize
            try? await Task.sleep(nanoseconds: 16_666_667)
        }
    }
    
    // Function to perform automated movement
    func customMovement() async {
        isAutomating = true
        
        // Execute a custom move sequence
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
                                await moveForward(2)
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
                                await moveBackward(2)
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
                    
                    /*
                    HStack {
                        // Action for Scale Up
                        Button {
                            modelControlData.scale += 0.5
                        } label: {
                            Label("", systemImage: "plus.magnifyingglass")
                        }
                        // Action for Scale Down
                        Button {
                            modelControlData.scale -= 0.5
                        } label: {
                            Label("", systemImage: "minus.magnifyingglass")
                        }
                    }
                     */
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

