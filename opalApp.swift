import SwiftUI
#if os(visionOS)
import CompositorServices
import RealityKitContent
#endif
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
    
    init() {
        #if os(visionOS)
        PointOfInterestComponent.registerComponent()
        #endif
    }

    var body: some Scene {
        #if os(iOS)
        // iOS version
        WindowGroup {
            createMainMenu()
        }
        #else
        // visionOS version - all existing window definitions
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
            NavigationControl(navigationData: navigationData, tabSelection: tabSelection)
        }
        .defaultWindowPlacement{content, context in
            return WindowPlacement(.utilityPanel)
        }
        .defaultSize(CGSize(width: 300, height: 350))
        
        // WINDOW - MODEL TABLETOP VIEW
        WindowGroup(id: "ModelRealityView", for: ModelInfo.self) { modelInfo in
            if let modelInfo = modelInfo.wrappedValue {
                TabletopModelView(
                    modelName: modelInfo.modelName
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
            if let mainWindow, let navigationWindow {
                return WindowPlacement(.leading(navigationWindow), size: size)
            } else if let mainWindow {
                return WindowPlacement(.trailing(mainWindow), size: size)
            }
            return WindowPlacement(size: size)
        }
        
        // All immersive spaces
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
        .immersionStyle(selection: .constant(.full), in: .full)
        
        ImmersiveSpace(id: "GaussianSplatView", for: URL.self) { url in
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
        
        ImmersiveSpace(id: "HandTrackingView"){
            HandTrackingView()
        }
        
        ImmersiveSpace(id: "BubbleView") {
            BubbleView()
        }
        .immersionStyle(selection: .constant(.full), in: .full)
        #endif
    }
    
    private func createMainMenu() -> some View {
        TabView (selection: $tabSelection.selectedTab) {
            HomeMenu().tabItem {
                Label("About", systemImage: "building.2.fill")
            }
            .tag(0)
            CatalogMenu(defaultModels: defaultModels).tabItem {
                Label("Build", systemImage: "hammer.fill")
            }
            .tag(1)
            PluginMenu().tabItem {
                Label("Import", systemImage: "square.and.arrow.down")
            }
            .tag(2)
            TeamMenu().tabItem {
                Label("Team", systemImage: "person")
            }
            .tag(3)
        }
        .environmentObject(navigationData)
    }
    
    // ... rest of your existing code ...
} 