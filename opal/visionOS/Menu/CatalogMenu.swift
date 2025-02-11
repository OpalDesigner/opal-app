//
//  CatalogMenu.swift
//  opal
//
//  Created by Vik Parth on 12/31/24.
//

import SwiftUI

enum ModelCategory: String, CaseIterable {
    case scenes     =   "Scenes"
    case scans      =   "Scans"
    case decor      =   "Decor"
    //case rocks      =   "Rocks"
    case anatomy    =   "Anatomy"
}

struct ModelInfo: Identifiable, Codable, Hashable {
    let id = UUID()
    let modelName: String
    let imageName: String
    let isImmersive: Bool
}

// Default Models array
let defaultModels = [
    ModelInfo(modelName: "Holodeck",          imageName: "holodeck",            isImmersive: true   ),
    ModelInfo(modelName: "Operating_Room",    imageName: "operating-room",      isImmersive: true   ),
    ModelInfo(modelName: "Old_Hotel",         imageName: "old-hotel",           isImmersive: true   ),
    ModelInfo(modelName: "SpaceStation_Hall", imageName: "space-corridor",      isImmersive: true   ),
    ModelInfo(modelName: "Old_Classroom",     imageName: "classroom",           isImmersive: true   ),
    ModelInfo(modelName: "Coffee_Shop",       imageName: "coffee-shop",         isImmersive: true   ),
    ModelInfo(modelName: "Convenience_Store", imageName: "convenience-store",   isImmersive: true   ),
    ModelInfo(modelName: "Planets",           imageName: "solar-system",        isImmersive: true   ),
    ModelInfo(modelName: "Bedroom",           imageName: "bedroom",             isImmersive: true   ),
    ModelInfo(modelName: "Potions_Store",     imageName: "potions-store",       isImmersive: true   ),
    ModelInfo(modelName: "Budapest_Hotel",    imageName: "budapest-hotel",      isImmersive: true   ),
    ModelInfo(modelName: "House_Interior",    imageName: "house-interior",      isImmersive: true   ),
    ModelInfo(modelName: "Mech_Drone",        imageName: "mech-drone",          isImmersive: false  ),
    ModelInfo(modelName: "Buster_Drone",      imageName: "buster-drone",        isImmersive: false  )
]

struct CatalogMenu: View {
    let defaultModels: [ModelInfo]
    
    @State private var selectedCategory: ModelCategory = .scenes
    @State private var modelFiles: [ModelInfo] = []
    
    private func updateModels() {
        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        // Create category directories if they don't exist
        ModelCategory.allCases.forEach { category in
            let categoryPath = documentsPath.appendingPathComponent(category.rawValue.lowercased())
            if !fileManager.fileExists(atPath: categoryPath.path) {
                try? fileManager.createDirectory(at: categoryPath, withIntermediateDirectories: true)
            }
        }
        
        // Load models from selected category
        let categoryPath = documentsPath.appendingPathComponent(selectedCategory.rawValue.lowercased())
        print("\nCurrently loading from: \(categoryPath.path)")
        do {
            let files = try fileManager.contentsOfDirectory(at: categoryPath, includingPropertiesForKeys: nil)
            let usdzFiles = files.filter { $0.pathExtension.lowercased() == "usdz" }
            let localModels = usdzFiles.compactMap { url in
                let baseName = url.deletingPathExtension().lastPathComponent
                let imageExtensions = ["jpg", "png", "jpeg"]
                let matchingImage = imageExtensions.compactMap { ext -> String? in
                    let imagePath = categoryPath.appendingPathComponent("\(baseName).\(ext)")
                    return fileManager.fileExists(atPath: imagePath.path) ? "\(baseName).\(ext)" : nil
                }.first ?? ""
                return ModelInfo(
                    modelName: baseName,
                    imageName: matchingImage,
                    isImmersive: true
                )
            }
            
            // Combine default models with local models for Scenes category
            if selectedCategory == .scenes {
                modelFiles = localModels + defaultModels
            } else {
                modelFiles = localModels
            }
            
            // Debug print statements
            print("Found \(modelFiles.count) models:")
            modelFiles.forEach { model in
                print("- Model: \(model.modelName), Image: \(model.imageName)")
            }
        } catch {
            print("Error reading directory: \(error)")
        }
    }
    
    var body: some View {
        VStack {
            // Category Picker Menu
            Picker("Category", selection: $selectedCategory) {
                ForEach(ModelCategory.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .onChange(of: selectedCategory) { _ in
                updateModels()
            }
            // Model Grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 250))
                ], spacing: 20) {
                    ForEach(modelFiles) { model in
                        CatalogItemView(
                            model: model,
                            category: selectedCategory
                        )
                    }
                }
                .padding()
            }
        }
        .onAppear {
            updateModels()
        }
        .background {
            Image("interior-shot-03")
        }
    }
}

struct CatalogItemView: View {
    let model: ModelInfo
    let category: ModelCategory
    
    @EnvironmentObject var navigationData: NavigationData
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    @State private var isWindowOpen = false
    @State private var isImmersiveOpen = false
    
    private func loadImage() -> Image {
        // Load image from asset catalog
        if let uiImage = UIImage(named: model.imageName) {
            return Image(uiImage: uiImage)
        }
        // If not in image catalog, load from documents directory
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
           let uiImage = UIImage(contentsOfFile: documentsPath.appendingPathComponent("\(category.rawValue.lowercased())/\(model.imageName)").path) {
            return Image(uiImage: uiImage)
        }
        // Fallback to system icon if image not found
        return Image(systemName: "photo")
    }
    
    var body: some View {
        VStack {
            Button {
                if (!(category == .scenes || category == .scans) || !model.isImmersive) {
                    return
                }
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
            } label: {
                loadImage()
                    .resizable()
                    .scaledToFill()
                    .frame(width: 275, height: 200)
                    .clipped()
                    .hoverEffect(.highlight)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                if(category == .decor || category == .anatomy){
                    navigationData.modelToPlace = (model: model, category: category)
                }
                isWindowOpen.toggle()
                if isWindowOpen {
                    openWindow(id: "ModelRealityView", value: model)
                } else {
                    dismissWindow(id: "ModelRealityView")
                }
            } label: {
                Label("", systemImage: "cube.fill")
                /*
                Text(model.modelName)
                    .font(.headline)
                    .padding()
                 */
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.thinMaterial)
        )
    }
}

#Preview {
    CatalogMenu(defaultModels: [])
}
