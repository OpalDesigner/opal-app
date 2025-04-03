//
//  MainView.swift
//  opal
//
//  Created by Brian Corrieri on 03/04/2025.
//

import SwiftUI

struct MainView: View {
    
    @Environment(AppModel.self) var appModel
    
    var body: some View {
        if appModel.isImmersiveSpaceOpen {
            Text("Exploring...")
                .frame(maxWidth: 200, maxHeight: 200)
        } else {
            MainMenuView()
                .frame(width: 1000, height: 880)
        }
    }
}

#Preview {
    MainView()
}
