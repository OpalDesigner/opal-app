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
    }
}

#Preview {
    HomeArea()
}
