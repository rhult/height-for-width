//
//  AppDelegate.m
//  HeightForWidth
//
//  Created by Richard Hult on 2009-10-14.
//  Copyright 2009 Richard Hult. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "HeightForWidthLayoutManager.h"

#define MARGIN  20
#define PADDING 10


@implementation AppDelegate

@synthesize window;

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application
{
    return YES;
}

- (NSDictionary *)nullActions
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNull null], @"bounds",
            [NSNull null], @"position",
            [NSNull null], @"contents",
            nil];
}

- (void)awakeFromNib
{
    // A black background layer.
    CALayer *backgroundLayer = [CALayer layer];
    backgroundLayer.backgroundColor = CGColorGetConstantColor(kCGColorWhite);
    backgroundLayer.layoutManager = [HeightForWidthLayoutManager layoutManager];

    // A blue gradient as background for the text.
    CAGradientLayer *textBackgroundLayer = [CAGradientLayer layer];
    textBackgroundLayer.colors = [NSArray arrayWithObjects:
                                  NSMakeCollectable(CGColorCreateGenericRGB(0.0, 0.0, 0.3, 1)),
                                  NSMakeCollectable(CGColorCreateGenericRGB(0.1, 0.1, 0.4, 1)),
                                  nil];
    textBackgroundLayer.cornerRadius = 6;
    textBackgroundLayer.shadowOpacity = 1;
    
    // We don't want animated changes of the bounds, position and contents, as it
    // looks weird when the contents of the box doesn't follow the box's bounds as
    // it changes size.
    textBackgroundLayer.actions = [self nullActions];

    // Make the text background follow the width of the background with some margin,
    // positioned towards the bottom.
    [textBackgroundLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidX
                                                                  relativeTo:@"text"
                                                                   attribute:kCAConstraintMidX]];
    [textBackgroundLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintWidth
                                                                  relativeTo:@"text"
                                                                   attribute:kCAConstraintWidth
                                                                      offset:2 * PADDING]];
    [textBackgroundLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidY
                                                                  relativeTo:@"text"
                                                                   attribute:kCAConstraintMidY]];
    [textBackgroundLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintHeight
                                                                  relativeTo:@"text"
                                                                   attribute:kCAConstraintHeight
                                                                      offset:2 * PADDING]];
    
    [backgroundLayer addSublayer:textBackgroundLayer];
    
    // Add our custom text layer.
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.name = @"text";
    textLayer.font = @"Lucida Grande";
    textLayer.fontSize = 18;
    NSString *string = (@"This is a text layer with some text in it, "
                        @"hopefully long enough to be wrapped if the "
                        @"window is not too large.");
    textLayer.string = string;
    textLayer.foregroundColor = CGColorGetConstantColor(kCGColorWhite);
    textLayer.wrapped = YES;

    // Again, we want no animations.
    textLayer.actions = [self nullActions];

    // Center the text on the background layer, at the bottom. Make it follow the width
    // of the background with some margin.
    [textLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidX
                                                        relativeTo:@"superlayer"
                                                         attribute:kCAConstraintMidX]];
    [textLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinY
                                                        relativeTo:@"superlayer"
                                                         attribute:kCAConstraintMinY
                                                            offset:MARGIN + PADDING]];
    [textLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintWidth
                                                        relativeTo:@"superlayer"
                                                         attribute:kCAConstraintWidth
                                                            offset:-2 * (PADDING + MARGIN)]];
    
    [backgroundLayer addSublayer:textLayer];

    // Set up the view for layer-hosting.
    [[window contentView] setLayer:backgroundLayer];
    [[window contentView] setWantsLayer:YES];
}

@end
