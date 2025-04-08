//
//  MainMenuView.swift
//  opal
//
//  Created by Brian Corrieri on 03/04/2025.
//

import SwiftUI

struct MainMenuView: View {
    
    @Environment(AppModel.self) var appModel
    
    var body: some View {
        @Bindable var appModel = appModel
        TabView (selection: $appModel.selectedTab) {
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
//        .task {
//            appModel.shuffle()
//        }
        .onChange(of: appModel.selectedTab) { _, newValue in
            guard newValue != appModel.sessionController?.appStateUpdate?.selectedTab else { return }
            Task { @MainActor in
                try? await appModel.sessionController?.messenger.send(appModel.appStateUpdate)
            }
        }
        .onChange(of: appModel.mainMenuState) { _, newValue in
            guard newValue != appModel.sessionController?.appStateUpdate?.mainMenuState else { return }
            Task { @MainActor in
                try? await appModel.sessionController?.messenger.send(appModel.appStateUpdate)
            }
        }
        .onChange(of: appModel.selectedCategory) { _, newValue in
            guard newValue != appModel.sessionController?.appStateUpdate?.selectedCategory else { return }
            Task { @MainActor in
                try? await appModel.sessionController?.messenger.send(appModel.appStateUpdate)
            }
        }
        .onChange(of: appModel.sessionController?.appStateUpdate, updateAppState)
        /*
        .task{
            // function located in  SharePlayControl.swift
            await configureGroupSession()
        }
        */
    }
    
    func updateAppState(
        oldActivityStage: AppStateUpdate?,
        newActivityStage: AppStateUpdate?
    ) {
        guard let newActivityStage else { return }
        appModel.selectedTab = newActivityStage.selectedTab
        appModel.mainMenuState = newActivityStage.mainMenuState
        appModel.selectedCategory = newActivityStage.selectedCategory
    }
}

#Preview {
    MainMenuView()
}
