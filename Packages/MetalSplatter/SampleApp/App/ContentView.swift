import SwiftUI
import RealityKit
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    @State private var isPickingFile = false
    @State var immersiveSpaceIsShown = false
    
    @ViewBuilder
    var body: some View {
        VStack {
            Text("MetalSplatter SampleApp")

            Button("Load .PLY or .SPLAT file)") {
                isPickingFile = true
            }
            .padding()
            .buttonStyle(.borderedProminent)
            .disabled(isPickingFile)
            .disabled(immersiveSpaceIsShown)
            .fileImporter(isPresented: $isPickingFile, allowedContentTypes: [UTType(filenameExtension: "ply")!, UTType(filenameExtension: "splat")!]) { result in
                isPickingFile = false
                if let url = try? result.get() {
                    _ = url.startAccessingSecurityScopedResource()
                    Task {
                        try await Task.sleep(for: .seconds(10))
                        url.stopAccessingSecurityScopedResource()
                    }
                    Task {
                        await openImmersiveSpace(value: ModelIdentifier.gaussianSplat(url))
                        immersiveSpaceIsShown = true
                    }
                }
            }

            Button("Show Sample Box") {
                Task {
                    await openImmersiveSpace(value: ModelIdentifier.sampleBox)
                    immersiveSpaceIsShown = true
                }
            }
            .padding()
            .buttonStyle(.borderedProminent)
            .disabled(immersiveSpaceIsShown)

            Button("Dismiss Immersive Space") {
                Task {
                    await dismissImmersiveSpace()
                    immersiveSpaceIsShown = false
                }
            }
            .padding()
            .buttonStyle(.borderedProminent)
            .disabled(!immersiveSpaceIsShown)
        }
    }
}
