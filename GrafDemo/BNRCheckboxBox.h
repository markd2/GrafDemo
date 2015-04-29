//
//  BNRCheckboxBox.h
//  GrafDemo
//
//  Created by Mark Dalrymple on 12/8/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

// NSBox subclass with a checkbox for a title that enables/disables its contents.

#import <Cocoa/Cocoa.h>

@interface BNRCheckboxBox : NSBox

@property (assign, getter=isEnabled) BOOL enabled;

@property (weak) id target;
@property SEL action;

@end // BNRCheckboxBox


