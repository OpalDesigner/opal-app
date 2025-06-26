//
//  SharePlayMessage.swift
//  opal
//
//  Created by Brian Corrieri on 21/03/2025.
//

import Foundation

struct SharePlayMessage: Codable {
    
    let type: MessageType
    let data: Data
    
    enum MessageType: Codable {
        case immersiveSpaceUpdate
        case spatialInteraction
    }
    
}

struct ImmersiveSpaceUpdate: Codable, Equatable {
    var isOpen: Bool
    var immersiveSpaceId: String
    var modelInfo: ModelInfo
}

struct AppStateUpdate: Codable, Equatable {
    var mainMenuState: MainMenuState
    var selectedTab: Int
    var selectedCategory: ModelCategory
}

struct InteractiveObjectUpdate: Codable, Equatable {
    var entityName: String
    var position: SIMD3<Float>
}

struct SceneCameraUpdate: Codable, Equatable {
    var position: SIMD3<Float>
    var rotationY: Float
}

struct InteractiveTVUpdate: Codable, Equatable {
    var modelRotation: Double
}

class SharePlayMessageHandler {
    
    func handle(_ message: SharePlayMessage) {
        switch message.type {
        case .immersiveSpaceUpdate:
            if let isOpen: ImmersiveSpaceUpdate = decodeData(from: message.data) {
                
            }
        case .spatialInteraction:
            break
        }
    }
    
    private func decodeData<T: Codable>(from data: Data) -> T? {
        let decoder = JSONDecoder()
        let decodedObject = try? decoder.decode(T.self, from: data)
        return decodedObject
    }
    
    
}
