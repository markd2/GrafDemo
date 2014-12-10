//
//  BNRCheckboxBox.m
//  GrafDemo
//
//  Created by Mark Dalrymple on 12/8/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import "BNRCheckboxBox.h"

@interface BNRCheckboxBox ()
@property (assign) BOOL contentEnabled;
@end // extension


@implementation BNRCheckboxBox

- (void) awakeFromNib {
    [super awakeFromNib];

    self.contentEnabled = YES;
    
    NSButtonCell *buttonCell = [[NSButtonCell alloc] initTextCell: @"Bork"];
    [buttonCell setButtonType: NSSwitchButton];
    buttonCell.state = NSOnState;

    buttonCell.target = self;
    buttonCell.action = @selector(toggleEnabledState:);

    [buttonCell setControlView:self];

    _titleCell = buttonCell;

} // awakeFromNib


- (void) walkView: (NSView *) view  settingEnabled: (BOOL) enabled {
    if ([view respondsToSelector: @selector(setEnabled:)]) {
        [(id)view setEnabled: enabled];
    }
    
    for (NSView *subview in view.subviews) {
        [self walkView: subview  settingEnabled: enabled];
    }
    
} // walkView


- (void) setContentEnabledState: (BOOL) enabled {
    [self walkView: self  settingEnabled: enabled];
} // setContentEnabledState



- (void) toggleEnabledState: (id) sender {
    self.contentEnabled = !self.contentEnabled;
    [self setContentEnabledState: self.contentEnabled];
} // toggleEnabledState



- (void) mouseDown:(NSEvent *)theEvent {
    CGPoint localPoint = [self convertPoint: theEvent.locationInWindow
                                   fromView: nil];
    if (CGRectContainsPoint(self.titleRect, localPoint)) {
        // TODO(markd 10-DEC-2014): this doesn't draw properly when tracking the mouse.
        [self.titleCell trackMouse: theEvent
                            inRect: self.titleRect
                            ofView: self
                      untilMouseUp: YES];
    } else {
        [super mouseDown: theEvent];
    }
    
} // mouseDown


@end // BNRCheckboxBox
