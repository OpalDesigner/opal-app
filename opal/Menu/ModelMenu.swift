//
//  ModelMenu.swift
//  TestApp
//
//  Created by Vik Parth on 9/27/24.
//

import SwiftUI
import AWSS3

// Struct to hold Model info
struct ModelInfo: Identifiable, Codable, Hashable {
    let id = UUID()
    let imageName: String
    let modelName: String
    let immersive: Bool
    let initialPosition: SIMD3<Float>
    let realityScale: Float
    let immersiveScale: Float
}

// Setup Grid View
struct ModelArea: View {
    @State private var models: [ModelInfo] = []  // Convert from constant to state
    
    // Add timer for polling
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                ForEach(models, id: \.id) { model in
                    ModelItemView(model: model)
                }
            }
            .padding(20)
        }
        .id(models)
        .background {
            Image("interior-shot-03")
        }
        .onAppear {
            updateModels()
        }
        .onReceive(timer) { _ in
            print("Checking for new model files...")
            updateModels()
        }
    }
    
    private func updateModels() {
        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        // Create path to Documents/uploads
        let uploadsPath = documentsPath.appendingPathComponent("uploads")
        
        do {
            let files = try fileManager.contentsOfDirectory(at: uploadsPath, includingPropertiesForKeys: nil)
            let usdzFiles = files.filter { $0.pathExtension.lowercased() == "usdz" }
            
            // Convert USDZ files to ModelInfo objects
            let newModels = usdzFiles.map { url in
                ModelInfo(
                    imageName: "",  // Default empty image
                    modelName: url.deletingPathExtension().lastPathComponent,
                    immersive: false,  // Default to non-immersive
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    realityScale: 0.03,  // Default scale
                    immersiveScale: 0.1   // Default immersive scale
                )
            }
            
            // Combine default models with discovered models
            let defaultModels = [
                ModelInfo(imageName: "coffee-shop",       modelName: "Coffee_Shop",       immersive: true,  initialPosition: SIMD3<Float>(0, 0, 0), realityScale: 0.001,  immersiveScale: 0.01),
                ModelInfo(imageName: "house-interior",    modelName: "House_Interior",    immersive: true,  initialPosition: SIMD3<Float>(0, 0, 0), realityScale: 0.001,  immersiveScale: 0.03),
                ModelInfo(imageName: "budapest-hotel",    modelName: "Budapest_Hotel",    immersive: true,  initialPosition: SIMD3<Float>(0, 0, 0), realityScale: 0.0015, immersiveScale: 0.1),
                ModelInfo(imageName: "space-corridor",    modelName: "SpaceStation_Hall", immersive: true,  initialPosition: SIMD3<Float>(0, 0, 0), realityScale: 0.001,  immersiveScale: 0.02),
                ModelInfo(imageName: "classroom",         modelName: "Old_Classroom",     immersive: true,  initialPosition: SIMD3<Float>(0, 0, 0), realityScale: 0.001,  immersiveScale: 0.015),
                ModelInfo(imageName: "bedroom",           modelName: "Bedroom",           immersive: true,  initialPosition: SIMD3<Float>(0, 0, 0), realityScale: 0.001,  immersiveScale: 0.012),
                ModelInfo(imageName: "potions-store",     modelName: "Potions_Store",     immersive: true,  initialPosition: SIMD3<Float>(0, 0, 0), realityScale: 0.001,  immersiveScale: 0.025),
                ModelInfo(imageName: "convenience-store", modelName: "Convenience_Store", immersive: true,  initialPosition: SIMD3<Float>(0, 0, 0), realityScale: 0.001,  immersiveScale: 0.01),
                ModelInfo(imageName: "old-hotel",         modelName: "Old_Hotel",         immersive: true,  initialPosition: SIMD3<Float>(0, 0, 0), realityScale: 0.001,  immersiveScale: 0.035),
                ModelInfo(imageName: "mech-drone",        modelName: "Mech_Drone",        immersive: false, initialPosition: SIMD3<Float>(0, 0, 0), realityScale: 0.01,   immersiveScale: 0.1),
                ModelInfo(imageName: "buster-drone",      modelName: "Buster_Drone",      immersive: false, initialPosition: SIMD3<Float>(0, 0, 0), realityScale: 0.002,  immersiveScale: 0.1),
                ModelInfo(imageName: "solar-system",      modelName: "Planets",           immersive: true,  initialPosition: SIMD3<Float>(0, 0, 0), realityScale: 0.25,   immersiveScale: 1)
            ]
            
            // Update models array with both default and discovered models
            models = newModels + defaultModels
        } catch {
            print("Error reading uploads directory: \(error)")
        }
    }
}

// Setup Model View (Window and Immersive)
struct ModelItemView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    let model: ModelInfo

    // State variables for each button
    @State private var isWindowOpen = false
    @State private var isImmersiveOpen = false

    var body: some View {
        VStack() {
            Button {
                if model.immersive {
                    isImmersiveOpen.toggle()
                    Task {
                        if isImmersiveOpen {
                            await openImmersiveSpace(id: "ModelImmersiveView", value: model)
                            openWindow(id: "NavigationControl")
                        } else {
                            await dismissImmersiveSpace()
                            dismissWindow(id: "NavigationControl")
                        }
                    }
                }
            } label: {
                Image(model.imageName.isEmpty ? "ui" : model.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 275, height: 200)
                    .clipped()
                    .hoverEffect(.highlight)
            }
        
            // Use an overlay to place button over the image
            .overlay(alignment: .bottomTrailing) {
                Button {
                    isWindowOpen.toggle()
                    if isWindowOpen {
                        openWindow(id: "ModelRealityView", value: model)
                    } else {
                        dismissWindow(id: "ModelRealityView")
                    }
                } label: {
                    Label("", systemImage: "cube.fill")
                }
                .padding()
            }
        }
        .padding()
        
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.thinMaterial)
        )
         
    }
}

#Preview {
    ModelMenu()
}
