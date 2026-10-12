import UIKit
import Photos

final class PhotoManager: ObservableObject {
    static let shared = PhotoManager()
    
    @Published var galleryItems: [GalleryItem] = []
    
    private init() {
        loadGalleryItems()
    }
    
    func saveToPhotos(image: UIImage, completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { success, error in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        }
    }
    
    func saveToLocalGallery(image: UIImage, title: String, mode: String) {
        guard let data = image.pngData() else { return }
        let fileName = "enhanced_\(UUID().uuidString).png"
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        
        do {
            try data.write(to: url)
            let item = GalleryItem(title: title, mode: mode, fileName: fileName)
            DispatchQueue.main.async {
                self.galleryItems.insert(item, at: 0)
                self.saveGalleryItems()
            }
        } catch {
            print("Error saving local file: \(error)")
        }
    }
    
    func loadImage(named fileName: String) -> UIImage? {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        return UIImage(contentsOfFile: url.path)
    }
    
    func deleteItem(_ item: GalleryItem) {
        let url = getDocumentsDirectory().appendingPathComponent(item.fileName)
        try? FileManager.default.removeItem(at: url)
        galleryItems.removeAll { $0.id == item.id }
        saveGalleryItems()
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func saveGalleryItems() {
        if let encoded = try? JSONEncoder().encode(galleryItems) {
            UserDefaults.standard.set(encoded, forKey: "enhancefox_gallery")
        }
    }
    
    private func loadGalleryItems() {
        if let data = UserDefaults.standard.data(forKey: "enhancefox_gallery"),
           let decoded = try? JSONDecoder().decode([GalleryItem].self, from: data) {
            galleryItems = decoded
        }
    }
    
    func loadSampleImage(named name: String) -> UIImage? {
        let cleanName = (name as NSString).deletingPathExtension
        let ext = (name as NSString).pathExtension.isEmpty ? "jpg" : (name as NSString).pathExtension
        
        // 1. Check in asset catalog (by clean name or raw name)
        if let img = UIImage(named: cleanName) { return img }
        if let img = UIImage(named: name) { return img }
        
        // 2. Check in main app bundle
        if let path = Bundle.main.path(forResource: cleanName, ofType: ext),
           let img = UIImage(contentsOfFile: path) {
            return img
        }
        if let path = Bundle.main.path(forResource: name, ofType: nil),
           let img = UIImage(contentsOfFile: path) {
            return img
        }
        return nil
    }
}
