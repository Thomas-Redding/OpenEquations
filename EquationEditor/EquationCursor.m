//
//  EquationCursor.m
//  EquationEditor
//
//  Created by Thomas Redding on 2/21/15.
//  Copyright (c) 2015 Thomas Redding. All rights reserved.
//

#import "EquationCursor.h"

@implementation EquationCursor

int counter = 0;

- (EquationCursor*)init {
    self = [super init];
    [self show];
    self.consistentHide = false;
    return self;
}

- (EquationCursor*)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    [self show];
    self.consistentHide = false;
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    if(!self.isHidden) {
        [[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1.0] setFill];
        NSRectFill(dirtyRect);
    }
}

- (void) changeState: (NSNumber*) counterAtCall {
    if(counter == counterAtCall.intValue) {
        if(self.hidden && !self.consistentHide) {
            
            [self setHidden:false];
            [self performSelector:@selector(changeState:) withObject:[NSNumber numberWithInt:counter] afterDelay:0.5];
        }
        else {
            
            [self setHidden:true];
            [self performSelector:@selector(changeState:) withObject:[NSNumber numberWithInt:counter] afterDelay:0.5];
        }
    }
}

- (void) show {
    counter++;
    if(self.isHidden && !self.consistentHide) {
        [self setHidden:false];
        [self performSelector:@selector(changeState:) withObject:[NSNumber numberWithInt:counter] afterDelay:0.5];
    }
    else {
        [self performSelector:@selector(changeState:) withObject:[NSNumber numberWithInt:counter] afterDelay:0.5];
    }
}

- (void) hide {
    counter++;
    if(!self.isHidden) {
        [self setHidden:true];
        [self performSelector:@selector(changeState:) withObject:[NSNumber numberWithInt:counter] afterDelay:0.5];
    }
    else {
        [self performSelector:@selector(changeState:) withObject:[NSNumber numberWithInt:counter] afterDelay:0.5];
    }
}

@end
