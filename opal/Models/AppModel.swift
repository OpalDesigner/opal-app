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
    
    var isImmersiveSpaceOpen = false
    var immersionStyle: ImmersionStyle = .full
}
