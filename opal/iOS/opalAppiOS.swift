//
//  OpalAppiOS.swift
//  opal
//
//  Created by Vik Parth on 1/29/25.
//

import SwiftUI

@main
struct OpalAppiOS: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                List {
                    NavigationLink {
                        CameraView()
                    } label: {
                        Label("Capture", systemImage: "camera.fill")
                    }
                    
                    NavigationLink {
                        SceneView()
                    } label: {
                        Label("Scenes", systemImage: "scanner.fill")
                    }
                    
                    NavigationLink {
                        Text("Import Models")
                            .font(.title)
                            .padding()
                    } label: {
                        Label("Import", systemImage: "square.and.arrow.down.fill")
                    }
                    
                    NavigationLink {
                        TeamView()
                    } label: {
                        Label("Team", systemImage: "person.2.fill")
                    }
                }
                .navigationTitle("Opal")
            }
        }
    }
}

#Preview {
    TeamView()
}
