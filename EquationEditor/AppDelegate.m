//
//  AppDelegate.m
//  EquationEditor
//
//  Created by Thomas Redding on 1/11/15.
//  Copyright (c) 2015 Thomas Redding. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Create a font manager to manage your fonts
    self.fontManager = [[FontManager alloc] init];
    
    // create the equation field and give it the font manager (note: all equation fields in an application may use the same font manager)
    self.eqField = [[EquationField alloc] initWithFont:self.fontManager];
    
    // set up the equation field
    [self.eqField setFrame: NSMakeRect(20, 20, 400, 300)];
    [self.eqField setAutoresizingMask: NSViewMaxXMargin | NSViewWidthSizable | NSViewHeightSizable];
    [self.window.contentView addSubview:self.eqField];
    [self.window makeFirstResponder:self.eqField];
    
    // print the current equation as LaTeX
    NSLog(@"%@", [self.eqField toLaTeX]);
    
    /*
     This recalculates the formating of the equation.
     It is usually unneccessary (it is unneccessary in this case), as the object should automatically detect when it needs to recalculate.
     The object automatically recalculates when either of the following occur
     1. The field's frame is set (either through the autoresizingMask or manually)
     2. The user changes the equation
     
     The main time that an applicaiton must tell the field to recalculate is when an option is changed (though the change will take effect once one of the above conditions occurs).
    */
    
    self.eqField.options.maxFontSize = 50;
    
    [self.eqField completeRecalculation];
    
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
