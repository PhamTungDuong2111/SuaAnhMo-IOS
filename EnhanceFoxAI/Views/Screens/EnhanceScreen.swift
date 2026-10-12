import SwiftUI
import PhotosUI

struct EnhanceScreen: View {
    @Binding var currentImage: UIImage?
    @Binding var resultImage: UIImage?
    @Binding var isProcessing: Bool
    @Binding var progress: Int
    @Binding var stageText: String
    
    var onUseSample: (String) -> Void
    var onStartEnhance: (EnhanceOptions) -> Void
    var onSave: () -> Void
    var onShare: () -> Void
    
    @EnvironmentObject var localization: LocalizationManager
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showCameraSheet: Bool = false
    @State private var selectedScale: Int = 1
    @State private var selectedStrength: SharpnessStrength = .high
    @State private var faceEnhance: Bool = true
    @State private var denoise: Bool = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Top Header Action
                HStack(spacing: 8) {
                    Text(localization.get("tool_enhance_title"))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        Button(action: { showCameraSheet = true }) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color(red: 0.65, green: 0.38, blue: 1.0))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(red: 0.49, green: 0.23, blue: 0.93).opacity(0.2))
                                .cornerRadius(10)
                        }
                    }
                    
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        HStack(spacing: 6) {
                            Image(systemName: "photo.badge.plus")
                            Text(currentImage == nil ? localization.get("select_photo") : localization.get("change_photo"))
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(Color(red: 0.65, green: 0.38, blue: 1.0))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(red: 0.49, green: 0.23, blue: 0.93).opacity(0.2))
                        .cornerRadius(10)
                    }
                }
                
                // Photo Comparison Slider or Placeholder
                if let current = currentImage {
                    ComparisonSliderView(
                        beforeImage: current,
                        afterImage: resultImage,
                        isProcessing: isProcessing
                    )
                } else {
                    VStack(spacing: 14) {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            VStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 0.49, green: 0.23, blue: 0.93).opacity(0.2))
                                        .frame(width: 58, height: 58)
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 26))
                                        .foregroundColor(Color(red: 0.49, green: 0.23, blue: 0.93))
                                }
                                
                                Text(localization.get("select_photo"))
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("PNG, JPG, HEIC")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(red: 0.39, green: 0.45, blue: 0.55))
                            }
                        }
                        
                        Button(action: {
                            onUseSample("sample_portrait")
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "play.circle.fill")
                                Text(localization.get("btn_try_sample"))
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(red: 0.65, green: 0.38, blue: 1.0))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color(red: 0.49, green: 0.23, blue: 0.93).opacity(0.25))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(red: 0.65, green: 0.38, blue: 1.0).opacity(0.4), lineWidth: 1)
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .background(Color(red: 0.09, green: 0.11, blue: 0.19))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 0.15, green: 0.20, blue: 0.30), lineWidth: 1)
                    )
                }
                
                // Processing Progress
                if isProcessing {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(localization.get("processing_title"))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(progress)%")
                                .font(.system(size: 13, weight: .black))
                                .foregroundColor(Color(red: 0.65, green: 0.38, blue: 1.0))
                        }
                        
                        ProgressView(value: Float(progress), total: 100.0)
                            .tint(Color(red: 0.49, green: 0.23, blue: 0.93))
                        
                        Text(stageText)
                            .font(.system(size: 11))
                            .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))
                    }
                    .padding(14)
                    .background(Color(red: 0.09, green: 0.11, blue: 0.19))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(red: 0.49, green: 0.23, blue: 0.93).opacity(0.4), lineWidth: 1)
                    )
                }
                
                // Controls Options
                VStack(alignment: .leading, spacing: 14) {
                    Text(localization.get("resolution_scale"))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 8) {
                        ScalePill(title: localization.get("scale_1x"), isSelected: selectedScale == 1) { selectedScale = 1 }
                        ScalePill(title: localization.get("scale_2x"), isSelected: selectedScale == 2) { selectedScale = 2 }
                        ScalePill(title: localization.get("scale_4x"), isSelected: selectedScale == 4) { selectedScale = 4 }
                    }
                    
                    Divider().background(Color(red: 0.15, green: 0.20, blue: 0.30))
                    
                    Text(localization.get("strength_level"))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 8) {
                        ScalePill(title: localization.get("strength_natural"), isSelected: selectedStrength == .natural) { selectedStrength = .natural }
                        ScalePill(title: localization.get("strength_high"), isSelected: selectedStrength == .high) { selectedStrength = .high }
                        ScalePill(title: localization.get("strength_ultra"), isSelected: selectedStrength == .ultra) { selectedStrength = .ultra }
                    }
                    
                    Divider().background(Color(red: 0.15, green: 0.20, blue: 0.30))
                    
                    Toggle(isOn: $faceEnhance) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(localization.get("face_enhance"))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                            Text(localization.get("face_enhance_desc"))
                                .font(.system(size: 11))
                                .foregroundColor(Color(red: 0.39, green: 0.45, blue: 0.55))
                        }
                    }
                    .tint(Color(red: 0.49, green: 0.23, blue: 0.93))
                    
                    Toggle(isOn: $denoise) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(localization.get("denoise"))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                            Text(localization.get("denoise_desc"))
                                .font(.system(size: 11))
                                .foregroundColor(Color(red: 0.39, green: 0.45, blue: 0.55))
                        }
                    }
                    .tint(Color(red: 0.49, green: 0.23, blue: 0.93))
                }
                .padding(16)
                .background(Color(red: 0.09, green: 0.11, blue: 0.19))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.15, green: 0.20, blue: 0.30), lineWidth: 1)
                )
                
                // Action Button
                Button(action: {
                    onStartEnhance(
                        EnhanceOptions(
                            scale: selectedScale,
                            strength: selectedStrength,
                            faceEnhance: faceEnhance,
                            denoise: denoise
                        )
                    )
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                        Text(localization.get("btn_process_enhance"))
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(currentImage != nil && !isProcessing ? Color(red: 0.49, green: 0.23, blue: 0.93) : Color(red: 0.15, green: 0.20, blue: 0.30))
                    .cornerRadius(12)
                }
                .disabled(currentImage == nil || isProcessing)
                
                // Save & Share Buttons
                if resultImage != nil && !isProcessing {
                    HStack(spacing: 10) {
                        Button(action: onSave) {
                            HStack(spacing: 6) {
                                Image(systemName: "square.and.arrow.down")
                                Text(localization.get("btn_save_gallery"))
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(Color(red: 0.06, green: 0.73, blue: 0.51))
                            .cornerRadius(12)
                        }
                        
                        Button(action: onShare) {
                            HStack(spacing: 6) {
                                Image(systemName: "square.and.arrow.up")
                                Text(localization.get("btn_share"))
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(Color(red: 0.39, green: 0.40, blue: 0.95))
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(Color(red: 0.03, green: 0.04, blue: 0.07).ignoresSafeArea())
        .onChange(of: selectedPhotoItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        currentImage = uiImage
                        resultImage = nil
                    }
                }
            }
        }
        .sheet(isPresented: $showCameraSheet) {
            CameraPickerView(selectedImage: Binding(
                get: { currentImage },
                set: {
                    currentImage = $0
                    resultImage = nil
                }
            ))
        }
    }
}

struct ScalePill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : Color(red: 0.58, green: 0.64, blue: 0.72))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? Color(red: 0.49, green: 0.23, blue: 0.93) : Color(red: 0.15, green: 0.20, blue: 0.30).opacity(0.5))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color(red: 0.65, green: 0.38, blue: 1.0) : Color.clear, lineWidth: 1)
                )
        }
    }
}
