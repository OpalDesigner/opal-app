//
//  ModelArea.swift
//  TestApp
//
//  Created by Vik Parth on 9/27/24.
//

import SwiftUI
import AWSS3

// Struct to hold Model info
struct ModelInfo: Identifiable {
    let id = UUID()
    let imageName: String
    let windowID: String
    let immersiveID: String
}

// Setup Grid View
struct ModelArea: View {
    // Add state for S3 files
    @State private var s3Files: [String] = []
    
    let models = [
        ModelInfo(imageName: "coffee-shop",       windowID: "CoffeeShopRealityView",      immersiveID: "CoffeeShopImmersiveView"       ),
        ModelInfo(imageName: "house-interior",    windowID: "HouseInteriorRealityView",   immersiveID: "HouseInteriorImmersiveView"    ),
        ModelInfo(imageName: "budapest-hotel",    windowID: "BudapestHotelRealityView",   immersiveID: "BudapestHotelImmersiveView"    ),
        ModelInfo(imageName: "space-corridor",    windowID: "SpaceStationRealityView",    immersiveID: "SpaceStationImmersiveView"     ),
        ModelInfo(imageName: "classroom",         windowID: "ClassroomRealityView",       immersiveID: "ClassroomImmersiveView"        ),
        ModelInfo(imageName: "bedroom",           windowID: "BedroomRealityView",         immersiveID: "BedroomImmersiveView"          ),
        ModelInfo(imageName: "potions-store",     windowID: "PotionsStoreRealityView",    immersiveID: "PotionsStoreImmersiveView"     ),
        ModelInfo(imageName: "convenience-store", windowID: "ConvenienceStoreRealityView",immersiveID: "ConvenienceStoreImmersiveView" ),
        ModelInfo(imageName: "old-hotel",         windowID: "OldHotelRealityView",        immersiveID: "OldHotelImmersiveView"         ),
        ModelInfo(imageName: "mech-drone",        windowID: "MechDroneRealityView",       immersiveID: ""                              ),
        ModelInfo(imageName: "buster-drone",      windowID: "BusterDroneRealityView",     immersiveID: ""                              ),
        ModelInfo(imageName: "solar-system",      windowID: "SolarSystemRealityView",     immersiveID: "SolarSystemImmersiveView"      )
    ]
    
    // Add function to get local document directory
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // Update fetchS3Files to download files
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

    var body: some View {
        // Add ScrollView for scrollability
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()), // Each column takes up equal width
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                ForEach(models, id: \.windowID) { model in
                    ModelItemView(model: model)
                }
            }
            .padding(20) // Add padding around the grid
        }
        .background {
            Image("interior-shot-03")
        }
        .task {
            // Fetch S3 files when view appears
            await fetchS3Files()
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
                if model.immersiveID != "" {
                    isImmersiveOpen.toggle()
                    Task {
                        if isImmersiveOpen {
                            await openImmersiveSpace(id: model.immersiveID)
                            openWindow(id: "NavigationControl")
                        } else {
                            await dismissImmersiveSpace()
                            dismissWindow(id: "NavigationControl")
                        }
                    }
                }
            } label: {
                Image(model.imageName)
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
                        openWindow(id: model.windowID)
                    } else {
                        dismissWindow(id: model.windowID)
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
    ModelArea()
}
