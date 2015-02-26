//
//  EquationTextField.m
//  EquationEditor
//
//  Created by Thomas Redding on 2/20/15.
//  Copyright (c) 2015 Thomas Redding. All rights reserved.
//

#import "EquationTextField.h"

@implementation EquationTextField

- (void)drawRect:(NSRect)dirtyRect {
    // for debugging - highlights all EquationTextFields (i.e. all TextFields) in translucent red
    /*
    [[NSColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.1] setFill];
    NSRectFill(dirtyRect);
    */
    [super drawRect:dirtyRect];
}

- (EquationTextField*) init {
    self = [super init];
    [self setEditable:false];
    [self setBordered:false];
    [self setDrawsBackground:false];
    [self setFocusRingType:NSFocusRingTypeNone];
    [self setAllowsEditingTextAttributes:false];
    self.containsCursor = false;
    return self;
}

- (EquationTextField*)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    [self setEditable:false];
    [self setBordered:false];
    [self setDrawsBackground:false];
    [self setFocusRingType:NSFocusRingTypeNone];
    [self setAllowsEditingTextAttributes:false];
    self.containsCursor = false;
    return self;
}


@end
