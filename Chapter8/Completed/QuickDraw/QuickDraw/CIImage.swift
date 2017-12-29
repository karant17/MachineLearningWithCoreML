//
//  CIImage.swift
//  QuickDraw
//
//  Created by Joshua Newnham on 29/12/2017.
//  Copyright © 2017 Method. All rights reserved.
//

import UIKit

extension CIImage{
    
    /**
     Return a horizintally flipped version of this instance
    */
    func flipHorizontal() -> CIImage {        
        return self.transformed(by: CGAffineTransform(scaleX: -1.0, y: 1.0))
    }
    
    /**
     Return a resized version of this instance (centered)
     */
    func resize(size: CGSize) -> CIImage {
        // Calculate how much we need to scale down our image
        let scale = size.width / self.extent.size.width
        
        let resizedImage = self.transformed(
            by: CGAffineTransform(
                scaleX: scale,
                y: scale))
        
        // Center the image
        let width = resizedImage.extent.width
        let height = resizedImage.extent.height
        let yOffset = (CGFloat(height) - size.height) / 2.0
        let rect = CGRect(x: (CGFloat(width) - size.width) / 2.0,
                          y: yOffset,
                          width: size.width,
                          height: size.height)
        return resizedImage.cropped(to: rect)
    }
    
    /**
     Property that returns a Core Video pixel buffer (CVPixelBuffer) of the image.
     CVPixelBuffer is a Core Video pixel buffer (or just image buffer) that holds pixels in main memory. Applications generating frames, compressing or decompressing video, or using Core Image can all make use of Core Video pixel buffers.
     https://developer.apple.com/documentation/corevideo/cvpixelbuffer
     */
    func toPixelBuffer(context:CIContext, gray:Bool=true) -> CVPixelBuffer?{
        // Create a dictionary requesting Core Graphics compatibility
        let attributes = [
            kCVPixelBufferCGImageCompatibilityKey:kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey:kCFBooleanTrue
            ] as CFDictionary
        
        // Create a pixel buffer at the size our model needs
        var nullablePixelBuffer: CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(self.extent.size.width),
                                         Int(self.extent.size.height),
                                         gray ? kCVPixelFormatType_OneComponent8 : kCVPixelFormatType_32ARGB,
                                         attributes,
                                         &nullablePixelBuffer)
        
        // Evaluate staus and unwrap nullablePixelBuffer
        guard status == kCVReturnSuccess, let pixelBuffer = nullablePixelBuffer
            else { return nil }
        
        // Render the CIImage to our CVPixelBuffer and return it
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        context.render(self,
                       to: pixelBuffer,
                       bounds: CGRect(x: 0,
                                      y: 0,
                                      width: self.extent.size.width,
                                      height: self.extent.size.height),
                       colorSpace:gray ?
                        CGColorSpaceCreateDeviceGray() :
                        self.colorSpace)
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}
