//
//  HomeArea.swift
//  TestApp
//
//  Created by Vik Parth on 9/30/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct HomeArea: View {
    @State private var modelRotation: Double = 0
    @State private var modelScale: CGFloat = 1
    @State private var modelAnimation: Bool = false

    var body: some View {
        HStack {
            VStack(spacing: 20) {
                Text("Welcome to Opal Designer")
                    .font(.largeTitle)
                Text("Opal is a set design visualization tool that combines realistic graphics with intuitive and playful animation.")
                    .font(.system(size: 20))
            }
            .frame(width: 500, height: 200)
            .padding()
            .glassBackgroundEffect()

            NavigationStack {
                Model3D(named: "Mars_Habitat") { model in model
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaledToFit()
                    .rotation3DEffect(.degrees(modelRotation), axis: (x: 0, y: 1, z: 0))
                    .animation(.easeInOut(duration: 1), value: modelRotation)
                    .scaleEffect(modelScale)
                    .animation(.spring(), value: modelScale)
                    .overlay(alignment: .topTrailing){
                        VStack{
                            Text("Mars Rover")
                            
                            Button{
                                modelRotation += 90
                            }label: {
                                Label("", systemImage: "arrow.triangle.2.circlepath.circle")
                            }
                            
                            Button {
                                modelScale = modelScale == 1 ? 2 : 1
                            } label: {
                                Label("", systemImage: modelScale == 1 ? "plus.magnifyingglass" : "minus.magnifyingglass")
                            }
                            
                            /*
                            Button {
                                modelAnimation.toggle()
                                /*
                                Task {
                                    guard let model = try? await Entity(named: "Mars_Habitat", in: realityKitContentBundle) else { fatalError("Unable to load scene model") }
                                     if(model.availableAnimations.count > 0){
                                         let anim = model.availableAnimations[0]
                                         model.playAnimation(anim.repeat())
                                     }
                                }
                                 */
                            } label: {
                                Label("", systemImage: modelAnimation ? "pause.circle" : "play.circle")
                            }
                             */
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
    }
}

#Preview {
    HomeArea()
}
