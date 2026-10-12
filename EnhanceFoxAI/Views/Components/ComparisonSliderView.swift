import SwiftUI

struct ComparisonSliderView: View {
    let beforeImage: UIImage
    let afterImage: UIImage?
    let isProcessing: Bool
    
    @EnvironmentObject var localization: LocalizationManager
    
    @State private var splitPosition: CGFloat = 0.5
    @State private var savedSplitPosition: CGFloat = 0.5
    @State private var isZoomed: Bool = false
    @State private var laserOffset: CGFloat = 0.0
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                let width = geo.size.width
                let height = geo.size.height
                
                ZStack(alignment: .leading) {
                    // BEFORE Layer
                    Image(uiImage: beforeImage)
                        .resizable()
                        .aspectRatio(contentMode: isZoomed ? .fill : .fit)
                        .frame(width: width, height: height)
                        .clipped()
                    
                    // AFTER Layer with clipping
                    if let after = afterImage {
                        Image(uiImage: after)
                            .resizable()
                            .aspectRatio(contentMode: isZoomed ? .fill : .fit)
                            .frame(width: width, height: height)
                            .clipped()
                            .mask(
                                HStack(spacing: 0) {
                                    Color.clear
                                        .frame(width: max(0, width * splitPosition))
                                    Color.white
                                        .frame(width: max(0, width * (1.0 - splitPosition)))
                                }
                                .frame(width: width, height: height)
                            )
                        
                        // Vertical Divider line
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 2, height: height)
                            .offset(x: max(0, min(width - 2, width * splitPosition - 1)))
                        
                        // Handle knob (vertically centered by ZStack leading alignment)
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.49, green: 0.23, blue: 0.93), Color(red: 0.39, green: 0.40, blue: 0.95)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image(systemName: "arrow.left.and.right")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 2)
                            .offset(x: max(0, min(width - 36, width * splitPosition - 18)))
                        
                        // Before Tag
                        Text(localization.get("label_before"))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(5)
                            .padding(10)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        
                        // After Tag
                        Text(localization.get("label_after"))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color(red: 0.49, green: 0.23, blue: 0.93).opacity(0.85))
                            .cornerRadius(5)
                            .padding(10)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    }
                    
                    // Scanning Laser Beam Animation during processing
                    if isProcessing {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.clear, Color(red: 0.51, green: 0.55, blue: 0.98), Color.white, Color(red: 0.51, green: 0.55, blue: 0.98), Color.clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: width, height: 4)
                            .offset(y: laserOffset)
                            .onAppear {
                                withAnimation(Animation.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                                    laserOffset = height - 4
                                }
                            }
                    }
                }
                .frame(width: width, height: height)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let pos = (value.location.x / width)
                            splitPosition = max(0.0, min(1.0, pos))
                        }
                )
            }
            .frame(height: 380)
            .background(Color.black)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(red: 0.15, green: 0.20, blue: 0.30), lineWidth: 1)
            )
            
            // Toolbar (Zoom & Hold to Compare)
            if afterImage != nil && !isProcessing {
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation { isZoomed.toggle() }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: isZoomed ? "minus.magnifyingglass" : "plus.magnifyingglass")
                            Text(isZoomed ? localization.get("btn_zoom_out") : localization.get("btn_zoom"))
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(isZoomed ? Color(red: 0.49, green: 0.23, blue: 0.93) : Color(red: 0.10, green: 0.13, blue: 0.22))
                        .cornerRadius(8)
                    }
                    
                    Button(action: {}) {
                        HStack(spacing: 6) {
                            Image(systemName: "eye")
                            Text(localization.get("btn_hold_compare"))
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.10, green: 0.13, blue: 0.22))
                        .cornerRadius(8)
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                savedSplitPosition = splitPosition
                                splitPosition = 1.0 // Reveal 100% original
                            }
                            .onEnded { _ in
                                splitPosition = savedSplitPosition
                            }
                    )
                }
                .padding(.top, 8)
            }
        }
    }
}
