/*
Abstract:
 SwiftUI views can't be directly attached to RealityKit entities
 AttachmentsProvider helps bridge this gap by maintaining references to SwiftUI views that will be rendered as attachments
*/

import SwiftUI
import Observation

@Observable
final class AttachmentsProvider {
    // Dictionary that stores views, keyed by their unique identifiers
    var attachments: [ObjectIdentifier: AnyView] = [:]
    
    // Helper property that returns the attachments in a sorted array
    var sortedTagViewPairs: [(tag: ObjectIdentifier, view: AnyView)] {
        attachments.map { key, value in
            (tag: key, view: value)
        }.sorted { $0.tag < $1.tag }
    }
}
