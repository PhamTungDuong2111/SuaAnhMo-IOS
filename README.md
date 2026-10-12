# EnhanceFox AI - Sửa Ảnh Mờ & Phục Chế Kỷ Niệm (iOS Native App)

> **Dự án iOS Native thuần (Swift 5.9 + SwiftUI + CoreGraphics / Accelerate)**  
> **Bundle Identifier:** `com.enhancefox.photoenhancer`  
> **iOS Deployment Target:** iOS 16.0+ (Tương thích iPhone 11, 12, 13, 14, 15, 16 và iPadOS)  
> **Mục tiêu:** Ứng dụng khôi phục ảnh mờ, làm nét chân dung, tô màu ảnh đen trắng và tẩy vết xước ảnh cũ chuyên nghiệp trên iPhone với chức năng song ngữ **Tiếng Việt 🇻🇳 & Tiếng Anh 🇬🇧**.

---

## 🦊 Các tính năng nổi bật chuẩn iOS Native (Tương đương 100% bản Android)

1. **Làm nét & Khử mờ (AI Deblur & Super Resolution):**
   - Thuật toán unsharp masking đa tầng (Multi-Scale Luminance Decomposition) tối ưu tốc độ cao.
   - Tự động chuẩn hóa xoay ảnh EXIF / Camera orientation (`fixOrientation`), khắc phục triệt để lỗi ảnh bị xoay ngang trên iPhone.
   - Tùy chọn độ phân giải: **HD Tiêu chuẩn (1X), Ultra HD (2X), Studio 4K (4X)**.
   - Chế độ nét: **Tự nhiên, Sắc nét cao, Cực nét Ultra**.
   - Làm trong ánh mắt & Nét khuôn mặt (Face Beautify) + Khử hạt nhiễu thích ứng (Adaptive Denoising).

2. **Tô màu ảnh đen trắng (AI Colorizer):**
   - Tự động nhận diện ảnh đen trắng hoặc ảnh màu phai nhạt.
   - 3 bảng màu phục chế chuẩn xác: **Tự nhiên ấm áp (Natural Warm)**, **Màu hoài niệm 1970s (Vintage Kodachrome)**, **Tươi tắn hiện đại (Modern Vibrant)**.

3. **Phục chế ảnh cũ & Tẩy vết xước (Old Photo Restore):**
   - Xóa nếp gấp, nứt rách bằng thuật toán nội suy trung vị 2D Directional Median Inpainting.
   - Tự động cân bằng sáng, khử màu ố vàng loang lổ thời gian (Auto-levels Defade).

4. **Thanh trượt so sánh Trước & Sau (Split Screen Slider):**
   - Vuốt kéo mượt mà 60/120 FPS trên màn hình Promotion của iPhone.
   - Khắc phục xung đột cảm ứng vuốt màn hình (Zero gesture conflict).
   - Phóng to 2.5X xem cận cảnh chi tiết điểm ảnh.
   - Nhấn giữ xem tức thì ảnh gốc (Hold to view before).
   - Hiệu ứng tia quét laser AI phát sáng công nghệ cao trong lúc xử lý.

5. **Chọn ảnh linh hoạt & Chụp ảnh trực tiếp từ Camera:**
   - Hỗ trợ chọn ảnh từ Thư viện qua `PhotosPicker` (iOS 16+).
   - Hỗ trợ chụp ảnh trực tiếp bằng Camera iPhone qua `UIImagePickerController`.
   - Nút **Thử ảnh mẫu có sẵn** trực tiếp ngay trên từng màn hình công cụ (giống bản Android).

6. **Ảnh mẫu có sẵn tích hợp trong app:**
   - `sample_portrait.jpg`: Chân dung mờ nét để trải nghiệm ngay.
   - `sample_vintage.jpg`: Ảnh đen trắng phục chế vết xước và tô màu.

7. **Chuyển đổi song ngữ tức thì:**
   - Nút đổi nhanh **🇻🇳 Tiếng Việt <-> 🇬🇧 English** ở thanh tiêu đề trên cùng.

8. **Thư viện ảnh đã lưu (Gallery Screen) & Chia sẻ:**
   - Quản lý danh sách các ảnh đã sửa kèm nhãn công cụ và mốc thời gian (HH:mm dd/MM).
   - Nhấn vào ảnh để xem toàn màn hình (Full-screen preview).
   - Lưu trực tiếp vào **Photos (Cuộn camera)** của iPhone qua Photos Framework (`PHPhotoLibrary`).
   - Chia sẻ nhanh qua AirDrop, Tin nhắn, Zalo, Messenger qua `UIActivityViewController`.

