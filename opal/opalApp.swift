//
//  opalApp.swift
//  opal
//
//  Created by Vik Parth on 10/24/24.
//

import SwiftUI
import AWSS3

class TabSelection: ObservableObject {
    @Published var selectedTab = 0
}

@main
struct opalApp: App {
    // Shared variables
    @StateObject var navigationData = NavigationData()
    @StateObject var tabSelection = TabSelection()

    // Private variables
    @State private var s3Files: [String] = []
    @State private var fetchTimer: Timer?
    
    // Initialization Functions
    init() {
            setupAppDirectories()
        }
        
    // Helper Functions
    private func setupAppDirectories() {
        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        // Create all needed directories
        let directories = ["uploads", "decor", "scans"]
        
        for directory in directories {
            let directoryPath = documentsPath.appendingPathComponent(directory)
            if !fileManager.fileExists(atPath: directoryPath.path) {
                do {
                    try fileManager.createDirectory(at: directoryPath, withIntermediateDirectories: true)
                    print("Created directory: \(directory)")
                } catch {
                    print("Error creating \(directory) directory: \(error)")
                }
            }
        }
    }
    
    private func createMainMenu() -> some View {
        TabView (selection: $tabSelection.selectedTab) {
            HomeMenu().tabItem {
                Label("About", systemImage: "building.2.fill")
            }
            .tag(0)
            ModelMenu().tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(1)
            ScanMenu().tabItem {
                Label("Scans", systemImage: "scanner")
            }
            .tag(2)
            BuildMenu().tabItem {
                Label("Build", systemImage: "hammer.fill")
            }
            .tag(3)
            /*
            PluginMenu().tabItem {
                Label("Import", systemImage: "square.and.arrow.down")
            }
            */
            TeamMenu().tabItem {
                Label("Team", systemImage: "person")
            }
            .tag(4)
        }
        /*
        .task {
            print("Fetching S3 files...")
            await fetchS3Files()
            setupPeriodicFetch()
        }
         */
    }

    private func setupPeriodicFetch() {
        fetchTimer?.invalidate()
        
        fetchTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            Task {
                print("Fetching S3 files...")
                await fetchS3Files()
            }
        }
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

    var body: some Scene {
        // MAIN SCENE
        WindowGroup(id: "Menu") {
            createMainMenu()
        }
        .defaultSize(CGSize(width: 1000, height: 880))
        
        // NAVIGATION CONTROL
        WindowGroup(id: "NavigationControl") {
            NavigationControl(navigationData: navigationData, tabSelection: tabSelection)
        }
        .defaultWindowPlacement{content, context in
            return WindowPlacement(.utilityPanel)
        }
        .defaultSize(CGSize(width: 300, height: 350))
        
        // BUILDER
        WindowGroup(id: "BuilderView") {
            TabletopModelView(
                modelName: "Mech_Drone",  // Replace with your model name
                initialScale: 0.01
            )
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.5, height: 1, depth: 1, in: .meters)
        /*
        .defaultWindowPlacement{content, context in
            return WindowPlacement(.trailing(<#T##relativeWindow: WindowProxy##WindowProxy#>))
        }
         */
        
        // HAND INTERACTION
        ImmersiveSpace(id: "HandTrackingView"){
            HandTrackingView()
        }
        
        // BUBBLE ANIMATION 
        ImmersiveSpace(id: "BubbleView") {
            BubbleView()
        }
        .immersionStyle(selection: .constant(.full), in: .full)
        
        // TABLETOP VIEWS
        WindowGroup(id: "ModelRealityView", for: ModelInfo.self) { modelInfo in
            if let modelInfo = modelInfo.wrappedValue {
                TabletopModelView(
                    modelName: modelInfo.modelName,
                    initialScale: modelInfo.realityScale
                )
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
        
        // IMMERSIVE VIEWS
        Group {
            ImmersiveSpace(id: "ModelImmersiveView", for: ModelInfo.self) { modelInfo in
                if let modelInfo = modelInfo.wrappedValue {
                    ImmersiveModelView(
                        navigationData: navigationData,
                        modelName: modelInfo.modelName
                    )
                } else {
                    Text("No model information available")
                }
            }
        }.immersionStyle(selection: .constant(.full), in: .full)
    }
}
