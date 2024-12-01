//
//  HandInteractionView.swift
//
//  Created by Vik Parth on 10/23/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import ARKit

//This code is not yet complete. This is to allow you to place objects on real world surfaces using ARkit and SceneReconstruction (detect planes, surfaces)

struct HandInteractionView: View {
    @StateObject var model = HandTrackingViewModel()
    
    var body: some View {
        RealityView{ content in
            //add content entity
            content.add(model.setupContentEntity())
        }.task{
            //run ARkit session to track hands and environment
            await model.runSession()
        }.task{
            //process hand updates
            await model.processHandUpdates()
        }.task{
            //process world reconstruction
        }.gesture(SpatialTapGesture().targetedToAnyEntity().onEnded({value in
            //add code
        }))
    }
}

#Preview {
    HandInteractionView()
}

