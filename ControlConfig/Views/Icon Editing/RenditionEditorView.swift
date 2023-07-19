//
//  CAMLDebugView.swift
//  ControlConfig
//
//  Created by f1shy-dev on 12/04/2023
//

import AEXML
import AssetCatalogWrapper
import SwiftUI

struct RenditionEditorView: View {
    @ObservedObject var customisations: CustomisationList
    @State var catalog: CUICatalog
    @State var rendition: Rendition
    @State var filePath: URL
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?

    @State private var width: Double?
    @State private var height: Double?
    @State private var padding: Double = 0

    var body: some View {
        List {
            Section(header: Text(rendition.name)) {
                if let image = rendition.image {
                    HStack {
                        Spacer()
                        Image(uiImage: UIImage(cgImage: image))
                            .resizable()
                            .colorInvert()
                            .frame(width: CGFloat(image.width), height: CGFloat(image.height))
//                            .padding(EdgeInsets(top: 7, leading: 7, bottom: 7, trailing: 7))
                            .onTapGesture {
                                showingImagePicker = true
                            }
                            .overlay(
                                Rectangle().stroke(Color.gray, lineWidth: 1)
                            )
//                            .listRowBackground(.none)
                        Spacer()
                    }.listRowBackground(Color.clear)
                }
            }

            Section(footer: Text("Click the image to import an image. Height and Width will reisze the asset, but padding will be applied recursively unless you import an image.")) {
                //                LabelTextField(label: "Width", value: $width.intSafeBinding)
                //                LabelTextField(label: "Height", value: $height.intSafeBinding)
                HStack {
                    Text("Width (\(width ?? 0.0, specifier: "%.2f"))")
                    Spacer()
                    Slider(value: $width.toUnwrapped(defaultValue: 0), in: 1...200, step: 0.5).frame(width: 150)
                }
                HStack {
                    Text("Height (\(height ?? 0.0, specifier: "%.2f"))")
                    Spacer()
                    Slider(value: $height.toUnwrapped(defaultValue: 0), in: 1...200, step: 0.5).frame(width: 150)
                    //                    TextField("1", text: $height.intSafeBinding)
                }
                HStack {
                    Text("Padding (\(padding, specifier: "%.2f"))")
                    Spacer()
                    Slider(value: $padding, in: 1...100, step: 0.5).frame(width: 150)
                    //                    TextField("1", text: $padding.intSafeBinding)
                }
                Button("Apply changes") {
                    if let width = width, let height = height {
                        if let sourceImg = inputImage {
                            print("source")
                            reRenderWithImage(originalImage: sourceImg, width: width, height: height, padding: padding)
                            copyAndLoadAssetsCar()
                        } else if let img = rendition.image {
                            print("rendition img")
                            reRenderWithImage(originalImage: UIImage(cgImage: img), width: width, height: height, padding: padding)
                            copyAndLoadAssetsCar()
                        }
                    }
                }
                Button("Debug") {
                    print(rendition.cuiRend.unslicedSize())
                }
            }
            Section {
                Menu {
                    Section {
                        Button("85x85-0") {
                            applyPreset(w: 85.0, h: 85.0, p: 0.0)
                        }
                        Button("80x80-0") {
                            applyPreset(w: 80.0, h: 80.0, p: 0.0)
                        }
                    }

                    Section {
                        Button("100x100-25") {
                            applyPreset(w: 100.0, h: 100.0, p: 25.0)
                        }
                        Button("100x100-16") {
                            applyPreset(w: 100.0, h: 100.0, p: 16.0)
                        }
                        Button("100x100-0") {
                            applyPreset(w: 100.0, h: 100.0, p: 0.0)
                        }
                    }
                    Section {
                        Button("200x200-25") {
                            applyPreset(w: 200.0, h: 200.0, p: 25.0)
                        }
                        Button("200x200-16") {
                            applyPreset(w: 200.0, h: 200.0, p: 16.0)
                        }

                        Button("200x200-0") {
                            applyPreset(w: 200.0, h: 200.0, p: 0.0)
                        }
                    }

                } label: {
                    HStack {
                        Label("Size/Padding Presets", systemImage: "scope")
                        Spacer()
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .navigationTitle("CAML/Car Debugger")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            copyAndLoadAssetsCar()
        }
        .onChange(of: inputImage) { _ in
            if let image = inputImage, let width = width, let height = height {
                reRenderWithImage(originalImage: image, width: width, height: height, padding: padding)
                copyAndLoadAssetsCar()
            }
        }

        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
        }
    }

    func applyPreset(w: Double, h: Double, p: Double) {
        width = w
        height = h
        padding = p
        if let width = width, let height = height {
            if let sourceImg = inputImage {
                print("source")
                reRenderWithImage(originalImage: sourceImg, width: width, height: height, padding: padding)
                copyAndLoadAssetsCar()
            } else if let img = rendition.image {
                print("rendition img")
                reRenderWithImage(originalImage: UIImage(cgImage: img), width: width, height: height, padding: padding)
                copyAndLoadAssetsCar()
            }
        }
    }

    func reRenderWithImage(originalImage: UIImage, width: Double, height: Double, padding: Double) {
        // Create a new image renderer with the desired size
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))

        // Get the resized image from the renderer
        let resizedImage = renderer.image { _ in
            originalImage.draw(in: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
        }

        // Create a new image context with the desired size and transparent background
        let imageSizeWithPadding = CGSize(width: width + padding, height: height + padding) // Replace with your desired size
        UIGraphicsBeginImageContextWithOptions(imageSizeWithPadding, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(CGRect(origin: .zero, size: imageSizeWithPadding))

        // Get the transparent image from the context
        let transparentImage = UIGraphicsGetImageFromCurrentImageContext()!

        // End the image context
        UIGraphicsEndImageContext()

        // Calculate the size for the new image with padding
//                let imageSizeWithPadding_new = CGSize(width: originalImage.size.width + 50, height: originalImage.size.height + 50)

        // Begin an image context with the new size and transparent background
        UIGraphicsBeginImageContextWithOptions(imageSizeWithPadding, false, 0.0)
        let context_new = UIGraphicsGetCurrentContext()!

        transparentImage.draw(in: CGRect(origin: .zero, size: imageSizeWithPadding))

        // Draw the original image in the center of the context
        let origin = CGPoint(x: (imageSizeWithPadding.width - resizedImage.size.width) / 2, y: (imageSizeWithPadding.height - resizedImage.size.height) / 2)
        print(origin, resizedImage.size, imageSizeWithPadding)
        resizedImage.draw(in: CGRect(origin: origin, size: resizedImage.size))

        // Get the combined image from the context
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()!

        // End the image context
        UIGraphicsEndImageContext()

        guard let cgImage = combinedImage.cgImage else {
            print("error conv to cgimg")
            return
        }

        do {
            let tmpFilename = "\(filePath.lastPathComponent)-TMP-EDIT-\(UUID().uuidString.prefix(5))"
            let temporaryFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpFilename)

            if let w = rendition.image?.width, let h = rendition.image?.height {
                try FileManager.default.copyItem(at: filePath, to: temporaryFileURL)

                try catalog.editItem(rendition, fileURL: temporaryFileURL, to: .image(cgImage), renWidth: Double(_width.wrappedValue ?? Double(w)), renHeight: Double(_height.wrappedValue ?? Double(h)))

                try FileManager.default.removeItem(at: filePath)
                try FileManager.default.moveItem(at: temporaryFileURL, to: filePath)

                let (cata, coll) = try AssetCatalogWrapper.shared.renditions(forCarArchive: filePath)
                if let newRen = coll.flatMap(\.renditions).first(where: { ren in
                    ren.type == rendition.type && ren.name == rendition.name
                }) {
                    rendition = newRen
                }
                catalog = cata
                // re-fetch from rendition?
                if let w2 = (rendition.image?.width), let h2 = (rendition.image?.height) {
                    _width.wrappedValue = Double(w2)
                    _height.wrappedValue = Double(h2)
                }
            }

        } catch {
            print("error editing item")
        }
    }

    func copyAndLoadAssetsCar() {
        do {
            let (cata, coll) = try AssetCatalogWrapper.shared.renditions(forCarArchive: filePath)
            if let newRen = coll.flatMap(\.renditions).first(where: { ren in
                ren.type == rendition.type && ren.name == rendition.name && ren.cuiRend.scale() == rendition.cuiRend.scale()
            }) {
                rendition = newRen
            }
            catalog = cata
            if let w2 = (rendition.image?.width), let h2 = (rendition.image?.height) {
                _width.wrappedValue = Double(w2)
                _height.wrappedValue = Double(h2)
            }

        } catch {
            print(error)
        }
    }
}
