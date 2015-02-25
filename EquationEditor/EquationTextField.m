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
