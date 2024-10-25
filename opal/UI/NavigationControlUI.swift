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
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    dismissWindow(id: "NavigationControlUI")
                } label: {
                    Label("", systemImage: "house.fill")
                }
                
                Text("Navigate 3D space")
                    .font(.headline) // Add a headline font
                    .padding()
            }

            VStack {
                //MAIN MOVE CONTROLS
                VStack {
                    HStack {
                        // Action for Rotate Left
                        Button {
                            modelControlData.rotation -= 45 * .pi / 180
                        } label: {
                            Label("", systemImage: "rotate.left")
                        }
                        
                        // Action for Move Forward
                        Button {
                            modelControlData.position.z += 50
                        } label: {
                            Label("", systemImage: "arrow.up")
                                .foregroundColor(.orange)
                        }
                        
                        // Action for Rotate Right
                        Button {
                            modelControlData.rotation += 45 * .pi / 180
                        } label: {
                            Label("", systemImage: "rotate.right")
                        }
                    }
                    
                    HStack {
                        // Action for Move Left
                        Button {
                            modelControlData.position.x += 50
                        } label: {
                            Label("", systemImage: "arrow.left")
                                .foregroundColor(.orange)
                        }
                        // Action for Move Right
                        Button {
                            modelControlData.position.x -= 50
                        } label: {
                            Label("", systemImage: "arrow.right")
                                .foregroundColor(.orange)
                        }
                    }
                    
                    HStack {
                        // Action for Elevate Up
                        Button {
                            modelControlData.position.y -= 50
                        } label: {
                            Label("", systemImage: "arrow.up.to.line")
                        }
                        
                        // Action for Move Backward
                        Button {
                            modelControlData.position.z -= 50
                        } label: {
                            Label("", systemImage: "arrow.down")
                                .foregroundColor(.orange)
                        }
                        
                        // Action for Elevate Down
                        Button {
                            modelControlData.position.y += 50
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

