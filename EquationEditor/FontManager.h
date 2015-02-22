//
//  FontManager.h
//  CharacterRenderer
//
//  Created by Thomas Redding on 1/17/15.
//  Copyright (c) 2015 Thomas Redding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface FontManager : NSObject

@property NSMutableArray *fonts;

- (FontManager*) init;
- (NSFont*) getFont: (double) s;
- (CTFontRef) fontFromBundle : (NSString*) fontName withHeight : (CGFloat) height;

@end
