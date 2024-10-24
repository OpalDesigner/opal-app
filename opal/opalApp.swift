//
//  opalApp.swift
//  opal
//
//  Created by Vik Parth on 10/24/24.
//

import SwiftUI

@main
struct opalApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }.immersionStyle(selection: .constant(.full), in: .full)
    }
}
