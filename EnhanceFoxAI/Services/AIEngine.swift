import UIKit
import CoreGraphics
import Accelerate

final class AIEngine {
    static let shared = AIEngine()
    private init() {}
    
    // Fast separable 1D sliding box blur on float luminance
    private func fastBoxBlur(src: [Float], w: Int, h: Int, r: Int) -> [Float] {
        var tmp = [Float](repeating: 0, count: w * h)
        var out = [Float](repeating: 0, count: w * h)
        let mul = 1.0 / Float(2 * r + 1)
        
        // Horizontal pass
        for y in 0..<h {
            let rowOffset = y * w
            var sum: Float = 0.0
            for k in -r...r {
                let x = max(0, min(w - 1, k))
                sum += src[rowOffset + x]
            }
            tmp[rowOffset] = sum * mul
            for x in 1..<w {
                let left = max(0, x - r - 1)
                let right = min(w - 1, x + r)
                sum += src[rowOffset + right] - src[rowOffset + left]
                tmp[rowOffset + x] = sum * mul
            }
        }
        
        // Vertical pass
        for x in 0..<w {
            var sum: Float = 0.0
            for k in -r...r {
                let y = max(0, min(h - 1, k))
                sum += tmp[y * w + x]
            }
            out[x] = sum * mul
            for y in 1..<h {
                let top = max(0, y - r - 1)
                let bottom = min(h - 1, y + r)
                sum += tmp[bottom * w + x] - tmp[top * w + x]
                out[y * w + x] = sum * mul
            }
        }
        
        return out
    }
    
    // AI Deblur & Super Resolution
    func enhanceImage(
        image: UIImage,
        options: EnhanceOptions = EnhanceOptions(),
        onProgress: ((Int) -> Void)? = nil
    ) -> UIImage? {
        onProgress?(10)
        
        let normalized = image.fixOrientation()
        guard let cgImage = normalized.cgImage else { return nil }
        let srcW = cgImage.width
        let srcH = cgImage.height
        
        var multiplier: CGFloat = 1.0
        if options.scale == 2 { multiplier = 2.0 }
        if options.scale == 4 { multiplier = 2.5 } // Safe clamp for iOS memory limits
        
        var targetW = Int(CGFloat(srcW) * multiplier)
        var targetH = Int(CGFloat(srcH) * multiplier)
        let maxDim = 2400
        if targetW > maxDim || targetH > maxDim {
            let ratio = min(CGFloat(maxDim) / CGFloat(targetW), CGFloat(maxDim) / CGFloat(targetH))
            targetW = Int(CGFloat(targetW) * ratio)
            targetH = Int(CGFloat(targetH) * ratio)
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * targetW
        var pixelData = [UInt8](repeating: 0, count: targetH * bytesPerRow)
        
        guard let context = CGContext(
            data: &pixelData,
            width: targetW,
            height: targetH,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else { return nil }
        
        context.interpolationQuality = .high
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: targetW, height: targetH))
        
        onProgress?(30)
        
        let totalPixels = targetW * targetH
        var lum = [Float](repeating: 0, count: totalPixels)
        for i in 0..<totalPixels {
            let offset = i * 4
            let r = Float(pixelData[offset])
            let g = Float(pixelData[offset + 1])
            let b = Float(pixelData[offset + 2])
            lum[i] = 0.299 * r + 0.587 * g + 0.114 * b
        }
        
        onProgress?(45)
        
        let blurFine = fastBoxBlur(src: lum, w: targetW, h: targetH, r: 1)
        let blurMacro = fastBoxBlur(src: lum, w: targetW, h: targetH, r: 4)
        
        onProgress?(65)
        
        let detailWeight: Float = options.strength == .natural ? 1.6 : (options.strength == .ultra ? 3.8 : 2.6)
        let contourWeight: Float = options.strength == .natural ? 1.3 : (options.strength == .ultra ? 3.0 : 2.2)
        let contrastBoost: Float = options.strength == .natural ? 1.06 : (options.strength == .ultra ? 1.20 : 1.14)
        let noiseThresh: Float = options.denoise ? 6.0 : 3.0
        
        for i in 0..<totalPixels {
            let origL = lum[i]
            let fineL = blurFine[i]
            let macroL = blurMacro[i]
            let d1 = origL - fineL
            let d2 = fineL - macroL
            
            let deltaL: Float
            if abs(d1) < noiseThresh {
                deltaL = options.denoise ? (-0.35 * d1 + d2 * 0.4) : (d1 * 0.6 + d2 * 0.8)
            } else {
                deltaL = d1 * detailWeight + d2 * contourWeight
            }
            
            var newL = origL + deltaL
            if options.faceEnhance {
                let norm = newL / 255.0
                let curve = norm > 0.5
                    ? norm + pow(norm - 0.5, 2) * 0.45 * (contrastBoost - 1.0)
                    : norm - pow(0.5 - norm, 2) * 0.45 * (contrastBoost - 1.0)
                newL = curve * 255.0
            }
            newL = max(0.0, min(255.0, newL))
            
            let diff = newL - origL
            let offset = i * 4
            var r = Float(pixelData[offset]) + diff
            var g = Float(pixelData[offset + 1]) + diff
            var b = Float(pixelData[offset + 2]) + diff
            
            // Vibrancy polish
            let gray = 0.299 * r + 0.587 * g + 0.114 * b
            r = gray + (r - gray) * 1.12
            g = gray + (g - gray) * 1.12
            b = gray + (b - gray) * 1.12
            
            pixelData[offset] = UInt8(max(0, min(255, Int(round(r)))))
            pixelData[offset + 1] = UInt8(max(0, min(255, Int(round(g)))))
            pixelData[offset + 2] = UInt8(max(0, min(255, Int(round(b)))))
        }
        
        onProgress?(90)
        
        guard let resultCG = context.makeImage() else { return nil }
        onProgress?(100)
        return UIImage(cgImage: resultCG)
    }
    
