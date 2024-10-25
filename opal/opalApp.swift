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
                HomeArea()
                    .tabItem{
                        Label("Build", systemImage: "building.2.fill")
                    }
                TeamArea()
                    .tabItem{
                        Label("About", systemImage: "person")
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
        
        //Hand Interaction INTERACTION VIEW
        ImmersiveSpace(id: "HandInteractionView"){
            HandInteractionView()
        }
        
        //3D MODEL SETS - WINDOW VIEWS
        Group {
            /*
            WindowGroup(id: "ApartmentRealityView") {
                RealityModelView(
                    modelName: "Apartment",
                    initialPosition: SIMD3<Float>(-200, 0, 0),
                    initialScale: 0.001)
            }
            .windowStyle(.volumetric)
            .defaultSize(width: 2, height: 1, depth: 1, in: .meters)
            */
            
            WindowGroup(id: "CoffeeShopRealityView") {
                RealityModelView(
                    modelName: "Coffee_Shop",
                    initialPosition: SIMD3<Float>(100, 0, 0),
                    initialScale: 0.001)
            }
            .windowStyle(.volumetric)
            .defaultSize(width: 2, height: 1, depth: 1, in: .meters)
            
            WindowGroup(id: "HouseInteriorRealityView") {
                RealityModelView(
                    modelName: "House_Interior",
                    initialPosition: SIMD3<Float>(-350, 0, 250),
                    initialScale: 0.001)
            }
            .windowStyle(.volumetric)
            .defaultSize(width: 2, height: 1, depth: 1, in: .meters)
            
            WindowGroup(id: "BudapestHotelRealityView") {
                RealityModelView(
                    modelName: "Budapest_Hotel",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.001)
            }
            .windowStyle(.volumetric)
            .defaultSize(width: 2, height: 1, depth: 1, in: .meters)
            
            WindowGroup(id: "SpaceStationRealityView") {
                RealityModelView(
                    modelName: "SpaceStation_Hall",
                    initialPosition: SIMD3<Float>(-50, 0, 90),
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
                    initialPosition: SIMD3<Float>(-20, 0, -70),
                    initialScale: 0.001)
            }
            .windowStyle(.volumetric)
            .defaultSize(width: 2, height: 1, depth: 1, in: .meters)
            
            WindowGroup(id: "PotionsStoreRealityView") {
                RealityModelView(
                    modelName: "Potions_Store",
                    initialPosition: SIMD3<Float>(0, 0, 150),
                    initialScale: 0.001)
            }
            .windowStyle(.volumetric)
            .defaultSize(width: 2, height: 1, depth: 1, in: .meters)
            
            WindowGroup(id: "ConvenienceStoreRealityView") {
                RealityModelView(
                    modelName: "Convenience_Store",
                    initialPosition: SIMD3<Float>(250, 0, 0),
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
                    initialPosition: SIMD3<Float>(0, -0.25, 0),
                    initialScale: 0.7)
            }
            .windowStyle(.volumetric)
            .defaultSize(width: 1, height: 1, depth: 1, in: .meters)
            
            WindowGroup(id: "BusterDroneRealityView") {
                RealityModelView(
                    modelName: "Buster_Drone",
                    initialPosition: SIMD3<Float>(0, 0.4, 0),
                    initialScale: 1)
            }
            .windowStyle(.volumetric)
            .defaultSize(width: 1, height: 1, depth: 1, in: .meters)
        }
        
        //3D MODEL SETS - IMMERSIVE VIEWS
        Group {
            /*
            ImmersiveSpace(id: "ApartmentImmersiveView") {
                ImmersiveModelView(
                    modelControlData: modelControlData,
                    modelName: "Apartment",
                    initialPosition: SIMD3<Float>(0, -150, 0),
                    initialScale: 0.5)
            }
            .immersionStyle(selection: .constant(.full), in: .full)
             */
            
            ImmersiveSpace(id: "CoffeeShopImmersiveView") {
                ImmersiveModelView(
                    modelControlData: modelControlData,
                    modelName: "Coffee_Shop",
                    initialPosition: SIMD3<Float>(0, -150, 0),
                    initialScale: 0.5)
            }
            .immersionStyle(selection: .constant(.full), in: .full)
            
            ImmersiveSpace(id: "HouseInteriorImmersiveView") {
                ImmersiveModelView(
                    modelControlData: modelControlData,
                    modelName: "House_Interior",
                    initialPosition: SIMD3<Float>(-150, -50, 50),
                    initialScale: 0.5)
            }
            .immersionStyle(selection: .constant(.full), in: .full)
            
            ImmersiveSpace(id: "BudapestHotelImmersiveView") {
                ImmersiveModelView(
                    modelControlData: modelControlData,
                    modelName: "Budapest_Hotel",
                    initialPosition: SIMD3<Float>(0, -25, 25),
                    initialScale: 0.5)
            }
            .immersionStyle(selection: .constant(.full), in: .full)
            
            ImmersiveSpace(id: "SpaceStationImmersiveView") {
                ImmersiveModelView(
                    modelControlData: modelControlData,
                    modelName: "SpaceStation_Hall",
                    initialPosition: SIMD3<Float>(-50, -125, 75),
                    initialScale: 0.5)
            }
            .immersionStyle(selection: .constant(.full), in: .full)
            
            ImmersiveSpace(id: "ClassroomImmersiveView") {
                ImmersiveModelView(
                    modelControlData: modelControlData,
                    modelName: "Old_Classroom",
                    initialPosition: SIMD3<Float>(0, -100, -25),
                    initialScale: 0.5)
            }
            .immersionStyle(selection: .constant(.full), in: .full)
            
            ImmersiveSpace(id: "BedroomImmersiveView") {
                ImmersiveModelView(
                    modelControlData: modelControlData,
                    modelName: "Bedroom",
                    initialPosition: SIMD3<Float>(0, -150, 0),
                    initialScale: 0.5)
            }
            .immersionStyle(selection: .constant(.full), in: .full)
            
            ImmersiveSpace(id: "PotionsStoreImmersiveView") {
                ImmersiveModelView(
                    modelControlData: modelControlData,
                    modelName: "Potions_Store",
                    initialPosition: SIMD3<Float>(-50, -75, 105),
                    initialScale: 0.5)
            }
            .immersionStyle(selection: .constant(.full), in: .full)
            
            ImmersiveSpace(id: "ConvenienceStoreImmersiveView") {
                ImmersiveModelView(
                    modelControlData: modelControlData,
                    modelName: "Convenience_Store",
                    initialPosition: SIMD3<Float>(0, -150, 0),
                    initialScale: 0.5)
            }
            .immersionStyle(selection: .constant(.full), in: .full)
            
            ImmersiveSpace(id: "OldHotelImmersiveView") {
                ImmersiveModelView(
                    modelControlData: modelControlData,
                    modelName: "Old_Hotel",
                    initialPosition: SIMD3<Float>(0, -45, 0),
                    initialScale: 0.5)
            }
            .immersionStyle(selection: .constant(.full), in: .full)
        }
    }
}



