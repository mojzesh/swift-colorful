import Foundation
import AppKit
import Colorful

public func savePNG(image: NSImage, path:String) -> Bool {
    let imageRep = NSBitmapImageRep(data: image.tiffRepresentation!)
    let pngData = imageRep?.representation(using: .png, properties: [:])
    do {
        try pngData?.write(to: URL(fileURLWithPath: path))
    }
    catch {
        return false
    }
    return true
}

public func createImageRep(_ size: NSSize) -> (NSImage, NSBitmapImageRep) {
    let image = NSImage(size: size)

    let imageRep = NSBitmapImageRep(bitmapDataPlanes: nil,
        pixelsWide: Int(image.size.width),
        pixelsHigh: Int(image.size.height),
        bitsPerSample: 8,
        samplesPerPixel: 3,
        hasAlpha: false,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0, bitsPerPixel: 0)!

    image.addRepresentation(imageRep)
    return (image, imageRep)
}

public func drawRect(imageRep: NSBitmapImageRep, rect: NSRect, color: Color) {
    let (r, g, b) = color.RGB255()
    var col: [Int] = [Int(r), Int(g), Int(b)]
    for posx in stride(from: 0, to: rect.size.width, by: 1) {
        for posy in stride(from: 0, to: rect.size.height, by: 1) {
            imageRep.setPixel(&col, atX: Int(rect.origin.x+posx), y: Int(rect.origin.y+posy))
        }
    }
}

public func setPixel(imageRep: NSBitmapImageRep, pos: NSPoint, color: Color) {
    let (r, g, b) = color.RGB255()
    var col: [Int] = [Int(r), Int(g), Int(b)]
    imageRep.setPixel(&col, atX: Int(pos.x), y: Int(pos.y))
}
