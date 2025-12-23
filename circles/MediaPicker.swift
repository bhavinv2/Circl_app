//
//  MediaPicker.swift
//  circl_test_app
//
//  Created by Bhavin Vulli on 7/27/25.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct MediaPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var videoURL: URL?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .any(of: [.images, .videos])

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: MediaPicker

        init(_ parent: MediaPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else { return }

            if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                        self.parent.videoURL = nil
                    }
                }
            } else if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, _ in
                    guard let url = url else { return }
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
                    if FileManager.default.fileExists(atPath: tempURL.path) {
                        try? FileManager.default.removeItem(at: tempURL)
                    }
                    do {
                        try FileManager.default.copyItem(at: url, to: tempURL)
                        DispatchQueue.main.async {
                            self.parent.videoURL = tempURL
                            self.parent.image = nil
                        }
                    } catch {
                        print("🔥 Failed to copy video to temp: \(error)")
                    }

                    DispatchQueue.main.async {
                        self.parent.videoURL = tempURL
                        self.parent.image = nil
                    }
                }
            }
        }
    }
}
