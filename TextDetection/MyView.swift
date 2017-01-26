//
//  MyView.swift
//  TextDetection
//
//  Created by Friedrich HAEUPL on 26.01.17.
//  Copyright © 2017 Friedrich HAEUPL. All rights reserved.
//
//  https://gist.github.com/Koze/bc6aa304744dc243ad48
//

import Cocoa

class MyView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        NSLog("dirtyRect = \(dirtyRect)")
        
        // Drawing code here.
        
        // avoid optional unwrapping later :
        // 1
        guard let fileURL = Bundle.main.url(forResource: "text", withExtension: "jpg")
            else
        {
            NSLog("ciImage doesn't exist")
            return
        }
        // 2
        guard let ciImage = CIImage(contentsOf: fileURL)
            else
        {
            NSLog("ciImage not loaded")
            return
        }
        
        // 3    get size of the image
        let ciImageSize = ciImage.extent.size
        NSLog("ciImage extent \(ciImage.extent)")
        
        // 4    convert CIImage to NSImage
        let rep: NSCIImageRep = NSCIImageRep(ciImage: ciImage)
        let nsImage: NSImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        
        // 5    draw it
        nsImage.draw(in: self.bounds, from:NSZeroRect ,operation:.sourceOver, fraction:1)
        
        // --------
        let options = [CIDetectorReturnSubFeatures: true]
        
        let textDetector = CIDetector(ofType: CIDetectorTypeText, context: nil, options: options)!

        // retrive array of CITextFeature
        let texts = textDetector.features(in: ciImage)
        
        for text in texts as! [CITextFeature] {
            //if let face = faces.first as? CIFaceFeature {
            NSLog("---------")

            NSLog("Found texts at \(text.bounds) of \(texts.count) texts")
            //
            var textViewBounds = text.bounds
            
            // Calculate the actual position and size of the rectangle in the image view
            let viewSize = dirtyRect.size
            
            // scale correctly
            let scale_w = viewSize.width / (ciImageSize.width)
            let scale_h = viewSize.height / (ciImageSize.height)
            let offsetX = (viewSize.width - (ciImageSize.width) * scale_w) / 2.0
            let offsetY = (viewSize.height - (ciImageSize.height) * scale_h) / 2.0
            
            textViewBounds = textViewBounds.applying(CGAffineTransform(scaleX: scale_w, y: scale_h))
            textViewBounds.origin.x += offsetX
            textViewBounds.origin.y += offsetY
            NSLog("textViewBounds is \(textViewBounds)")
            
            NSColor.red.set()
            let path:NSBezierPath = NSBezierPath()
            path.appendRect(textViewBounds)
            
            path.stroke()
            
        }
        
    }
    
}
