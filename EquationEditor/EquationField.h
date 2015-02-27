//
//  EquationField.h
//  EquationEditor
//
//  Created by Thomas Redding on 1/11/15.
//  Copyright (c) 2015 Thomas Redding. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

#import "EquationFieldComponent.h"
#import "FontManager.h"
#import "EquationCursor.h"
#import "EquationTextField.h"

@interface EquationField : NSView

@property EquationFieldComponent *eq;
@property FontManager* fontManager;
@property EquationCursor *cursor;

- (EquationField*) initWithFont: (FontManager*) f;
- (void) completeRecalculation;             // completely redo formating based on self.eq and its descendants
- (NSString*) toLaTeX;                      // convert the current equation into LaTeX

// Setting Options

- (double) maxFontSize;                     // the maximum font size that will be displayed (should never exceed 99)
- (double) divisionDecayRate;               // ratio between the font-size of the numerator (denominator) to the text surrounding the fraction
- (double) superscriptDecayRate;            // ratio between the font-size of a superscript to the text to its left
- (double) squarerootDecayRate;

// Check EquationFieldOptions for default values
- (void) setMaxFontSize: (double) newSize;
- (void) setDivisionDecayRate: (double) newRate;
- (void) setSuperscriptDecayRate: (double) newRate;
- (void) setSquarerootDecayRate: (double) newRate;

- (void) setMinSizeOfSummationSymbolRelativeToTermHeight: (double) newRatio;
- (double) minSizeOfSummationSymbolRelativeToTermHeight;

- (double) minFontSize;                     // how small the smallest font-size can be
- (void) setMinFontSize:(double) newSize;

@end
