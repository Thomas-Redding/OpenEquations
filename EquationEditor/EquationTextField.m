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
    
    // Drawing code here.
}

- (EquationTextField*) init {
    self = [super init];
    [self setEditable:false];
    [self setBordered:false];
    [self setDrawsBackground:false];
    [self setFocusRingType:NSFocusRingTypeNone];
    [self setAllowsEditingTextAttributes:false];
    
    // delete me
    [self setDrawsBackground:true];
    [self setBackgroundColor:[NSColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.5]];
    return self;
}

- (EquationTextField*)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    [self setEditable:false];
    [self setBordered:false];
    [self setDrawsBackground:false];
    [self setFocusRingType:NSFocusRingTypeNone];
    [self setAllowsEditingTextAttributes:false];
    
    // delete me
    [self setDrawsBackground:true];
    [self setBackgroundColor:[NSColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:0.5]];
    
    return self;
}


@end
