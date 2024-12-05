//
//  opalApp.swift
//  opal
//
//  Created by Vik Parth on 10/24/24.
//

import SwiftUI
import AWSS3

@main
struct opalApp: App {
    // Access shared data in NavigationControlUI.swift
    @StateObject var navigationData = NavigationData()
    @State private var s3Files: [String] = []
    
    var realityViews: [String] = [
        "Sewage",
        "Coffee_Shop",
        "House_Interior",
        "Budapest_Hotel",
        "SpaceStation_Hall",
        "Old_Classroom",
        "Bedroom",
        "Potions_Store",
        "Convenience_Store",
        "Old_Hotel",
        "Mech_Drone",
        "Buster_Drone"
    ]

    var immersiveViews: [String] = [
        "CoffeeShop",
        "HouseInterior",
        "BudapestHotel",
        "SpaceStation",
        "Classroom",
        "Bedroom",
        "PotionsStore",
        "ConvenienceStore",
        "OldHotel",
        "Planets"
    ]

    private func createMainMenu() -> some View {
        TabView {
            ModelArea().tabItem {
                Label("Home", systemImage: "house.fill")
            }
            PluginArea().tabItem {
                Label("Import", systemImage: "square.and.arrow.down")
            }
            HomeArea().tabItem {
                Label("About", systemImage: "building.2.fill")
            }
            TeamArea().tabItem {
                Label("Team", systemImage: "person")
            }
        }
        .task {
            await fetchS3Files()
        }
    }

    var body: some Scene {
        // MAIN SCENE
        WindowGroup(id: "Menu") {
            createMainMenu()
        }
        .defaultSize(CGSize(width: 1000, height: 880))
        
        // NAVIGATION CONTROL
        WindowGroup(id: "NavigationControl") {
            NavigationControl(navigationData: navigationData)
        }
        .defaultWindowPlacement{content, context in
            return WindowPlacement(.utilityPanel)
        }
        .defaultSize(CGSize(width: 300, height: 350))
        
        // HAND INTERACTION
        ImmersiveSpace(id: "HandInteractionView"){
            HandInteractionView()
        }
        
        // BUBBLE ANIMATION 
        ImmersiveSpace(id: "BubbleView") {
            BubbleView()
        }
        .immersionStyle(selection: .constant(.full), in: .full)
        
        // 3D MODEL SETS - WINDOW VIEWS
        WindowGroup(id: "ModelRealityView", for: ModelInfo.self) { modelInfo in
            if let modelInfo = modelInfo.wrappedValue {
                ModelRealityView(modelInfo: modelInfo)
            } else {
                Text("No model information available")
            }
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.5, height: 1, depth: 1, in: .meters)
        .defaultWindowPlacement{content, context in
            let size = content.sizeThatFits(.unspecified)
            let mainWindow = context.windows.first { window in
                window.id == "Menu"
            }
            if let mainWindow{
                return WindowPlacement(.trailing(mainWindow), size: size)
            }
            return WindowPlacement(size: size)
        }
        
        // 3D MODEL SETS - IMMERSIVE VIEWS
        Group {
            ImmersiveSpace(id: "ModelImmersiveView", for: ModelInfo.self) { modelInfo in
                if let modelInfo = modelInfo.wrappedValue {
                    ImmersiveModelView(
                        navigationData: navigationData,
                        modelName: modelInfo.modelName,
                        initialPosition: modelInfo.initialPosition,
                        initialScale: modelInfo.immersiveScale)
                } else {
                    Text("No model information available")
                }
            }
        }.immersionStyle(selection: .constant(.full), in: .full)
    }
    
    private func fetchS3Files() async {
        do {
            let s3Client = try S3Client(region: "us-east-1")
            let input = ListObjectsV2Input(bucket: "opal-designer")
            let output = try await s3Client.listObjectsV2(input: input)
            
            if let contents = output.contents {
                let fileNames = contents.compactMap { $0.key }
                    .filter { $0.lowercased().hasSuffix(".usdz") }
                
                // Download each file
                for fileName in fileNames {
                    let getObjectInput = GetObjectInput(
                        bucket: "opal-designer",
                        key: fileName
                    )
                    print("Downloading file: \(fileName)")
                    let getObjectOutput = try await s3Client.getObject(input: getObjectInput)
                    if let body = getObjectOutput.body {
                        if let data = try await body.readData() {
                            // Create local file URL
                            let localURL = getDocumentsDirectory().appendingPathComponent(fileName)
                            
                            // Write file to disk
                            try data.write(to: localURL)
                            print("Successfully saved file to:", localURL.path)
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.s3Files = fileNames
                }
            }
        } catch {
            print("Error handling S3 files:", error)
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

struct ModelRealityView: View {
    @State private var modelName: String
    @State private var initialPosition: SIMD3<Float>
    @State private var initialScale: Float

    init(modelInfo: ModelInfo) {
        _modelName = State(initialValue: modelInfo.modelName)
        _initialPosition = State(initialValue: modelInfo.initialPosition)
        _initialScale = State(initialValue: modelInfo.realityScale)
    }

    var body: some View {
        RealityModelView(
            modelName: modelName,
            initialPosition: initialPosition,
            initialScale: initialScale
        )
    }
}