    // AI Colorizer
    func colorizeImage(
        image: UIImage,
        palette: ColorizePalette = .naturalWarm,
        onProgress: ((Int) -> Void)? = nil
    ) -> UIImage? {
        onProgress?(15)
        let normalized = image.fixOrientation()
        guard let cgImage = normalized.cgImage else { return nil }
        let w = cgImage.width
        let h = cgImage.height
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * w
        var pixelData = [UInt8](repeating: 0, count: h * bytesPerRow)
        
        guard let context = CGContext(
            data: &pixelData,
            width: w,
            height: h,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else { return nil }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: w, height: h))
        let totalPixels = w * h
        
        // Check if grayscale
        var totalSat: Float = 0.0
        let step = max(1, totalPixels / 4000)
        var samples = 0
        var p = 0
        while p < totalPixels {
            let offset = p * 4
            let r = Float(pixelData[offset])
            let g = Float(pixelData[offset + 1])
            let b = Float(pixelData[offset + 2])
            let maxC = max(r, max(g, b))
            let minC = min(r, min(g, b))
            totalSat += (maxC - minC) / (maxC + 1.0)
            samples += 1
            p += step
        }
        let isGrayscale = (totalSat / Float(max(1, samples))) < 0.14
        
        onProgress?(40)
        
        for i in 0..<totalPixels {
            let offset = i * 4
            let rOrig = Float(pixelData[offset])
            let gOrig = Float(pixelData[offset + 1])
            let bOrig = Float(pixelData[offset + 2])
            let l = 0.299 * rOrig + 0.587 * gOrig + 0.114 * bOrig
            let normL = l / 255.0
            
            var r: Float
            var g: Float
            var b: Float
            
            if isGrayscale {
                switch palette {
                case .naturalWarm:
                    if normL < 0.22 {
                        r = l * 1.12
                        g = l * 0.98
                        b = l * 0.94
                    } else if normL < 0.72 {
                        let t = (normL - 0.22) / 0.50
                        r = l * (1.30 + 0.08 * (1.0 - t))
                        g = l * (1.04 + 0.06 * t)
                        b = l * (0.82 + 0.16 * t)
                    } else {
                        let t = (normL - 0.72) / 0.28
                        r = l * (1.06 + 0.04 * t)
                        g = l * (1.04 + 0.02 * t)
                        b = l * (0.94 + 0.12 * t)
                    }
                case .vintage1970s:
                    r = l * 1.28 + 14.0
                    g = l * 1.06 + 4.0
                    b = l * 0.82
                case .modernVibrant:
                    if normL < 0.25 {
                        r = l * 1.08
                        g = l * 0.95
                        b = l * 1.02
                    } else if normL < 0.70 {
                        r = l * 1.34
                        g = l * 1.08
                        b = l * 0.88
                    } else {
                        r = l * 1.10
                        g = l * 1.10
                        b = l * 1.05
                    }
                }
            } else {
                switch palette {
                case .vintage1970s:
                    r = rOrig * 1.12 + 10.0
                    g = gOrig * 1.02 + 4.0
                    b = bOrig * 0.90
                case .modernVibrant:
                    r = l + (rOrig - l) * 1.28
                    g = l + (gOrig - l) * 1.28
                    b = l + (bOrig - l) * 1.28
                default:
                    r = l + (rOrig - l) * 1.18 + 4.0
                    g = l + (gOrig - l) * 1.14 + 1.0
                    b = l + (bOrig - l) * 1.10
                }
            }
            
            pixelData[offset] = UInt8(max(0, min(255, Int(round(r)))))
            pixelData[offset + 1] = UInt8(max(0, min(255, Int(round(g)))))
            pixelData[offset + 2] = UInt8(max(0, min(255, Int(round(b)))))
        }
        
        onProgress?(75)
        
        guard let colorizedCG = context.makeImage() else { return nil }
        let colorizedImg = UIImage(cgImage: colorizedCG)
        
        // Polish with clarity pass
        let polished = enhanceImage(
            image: colorizedImg,
            options: EnhanceOptions(scale: 1, strength: .natural, faceEnhance: true, denoise: true)
        ) { p in
            onProgress?(75 + Int(Float(p) * 0.25))
        }
        
