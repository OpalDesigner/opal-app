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

// Default Models array
let defaultModels = [
    ModelInfo(imageName: "coffee-shop",       modelName: "Coffee_Shop",       immersive: true,  initialPosition: SIMD3<Float>(0, 0, 0), realityScale: 0.1,  immersiveScale: 1),
    ModelInfo(imageName: "house-interior",    modelName: "House_Interior",    immersive: true,  initialPosition: SIMD3<Float>(0, 0, 0), realityScale: 0.03,  immersiveScale: 1),
    ModelInfo(imageName: "budapest-hotel",    modelName: "Budapest_Hotel",    immersive: true,  initialPosition: SIMD3<Float>(0, 0, 0), realityScale: 0.015, immersiveScale: 1),
    ModelInfo(imageName: "space-corridor",    modelName: "SpaceStation_Hall", immersive: true,  initialPosition: SIMD3<Float>(0, 0, 0), realityScale: 0.05,  immersiveScale: 1),
    ModelInfo(imageName: "classroom",         modelName: "Old_Classroom",     immersive: true,  initialPosition: SIMD3<Float>(0, 0, 0), realityScale: 0.05,  immersiveScale: 1),
    ModelInfo(imageName: "bedroom",           modelName: "Bedroom",           immersive: true,  initialPosition: SIMD3<Float>(0, 0, 0), realityScale: 0.1,  immersiveScale: 1),
    ModelInfo(imageName: "potions-store",     modelName: "Potions_Store",     immersive: true,  initialPosition: SIMD3<Float>(0, 0, 0), realityScale: 0.05,  immersiveScale: 1),
    ModelInfo(imageName: "convenience-store", modelName: "Convenience_Store", immersive: true,  initialPosition: SIMD3<Float>(0, 0, 0), realityScale: 0.1,  immersiveScale: 1),
    ModelInfo(imageName: "old-hotel",         modelName: "Old_Hotel",         immersive: true,  initialPosition: SIMD3<Float>(0, 0, 0), realityScale: 0.03,  immersiveScale: 1),
    ModelInfo(imageName: "mech-drone",        modelName: "Mech_Drone",        immersive: false, initialPosition: SIMD3<Float>(0, 0, 0), realityScale: 0.01,   immersiveScale: 1),
    ModelInfo(imageName: "buster-drone",      modelName: "Buster_Drone",      immersive: false, initialPosition: SIMD3<Float>(0, 0, 0), realityScale: 0.002,  immersiveScale: 1),
    ModelInfo(imageName: "solar-system",      modelName: "Planets",           immersive: true,  initialPosition: SIMD3<Float>(0, 0, 0), realityScale: 0.25,   immersiveScale: 1)
]

// Setup Grid View
struct ModelMenu: View {
    // Timer for polling
    //let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    // State Variables
    @State private var models: [ModelInfo] = []  // Convert from constant to state
    
    // Helper Functions
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
                let baseName = url.deletingPathExtension().lastPathComponent
                let imageExtensions = ["jpg", "png", "jpeg"]
                let matchingImage = imageExtensions.compactMap { ext -> String? in
                    let imagePath = uploadsPath.appendingPathComponent("\(baseName).\(ext)")
                    return fileManager.fileExists(atPath: imagePath.path) ? "\(baseName).\(ext)" : nil
                }.first ?? ""
                
                return ModelInfo(
                    imageName: matchingImage,                                   // Default empty image
                    modelName: baseName,
                    immersive: true,                                            // Default to non-immersive
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    realityScale: 0.03,                                         // Default scale
                    immersiveScale: 1                                           // Default immersive scale
                )
            }
            print("New models discovered:", newModels.map { $0.modelName })
            print("Full directory path:", uploadsPath.path)
            
            // Update models array with both default and discovered models
            models = newModels + defaultModels
        } catch {
            print("Error reading uploads directory: \(error)")
        }
    }
    
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
        /*
        .onReceive(timer) { _ in
            print("Checking for new model files...")
            updateModels()
        }
         */
    }
}

// Setup Model View (Window and Immersive)
struct ModelItemView: View {
    // Function parameters
    let model: ModelInfo
    
    // Environment variables
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    // State variables for each button
    @State private var isWindowOpen = false
    @State private var isImmersiveOpen = false
    
    // Helper Functions
    private func loadImage(named imageName: String) -> Image {
        if imageName.contains("."),
           let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
           let uiImage = UIImage(contentsOfFile: documentsPath.appendingPathComponent("uploads/\(imageName)").path) {
            return Image(uiImage: uiImage)
        }
        return Image(imageName.isEmpty ? "ui" : imageName)
    }

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
                loadImage(named: model.imageName)
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
