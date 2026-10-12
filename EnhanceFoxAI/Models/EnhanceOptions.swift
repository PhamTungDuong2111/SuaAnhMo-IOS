import SwiftUI

enum EnhanceTab: String, CaseIterable, Identifiable {
    case home
    case enhance
    case colorize
    case restore
    case gallery
    
    var id: String { rawValue }
}

enum SharpnessStrength: String, CaseIterable, Identifiable {
    case natural
    case high
    case ultra
    
    var id: String { rawValue }
}

enum ColorizePalette: String, CaseIterable, Identifiable {
    case naturalWarm
    case vintage1970s
    case modernVibrant
    
    var id: String { rawValue }
}

struct EnhanceOptions {
    var scale: Int = 1
    var strength: SharpnessStrength = .high
    var faceEnhance: Bool = true
    var denoise: Bool = true
    var palette: ColorizePalette = .naturalWarm
    var removeScratches: Bool = true
    var defade: Bool = true
}

struct GalleryItem: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var mode: String
    var fileName: String
    var timestamp: Date = Date()
}
