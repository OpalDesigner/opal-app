//
//  opalApp.swift
//  opal
//
//  Created by Vik Parth on 10/24/24.
//

import SwiftUI

@main
struct opalApp: App {
    // Access Shared data in NavigationControlUI.swift
    @StateObject var modelControlData = ModelControlData()
        
    var body: some Scene {
        //MAIN SCENE
        WindowGroup(id: "Menu") {
            TabView{
                ModelArea()
                    .tabItem{
                        Label("Home", systemImage: "house.fill")
                    }
                PluginArea()
                    .tabItem{
                        Label("Import", systemImage: "square.and.arrow.down")
                    }
                HomeArea()
                    .tabItem{
                        Label("About", systemImage: "building.2.fill")
                    }
                TeamArea()
                    .tabItem{
                        Label("Team", systemImage: "person")
                    }
            }
        }
        .defaultSize(CGSize(width: 1000, height: 880))
        
        //NAVIGATION CONTROL VIEW
        WindowGroup(id: "NavigationControlUI") {
            NavigationControlUI(modelControlData: modelControlData)
        }
         .defaultSize(CGSize(width: 300, height: 350))
        
        //BUBBLE ANIMATION VIEW
        ImmersiveSpace(id: "BubbleView") {
            BubbleView()
        }
        .immersionStyle(selection: .constant(.full), in: .full)
        
        //HAND INTERACTION VIEW
        ImmersiveSpace(id: "HandInteractionView"){
            HandInteractionView()
        }
        
        //3D MODEL SETS - WINDOW VIEWS
        Group {
            WindowGroup(id: "CoffeeShopRealityView") {
                RealityModelView(
                    modelName: "Coffee_Shop",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.001)
            }
            .windowStyle(.volumetric)
            .defaultSize(width: 2, height: 1, depth: 1, in: .meters)
            
            WindowGroup(id: "HouseInteriorRealityView") {
                RealityModelView(
                    modelName: "House_Interior",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.001)
            }
            .windowStyle(.volumetric)
            .defaultSize(width: 2, height: 1, depth: 1, in: .meters)
            
            WindowGroup(id: "BudapestHotelRealityView") {
                RealityModelView(
                    modelName: "Budapest_Hotel",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.0015)
            }
            .windowStyle(.volumetric)
            .defaultSize(width: 2, height: 1, depth: 1, in: .meters)
            
            WindowGroup(id: "SpaceStationRealityView") {
                RealityModelView(
                    modelName: "SpaceStation_Hall",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.001)
            }
            .windowStyle(.volumetric)
            .defaultSize(width: 2, height: 1, depth: 1, in: .meters)
            
            WindowGroup(id: "ClassroomRealityView") {
                RealityModelView(
                    modelName: "Old_Classroom",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.001)
            }
            .windowStyle(.volumetric)
            .defaultSize(width: 2, height: 1, depth: 1, in: .meters)
            
            WindowGroup(id: "BedroomRealityView") {
                RealityModelView(
                    modelName: "Bedroom",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.001)
            }
            .windowStyle(.volumetric)
            .defaultSize(width: 2, height: 1, depth: 1, in: .meters)
            
            WindowGroup(id: "PotionsStoreRealityView") {
                RealityModelView(
                    modelName: "Potions_Store",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.001)
            }
            .windowStyle(.volumetric)
            .defaultSize(width: 2, height: 1, depth: 1, in: .meters)
            
            WindowGroup(id: "ConvenienceStoreRealityView") {
                RealityModelView(
                    modelName: "Convenience_Store",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.001)
            }
            .windowStyle(.volumetric)
            .defaultSize(width: 2, height: 1, depth: 1, in: .meters)
            
            WindowGroup(id: "OldHotelRealityView") {
                RealityModelView(
                    modelName: "Old_Hotel",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.001)
            }
            .windowStyle(.volumetric)
            .defaultSize(width: 2, height: 1, depth: 1, in: .meters)
        }
        
        //3D MODEL ROBOTS - WINDOW VIEW
        Group{
            WindowGroup(id: "MechDroneRealityView") {
                RealityModelView(
                    modelName: "Mech_Drone",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.01)
            }
            .windowStyle(.volumetric)
            .defaultSize(width: 1, height: 1, depth: 1, in: .meters)
            
            WindowGroup(id: "BusterDroneRealityView") {
                RealityModelView(
                    modelName: "Buster_Drone",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.002)
            }
            .windowStyle(.volumetric)
            .defaultSize(width: 1, height: 1, depth: 1, in: .meters)
        }
        
        //3D MODEL SETS - IMMERSIVE VIEWS
        Group {
            ImmersiveSpace(id: "CoffeeShopImmersiveView") {
                ImmersiveModelView(
                    modelControlData: modelControlData,
                    modelName: "Coffee_Shop",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.01) //this gets the model to human scale
            }
            .immersionStyle(selection: .constant(.full), in: .full)
            
            ImmersiveSpace(id: "HouseInteriorImmersiveView") {
                ImmersiveModelView(
                    modelControlData: modelControlData,
                    modelName: "House_Interior",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.03) //this gets the model to human scale
            }
            .immersionStyle(selection: .constant(.full), in: .full)
            
            ImmersiveSpace(id: "BudapestHotelImmersiveView") {
                ImmersiveModelView(
                    modelControlData: modelControlData,
                    modelName: "Budapest_Hotel",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.1) //this gets the model to human scale
            }
            .immersionStyle(selection: .constant(.full), in: .full)
            
            ImmersiveSpace(id: "SpaceStationImmersiveView") {
                ImmersiveModelView(
                    modelControlData: modelControlData,
                    modelName: "SpaceStation_Hall",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.02) //this gets the model to human scale
            }
            .immersionStyle(selection: .constant(.full), in: .full)
            
            ImmersiveSpace(id: "ClassroomImmersiveView") {
                ImmersiveModelView(
                    modelControlData: modelControlData,
                    modelName: "Old_Classroom",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.015) //this gets the model to human scale
            }
            .immersionStyle(selection: .constant(.full), in: .full)
            
            ImmersiveSpace(id: "BedroomImmersiveView") {
                ImmersiveModelView(
                    modelControlData: modelControlData,
                    modelName: "Bedroom",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.012) //this gets the model to human scale
            }
            .immersionStyle(selection: .constant(.full), in: .full)
            
            ImmersiveSpace(id: "PotionsStoreImmersiveView") {
                ImmersiveModelView(
                    modelControlData: modelControlData,
                    modelName: "Potions_Store",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.025) //this gets the model to human scale
            }
            .immersionStyle(selection: .constant(.full), in: .full)
            
            ImmersiveSpace(id: "ConvenienceStoreImmersiveView") {
                ImmersiveModelView(
                    modelControlData: modelControlData,
                    modelName: "Convenience_Store",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.01) //this gets the model to human scale
            }
            .immersionStyle(selection: .constant(.full), in: .full)
            
            ImmersiveSpace(id: "OldHotelImmersiveView") {
                ImmersiveModelView(
                    modelControlData: modelControlData,
                    modelName: "Old_Hotel",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.035)
            }
            .immersionStyle(selection: .constant(.full), in: .full)
        }
    }
}



