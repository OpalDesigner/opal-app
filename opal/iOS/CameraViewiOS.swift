//
//  CameraViewiOS.swift
//  opal
//
//  Created by Vik Parth on 1/29/25.
//


import SwiftUI
import RealityKit

@MainActor
class CaptureModel: ObservableObject {
    @Published var session: ObjectCaptureSession?
    @Published var imageCount = 0
    @Published var feedback = ""
    @Published var isCapturing = false
    
    func startCapture() {
        let imagesFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Capture-\(Date().timeIntervalSince1970)")
            .appendingPathComponent("images")
        print("📁 Images folder path: \(imagesFolder.path)")
        
        try? FileManager.default.createDirectory(at: imagesFolder, withIntermediateDirectories: true)
        
        session = ObjectCaptureSession()
        session?.start(imagesDirectory: imagesFolder)
        
        // Monitor feedback and state
        if let session = session {
            // Monitor feedback
            Task {
                for await feedback in session.feedbackUpdates {
                    if feedback.contains(.objectTooClose) {
                        self.feedback = "Move back"
                    } else if feedback.contains(.objectTooFar) {
                        self.feedback = "Move closer"
                    } else if feedback.contains(.movingTooFast) {
                        self.feedback = "Move slower"
                    } else if feedback.contains(.environmentTooDark) {
                        self.feedback = "More light needed"
                    } else {
                        self.feedback = ""
                    }
                }
            }
            
            // Monitor state and image count
            Task {
                for await state in session.stateUpdates {
                    print("State changed to: \(state)")
                    
                    // Update image count regardless of state
                    self.imageCount = session.numberOfShotsTaken
                    print("📸 Image count updated: \(self.imageCount)")
                    
                    // Update capturing state based on current state
                    if case .capturing = state {
                        self.isCapturing = true
                    } else {
                        self.isCapturing = false
                    }
                }
            }
        }
    }
}

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var model = CaptureModel()
    
    var body: some View {
        ZStack {
            if let session = model.session {
                ObjectCaptureView(session: session)
                    .ignoresSafeArea()
                    .overlay(alignment: .top) {
                        if !model.feedback.isEmpty {
                            Text(model.feedback)
                                .foregroundColor(.white)
                                .padding()
                                .background(.black.opacity(0.5))
                                .cornerRadius(8)
                                .padding(.top, 50)
                        }
                    }
            }
            
            VStack {
                HStack {
                    Button("Cancel") { dismiss() }
                    Spacer()
                    Button("Done") {
                        model.session?.finish()
                        dismiss()
                    }
                    .disabled(model.imageCount < 10)
                }
                .padding()
                .foregroundColor(.white)
                
                Spacer()
                
                VStack {
                    Text("\(model.imageCount) shots")
                        .foregroundColor(.white)
                    
                    Button {
                        if !model.isCapturing {
                            try? model.session?.startCapturing()
                            model.isCapturing = true
                            print("Starting capture. Current count: \(model.imageCount)")
                        }
                    } label: {
                        Circle()
                            .stroke(.white, lineWidth: 3)
                            .frame(width: 65, height: 65)
                    }
                }
                .padding()
            }
        }
        .statusBar(hidden: true)
        .task {
            model.startCapture()
        }
    }
}
