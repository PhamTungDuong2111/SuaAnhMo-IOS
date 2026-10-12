import SwiftUI
import Combine

enum AppLanguage: String, CaseIterable, Identifiable {
    case vi = "vi"
    case en = "en"
    
    var id: String { rawValue }
    var flag: String {
        switch self {
        case .vi: return "🇻🇳"
        case .en: return "🇬🇧"
        }
    }
    var displayName: String {
        switch self {
        case .vi: return "Tiếng Việt"
        case .en: return "English"
        }
    }
}

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @AppStorage("app_lang") private var storedLang: String = "vi"
    @Published var currentLanguage: AppLanguage = .vi
    
    init() {
        if storedLang == "en" {
            currentLanguage = .en
        } else {
            currentLanguage = .vi
        }
    }
    
    func toggle() {
        if currentLanguage == .vi {
            currentLanguage = .en
            storedLang = "en"
        } else {
            currentLanguage = .vi
            storedLang = "vi"
        }
    }
    
    func get(_ key: String) -> String {
        let dict = currentLanguage == .vi ? viDict : enDict
        return dict[key] ?? enDict[key] ?? key
    }
    
    private let viDict: [String: String] = [
        "app_name": "EnhanceFox AI",
        "app_tagline": "Sửa ảnh mờ & Phục chế kỷ niệm chuyên nghiệp",
        "tab_home": "Trang chủ",
        "tab_enhance": "Làm nét",
        "tab_colorize": "Tô màu AI",
        "tab_restore": "Phục chế",
        "tab_gallery": "Thư viện",
        "hero_badge": "Công nghệ AI Thế hệ mới",
        "hero_title": "Làm Nét Ảnh Mờ & Phục Chế Kỷ Niệm",
        "hero_desc": "Biến những bức ảnh mờ, nhòe, cũ kỹ thành ảnh có độ nét cực cao HD & 4K chỉ trong tích tắc trên iPhone.",
        "btn_start_now": "Bắt đầu làm nét ngay",
        "btn_try_sample": "Thử ảnh mẫu có sẵn",
        "quick_tools_title": "Công cụ AI nổi bật",
        "tool_enhance_title": "Làm nét & Khử mờ",
        "tool_enhance_desc": "Tăng chi tiết khuôn mặt, sửa ảnh out nét",
        "tool_colorize_title": "Tô màu ảnh đen trắng",
        "tool_colorize_desc": "Phục chế màu sắc sống động cho ảnh xưa",
        "tool_restore_title": "Phục chế ảnh cũ & Vết xước",
        "tool_restore_desc": "Xóa nếp gấp, vết xước, khử ố vàng",
        "sample_portrait_title": "Chân dung mờ nét",
        "sample_vintage_title": "Ảnh đen trắng 1950s",
        "select_photo": "Chọn ảnh từ Thư viện",
        "take_photo": "Chụp ảnh mới",
        "change_photo": "Đổi ảnh khác",
        "resolution_scale": "Độ phân giải đầu ra",
        "scale_1x": "Chuẩn HD (1X)",
        "scale_2x": "Ultra HD (2X)",
        "scale_4x": "Studio 4K (4X)",
        "strength_level": "Mức độ nét & Khử mờ",
        "strength_natural": "Tự nhiên",
        "strength_high": "Sắc nét cao",
        "strength_ultra": "Cực nét Ultra",
        "face_enhance": "Làm trong ánh mắt & Nét khuôn mặt",
        "face_enhance_desc": "Tái tạo độ chi tiết đồng tử, lông mi và nụ cười",
        "denoise": "Khử hạt nhiễu nền (Denoise)",
        "denoise_desc": "Làm mịn hạt nhiễu kỹ thuật số",
        "btn_process_enhance": "Bắt đầu khử mờ & Tăng nét AI",
        "btn_process_colorize": "Bắt đầu tô màu AI",
        "btn_process_restore": "Bắt đầu phục chế & Tẩy vết xước",
        "palette_title": "Bảng màu phục chế",
        "palette_natural": "Tự nhiên ấm áp (Da người & Cảnh)",
        "palette_vintage": "Hoài niệm (Vintage Kodachrome)",
        "palette_vibrant": "Tươi tắn hiện đại",
        "option_scratches": "Tẩy vết xước, nứt vỡ & Nếp gấp",
        "option_scratches_desc": "Thuật toán Inpainting tự xóa nếp gấp và vết nứt",
        "option_defade": "Khử ố vàng & Cân bằng tương phản",
        "option_defade_desc": "Tự động cân bằng sáng khử ố thời gian",
        "btn_save_gallery": "Lưu vào Photos",
        "btn_share": "Chia sẻ",
        "label_before": "GỐC",
        "label_after": "ĐÃ SỬA",
        "btn_zoom": "Phóng to 2.5X",
        "btn_zoom_out": "Thu nhỏ 1X",
        "btn_hold_compare": "Nhấn giữ xem GỐC",
        "saved_success": "Đã lưu ảnh thành công vào Photos của iPhone!",
        "processing_title": "Đang xử lý ảnh bằng AI...",
        "stage_analyzing": "Đang phân tích cấu trúc điểm ảnh...",
        "stage_deblurring": "Đang tái tạo biên độ viền & Khử mờ...",
        "stage_polishing": "Đang chuốt mịn chi tiết & Tối ưu màu...",
        "gallery_empty": "Chưa có ảnh nào được lưu",
        "gallery_empty_desc": "Các bức ảnh bạn xử lý sẽ xuất hiện tại đây."
    ]
    
    private let enDict: [String: String] = [
        "app_name": "EnhanceFox AI",
        "app_tagline": "AI Photo Enhancer & Memory Restoration",
        "tab_home": "Home",
        "tab_enhance": "Enhance",
        "tab_colorize": "Colorize",
        "tab_restore": "Restore",
        "tab_gallery": "Gallery",
        "hero_badge": "Next-Gen AI Technology",
        "hero_title": "Unblur Photos & Restore Memories",
        "hero_desc": "Transform blurry, low-res, vintage photos into crystal-clear HD & 4K master quality on iPhone.",
        "btn_start_now": "Start Enhancing Now",
        "btn_try_sample": "Try Built-in Samples",
        "quick_tools_title": "Featured AI Tools",
        "tool_enhance_title": "Unblur & Sharpen",
        "tool_enhance_desc": "Enhance facial details & fix out-of-focus blur",
        "tool_colorize_title": "AI Colorize B&W",
        "tool_colorize_desc": "Restore lifelike colors to vintage memories",
        "tool_restore_title": "Old Photo & Scratch Repair",
        "tool_restore_desc": "Remove tears, creases, and yellow age stains",
        "sample_portrait_title": "Blurry Portrait",
        "sample_vintage_title": "Vintage 1950s Photo",
        "select_photo": "Choose from Photos",
        "take_photo": "Take New Photo",
        "change_photo": "Change Photo",
        "resolution_scale": "Output Resolution",
        "scale_1x": "Standard HD (1X)",
        "scale_2x": "Ultra HD (2X)",
        "scale_4x": "Studio 4K (4X)",
        "strength_level": "Sharpness & Deblur Strength",
        "strength_natural": "Natural",
        "strength_high": "High Clarity",
        "strength_ultra": "Ultra Crisp",
        "face_enhance": "Enhance Eyes & Facial Details",
        "face_enhance_desc": "Refine pupil clarity, eyelashes, and smile texture",
        "denoise": "Background Denoising",
        "denoise_desc": "Smooth out digital camera sensor noise",
        "btn_process_enhance": "Start AI Deblur & Enhance",
        "btn_process_colorize": "Start AI Colorization",
        "btn_process_restore": "Start Scratch & Old Photo Repair",
        "palette_title": "Colorization Palette",
        "palette_natural": "Warm Natural (Skin & Scene)",
        "palette_vintage": "1970s Vintage Kodachrome",
        "palette_vibrant": "Modern Vibrant",
        "option_scratches": "Remove Scratches & Creases",
        "option_scratches_desc": "Inpainting filter fills cracks and tears",
        "option_defade": "Defade & Balance Contrast",
        "option_defade_desc": "Automatically eliminate yellow age stains",
        "btn_save_gallery": "Save to Photos",
        "btn_share": "Share",
        "label_before": "BEFORE",
        "label_after": "AFTER",
        "btn_zoom": "2.5X Detail Zoom",
        "btn_zoom_out": "1X View",
        "btn_hold_compare": "Hold to View BEFORE",
        "saved_success": "Photo saved successfully to iPhone Photos!",
        "processing_title": "Enhancing with AI...",
        "stage_analyzing": "Analyzing pixel structures...",
        "stage_deblurring": "Deblurring gradients & Steepening edges...",
        "stage_polishing": "Polishing textures & Micro-contrast...",
        "gallery_empty": "No saved photos yet",
        "gallery_empty_desc": "Photos you enhance will appear here."
    ]
}
