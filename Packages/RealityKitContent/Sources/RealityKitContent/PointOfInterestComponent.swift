import RealityKit

// Ensure you register this component in your app’s delegate using:
// PointOfInterestComponent.registerComponent()
public struct PointOfInterestComponent: Component, Codable {
    // The title of the point of interest
    public var title: String
    public var description: String?

    public init(title: String, description: String? = nil) {
        self.title = title
        self.description = description
    }
}