---

## 📊 Bảng so sánh tính năng iOS vs Android

| Tính năng | Bản Android (Kotlin/Compose) | Bản iOS (Swift/SwiftUI) | Trạng thái |
| :--- | :---: | :---: | :---: |
| Giao diện Dark Modern Theme | ✅ Material 3 | ✅ Native SwiftUI | Đã đồng bộ 100% |
| Khử mờ & Tăng nét đa tầng | ✅ AIEngine (Kotlin) | ✅ AIEngine (Swift) | Đã đồng bộ 100% |
| Tùy chọn 1X / 2X / 4X | ✅ Có | ✅ Có | Đã đồng bộ 100% |
| Mức nét Tự nhiên / Cao / Ultra | ✅ Có | ✅ Có | Đã đồng bộ 100% |
| Nét mặt & Khử nhiễu Denoise | ✅ Có | ✅ Có | Đã đồng bộ 100% |
| Tô màu đen trắng (3 palette) | ✅ Có | ✅ Có | Đã đồng bộ 100% |
| Phục chế xước & Khử ố vàng | ✅ Inpainting | ✅ Inpainting | Đã đồng bộ 100% |
| Thanh trượt trước/sau + Zoom 2.5X | ✅ ComparisonSlider | ✅ ComparisonSliderView | Đã đồng bộ 100% |
| Chụp ảnh bằng Camera | ✅ Có | ✅ Có (`CameraPickerView`) | Đã đồng bộ 100% |
| Chọn ảnh từ Thư viện | ✅ MediaPicker | ✅ PhotosPicker | Đã đồng bộ 100% |
| Nút thử ảnh mẫu tại chỗ | ✅ Có | ✅ Có | Đã đồng bộ 100% |
| Chuyển ngữ Song ngữ Việt - Anh | ✅ Có | ✅ Có | Đã đồng bộ 100% |
| Quản lý Thư viện nội bộ | ✅ Có | ✅ Có | Đã đồng bộ 100% |
| Xem trước ảnh đã lưu | ✅ Có | ✅ Có | Đã đồng bộ 100% |
| Lưu ảnh vào máy & Chia sẻ | ✅ MediaStore + Share | ✅ PHPhotoLibrary + Share | Đã đồng bộ 100% |

---

## 📱 Hướng dẫn mở và build trên máy Mac & iPhone thật

### Bước 1: Sao chép thư mục sang máy Mac
Chép toàn bộ thư mục `SuaAnhMo-IOS` sang máy Mac (qua AirDrop, Google Drive, hoặc USB).

### Bước 2: Mở dự án trong Xcode
1. Trên máy Mac, nhấp đúp vào tệp:
   👉 **`EnhanceFoxAI.xcodeproj`**
2. Xcode sẽ mở dự án lên ngay lập tức (không cần cài đặt Pods hay SPM bên ngoài vì dự án dùng 100% Native Apple Frameworks).

### Bước 3: Cấu hình tài khoản Apple ID để chạy trên iPhone thật (Miễn phí)
1. Trong Xcode, chọn mục **EnhanceFoxAI** ở cây thư mục bên trái (mục trên cùng có biểu tượng màu xanh).
2. Chọn tab **Signing & Capabilities**.
3. Tại dòng **Team**, nhấn chọn tài khoản Apple ID của bạn (nếu chưa có, bấm **Add Account...** và đăng nhập Apple ID cá nhân của bạn, không cần tài khoản Developer trả phí).
4. Dòng **Bundle Identifier** sẽ tự động được kích hoạt.

### Bước 4: Cắm iPhone thật vào máy Mac và nhấn Run
1. Cắm iPhone vào máy Mac bằng dây cáp (trên iPhone chọn **Tin cậy máy tính này / Trust This Computer**).
2. Ở thanh công cụ trên cùng của Xcode (cạnh nút Run hình tam giác), nhấp vào menu thiết bị và chọn tên **iPhone của bạn** (ví dụ: *iPhone của Admin*).
3. Nhấn tổ hợp phím **Cmd + R** (hoặc bấm nút **Play / Run** màu xám).
4. Xcode sẽ tự động biên dịch, ký số và cài đặt ứng dụng trực tiếp lên iPhone của bạn.

> **Lưu ý nhỏ lần đầu chạy trên iPhone thật:**  
> Trên iPhone, vào **Cài đặt (Settings) -> Cài đặt chung (General) -> Quản lý VPN & Thiết bị (VPN & Device Management)** -> Chọn Apple ID của bạn và bấm **Tin cậy (Trust)** để mở app.
