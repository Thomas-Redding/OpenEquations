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
@property double relativeSize;
@property double requestGrantRatio;
@property FontManager* fontManager;
@property EquationFieldOptions* options;

@property int childWithStartCursor;
@property int childWithEndCursor;
@property int startCursorLocation;
@property int endCursorLocation;
@property BOOL shouldBeCompletelyHighlighted;
@property int highlightLeafLeft;
@property int highlightLeafRight;

@property EquationFieldComponentType eqFormat;
@property EquationTextField* eqTextField;
@property NSImageView* eqImageView;
@property NSImageView* eqImageViewB;
@property EquationFieldComponent *parent;

/*
 - LEAF:
    Children: None
    Other: Has a EquationTextField
 - NORMAL:
    Children: leftmost (0), ... rightmost
    Other: None
 - DIVISION:
    Children: top (0), bottom (1) - these children are either LEAFs or NORMALs
    Other: Draws a horizontal line between its children
 - SUPERSCRIPT:
    Children: 1 child - the child is always either a LEAF or a NORMAL
*/
@property NSMutableArray *eqChildren;

- (EquationFieldComponent*)initWithFontManagerOptionsAndParent:(FontManager*)f options: (EquationFieldOptions*) o parent: (EquationFieldComponent*) p;
// request space
- (void) makeSizeRequest: (double) fontSize;
// accept the space given by parent; give children space
- (void) grantSizeRequest: (NSRect) rect;
// remove everyone from current subview and add all children to subview
- (void) addDescendantsToSubview;
// pass information on to correct child involving where to send the cursor; if a LEAF, place the cursor at the correct spot
- (BOOL) setStartCursorToEq: (double) x y: (double) y;
// convert self to LaTex (recursively call children)
- (NSString*) toLaTeX;
// shift component's x positions to eliminate unneccessary space that occurs due to the fact that font sizes must be integers
- (void) completeMinorComponentShifts;
// erase the integers that say where the cursor (or highlighting endpoints) currently is (are)
- (void) resetAllCursorPointers;

- (void) simplifyStructure;
- (void) deleteMyChildren;
- (void) addHundredToWidth;
- (NSArray*) toArray;
- (void) callAllDrawRects;
- (void) calculateHighlights: (int) condition isStartLeft: (int) isStartLeft;
- (void) highlightLeft;
- (void) highlightRight;
- (void) undoHighlighting;
- (void) setEndCursorEq: (double) x y: (double) y;
- (void) deleteHighlightedPart;

@end
