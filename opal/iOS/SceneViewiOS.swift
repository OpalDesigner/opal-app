import AWSS3
import QuickLook
import SceneKit
import SwiftUI

struct ScanCard: View {
    let title: String
    let imageURL: URL?
    let modelURL: URL
    @State private var loadedImage: UIImage?
    @State private var previewURL: URL?
    
    var body: some View {
        Button {
            previewURL = modelURL
        } label: {
            ZStack(alignment: .bottom) {
                if let loadedImage = loadedImage {
                    Image(uiImage: loadedImage).resizable().aspectRatio(contentMode: .fill)
                } else { Color.gray.opacity(0.2) }
                Text(title.components(separatedBy: "/").last?.replacingOccurrences(of: ".usdz", with: "") ?? "")
                    .foregroundColor(.white)
                    .font(.caption)
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
            }
            .frame(width: 120, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .quickLookPreview($previewURL)
        .onAppear {
            if let baseURL = imageURL?.deletingPathExtension() {
                for ext in ["jpg", "png", "jpeg"] {
                    let imageURL = baseURL.appendingPathExtension(ext)
                    if let imageData = try? Data(contentsOf: imageURL),
                       let image = UIImage(data: imageData) {
                        loadedImage = image
                        break
                    }
                }
            }
        }
    }
}

struct SceneView: View {
    @State private var files: [(String, URL)] = []
    @State private var selectedCategory = 0
    @State private var isLoading = false
    let categories = ["Scans", "Decor", "Anatomy"]
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    var filteredFiles: [(String, URL)] {
        files.filter { name, _ in
            name.lowercased().contains(categories[selectedCategory].lowercased())
        }
    }
    var body: some View {
        VStack {
            Picker("Category", selection: $selectedCategory) {
                ForEach(0..<categories.count) { index in
                    Text(categories[index]).tag(index)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(filteredFiles, id: \.0) { (name, url) in
                        ScanCard(
                            title: name.replacingOccurrences(of: ".usdz", with: ""),
                            imageURL: url.deletingPathExtension(),
                            modelURL: url
                        )
                    }
                }
                .padding()
            }
        }
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
        .task {
            await fetchS3Files()
        }
    }
    
    private func fetchS3Files() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let s3Client = try S3Client(region: "us-east-1")
            let output = try await s3Client.listObjectsV2(input: .init(bucket: "opal-designer"))
            if let objects = output.contents {
                // First pass: find all image files and store them by base name
                var imageMap: [String: URL] = [:]
                for object in objects {
                    guard let key = object.key else { continue }
                    let imageExtensions = [".jpg", ".jpeg", ".png", ".gif", ".heic", ".webp"]
                    if imageExtensions.contains(where: { key.lowercased().hasSuffix($0) }) {
                        let baseName = key.components(separatedBy: ".").dropLast().joined(separator: ".")
                        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                            .appendingPathComponent(key)
                        // Download image if it doesn't exist
                        if !FileManager.default.fileExists(atPath: url.path) {
                            if let data = try await s3Client.getObject(
                                input: .init(bucket: "opal-designer", key: key)
                            ).body?.readData() {
                                try? FileManager.default.createDirectory(
                                    at: url.deletingLastPathComponent(),
                                    withIntermediateDirectories: true
                                )
                                try data.write(to: url)
                            }
                        }
                        imageMap[baseName] = url
                    }
                }
                
                // Second pass: process USDZ files and pair them with images
                let validObjects = objects.compactMap { $0.key }
                    .filter { $0.contains(".usdz") }
                for key in validObjects {
                    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        .appendingPathComponent(key)
                    // Check if file already exists
                    if FileManager.default.fileExists(atPath: url.path) {
                        files.append((key, url))
                        continue
                    }
                    // Create directory if needed
                    try? FileManager.default.createDirectory(
                        at: url.deletingLastPathComponent(),
                        withIntermediateDirectories: true
                    )
                    // Only download if file doesn't exist
                    if let data = try await s3Client.getObject(
                        input: .init(bucket: "opal-designer", key: key)
                    ).body?.readData() {
                        try data.write(to: url)
                        files.append((key, url))
                    }
                }
            }
            
            // Debug print all loaded files
            print("\nTotal files loaded: \(files.count)")
            files.forEach { name, url in
                print("- Loaded: \(name), at: \(url.path)")
            }
            
        } catch {
            print("Error loading files:", error)
        }
    }
}
