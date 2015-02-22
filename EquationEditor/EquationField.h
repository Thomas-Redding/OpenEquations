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
@property EquationFieldOptions* options;
@property EquationCursor *cursor;

- (EquationField*) initWithFont: (FontManager*) f;
- (void) completeRecalculation;
- (NSString*) toLaTeX;

@end
