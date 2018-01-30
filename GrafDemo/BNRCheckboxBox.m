#import "BNRCheckboxBox.h"

@interface BNRCheckboxBox ()
@property(strong) NSButtonCell *buttonCell; // for the checkbox
@end // extension


@implementation BNRCheckboxBox
@synthesize enabled = _enabled;

- (void) awakeFromNib {
    [super awakeFromNib];
    self.enabled = YES;
    
    self.buttonCell = [[NSButtonCell alloc] initTextCell: self.title];
    [self.buttonCell setButtonType: NSSwitchButton];
    self.buttonCell.state = NSOnState;

    self.buttonCell.target = self;
    self.buttonCell.action = @selector(toggleEnabledState:);

    [self.buttonCell setControlView:self];

    _titleCell = self.buttonCell;

} // awakeFromNib


- (void) walkView: (NSView *) view  settingEnabled: (BOOL) enabled {
    if (view != self && [view respondsToSelector: @selector(setEnabled:)]) {
        [(id)view setEnabled: enabled];
    }
    
    if ([view isKindOfClass: NSTextField.class]) {
        [(id)view setTextColor: (enabled) ? NSColor.controlTextColor : NSColor.disabledControlTextColor];
    }
    
    for (NSView *subview in view.subviews) {
        [self walkView: subview  settingEnabled: enabled];
    }
    
} // walkView


- (void) setContentEnabledState: (BOOL) enabled {
    [self walkView: self  settingEnabled: enabled];
} // setContentEnabledState


- (void) toggleEnabledState: (id) sender {
    self.enabled = !self.enabled;
    [self setContentEnabledState: self.enabled];
    
    [NSApp sendAction: self.action  to: self.target  from: self];
} // toggleEnabledState


- (void) setEnabled: (BOOL) enabled {
    _enabled = enabled;
    [self setContentEnabledState: enabled];
    self.buttonCell.state = enabled ? NSOnState : NSOffState;
} // setEnabled


- (BOOL) isEnabled {
    return _enabled;
} // isEnabled


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
