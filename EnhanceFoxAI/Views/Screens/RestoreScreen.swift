import SwiftUI
import PhotosUI

struct RestoreScreen: View {
    @Binding var currentImage: UIImage?
    @Binding var resultImage: UIImage?
    @Binding var isProcessing: Bool
    @Binding var progress: Int
    @Binding var stageText: String
    
    var onUseSample: (String) -> Void
    var onStartRestore: (Bool, Bool) -> Void
    var onSave: () -> Void
    var onShare: () -> Void
    
    @EnvironmentObject var localization: LocalizationManager
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showCameraSheet: Bool = false
    @State private var removeScratches: Bool = true
    @State private var defade: Bool = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                HStack(spacing: 8) {
                    Text(localization.get("tool_restore_title"))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        Button(action: { showCameraSheet = true }) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color(red: 0.06, green: 0.73, blue: 0.51))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(red: 0.06, green: 0.73, blue: 0.51).opacity(0.2))
                                .cornerRadius(10)
                        }
                    }
                    
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        HStack(spacing: 6) {
                            Image(systemName: "photo.badge.plus")
                            Text(currentImage == nil ? localization.get("select_photo") : localization.get("change_photo"))
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(Color(red: 0.06, green: 0.73, blue: 0.51))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(red: 0.06, green: 0.73, blue: 0.51).opacity(0.2))
                        .cornerRadius(10)
                    }
                }
                
                // Slider or Placeholder
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
                                        .fill(Color(red: 0.06, green: 0.73, blue: 0.51).opacity(0.2))
                                        .frame(width: 58, height: 58)
                                    Image(systemName: "clock.arrow.circlepath")
                                        .font(.system(size: 26))
                                        .foregroundColor(Color(red: 0.06, green: 0.73, blue: 0.51))
                                }
                                
                                Text(localization.get("select_photo"))
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Chọn ảnh cũ bị xước, nứt rách hoặc ố vàng")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(red: 0.39, green: 0.45, blue: 0.55))
                            }
                        }
                        
                        Button(action: {
                            onUseSample("sample_vintage")
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "play.circle.fill")
                                Text(localization.get("btn_try_sample"))
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(red: 0.06, green: 0.73, blue: 0.51))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color(red: 0.06, green: 0.73, blue: 0.51).opacity(0.25))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(red: 0.06, green: 0.73, blue: 0.51).opacity(0.4), lineWidth: 1)
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
                
                // Progress
                if isProcessing {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(localization.get("processing_title"))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(progress)%")
                                .font(.system(size: 13, weight: .black))
                                .foregroundColor(Color(red: 0.06, green: 0.73, blue: 0.51))
                        }
                        
                        ProgressView(value: Float(progress), total: 100.0)
                            .tint(Color(red: 0.06, green: 0.73, blue: 0.51))
                        
                        Text(stageText)
                            .font(.system(size: 11))
                            .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))
                    }
                    .padding(14)
                    .background(Color(red: 0.09, green: 0.11, blue: 0.19))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(red: 0.06, green: 0.73, blue: 0.51).opacity(0.4), lineWidth: 1)
                    )
                }
                
                // Options Card
                VStack(spacing: 14) {
                    Toggle(isOn: $removeScratches) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(localization.get("option_scratches"))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                            Text(localization.get("option_scratches_desc"))
                                .font(.system(size: 11))
                                .foregroundColor(Color(red: 0.39, green: 0.45, blue: 0.55))
                        }
                    }
                    .tint(Color(red: 0.06, green: 0.73, blue: 0.51))
                    
                    Divider().background(Color(red: 0.15, green: 0.20, blue: 0.30))
                    
                    Toggle(isOn: $defade) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(localization.get("option_defade"))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                            Text(localization.get("option_defade_desc"))
                                .font(.system(size: 11))
                                .foregroundColor(Color(red: 0.39, green: 0.45, blue: 0.55))
                        }
                    }
                    .tint(Color(red: 0.06, green: 0.73, blue: 0.51))
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
                    onStartRestore(removeScratches, defade)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "clock.arrow.circlepath")
                        Text(localization.get("btn_process_restore"))
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(currentImage != nil && !isProcessing ? Color(red: 0.06, green: 0.73, blue: 0.51) : Color(red: 0.15, green: 0.20, blue: 0.30))
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
                            .background(Color(red: 0.49, green: 0.23, blue: 0.93))
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
