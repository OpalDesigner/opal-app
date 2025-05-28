//
//  AppModel.swift
//  opal
//
//  Created by Brian Corrieri on 21/03/2025.
//


import Foundation
import SwiftUI
import Observation

@Observable @MainActor
final class AppModel {
    var sessionController: SessionController?
    
    var selectedTab = 0
    var selectedCategory: ModelCategory = .scenes
    var mainMenuState: MainMenuState = .standard
    var openMenu: Bool = false
    var openMenuB: Bool = false
    var modelInfo: ModelInfo?
    
    var isImmersiveSpaceOpen = false
    var immersionStyle: ImmersionStyle = .full
    
    func setMainMenuState(_ state: MainMenuState) {
        withAnimation {
            mainMenuState = state
        }
    }
    
    func toggleImmersionStyle() {
        switch immersionStyle {
        case is FullImmersionStyle:
            immersionStyle = .mixed
        case is MixedImmersionStyle:
            immersionStyle = .full
        default:
            break
        }
    }
    
    var appStateUpdate: AppStateUpdate {
        .init(mainMenuState: mainMenuState,
              selectedTab: selectedTab,
              selectedCategory: selectedCategory)
    }
    
    /*
    var timer: Timer?
    /// Test method
    func shuffle() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            Task {
                await MainActor.run {
//                    self.selectedTab = Int.random(in: 0...2)
//                    print(self.selectedTab)
                    
//                    self.selectedCategory = ModelCategory.allCases.randomElement() ?? .scenes
                }
            }
        })
    }
    */
    
    
}

enum MainMenuState: Codable {
    case standard
    case minimized
}
