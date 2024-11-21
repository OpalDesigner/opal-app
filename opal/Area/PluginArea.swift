//
//  CADPluginView.swift
//  opal
//
//  Created by Vik Parth on 10/24/24.
//

import SwiftUI

struct PluginArea: View {
    var body: some View {
        NavigationStack {
            Text("Choose your tool to import from")
                .font(.largeTitle)
                .padding(20)
                .glassBackgroundEffect()
            HStack{
                VStack(alignment: .leading) {
                    Image("unreal-logo")
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .frame(width: 150, height: 150)
                    Text("Unreal Engine")
                        .font(.system(size: 25, weight: .bold))
                    Text("Import your Unreal files to preview 3D models, textures and animation")
                        .font(.system(size: 14))
                    Button{
                        
                    }label: {
                        Label("Import", systemImage: "arrow.triangle.2.circlepath.circle")
                    }
                }
                .frame(width: 250, height: 300)
                .padding(20)
                .glassBackgroundEffect()
                
                VStack(alignment: .leading) {
                    Image("blender-icon")
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .frame(width: 150, height: 150)
                    Text("Blender")
                        .font(.system(size: 20, weight: .bold))
                    Text("Import your Blender files to preview 3D models, textures and animation")
                        .font(.system(size: 14))
                    Button{
                        
                    }label: {
                        Label("Import", systemImage: "arrow.triangle.2.circlepath.circle")
                    }
                }
                .frame(width: 250, height: 300)
                .padding(20)
                .glassBackgroundEffect()
                
                VStack(alignment: .leading) {
                    Image("gaussian-splat")
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .frame(width: 150, height: 150)
                    Text("Gaussian Splat")
                        .font(.system(size: 20, weight: .bold))
                    Text("Import your Gaussian Splats (.ply) files to preview realistic 3D scenes")
                        .font(.system(size: 14))
                    Button{
                        
                    }label: {
                        Label("Import", systemImage: "arrow.triangle.2.circlepath.circle")
                    }
                }
                .frame(width: 250, height: 300)
                .padding(20)
                .glassBackgroundEffect()
            }
        }
        .background {
            Image("interior-shot-05")
        }
    }
}

#Preview {
    PluginArea()
}
