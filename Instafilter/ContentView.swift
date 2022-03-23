//
//  ContentView.swift
//  Instafilter
//
//  Created by Raymond Chen on 3/18/22.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    @State private var filterRadius = 0.1
    @State private var filterScale = 0.1
    
    
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    @State private var showingImagePicker = false
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context  = CIContext()
    
    @State private var showingFilterSheet = false
    
    private var isFilterIntensity: Bool {
        currentFilter.inputKeys.contains(kCIInputIntensityKey)
    }
    
    private var isFilterRadius: Bool {
        currentFilter.inputKeys.contains(kCIInputRadiusKey)
    }
    
    private var isFilterScale: Bool {
        currentFilter.inputKeys.contains(kCIInputScaleKey)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(.secondary)
                    
                    Text("Tap to select a picture")
                    
                    image?
                        .resizable()
                        .scaledToFit()
                }
                .onTapGesture {
                    showingImagePicker = true
                }
            
                HStack {
                    Text("Intensity")
                    Slider(value: $filterIntensity)
                        .onChange(of: filterIntensity) { _ in
                            applyProcessing()
                        }
                }
                .disabled(!isFilterIntensity)
                .opacity(!isFilterIntensity ? 0.2 : 1)
                HStack {
                    Text("Radius")
                    Slider(value: $filterRadius, in: 0.01...1)
                        .onChange(of: filterRadius) { _ in
                            applyProcessing()
                        }
                }
                .disabled(!isFilterRadius)
                .opacity(!isFilterRadius ? 0.2 : 1)
                HStack {
                    Text("Scale")
                    Slider(value: $filterScale, in: 0.01...1)
                        .onChange(of: filterScale) { _ in
                            applyProcessing()
                        }
                }
                .disabled(!isFilterScale)
                .opacity(!isFilterScale ? 0.2 : 1)
                .padding([.bottom])
                
                HStack {
                    Button("Change Filter") {
                        showingFilterSheet = true
                    }
                    
                    Spacer()
                    
                    Button("Save", action: save)
                        .disabled(image == nil)
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .onChange(of: inputImage) { _ in loadImage() }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
            .confirmationDialog("Select a filter", isPresented: $showingFilterSheet) {
                Group {
                    Button("Crystallize") { setFilter(CIFilter.crystallize()) }
                    Button("Edges") { setFilter(CIFilter.edges()) }
                    Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
                    Button("Pixellate") { setFilter(CIFilter.pixellate()) }
                    Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
                }
                Group {
                    Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
                    Button("Vignette") { setFilter(CIFilter.vignette()) }
                    Button("Bloom") { setFilter(CIFilter.bloom())}
                    Button("Noir") { setFilter(CIFilter.photoEffectNoir()) }
                    Button("XRay"){ setFilter(CIFilter.xRay())}
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func save() {
        guard let processedImage = processedImage else {
            return
        }

        let imageSaver = ImageSaver()
        imageSaver.successHandler = {
            print("Success!")
        }
        
        imageSaver.errorHandler = {
            print("Oops: \($0.localizedDescription)")
        }
        
        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
    
    func applyProcessing() {
        if isFilterIntensity {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        if isFilterRadius {
            currentFilter.setValue(filterRadius * 200, forKey: kCIInputRadiusKey)
        }
        if isFilterScale {
            currentFilter.setValue(filterScale * 10, forKey: kCIInputScaleKey)
        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }

    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

