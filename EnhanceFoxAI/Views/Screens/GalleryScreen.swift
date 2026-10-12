import SwiftUI

struct GalleryScreen: View {
    @EnvironmentObject var photoManager: PhotoManager
    @EnvironmentObject var localization: LocalizationManager
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(localization.get("tab_gallery"))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.top, 16)
            
            if photoManager.galleryItems.isEmpty {
                VStack(spacing: 14) {
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.09, green: 0.11, blue: 0.19))
                            .frame(width: 70, height: 70)
                        Image(systemName: "photo.stack")
                            .font(.system(size: 30))
                            .foregroundColor(Color(red: 0.39, green: 0.45, blue: 0.55))
                    }
                    
                    Text(localization.get("gallery_empty"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(localization.get("gallery_empty_desc"))
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.39, green: 0.45, blue: 0.55))
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(photoManager.galleryItems) { item in
                            GalleryGridCell(item: item)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .background(Color(red: 0.03, green: 0.04, blue: 0.07).ignoresSafeArea())
    }
}

struct GalleryGridCell: View {
    let item: GalleryItem
    @EnvironmentObject var photoManager: PhotoManager
    @State private var showShareSheet: Bool = false
    @State private var showPreview: Bool = false
    
    private var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm dd/MM"
        return formatter.string(from: item.timestamp)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button(action: { showPreview = true }) {
                if let image = photoManager.loadImage(named: item.fileName) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 130)
                        .clipped()
                        .cornerRadius(10)
                } else {
                    Rectangle()
                        .fill(Color.black)
                        .frame(height: 130)
                        .cornerRadius(10)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    HStack(spacing: 4) {
                        Text(item.mode)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color(red: 0.65, green: 0.38, blue: 1.0))
                        Text("•")
                            .font(.system(size: 9))
                            .foregroundColor(Color(red: 0.39, green: 0.45, blue: 0.55))
                        Text(dateFormatted)
                            .font(.system(size: 9))
                            .foregroundColor(Color(red: 0.58, green: 0.64, blue: 0.72))
                    }
                }
                
                Spacer()
                
                Button(action: {
                    showShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.49, green: 0.23, blue: 0.93))
                }
                
                Button(action: {
                    photoManager.deleteItem(item)
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 13))
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 6)
        }
        .padding(6)
        .background(Color(red: 0.09, green: 0.11, blue: 0.19))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(red: 0.15, green: 0.20, blue: 0.30), lineWidth: 1)
        )
        .sheet(isPresented: $showShareSheet) {
            if let img = photoManager.loadImage(named: item.fileName) {
                ActivityViewController(activityItems: [img])
            }
        }
        .sheet(isPresented: $showPreview) {
            if let img = photoManager.loadImage(named: item.fileName) {
                ZStack {
                    Color.black.ignoresSafeArea()
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: { showPreview = false }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding()
                            }
                        }
                        Spacer()
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        Spacer()
                    }
                }
            }
        }
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
