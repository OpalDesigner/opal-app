//
//  MainMenuView.swift
//  opal
//
//  Created by Brian Corrieri on 03/04/2025.
//

import SwiftUI

struct MainMenuView: View {
    
    @EnvironmentObject var tabSelection: TabSelection
    
    var body: some View {
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
        /*
        .task{
            // function located in  SharePlayControl.swift
            await configureGroupSession()
        }
        */
    }
}

#Preview {
    MainMenuView()
}
