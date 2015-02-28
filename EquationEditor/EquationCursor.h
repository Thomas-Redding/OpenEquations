//
//  EquationCursor.h
//  EquationEditor
//
//  Created by Thomas Redding on 2/21/15.
//  Copyright (c) 2015 Thomas Redding. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EquationCursor : NSView

@property BOOL consistentHide;

- (void) changeState: (NSNumber*) counterAtCall;
- (void) show;
- (void) hide;

@end
