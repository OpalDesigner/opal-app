//
//  BubbleView.swift
//
//  Created by Vik Parth on 10/15/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

//This code creates iridescent bubbles that you can interact with
struct BubbleView: View {
    @State var predicate = QueryPredicate<Entity>.has(ModelComponent.self)
    @State private var timer: Timer?
    @State private var bubble = Entity()

    var body: some View {
        RealityView { content in
            // Load the Bubble Scene
            guard let model = try? await Entity(named: "Bubble Scene", in: realityKitContentBundle) else {
                fatalError("Unable to load scene model")
            }
            let bubble = model.findEntity(named: "Bubble")!

            // Create and add bubbles
            for _ in 1...50 {
                let bubbleClone = bubble.clone(recursive: true)
                setupBubblePhysics(for: bubbleClone)
                randomizeBubblePosition(for: bubbleClone)
                content.add(bubbleClone)
            }
        }
        // Add Tap Gesture
        .gesture(SpatialTapGesture()
            .targetedToEntity(where: predicate)
            .onEnded { value in
                handleBubbleTap(value.entity)
            }
        )
    }

    // Setup Bubble Physics Body and Physics Motion
    func setupBubblePhysics(for bubble: Entity) {
        var physicsBody = PhysicsBodyComponent()
        physicsBody.linearDamping = 0
        physicsBody.isAffectedByGravity = false
        bubble.components[PhysicsBodyComponent.self] = physicsBody

        let linearVelX = Float.random(in: -0.05...0.05)
        let linearVelY = Float.random(in: -0.05...0.05)
        let linearVelZ = Float.random(in: -0.05...0.05)
        var physicsMotion = PhysicsMotionComponent(linearVelocity: [linearVelX, linearVelY, linearVelZ])
        bubble.components[PhysicsMotionComponent.self] = physicsMotion
    }

    // Randomize bubble position within a defined range
    func randomizeBubblePosition(for bubble: Entity) {
        bubble.position = [
            Float.random(in: -0.5...0.5),
            Float.random(in: -0.5...0.5),
            Float.random(in: -0.5...0.5)
        ]
    }

    // Handle bubble tap and pop animation
    func handleBubbleTap(_ entity: Entity) {
        guard var material = entity.components[ModelComponent.self]?.materials.first as? ShaderGraphMaterial else { return }

        let frameRate: TimeInterval = 1.0 / 60.0
        let duration: TimeInterval = 0.25
        let targetValue: Float = 1
        let totalFrames = Int(duration / frameRate)
        var currentFrame = 0
        var popValue: Float = 0

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: frameRate, repeats: true) { timer in
            currentFrame += 1
            let progress = Float(currentFrame) / Float(totalFrames)
            popValue = progress * targetValue

            do {
                try material.setParameter(name: "Pop", value: .float(popValue))
                entity.components[ModelComponent.self]?.materials = [material]
            } catch {
                print(error.localizedDescription)
            }

            if currentFrame >= totalFrames {
                timer.invalidate()
                entity.removeFromParent()
            }
        }
    }
}

#Preview {
    BubbleView()
}
