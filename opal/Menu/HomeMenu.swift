//
//  HomeMenu.swift
//
//  Created by Vik Parth on 9/30/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct HomeMenu: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    @State private var titleText: String = ""
    @State private var finalTitle: String = "Welcome to Scene Designer"
    @State private var descriptionText: String = "Scene Designer is an intuitive simulation tool that combines realistic graphics with playful animation."
    @State private var isTypingFinished: Bool = false
    @State private var isPressed = false
    @State private var modelRotation: Double = 0

    var body: some View {
        ZStack{
            HStack {
                VStack(spacing: 20) {
                    Text(titleText)
                        .font(.largeTitle)
                    Text(descriptionText)
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
                .task {
                    for index in finalTitle.indices {
                        titleText = String(finalTitle.prefix(through: index))
                        try? await Task.sleep(for: .milliseconds(100))
                    }
                    isTypingFinished = true
                }
                
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
            if(isTypingFinished){
                BubbleView()
            }
        }
    }
}

#Preview {
    HomeMenu()
}