        onProgress?(100)
        return polished ?? colorizedImg
    }
    
    // AI Old Photo Restore (Scratch Repair & Defade)
    func restoreOldPhoto(
        image: UIImage,
        removeScratches: Bool = true,
        defade: Bool = true,
        onProgress: ((Int) -> Void)? = nil
    ) -> UIImage? {
        onProgress?(15)
        let normalized = image.fixOrientation()
        guard let cgImage = normalized.cgImage else { return nil }
        let w = cgImage.width
        let h = cgImage.height
        guard w > 2, h > 2 else { return normalized }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * w
        var pixelData = [UInt8](repeating: 0, count: h * bytesPerRow)
        
        guard let context = CGContext(
            data: &pixelData,
            width: w,
            height: h,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else { return nil }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: w, height: h))
        let totalPixels = w * h
        
        // 1. Defade & Auto-Levels
        if defade {
            var minR = 255; var maxR = 0
            var minG = 255; var maxG = 0
            var minB = 255; var maxB = 0
            for i in 0..<totalPixels {
                let offset = i * 4
                let r = Int(pixelData[offset])
                let g = Int(pixelData[offset + 1])
                let b = Int(pixelData[offset + 2])
                minR = min(minR, r); maxR = max(maxR, r)
                minG = min(minG, g); maxG = max(maxG, g)
                minB = min(minB, b); maxB = max(maxB, b)
            }
            let rangeR = max(1, maxR - minR)
            let rangeG = max(1, maxG - minG)
            let rangeB = max(1, maxB - minB)
            
            for i in 0..<totalPixels {
                let offset = i * 4
                let r = Int(pixelData[offset])
                let g = Int(pixelData[offset + 1])
                let b = Int(pixelData[offset + 2])
                pixelData[offset] = UInt8(max(0, min(255, ((r - minR) * 255) / rangeR)))
                pixelData[offset + 1] = UInt8(max(0, min(255, ((g - minG) * 255) / rangeG)))
                pixelData[offset + 2] = UInt8(max(0, min(255, ((b - minB) * 255) / rangeB)))
            }
        }
        
        onProgress?(50)
        
        // 2. Scratch & Crease Inpainting
        if removeScratches {
            let copy = pixelData
            for y in 1..<(h - 1) {
                for x in 1..<(w - 1) {
                    let idx = (y * w + x) * 4
                    let curL = 0.299 * Float(copy[idx]) + 0.587 * Float(copy[idx + 1]) + 0.114 * Float(copy[idx + 2])
                    
                    let topIdx = ((y - 1) * w + x) * 4
                    let botIdx = ((y + 1) * w + x) * 4
                    let lftIdx = (y * w + (x - 1)) * 4
                    let rgtIdx = (y * w + (x + 1)) * 4
                    
                    let topL = 0.299 * Float(copy[topIdx]) + 0.587 * Float(copy[topIdx + 1]) + 0.114 * Float(copy[topIdx + 2])
                    let botL = 0.299 * Float(copy[botIdx]) + 0.587 * Float(copy[botIdx + 1]) + 0.114 * Float(copy[botIdx + 2])
                    let lftL = 0.299 * Float(copy[lftIdx]) + 0.587 * Float(copy[lftIdx + 1]) + 0.114 * Float(copy[lftIdx + 2])
                    let rgtL = 0.299 * Float(copy[rgtIdx]) + 0.587 * Float(copy[rgtIdx + 1]) + 0.114 * Float(copy[rgtIdx + 2])
                    
                    let avgL = (topL + botL + lftL + rgtL) * 0.25
                    
                    // If severe tear/crack
                    if abs(curL - avgL) > 42.0 {
                        pixelData[idx] = UInt8((Int(copy[topIdx]) + Int(copy[botIdx]) + Int(copy[lftIdx]) + Int(copy[rgtIdx])) / 4)
                        pixelData[idx + 1] = UInt8((Int(copy[topIdx + 1]) + Int(copy[botIdx + 1]) + Int(copy[lftIdx + 1]) + Int(copy[rgtIdx + 1])) / 4)
                        pixelData[idx + 2] = UInt8((Int(copy[topIdx + 2]) + Int(copy[botIdx + 2]) + Int(copy[lftIdx + 2]) + Int(copy[rgtIdx + 2])) / 4)
                    }
                }
            }
        }
        
        onProgress?(75)
        
        guard let restoredCG = context.makeImage() else { return nil }
        let restoredImg = UIImage(cgImage: restoredCG)
        
        let polished = enhanceImage(
            image: restoredImg,
            options: EnhanceOptions(scale: 1, strength: .high, faceEnhance: true, denoise: true)
        ) { p in
            onProgress?(75 + Int(Float(p) * 0.25))
        }
        
        onProgress?(100)
        return polished ?? restoredImg
    }
}

// MARK: - UIImage Orientation Helper
extension UIImage {
    func fixOrientation() -> UIImage {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalized ?? self
    }
}
