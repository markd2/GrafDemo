//
//  BNRLinesView.h
//  GrafDemo
//
//  Created by Mark Dalrymple on 12/8/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BNRLinesView;
typedef void (^BNRLinesViewPreRenderHook)(BNRLinesView *linesView, CGContextRef cgContext);


typedef NS_ENUM(NSInteger, BNRLinesViewRenderMode) {
    kRenderModeSinglePath,     // make one path and stroke it
    kRenderModeMultiplePaths,  // one stroke per line segment
    kRenderModeSegments        // use CGContextStrokeLineSegments
};

@interface BNRLinesView : NSView

@property (copy) BNRLinesViewPreRenderHook preRenderHook;
@property (assign) BNRLinesViewRenderMode renderMode;

@end
