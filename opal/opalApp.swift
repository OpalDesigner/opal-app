//
//  opalApp.swift
//  opal
//
//  Created by Vik Parth on 10/24/24.
//

import SwiftUI
import AWSS3
import CompositorServices
import RealityKitContent

class TabSelection: ObservableObject {
    @Published var selectedTab = 0
}

@main
struct opalApp: App {
    // Shared variables
    @StateObject var navigationData = NavigationData()      // NavigationControl.swift
    @StateObject var tabSelection = TabSelection()

    // Private variables
    @State private var s3Files: [String] = []
    @State private var fetchTimer: Timer?
    
    init() {
        // Packages/RealityKitContent/Sources/RealityKitContent/PointOfInterestComponent.swift
        PointOfInterestComponent.registerComponent()
    }

    var body: some Scene {
        // ----------------- DEFINE WINDOW SPACES ---------------
        // WINDOW - MENU
        WindowGroup(id: "Menu") {
            createMainMenu()
        }
        .defaultSize(CGSize(width: 1000, height: 880))
        .defaultWindowPlacement { content, context in
            let size = content.sizeThatFits(.unspecified)
            let navigationWindow = context.windows.first { window in
                window.id == "NavigationControl"
            }
            if let navigationWindow {
                return WindowPlacement(.trailing(navigationWindow), size: size)
            }
            return WindowPlacement(size: size)
        }
        
        // WINDOW - NAVIGATION CONTROL VIEW
        WindowGroup(id: "NavigationControl") {
            // NavigationControl.swift
            NavigationControl(navigationData: navigationData, tabSelection: tabSelection)
        }
        .defaultWindowPlacement{content, context in
            return WindowPlacement(.utilityPanel)
        }
        .defaultSize(CGSize(width: 300, height: 350))
        
        // WINDOW - MODEL TABLETOP VIEW
        WindowGroup(id: "ModelRealityView", for: ModelInfo.self) { modelInfo in
            if let modelInfo = modelInfo.wrappedValue {
                // TabletopModelView.swift
                TabletopModelView(
                    modelName: modelInfo.modelName
                )
                .handlesExternalEvents(
                    preferring: ["com.example.explore-together.activity"],
                    allowing: ["com.example.explore-together.activity"]
                )
            } else {
                Text("No model information available")
            }
        }
        .volumeWorldAlignment(.gravityAligned)
        .windowStyle(.volumetric)
        .defaultSize(width: 0.75, height: 0.75, depth: 0.75, in: .meters)
        .defaultWindowPlacement { content, context in
            let size = content.sizeThatFits(.unspecified)
            let mainWindow = context.windows.first { window in
                window.id == "Menu"
            }
            let navigationWindow = context.windows.first { window in
                window.id == "NavigationControl"
            }
            // Check if both windows exist
            if let mainWindow, let navigationWindow {
                return WindowPlacement(.leading(navigationWindow), size: size)
            } else if let mainWindow {
                // If only main window exists, place trailing to it
                return WindowPlacement(.trailing(mainWindow), size: size)
            }
            return WindowPlacement(size: size)
        }
        
        // ----------------- DEFINE IMMERSIVE SPACES ---------------
        // IMMERSIVE - MODEL IMMERSIVE VIEW
        ImmersiveSpace(id: "ModelImmersiveView", for: ModelInfo.self) { modelInfo in
            if let modelInfo = modelInfo.wrappedValue {
                // ImmersiveModelView.swift
                ImmersiveModelView(
                    navigationData: navigationData,
                    modelName: modelInfo.modelName
                )
            } else {
                Text("No model information available")
            }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
        
        // IMMERSIVE - SPLAT VIEW
        ImmersiveSpace(id: "GaussianSplatView", for: URL.self) { url in
            // ContentStageConfiguration.swift, VisionSceneRenderer.swift
            CompositorLayer(configuration: ContentStageConfiguration()) { layerRenderer in
                let renderer = VisionSceneRenderer(layerRenderer, navigationData: navigationData)
                Task {
                    do {
                        try await renderer.load(url.wrappedValue)
                    } catch {
                        print("Error loading model: \(error.localizedDescription)")
                    }
                    renderer.startRenderLoop()
                }
            }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        
        // IMMERSIVE - HAND INTERACTION
        ImmersiveSpace(id: "HandTrackingView"){
            // HandTrackingView.swift
            HandTrackingView()
        }
        
        // IMMERSIVE - BUBBLE ANIMATION
        ImmersiveSpace(id: "BubbleView") {
            // BubbleView.swift
            BubbleView()
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
    
    private func createMainMenu() -> some View {
        TabView (selection: $tabSelection.selectedTab) {
            // HomeMenu.swift
            HomeMenu().tabItem {
                Label("About", systemImage: "building.2.fill")
            }
            .tag(0)
            // CatalogMenu.swift
            CatalogMenu(defaultModels: defaultModels).tabItem {
                Label("Build", systemImage: "hammer.fill")
            }
            .tag(1)
            // PluginMenu.swift
            PluginMenu().tabItem {
                Label("Import", systemImage: "square.and.arrow.down")
            }
            .tag(2)
            /*
             // TeamMenu.swift
             TeamMenu().tabItem {
             Label("Team", systemImage: "person")
             }
             .tag(3)
             */
        }
        .environmentObject(navigationData)
        .toolbar {
            ToolbarItem(placement: .bottomOrnament) {
                Button {
                    Task {
                        // function located in SharePlayControl.swift
                        await startSharePlay()
                    }
                } label: {
                    Label("Collaborate", systemImage: "person.3.fill")
                        .labelStyle(.titleAndIcon)
                }
            }
        }
        .task{
            // function located in  SharePlayControl.swift
            await configureGroupSession()
        }
        /*
         .task {
         print("Fetching S3 files...")
         await fetchS3Files()
         }
         */
    }
    
    private func fetchS3Files() async {
        print("\nDownloading S3 files to: \(getDocumentsDirectory().path)\n")
        do {
            let s3Client = try S3Client(region: "us-east-1")
            let output = try await s3Client.listObjectsV2(input: ListObjectsV2Input(bucket: "opal-designer"))
            if let objects = output.contents {
                for object in objects {
                    guard let key = object.key else { continue }
                    let localURL = getDocumentsDirectory().appendingPathComponent(key)
                    try? FileManager.default.createDirectory(at: localURL.deletingLastPathComponent(),
                                                          withIntermediateDirectories: true)
                    if let data = try await s3Client.getObject(input: GetObjectInput(bucket: "opal-designer", key: key)).body?.readData() {
                        try data.write(to: localURL)
                        print("Downloaded: \(key) to \(localURL.path)")
                    }
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
