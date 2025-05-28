//
//  NavigationControlMenu.swift
//  opal
//
//  Created by Brian Corrieri on 27/05/2025.
//

import SwiftUI

struct NavigationControlMenu: View {
    
    var isOpen: Bool
    @ObservedObject var navigationData: NavigationData
    @Environment(AppModel.self) var appModel
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading) {
            if isOpen {
                NavigationControl(navigationData: navigationData, controlSize: .small)
            } else {
                Image(systemName: "circle")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .transition(.identity)
            }
        }
        .padding(isOpen ? 10 : 5)
        .glassBackgroundEffect()
        .frame(maxWidth: 550, maxHeight: 450)
        .offset(x: isOpen ? 0 : offsetX, y: isOpen ? 0 : offsetY)
        .animation(.default, value: isOpen)
    }
    
}

/*
#Preview {
    NavigationControlMenu()
}
*/
