//
//  HeightForWidthManager.m
//  HeightForWidth
//
//  Created by Richard Hult on 2009-10-14, with revisions by Sam Stigler on 2012-03-01.
//  Copyright 2009 Richard Hult. All rights reserved.
//

#import "HeightForWidthLayoutManager.h"

#define BOTTOM_MARGIN 0;

@implementation HeightForWidthLayoutManager

- (NSFont *)fontForTextLayer:(CATextLayer *)layer
{    
    NSFont *font = nil;
    
    // Convert the separate font and font size to an NSFont. There are four different ways
    // to specify the font used in CATextLayer: NSFont/CTFontRef, NSString, CGFontRet.
    if ([(id)layer.font isKindOfClass:[NSFont class]]) {
        font = [NSFont fontWithName:[(NSFont *)layer.font fontName] size:layer.fontSize];
    }
    else if ([(id)layer.font isKindOfClass:[NSString class]]) {
        font = [NSFont fontWithName:(NSString *)layer.font size:layer.fontSize];
    } else {
        CFTypeID typeID = CFGetTypeID(layer.font);
        if (typeID == CGFontGetTypeID()) {
            // ... we ignore this here, could be implemented later.
        }
    }
    
    return font;
}

- (NSAttributedString *)attributedStringForTextLayer:(CATextLayer *)layer
{
    // We have two different cases, self.string can be either an NSString or NSAttributedString.
    // Those need to be handled differently, as the font/fontSize properties are not used in
    // in the attributed string case.
    
    if ([layer.string isKindOfClass:[NSAttributedString class]]) {
        return layer.string;
    }
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[self fontForTextLayer:layer]
                                                           forKey:NSFontAttributeName];
    
    return [[NSAttributedString alloc] initWithString:layer.string
                                           attributes:attributes];
}

// verified 2/23/2012 that this returns the correct size for sstigler user.
- (CGSize)frameSizeForTextLayer:(CATextLayer *)layer
{
    if ([layer string] == nil) {
        return CGSizeZero;
    }
    
    NSAttributedString *string = [self attributedStringForTextLayer:layer];
    CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)string);
    CGFloat width = layer.bounds.size.width;
    
    CFIndex offset = 0, length;
    CGFloat y = 0;
    do {
        length = CTTypesetterSuggestLineBreak(typesetter, offset, width);
        CTLineRef line = CTTypesetterCreateLine(typesetter, CFRangeMake(offset, length));
        
        CGFloat ascent, descent, leading;
        CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        
        CFRelease(line);
        
        offset += length;
        y += ascent + descent + leading;
    } while (offset < [string length]);
    
    CFRelease(typesetter);
    return CGSizeMake(width, ceil(y));
}

- (CGSize)preferredSizeOfLayer:(CALayer *)layer
{
    if ([layer isKindOfClass:[CATextLayer class]] && ((CATextLayer *)layer).wrapped) {
        CGRect bounds = layer.bounds;
        bounds.size = [self frameSizeForTextLayer:(CATextLayer *)layer];
        if (bounds.origin.y < 0) {
            bounds.origin.y -= bounds.origin.y;
        }
        bounds.origin.y += 3;
        layer.bounds = bounds;
    }
    
    return [super preferredSizeOfLayer:layer];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    // First let the regular constraints kick in to set the width of text layers.
    [super layoutSublayersOfLayer:layer];
    
    // Now adjust the height of any wrapped text layers, as their widths are known.
    for (CALayer *child in [layer sublayers]) {
        if ([child isKindOfClass:[CATextLayer class]]) {
            [self preferredSizeOfLayer:(CATextLayer *)child];
            CGRect frame = child.frame;
            if (frame.origin.y < 0) {
                frame.origin.y -= child.frame.origin.y;
            }
            frame.origin.y += BOTTOM_MARGIN; // bottom margin
            child.frame = frame;
        }
    }
    
    // Then let the regular constraints adjust any values that depend on heights.
}

@end
