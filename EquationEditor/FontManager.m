//
//  FontManager.m
//  CharacterRenderer
//
//  Created by Thomas Redding on 1/17/15.
//  Copyright (c) 2015 Thomas Redding. All rights reserved.
//

#import "FontManager.h"

@implementation FontManager

- (FontManager*) init {
    self.fonts = [[NSMutableArray alloc] init];
    // 100 = maximum font size
    for(int i=0; i<100; i++) {
        [self.fonts addObject:[NSNumber numberWithInt:5]];
    }
    [self loadFontSize:12];
    return self;
}

- (void) loadFontSize: (int) size {
    CTFontRef bundleFont = [self fontFromBundle:@"latinmodern-math" withHeight:size];
    // CTFontRef bundleFont = [self fontFromBundle:@"STIXMathJax_Main-Italic" withHeight:size];
    NSFont* font = (__bridge NSFont*)bundleFont;
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    
    
    
    
    [fontManager convertFont:font toHaveTrait:NSItalicFontMask];
    [self.fonts setObject:font atIndexedSubscript:size];
}

- (NSFont*) getFont: (double) s {
    int size = (int) s;
    if(size > 0 & size < self.fonts.count) {
        if([self.fonts[size] respondsToSelector:@selector(intValue)]) {
            [self loadFontSize:size];
        }
        return self.fonts[size];
    }
    return nil;
}

- (CTFontRef) fontFromBundle : (NSString*) fontName withHeight : (CGFloat) height;
{
    // Get the path to our custom font and create a data provider.
    NSString* fontPath = [[NSBundle mainBundle] pathForResource : fontName ofType : @"otf" ];
    if(nil==fontPath)
        return NULL;
    
    CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename ([fontPath UTF8String]);
    if(NULL==dataProvider)
        return NULL;
    
    // Create the font with the data provider, then release the data provider.
    CGFontRef fontRef = CGFontCreateWithDataProvider (dataProvider);
    if(NULL == fontRef)
    {
        CGDataProviderRelease (dataProvider);
        return NULL;
    }
    
    CTFontRef fontCore = CTFontCreateWithGraphicsFont(fontRef, height, NULL, NULL);
    CGDataProviderRelease(dataProvider);
    CGFontRelease(fontRef);
    
    return fontCore;
}

@end
