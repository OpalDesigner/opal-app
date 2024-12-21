import SwiftUI
import CompositorServices
import Foundation

enum ModelIdentifier: Equatable, Hashable, Codable, CustomStringConvertible {
    case gaussianSplat(URL)
    case sampleBox

    var description: String {
        switch self {
        case .gaussianSplat(let url):
            "Gaussian Splat: \(url.path)"
        case .sampleBox:
            "Sample Box"
        }
    }
}


@main
struct SampleApp: App {
    var body: some Scene {
        WindowGroup("MetalSplatter Sample App", id: "main") {
            ContentView()
        }
        .defaultSize(CGSize(width: 300, height: 400))
        
        ImmersiveSpace(for: ModelIdentifier.self) { modelIdentifier in
            CompositorLayer(configuration: ContentStageConfiguration()) { layerRenderer in
                let renderer = VisionSceneRenderer(layerRenderer)
                Task {
                    do {
                        try await renderer.load(modelIdentifier.wrappedValue)
                    } catch {
                        print("Error loading model: \(error.localizedDescription)")
                    }
                    renderer.startRenderLoop()
                }
            }
        }
        //.mixed or .full
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}

