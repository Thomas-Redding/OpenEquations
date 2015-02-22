//
//  EquationFieldComponent.h
//  EquationEditor
//
//  Created by Thomas Redding on 1/16/15.
//  Copyright (c) 2015 Thomas Redding. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EquationFieldComponentType.h"
#import "EquationTextField.h"
#import "FontManager.h"
#import "EquationFieldOptions.h"

@interface EquationFieldComponent : NSView

@property double heightRatio;
@property FontManager* fontManager;
@property EquationFieldOptions* options;

@property int childWithStartCursor;
@property int childWithEndCursor;
@property int startCursorLocation;
@property int endCursorLocation;

// is true if any part of the component should be highlighted
@property int isHighlighted;

@property EquationFieldComponentType eqFormat;
@property EquationTextField* eqTextField;
@property NSImageView* eqImageView;

/*
 - LEAF: No children
 - NORMAL: Children from left (0) to right (infinity)
 - DIVISION: Children from top (0) to bottom (1)
*/
@property NSMutableArray *eqChildren;

- (EquationFieldComponent*)initWithFontManagerAndOptions:(FontManager*)f options: (EquationFieldOptions*) o;
- (void) makeSizeRequest: (double) fontSize;
- (void) grantSizeRequest: (NSRect) rect;
- (void) addDescendantsToSubview;
- (BOOL) setStartCursorToEq: (double) x y: (double) y;
- (NSString*) toLaTeX;
- (void) completeMinorComponentShifts;

@end
