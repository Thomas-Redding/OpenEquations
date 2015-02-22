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
    // Insert code here to initialize your application
    self.fontManager = [[FontManager alloc] init];
    
    self.eqField = [[EquationField alloc] initWithFont:self.fontManager];
    [self.eqField setFrame: NSMakeRect(20, 20, 400, 300)];
    [self.eqField setAutoresizingMask: NSViewMaxXMargin | NSViewWidthSizable | NSViewHeightSizable];
    [self.window.contentView addSubview:self.eqField];
    [self.window makeFirstResponder:self.eqField];
    
    [self.window.contentView addSubview:self.t];
    
    [self.eqField completeRecalculation];
    
    NSLog(@"%@", [self.eqField toLaTeX]);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
