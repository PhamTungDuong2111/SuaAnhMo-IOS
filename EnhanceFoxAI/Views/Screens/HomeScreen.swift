import SwiftUI

struct HomeScreen: View {
    @Binding var selectedTab: EnhanceTab
    var onSelectSample: (String, EnhanceTab) -> Void
    
    @EnvironmentObject var localization: LocalizationManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Hero Banner
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.65, green: 0.38, blue: 1.0))
                        Text(localization.get("hero_badge"))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.49, green: 0.23, blue: 0.93).opacity(0.3))
                    .cornerRadius(12)
                    
                    Text(localization.get("hero_title"))
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(localization.get("hero_desc"))
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))
                        .lineSpacing(3)
                    
                    Button(action: {
                        selectedTab = .enhance
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "wand.and.stars")
                            Text(localization.get("btn_start_now"))
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(red: 0.49, green: 0.23, blue: 0.93))
                        .cornerRadius(12)
                    }
                }
                .padding(20)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.49, green: 0.23, blue: 0.93).opacity(0.25), Color(red: 0.09, green: 0.11, blue: 0.19)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(red: 0.49, green: 0.23, blue: 0.93).opacity(0.35), lineWidth: 1)
                )
                
                // Featured AI Tools
                VStack(alignment: .leading, spacing: 12) {
                    Text(localization.get("quick_tools_title"))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    
                    ToolCard(
                        title: localization.get("tool_enhance_title"),
                        desc: localization.get("tool_enhance_desc"),
                        icon: "sparkles",
                        accentColor: Color(red: 0.49, green: 0.23, blue: 0.93),
                        action: { selectedTab = .enhance }
                    )
                    
                    ToolCard(
                        title: localization.get("tool_colorize_title"),
                        desc: localization.get("tool_colorize_desc"),
                        icon: "paintpalette.fill",
                        accentColor: Color(red: 0.39, green: 0.40, blue: 0.95),
                        action: { selectedTab = .colorize }
                    )
                    
                    ToolCard(
                        title: localization.get("tool_restore_title"),
                        desc: localization.get("tool_restore_desc"),
                        icon: "clock.arrow.circlepath",
                        accentColor: Color(red: 0.06, green: 0.73, blue: 0.51),
                        action: { selectedTab = .restore }
                    )
                }
                
                // Sample Photos Section
                VStack(alignment: .leading, spacing: 12) {
                    Text(localization.get("btn_try_sample"))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        SampleCard(
                            imageName: "sample_portrait",
                            title: localization.get("sample_portrait_title"),
                            tag: localization.get("tool_enhance_title"),
                            action: { onSelectSample("sample_portrait", .enhance) }
                        )
                        
                        SampleCard(
                            imageName: "sample_vintage",
                            title: localization.get("sample_vintage_title"),
                            tag: localization.get("tool_restore_title"),
                            action: { onSelectSample("sample_vintage", .restore) }
                        )
                    }
                }
            }
            .padding(16)
        }
        .background(Color(red: 0.03, green: 0.04, blue: 0.07).ignoresSafeArea())
    }
}

struct ToolCard: View {
    let title: String
    let desc: String
    let icon: String
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.2))
                        .frame(width: 46, height: 46)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(accentColor)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    Text(desc)
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.39, green: 0.45, blue: 0.55))
            }
            .padding(14)
            .background(Color(red: 0.09, green: 0.11, blue: 0.19))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(red: 0.15, green: 0.20, blue: 0.30), lineWidth: 1)
            )
        }
    }
}

struct SampleCard: View {
    let imageName: String
    let title: String
    let tag: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .bottomTrailing) {
                    Group {
                        if let uiImg = UIImage(named: imageName) ?? PhotoManager.shared.loadSampleImage(named: imageName) {
                            Image(uiImage: uiImg)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Rectangle()
                                .fill(Color.black)
                        }
                    }
                    .frame(height: 110)
                    .clipped()
                    
                    Circle()
                        .fill(Color(red: 0.49, green: 0.23, blue: 0.93))
                        .frame(width: 26, height: 26)
                        .overlay(
                            Image(systemName: "play.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.white)
                        )
                        .padding(6)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(tag)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(red: 0.65, green: 0.38, blue: 1.0))
                        .lineLimit(1)
                }
                .padding(10)
            }
            .background(Color(red: 0.09, green: 0.11, blue: 0.19))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(red: 0.15, green: 0.20, blue: 0.30), lineWidth: 1)
            )
        }
    }
}
