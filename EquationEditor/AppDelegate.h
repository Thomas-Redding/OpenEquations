//
//  AppDelegate.h
//  EquationEditor
//
//  Created by Thomas Redding on 1/11/15.
//  Copyright (c) 2015 Thomas Redding. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EquationField.h"

/*
 TODO
 - customize/fix highlighting for non-Normal components
*/

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property EquationField *eqField;
@property FontManager *fontManager;

@end
