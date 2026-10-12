import SwiftUI

struct TopHeaderView: View {
    @EnvironmentObject var localization: LocalizationManager
    
    var body: some View {
        HStack {
            HStack(spacing: 10) {
                Group {
                    if let uiImg = UIImage(named: "AppLogo") {
                        Image(uiImage: uiImg)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 9)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.49, green: 0.23, blue: 0.93), Color(red: 0.39, green: 0.40, blue: 0.95)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Image(systemName: "sparkles")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(width: 36, height: 36)
                .cornerRadius(9)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(localization.get("app_name"))
                        .font(.system(size: 17, weight: .black))
                        .foregroundColor(.white)
                    
                    Text(localization.get("app_tagline"))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Language Switcher
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    localization.toggle()
                }
            }) {
                HStack(spacing: 5) {
                    Text(localization.currentLanguage.flag)
                        .font(.system(size: 14))
                    Text(localization.currentLanguage.rawValue.uppercased())
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(red: 0.49, green: 0.23, blue: 0.93).opacity(0.2))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(red: 0.49, green: 0.23, blue: 0.93).opacity(0.5), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(red: 0.07, green: 0.09, blue: 0.15))
    }
}
