import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: EnhanceTab = .home
    
    // Working images
    @State private var enhanceBefore: UIImage? = nil
    @State private var enhanceAfter: UIImage? = nil
    
    @State private var colorizeBefore: UIImage? = nil
    @State private var colorizeAfter: UIImage? = nil
    
    @State private var restoreBefore: UIImage? = nil
    @State private var restoreAfter: UIImage? = nil
    
    // Processing state
    @State private var isProcessing: Bool = false
    @State private var progress: Int = 0
    @State private var stageText: String = ""
    
    @State private var showShareSheet: Bool = false
    @State private var shareImage: UIImage? = nil
    @State private var toastMessage: String? = nil
    
    @EnvironmentObject var localization: LocalizationManager
    @EnvironmentObject var photoManager: PhotoManager
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Brand Top Bar
                TopHeaderView()
                
                // Main Content
                ZStack {
                    switch selectedTab {
                    case .home:
                        HomeScreen(
                            selectedTab: $selectedTab,
                            onSelectSample: { sampleName, targetTab in
                                loadSample(sampleName, for: targetTab)
                            }
                        )
                    case .enhance:
                        EnhanceScreen(
                            currentImage: $enhanceBefore,
                            resultImage: $enhanceAfter,
                            isProcessing: $isProcessing,
                            progress: $progress,
                            stageText: $stageText,
                            onUseSample: { sampleName in
                                loadSample(sampleName, for: .enhance)
                            },
                            onStartEnhance: { opts in
                                runEnhance(opts)
                            },
                            onSave: {
                                if let img = enhanceAfter {
                                    saveImage(img, title: "Enhance HD", mode: "Làm nét")
                                }
                            },
                            onShare: {
                                if let img = enhanceAfter {
                                    share(img)
                                }
                            }
                        )
                    case .colorize:
                        ColorizeScreen(
                            currentImage: $colorizeBefore,
                            resultImage: $colorizeAfter,
                            isProcessing: $isProcessing,
                            progress: $progress,
                            stageText: $stageText,
                            onUseSample: { sampleName in
                                loadSample(sampleName, for: .colorize)
                            },
                            onStartColorize: { palette in
                                runColorize(palette)
                            },
                            onSave: {
                                if let img = colorizeAfter {
                                    saveImage(img, title: "Colorize AI", mode: "Tô màu")
                                }
                            },
                            onShare: {
                                if let img = colorizeAfter {
                                    share(img)
                                }
                            }
                        )
                    case .restore:
                        RestoreScreen(
                            currentImage: $restoreBefore,
                            resultImage: $restoreAfter,
                            isProcessing: $isProcessing,
                            progress: $progress,
                            stageText: $stageText,
                            onUseSample: { sampleName in
                                loadSample(sampleName, for: .restore)
                            },
                            onStartRestore: { scratches, defade in
                                runRestore(scratches: scratches, defade: defade)
                            },
                            onSave: {
                                if let img = restoreAfter {
                                    saveImage(img, title: "Restore Old Photo", mode: "Phục chế")
                                }
                            },
                            onShare: {
                                if let img = restoreAfter {
                                    share(img)
                                }
                            }
                        )
                    case .gallery:
                        GalleryScreen()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Custom Bottom Navigation Bar
                CustomBottomBar(selectedTab: $selectedTab)
            }
            
            // Toast notification
            if let toast = toastMessage {
                VStack {
                    Spacer()
                    Text(toast)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(red: 0.06, green: 0.73, blue: 0.51))
                        .cornerRadius(20)
                        .shadow(radius: 8)
                        .padding(.bottom, 70)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let img = shareImage {
                ActivityViewController(activityItems: [img])
            }
        }
    }
    
    private func loadSample(_ name: String, for tab: EnhanceTab) {
        if let img = photoManager.loadSampleImage(named: name) {
            switch tab {
            case .enhance:
                enhanceBefore = img
                enhanceAfter = nil
                selectedTab = .enhance
            case .colorize:
                colorizeBefore = img
                colorizeAfter = nil
                selectedTab = .colorize
            case .restore:
                restoreBefore = img
                restoreAfter = nil
                selectedTab = .restore
            default:
                enhanceBefore = img
                selectedTab = .enhance
            }
        }
    }
    
    private func runEnhance(_ options: EnhanceOptions) {
        guard let src = enhanceBefore else { return }
        isProcessing = true
        progress = 5
        stageText = localization.get("stage_analyzing")
        
        DispatchQueue.global(qos: .userInitiated).async {
            let res = AIEngine.shared.enhanceImage(image: src, options: options) { p in
                DispatchQueue.main.async {
                    self.progress = p
                    if p < 40 {
                        self.stageText = self.localization.get("stage_analyzing")
                    } else if p < 80 {
                        self.stageText = self.localization.get("stage_deblurring")
                    } else {
                        self.stageText = self.localization.get("stage_polishing")
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.isProcessing = false
                self.enhanceAfter = res
                self.progress = 100
            }
        }
    }
    
    private func runColorize(_ palette: ColorizePalette) {
        guard let src = colorizeBefore else { return }
        isProcessing = true
        progress = 10
        stageText = localization.get("stage_analyzing")
        
        DispatchQueue.global(qos: .userInitiated).async {
            let res = AIEngine.shared.colorizeImage(image: src, palette: palette) { p in
                DispatchQueue.main.async {
                    self.progress = p
                    self.stageText = p < 50 ? self.localization.get("stage_analyzing") : self.localization.get("stage_polishing")
                }
            }
            
            DispatchQueue.main.async {
                self.isProcessing = false
                self.colorizeAfter = res
                self.progress = 100
            }
        }
    }
    
    private func runRestore(scratches: Bool, defade: Bool) {
        guard let src = restoreBefore else { return }
        isProcessing = true
        progress = 10
        stageText = localization.get("stage_analyzing")
        
        DispatchQueue.global(qos: .userInitiated).async {
            let res = AIEngine.shared.restoreOldPhoto(image: src, removeScratches: scratches, defade: defade) { p in
                DispatchQueue.main.async {
                    self.progress = p
                    if p < 50 {
                        self.stageText = self.localization.get("stage_analyzing")
                    } else if p < 80 {
                        self.stageText = self.localization.get("stage_deblurring")
                    } else {
                        self.stageText = self.localization.get("stage_polishing")
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.isProcessing = false
                self.restoreAfter = res
                self.progress = 100
            }
        }
    }
    
    private func saveImage(_ img: UIImage, title: String, mode: String) {
        photoManager.saveToPhotos(image: img) { success in
            photoManager.saveToLocalGallery(image: img, title: title, mode: mode)
            showToast(localization.get("saved_success"))
        }
    }
    
    private func share(_ img: UIImage) {
        shareImage = img
        showShareSheet = true
    }
    
    private func showToast(_ msg: String) {
        withAnimation { toastMessage = msg }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { toastMessage = nil }
        }
    }
}

struct CustomBottomBar: View {
    @Binding var selectedTab: EnhanceTab
    @EnvironmentObject var localization: LocalizationManager
    
    var body: some View {
        HStack {
            BarItem(icon: "house.fill", label: localization.get("tab_home"), isSelected: selectedTab == .home) {
                selectedTab = .home
            }
            BarItem(icon: "wand.and.stars", label: localization.get("tab_enhance"), isSelected: selectedTab == .enhance) {
                selectedTab = .enhance
            }
            BarItem(icon: "paintpalette.fill", label: localization.get("tab_colorize"), isSelected: selectedTab == .colorize) {
                selectedTab = .colorize
            }
            BarItem(icon: "clock.arrow.circlepath", label: localization.get("tab_restore"), isSelected: selectedTab == .restore) {
                selectedTab = .restore
            }
            BarItem(icon: "photo.stack", label: localization.get("tab_gallery"), isSelected: selectedTab == .gallery) {
                selectedTab = .gallery
            }
        }
        .padding(.vertical, 8)
        .background(Color(red: 0.07, green: 0.09, blue: 0.15))
        .overlay(
            Rectangle()
                .fill(Color(red: 0.15, green: 0.20, blue: 0.30))
                .frame(height: 1),
            alignment: .top
        )
    }
}

struct BarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? Color(red: 0.49, green: 0.23, blue: 0.93) : Color(red: 0.39, green: 0.45, blue: 0.55))
                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .bold : .normal))
                    .foregroundColor(isSelected ? Color(red: 0.49, green: 0.23, blue: 0.93) : Color(red: 0.39, green: 0.45, blue: 0.55))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Native Camera Picker
struct CameraPickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerView
        init(_ parent: CameraPickerView) { self.parent = parent }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let img = info[.originalImage] as? UIImage {
                parent.selectedImage = img
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

