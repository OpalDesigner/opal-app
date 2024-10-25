//
//  ModelArea.swift
//  TestApp
//
//  Created by Vik Parth on 9/27/24.
//

import SwiftUI

// Struct to hold Model info
struct ModelInfo: Identifiable {
    let id = UUID()
    let imageName: String
    let windowID: String
    let immersiveID: String
}

// Setup Grid View
struct ModelArea: View {
    let models = [
        ModelInfo(imageName: "coffee-shop", windowID: "CoffeeShopRealityView", immersiveID: "CoffeeShopImmersiveView"),
        ModelInfo(imageName: "house-interior", windowID: "HouseInteriorRealityView", immersiveID: "HouseInteriorImmersiveView"),
        ModelInfo(imageName: "budapest-hotel", windowID: "BudapestHotelRealityView", immersiveID: "BudapestHotelImmersiveView"),
        ModelInfo(imageName: "space-corridor", windowID: "SpaceStationRealityView", immersiveID: "SpaceStationImmersiveView"),
        ModelInfo(imageName: "classroom", windowID: "ClassroomRealityView", immersiveID: "ClassroomImmersiveView"),
        ModelInfo(imageName: "bedroom", windowID: "BedroomRealityView", immersiveID: "BedroomImmersiveView"),
        ModelInfo(imageName: "potions-store", windowID: "PotionsStoreRealityView", immersiveID: "PotionsStoreImmersiveView"),
        ModelInfo(imageName: "convenience-store", windowID: "ConvenienceStoreRealityView", immersiveID: "ConvenienceStoreImmersiveView"),
        ModelInfo(imageName: "old-hotel", windowID: "OldHotelRealityView", immersiveID: "OldHotelImmersiveView"),
        ModelInfo(imageName: "mech-drone", windowID: "MechDroneRealityView", immersiveID: ""),
        ModelInfo(imageName: "buster-drone", windowID: "BusterDroneRealityView", immersiveID: "")
    ]

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
            Image(model.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 275, height: 200)
                .clipped()
                // Use an overlay to place buttons over the image
                .overlay(alignment: .top) {
                    VStack {
                        HStack {
                            //Window View Button
                            Button(action: {
                                isWindowOpen.toggle()
                                if isWindowOpen {
                                    openWindow(id: model.windowID)
                                } else {
                                    dismissWindow(id: model.windowID)
                                }
                            }) {
                                Label("", systemImage: "cube.fill")
                            }
                            .padding()

                            //Immersive View Button
                            Button(action: {
                                isImmersiveOpen.toggle()
                                if(model.immersiveID != ""){
                                    
                                    //When Immersive View is open, also allow for Navigation View
                                    Task {
                                        if isImmersiveOpen {
                                            await openImmersiveSpace(id: model.immersiveID)
                                            openWindow(id: "NavigationControlUI")
                                        } else {
                                            await dismissImmersiveSpace()
                                            dismissWindow(id: "NavigationControlUI")
                                        }
                                    }
                                }
                            }) {
                                Label("1:1", systemImage: "")
                            }
                            .padding()
                        }
                        .padding(.top, 130) // Adjust spacing from the top
                    }
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
