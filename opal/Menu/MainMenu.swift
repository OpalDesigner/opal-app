//
//  MainMenu.swift
//  opal
//
//  Created by Vik Parth on 12/16/24.
//

import SwiftUI
import UniformTypeIdentifiers

// Configuration for different menu types
struct MenuConfiguration {
    let directoryName: String
    let isImmersive: Bool
    let realityScale: Float
    
    static let model = MenuConfiguration(
        directoryName: "uploads",
        isImmersive: true,
        realityScale: 0.03
    )
    
    static let build = MenuConfiguration(
        directoryName: "decor",
        isImmersive: false,
        realityScale: 0.3
    )
    
    static let scan = MenuConfiguration(
        directoryName: "scans",
        isImmersive: true,
        realityScale: 0.05
    )
}

// Unified ModelInfo struct remains the same
struct ModelInfo: Identifiable, Codable, Hashable {
    let id = UUID()
    let imageName: String
    let modelName: String
    let isImmersive: Bool
    let realityScale: Float
}

// Default Models array
let defaultModels = [
    ModelInfo(imageName: "coffee-shop",       modelName: "Coffee_Shop",       isImmersive: true,  realityScale: 0.1    ),
    ModelInfo(imageName: "house-interior",    modelName: "House_Interior",    isImmersive: true,  realityScale: 0.03   ),
    ModelInfo(imageName: "budapest-hotel",    modelName: "Budapest_Hotel",    isImmersive: true,  realityScale: 0.015  ),
    ModelInfo(imageName: "space-corridor",    modelName: "SpaceStation_Hall", isImmersive: true,  realityScale: 0.03   ),
    ModelInfo(imageName: "classroom",         modelName: "Old_Classroom",     isImmersive: true,  realityScale: 0.05   ),
    ModelInfo(imageName: "bedroom",           modelName: "Bedroom",           isImmersive: true,  realityScale: 0.1    ),
    ModelInfo(imageName: "potions-store",     modelName: "Potions_Store",     isImmersive: true,  realityScale: 0.05   ),
    ModelInfo(imageName: "convenience-store", modelName: "Convenience_Store", isImmersive: true,  realityScale: 0.1    ),
    ModelInfo(imageName: "old-hotel",         modelName: "Old_Hotel",         isImmersive: true,  realityScale: 0.03   ),
    ModelInfo(imageName: "mech-drone",        modelName: "Mech_Drone",        isImmersive: false, realityScale: 0.01   ),
    ModelInfo(imageName: "buster-drone",      modelName: "Buster_Drone",      isImmersive: false, realityScale: 0.002  ),
    ModelInfo(imageName: "solar-system",      modelName: "Planets",           isImmersive: true,  realityScale: 0.25   )
]

// Example usage for different menus
struct ModelMenu: View {
    var body: some View {
        MainMenu(configuration: .model, defaultModels: defaultModels)
    }
}

struct BuildMenu: View {
    var body: some View {
        MainMenu(configuration: .build, defaultModels: [])
    }
}

struct ScanMenu: View {
    var body: some View {
        MainMenu(configuration: .scan, defaultModels: [])
    }
}

// Unified Menu View
struct MainMenu: View {
    // Function parameters
    let configuration: MenuConfiguration
    let defaultModels: [ModelInfo]
    
    // State variables
    @State private var models: [ModelInfo] = []
    @State private var isPickingFile: Bool = false
    
    // Helper functions
    private func updateModels() {
        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let uploadsPath = documentsPath.appendingPathComponent(configuration.directoryName)
        if !fileManager.fileExists(atPath: uploadsPath.path) {
            do {
                try fileManager.createDirectory(at: uploadsPath, withIntermediateDirectories: true)
            } catch {
                print("Error creating directory: \(error)")
                return
            }
        }
        
        do {
            let files = try fileManager.contentsOfDirectory(at: uploadsPath, includingPropertiesForKeys: nil)
            let usdzFiles = files.filter { $0.pathExtension.lowercased() == "usdz" }
            
            let newModels = usdzFiles.map { url in
                let baseName = url.deletingPathExtension().lastPathComponent
                let imageExtensions = ["jpg", "png", "jpeg"]
                let matchingImage = imageExtensions.compactMap { ext -> String? in
                    let imagePath = uploadsPath.appendingPathComponent("\(baseName).\(ext)")
                    return fileManager.fileExists(atPath: imagePath.path) ? "\(baseName).\(ext)" : nil
                }.first ?? ""
                
                return ModelInfo(
                    imageName: matchingImage,
                    modelName: baseName,
                    isImmersive: configuration.isImmersive,
                    realityScale: configuration.realityScale
                )
            }
            models = newModels + defaultModels
            print("New Models found:    \(newModels.map { $0.modelName })")
            print("Uploads directory:   \(uploadsPath.path)")
        } catch {
            print("Error reading directory: \(error)")
        }
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(models, id: \.id) { model in
                        ModelItemView(model: model, directoryName: configuration.directoryName)
                    }
                }
                .padding(20)
            }
            
            Button {
                isPickingFile.toggle()
            } label: {
                Label("", systemImage: "plus.circle.fill")
            }
            .padding(.top, 20)
            .padding(.trailing, 20)
            .disabled(isPickingFile)
            .fileImporter(isPresented: $isPickingFile, allowedContentTypes: [.usdz]) { result in
                isPickingFile = false
                if let url = try? result.get() {
                    let fileManager = FileManager.default
                        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
                        let uploadsPath = documentsPath?.appendingPathComponent(configuration.directoryName)
                        
                        do {
                            try fileManager.moveItem(at: url, to: uploadsPath!.appendingPathComponent(url.lastPathComponent))
                            print("File moved to uploads directory: \(uploadsPath!.appendingPathComponent(url.lastPathComponent).path)")
                            
                            // Call updateModels() to refresh the grid
                            updateModels()
                        } catch {
                            print("Error moving file: \(error)")
                        }
                }
            }
        }
        .background {
            Image("interior-shot-03")
        }
        .onAppear {
            updateModels()
        }
    }
}

// Model Item View
struct ModelItemView: View {
    let model: ModelInfo
    let directoryName: String
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    @State private var isWindowOpen = false
    @State private var isImmersiveOpen = false
    
    private func loadImage(named imageName: String) -> Image {
        if imageName.contains("."),
           let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
           let uiImage = UIImage(contentsOfFile: documentsPath.appendingPathComponent("\(directoryName)/\(imageName)").path) {
            return Image(uiImage: uiImage)
        }
        return Image(imageName.isEmpty ? "ui" : imageName)
    }
    
    var body: some View {
        VStack {
            Button {
                if model.isImmersive {
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
    MainMenu(
        configuration: .model,
        defaultModels: defaultModels
    )
}
