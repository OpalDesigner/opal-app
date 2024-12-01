//
//  opalApp.swift
//  opal
//
//  Created by Vik Parth on 10/24/24.
//

import SwiftUI

@main
struct opalApp: App {
    // Access shared data in NavigationControlUI.swift
    @StateObject var navigationData = NavigationData()
        
    var body: some Scene {
        //MAIN SCENE
        WindowGroup(id: "Menu") {
            TabView{
                ModelMenu()
                    .tabItem{
                        Label("Home", systemImage: "house.fill")
                    }
                PluginMenu()
                    .tabItem{
                        Label("Import", systemImage: "square.and.arrow.down")
                    }
                HomeMenu()
                    .tabItem{
                        Label("About", systemImage: "building.2.fill")
                    }
                TeamMenu()
                    .tabItem{
                        Label("Team", systemImage: "person")
                    }
            }
        }
        .defaultSize(CGSize(width: 1000, height: 880))
        
        //NAVIGATION CONTROL
        WindowGroup(id: "NavigationControl") {
            NavigationControl(navigationData: navigationData)
        }
        .defaultWindowPlacement{content, context in
            return WindowPlacement(.utilityPanel)
        }
        .defaultSize(CGSize(width: 300, height: 350))
        
        //HAND INTERACTION
        ImmersiveSpace(id: "HandInteractionView"){
            HandInteractionView()
        }
        
        //BUBBLE ANIMATION 
        ImmersiveSpace(id: "BubbleView") {
            BubbleView()
        }
        .immersionStyle(selection: .constant(.full), in: .full)
        
        //3D MODEL SETS - TABLETOP VIEWS
        Group {
            WindowGroup(id: "CoffeeShopRealityView") {
                TabletopModelView(
                    modelName: "Coffee_Shop",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.1)
            }
            //.volumeWorldAlignment(.gravityAligned)
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
            .windowStyle(.volumetric)
            .defaultSize(width: 1.5, height: 1, depth: 1, in: .meters)
            
            WindowGroup(id: "HouseInteriorRealityView") {
                TabletopModelView(
                    modelName: "House_Interior",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.03)
            }
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
            .windowStyle(.volumetric)
            .defaultSize(width: 1.5, height: 1, depth: 1, in: .meters)
            
            WindowGroup(id: "BudapestHotelRealityView") {
                TabletopModelView(
                    modelName: "Budapest_Hotel",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.015)
            }
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
            .windowStyle(.volumetric)
            .defaultSize(width: 1.5, height: 1, depth: 1, in: .meters)
            
            WindowGroup(id: "SpaceStationRealityView") {
                TabletopModelView(
                    modelName: "SpaceStation_Hall",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.05)
            }
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
            .windowStyle(.volumetric)
            .defaultSize(width: 1.5, height: 1, depth: 1, in: .meters)
            
            WindowGroup(id: "ClassroomRealityView") {
                TabletopModelView(
                    modelName: "Old_Classroom",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.0667)
            }
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
            .windowStyle(.volumetric)
            .defaultSize(width: 1.5, height: 1, depth: 1, in: .meters)
            
            WindowGroup(id: "BedroomRealityView") {
                TabletopModelView(
                    modelName: "Bedroom",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.0833)
            }
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
            .windowStyle(.volumetric)
            .defaultSize(width: 1.5, height: 1, depth: 1, in: .meters)
            
            WindowGroup(id: "PotionsStoreRealityView") {
                TabletopModelView(
                    modelName: "Potions_Store",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.04)
            }
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
            .windowStyle(.volumetric)
            .defaultSize(width: 1.5, height: 1, depth: 1, in: .meters)
            
            WindowGroup(id: "ConvenienceStoreRealityView") {
                TabletopModelView(
                    modelName: "Convenience_Store",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.1)
            }
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
            .windowStyle(.volumetric)
            .defaultSize(width: 1.5, height: 1, depth: 1, in: .meters)
            
            WindowGroup(id: "OldHotelRealityView") {
                TabletopModelView(
                    modelName: "Old_Hotel",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.0286)
            }
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
            .windowStyle(.volumetric)
            .defaultSize(width: 1.5, height: 1, depth: 1, in: .meters)
        }
        
        //3D MODEL SETS - IMMERSIVE VIEWS
        Group {
            ImmersiveSpace(id: "CoffeeShopImmersiveView") {
                ImmersiveModelView(
                    navigationData: navigationData,
                    modelName: "Coffee_Shop"
                )
            }
            .immersionStyle(selection: .constant(.full), in: .full)
            
            ImmersiveSpace(id: "HouseInteriorImmersiveView") {
                ImmersiveModelView(
                    navigationData: navigationData,
                    modelName: "House_Interior"
                )
            }
            .immersionStyle(selection: .constant(.full), in: .full)
            
            ImmersiveSpace(id: "BudapestHotelImmersiveView") {
                ImmersiveModelView(
                    navigationData: navigationData,
                    modelName: "Budapest_Hotel"
                )
            }
            .immersionStyle(selection: .constant(.full), in: .full)
            
            ImmersiveSpace(id: "SpaceStationImmersiveView") {
                ImmersiveModelView(
                    navigationData: navigationData,
                    modelName: "SpaceStation_Hall"
                )
            }
            .immersionStyle(selection: .constant(.full), in: .full)
            
            ImmersiveSpace(id: "ClassroomImmersiveView") {
                ImmersiveModelView(
                    navigationData: navigationData,
                    modelName: "Old_Classroom"
                )
            }
            .immersionStyle(selection: .constant(.full), in: .full)
            
            ImmersiveSpace(id: "BedroomImmersiveView") {
                ImmersiveModelView(
                    navigationData: navigationData,
                    modelName: "Bedroom"
                )
            }
            .immersionStyle(selection: .constant(.full), in: .full)
            
            ImmersiveSpace(id: "PotionsStoreImmersiveView") {
                ImmersiveModelView(
                    navigationData: navigationData,
                    modelName: "Potions_Store"
                )
            }
            .immersionStyle(selection: .constant(.full), in: .full)
            
            ImmersiveSpace(id: "ConvenienceStoreImmersiveView") {
                ImmersiveModelView(
                    navigationData: navigationData,
                    modelName: "Convenience_Store"
                )
            }
            .immersionStyle(selection: .constant(.full), in: .full)
            
            ImmersiveSpace(id: "OldHotelImmersiveView") {
                ImmersiveModelView(
                    navigationData: navigationData,
                    modelName: "Old_Hotel"
                )
            }
            .immersionStyle(selection: .constant(.full), in: .full)
        }
        
        //Drone
        Group{
            WindowGroup(id: "MechDroneRealityView") {
                TabletopModelView(
                    modelName: "Mech_Drone",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.01)
            }
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
            .windowStyle(.volumetric)
            .defaultSize(width: 1.5, height: 1, depth: 1, in: .meters)
            
            WindowGroup(id: "BusterDroneRealityView") {
                TabletopModelView(
                    modelName: "Buster_Drone",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.002)
            }
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
            .windowStyle(.volumetric)
            .defaultSize(width: 1.5, height: 1, depth: 1, in: .meters)
        }
        
        //Solar System
        Group{
            WindowGroup(id: "SolarSystemRealityView") {
                TabletopModelView(
                    modelName: "Planets",
                    initialPosition: SIMD3<Float>(0, 0, 0),
                    initialScale: 0.25)
            }
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
            .windowStyle(.volumetric)
            .defaultSize(width: 1.5, height: 1, depth: 1, in: .meters)
            
            ImmersiveSpace(id: "SolarSystemImmersiveView") {
                ImmersiveModelView(
                    navigationData: navigationData,
                    modelName: "Planets"
                )
            }
            .immersionStyle(selection: .constant(.full), in: .full)
        }
        
    }
}



