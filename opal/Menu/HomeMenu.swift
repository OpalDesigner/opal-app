//
//  HomeMenu.swift
//
//  Created by Vik Parth on 9/30/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct HomeMenu: View {
    @State private var modelRotation: Double = 0
    @State private var isPressed = false
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        ZStack{
            HStack {
                VStack(spacing: 20) {
                    Text("Welcome to Scene Designer")
                        .font(.largeTitle)
                    Text("Scene Designer is an intuitive simulation tool that combines realistic graphics with playful animation.")
                        .font(.system(size: 20))
                    Button{
                        isPressed.toggle()
                        Task {
                            if isPressed {
                                await openImmersiveSpace(id: "HandTrackingView")
                            } else {
                                await dismissImmersiveSpace()
                            }
                        }
                    }label: {
                        Label("Test Hand Tracking", systemImage: "")
                    }
                }
                .frame(width: 500, height: 200)
                .padding()
                .glassBackgroundEffect()
                
                NavigationStack {
                    Model3D(named: "tv_retro") { model in model
                            .resizable()
                            .scaledToFit()
                            .rotation3DEffect(.degrees(modelRotation), axis: (x: 0, y: 1, z: 0))
                            .animation(.easeInOut(duration: 1), value: modelRotation)
                            .scaleEffect(0.5)
                            .overlay(alignment: .bottom){
                                VStack{
                                    Button{
                                        modelRotation += 90
                                    }label: {
                                        Label("", systemImage: "arrow.triangle.2.circlepath.circle")
                                    }
                                }
                            }
                    } placeholder: {
                        ProgressView()
                    }
                }
            }
            .padding(.top, 300)
            .background {
                Image("interior-shot")
            }
            
        //Render Opals
        BubbleView()
        }
    }
}

#Preview {
    HomeMenu()
}
