//
//  EquationField.m
//  EquationEditor
//
//  Created by Thomas Redding on 1/11/15.
//  Copyright (c) 2015 Thomas Redding. All rights reserved.
//

#import "EquationField.h"

@implementation EquationField

EquationFieldOptions* options;
NSMutableArray *undoList;
int undoListCurrentIndex;
int cursorCounter = 0;
double minFontSize;

- (EquationField*) initWithFont: (FontManager*) f {
    self = [super init];
    self.fontManager = f;
    options = [[EquationFieldOptions alloc] init];
    minFontSize = 18;
    
    [self setWantsLayer:YES];
    double shade = 1; // system background: 0.905882353;
    self.layer.backgroundColor = ([NSColor colorWithCalibratedRed:shade green:shade blue:shade alpha:0.0]).CGColor;
    
    self.eq = [[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:nil];
    self.eq.eqFormat = LEAF;
    self.eq.eqTextField = [[EquationTextField alloc] init];
    
    [self addSubview:self.eq];
    [self.eq addDescendantsToSubview];
    
    self.cursor = [[EquationCursor alloc] init];
    [self addSubview:self.cursor];
    
    undoList = [[NSMutableArray alloc] init];
    undoListCurrentIndex = -1;
    [self addToUndoList];
    
    return self;
}

- (void) completeRecalculation {
    // make preliminary size requests
    [self.eq makeSizeRequest:options.maxFontSize];
    
    double bufferWidth = 0.1;
    
    double ratio = fmin((self.frame.size.width*(1-bufferWidth))/(self.eq.frame.size.width), self.frame.size.height/self.eq.frame.size.height);
    if(ratio > 1) {
        ratio = 1;
    }
    
    // set minimum font size to 24 pt
    options.minFontSizeAsRatioOfMaxFontSize = (self.minFontSize/ratio)/options.maxFontSize;
    
    // if minimum font size is too big to fit in the view, use the highest minimum font size that does fit
    if(options.minFontSizeAsRatioOfMaxFontSize > 1) {
        options.minFontSizeAsRatioOfMaxFontSize = 1;
    }
    
    // make final size requests
    [self.eq makeSizeRequest:options.maxFontSize];
    ratio = fmin(self.frame.size.width/self.eq.frame.size.width, self.frame.size.height/self.eq.frame.size.height);
    if(ratio > 1) {
        ratio = 1;
    }
    
    // finish recalculation
    [self.eq grantSizeRequest: NSMakeRect(1, (self.frame.size.height - self.eq.frame.size.height * ratio)/2, self.eq.frame.size.width * ratio, self.eq.frame.size.height * ratio)];
    
    [self.eq completeMinorComponentShifts];
    [self adjustCursorLocation];
    [self.eq addDescendantsToSubview];
    [self.eq addHundredToWidth];
}

- (NSString*) toLaTeX {
    return [self.eq toLaTeX];
}

// OPTIONS

- (void) setMaxFontSize: (double) newSize {
    options.maxFontSize = newSize;
    [self completeRecalculation];
}
- (void) setDivisionDecayRate: (double) newRate {
    options.divisionDecayRate = newRate;
    [self completeRecalculation];
}
- (void) setSuperscriptDecayRate: (double) newRate {
    options.superscriptDecayRate = newRate;
    [self completeRecalculation];
}
- (void) setSquarerootDecayRate: (double) newRate {
    options.squarerootDecayRate = newRate;
    [self completeRecalculation];
}
- (void) setMinFontSize: (double)newSize {
    minFontSize = newSize;
    [self completeRecalculation];
}

- (double) maxFontSize {
    return options.maxFontSize;
}
- (double) divisionDecayRate {
    return options.divisionDecayRate;
}
- (double) superscriptDecayRate {
    return options.superscriptDecayRate;
}
- (double) squarerootDecayRate {
    return options.squarerootDecayRate;
}
- (double) minFontSize {
    return minFontSize;
}

- (void) setMinSizeOfSummationSymbolRelativeToTermHeight: (double) newRatio {
    options.minSizeOfSummationSymbolRelativeToTermHeight = newRatio;
    [self completeRecalculation];
}
- (double) minSizeOfSummationSymbolRelativeToTermHeight {
    return options.minSizeOfSummationSymbolRelativeToTermHeight;
}


// USER INTERACTION

- (void) reshape {
}

- (void) magnifyWithEvent:(NSEvent *)theEvent {
}

- (void) scrollWheel:(NSEvent *)theEvent {
}

- (void) mouseDragged:(NSEvent *)theEvent {
}

- (void) mouseDown:(NSEvent *)theEvent {
    NSPoint pt = [self.window mouseLocationOutsideOfEventStream];
    pt.x -= self.frame.origin.x;
    pt.y -= self.frame.origin.y;
    [self.eq resetAllCursorPointers];
    [self setStartCursorToEq:pt.x y:pt.y];
}

- (void) mouseUp:(NSEvent *)theEvent {
}

- (void) keyDown:(NSEvent *)theEvent {
    
    if(theEvent.keyCode == 36) {
        // return key
    }
    else if(theEvent.keyCode == 48) {
        // tab key
    }
    else if(theEvent.keyCode == 51) {
        // delete key
        [self deleteKeyPressed];
    }
    else if(theEvent.keyCode == 123) {
        // left-arrow
        if(theEvent.modifierFlags & NSShiftKeyMask) {
            // shift-left (highlighting)
        }
        else {
            // normal left
            [self leftArrowPressed];
        }
    }
    else if(theEvent.keyCode == 124) {
        // right-arrow
        [self rightArrowPressed];
    }
    else if(theEvent.keyCode == 125) {
        // down-arrow
    }
    else if(theEvent.keyCode == 126) {
        // up-arrow
    }
    else if(theEvent.keyCode == 0 && (theEvent.modifierFlags & NSCommandKeyMask)) {
        // command + A
        // highlight all
        // todo
    }
    else if(theEvent.keyCode == 6 && (theEvent.modifierFlags & NSCommandKeyMask) && (theEvent.modifierFlags & NSShiftKeyMask)) {
        // command + shift + Z
        // redo
        [self redo];
    }
    else if(theEvent.keyCode == 6 && (theEvent.modifierFlags & NSCommandKeyMask)) {
        // command + Z
        // undo
        [self undo];
    }
    else if(theEvent.characters.length == 1) {
        // insert character
        if(self.eq.childWithEndCursor != -1) {
            // something is currently highlighted
        }
        else {
            BOOL success = [self insertCharacter:theEvent.characters];
            if(success) {
                [self addToUndoList];
            }
        }
    }
    else {
        NSLog(@"Unknown Character");
    }
}

- (void) rightMouseDown: (NSEvent*) theEvent {
    // mouse drop-down menu
    NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
    [theMenu insertItemWithTitle:@"Save Image as PNG" action:@selector(saveImageAsPNG) keyEquivalent:@"" atIndex:0];
    [theMenu insertItemWithTitle:@"Delete Equation" action:@selector(deleteEquation) keyEquivalent:@"" atIndex:0];
    [theMenu insertItemWithTitle:@"Copy LateX to Clipboard" action:@selector(latexToClipBoard) keyEquivalent:@"" atIndex:0];
    [NSMenu popUpContextMenu:theMenu withEvent:theEvent forView:self];
}

- (void) saveImageAsPNG {
    
    [self.cursor hide];
    
    NSData *data = [self dataWithPDFInsideRect:[self bounds]];
    NSImage *img = [[NSImage alloc] initWithData:data];
    
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)[img TIFFRepresentation], NULL);
    CGImageRef maskRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);
    
    NSBitmapImageRep *imgRep = [[NSBitmapImageRep alloc] initWithCGImage:maskRef];
    NSData *exportedData = [imgRep representationUsingType:NSPNGFileType properties:nil];
    
    NSSavePanel *savepanel = [NSSavePanel savePanel];
    savepanel.title = @"Save chart";
    
    [savepanel setAllowedFileTypes:[NSArray arrayWithObjects:@"png", nil]];
    
    
    [savepanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result)
     {
         if(NSFileHandlingPanelOKButton == result)
         {
             NSURL* fileURL = [savepanel URL];
             if ([fileURL.pathExtension isEqualToString:@""])
                 fileURL = [fileURL URLByAppendingPathExtension:@"png"];
             [exportedData writeToURL:fileURL atomically:YES];
         }
     }];
    
    [self.cursor show];
}

- (void) deleteEquation {
    [self.eq deleteMyChildren];
    [self.eq removeFromSuperview];
    self.eq = [[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:nil];
    self.eq.eqFormat = LEAF;
    self.eq.eqTextField = [[EquationTextField alloc] init];
    self.eq.startCursorLocation = 0;
    [self completeRecalculation];
}

- (void) latexToClipBoard {
    NSString *str = [self toLaTeX];
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    NSArray *copiedObjects = [NSArray arrayWithObject:str];
    [pasteboard writeObjects:copiedObjects];
}

- (void) undo {
    if(undoListCurrentIndex > 0) {
        undoListCurrentIndex--;
        [self deleteEquation];
        self.eq = [self constructComponentByArray:undoList[undoListCurrentIndex] parent:nil];
        [self addSubview:self.eq];
        [self completeRecalculation];
    }
}

- (void) redo {
    if(undoListCurrentIndex < undoList.count-1) {
        undoListCurrentIndex++;
        [self deleteEquation];
        self.eq = [self constructComponentByArray:undoList[undoListCurrentIndex] parent:nil];
        [self addSubview:self.eq];
        [self completeRecalculation];
    }
}

// OTHER OVERRIDDEN METHODS

// draw background color
- (void) drawRect:(NSRect)dirtyRect {
    [[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0] setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

- (void) setFrame:(NSRect)frame {
    [super setFrame:frame];
    // [self completeRecalculation];
}

- (BOOL) acceptsFirstResponder {
    return YES;
}

- (BOOL) becomeFirstResponder {
    return YES;
}

- (BOOL) resignFirstResponder {
    return YES;
}

- (void) resetCursorRects {
    [self addCursorRect:self.frame cursor:[NSCursor IBeamCursor]];
}

// OTHER (HELPER) FUNCTIONS

- (void) addToUndoList {
    if(undoListCurrentIndex != (int) undoList.count - 1) {
        [undoList removeObjectsInRange:NSMakeRange(undoListCurrentIndex+1, undoList.count-undoListCurrentIndex-1)];
    }
    [undoList addObject:[self.eq toArray]];
    undoListCurrentIndex++;
}

- (EquationFieldComponent*) constructComponentByArray: (NSArray*) array parent: (EquationFieldComponent*) parent {
    if(array.count == 0) {
        NSLog(@"Error with Undo");
        // error
        return nil;
    }
    
    EquationFieldComponent *rtn = [[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:parent];
    if(array.count == 1) {
        // leaf
        rtn.eqFormat = LEAF;
        rtn.eqTextField = [[EquationTextField alloc] init];
        NSDictionary *attr = @{NSFontAttributeName : [self.fontManager getFont:12]};
        rtn.eqTextField.attributedStringValue = [[NSAttributedString alloc] initWithString:array[0] attributes:attr];
    }
    else if([array[0] isEqual: @"DIVISION"]) {
        // division
        rtn.eqFormat = DIVISION;
    }
    else if([array[0] isEqual: @"SUPERSCRIPT"]) {
        // superscript
        rtn.eqFormat = SUPERSCRIPT;
    }
    else if([array[0] isEqual: @"SQUAREROOT"]) {
        // square-root
        rtn.eqFormat = SQUAREROOT;
        NSString *pathToImage = [[NSString alloc] initWithString:[[NSBundle mainBundle] pathForImageResource:@"root.png"]];
        NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 50, 50)];
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:pathToImage];
        [imageView setImage:image];
        [rtn setEqImageView:imageView];
    }
    else if([array[0] isEqual: @"SUMMATION"]) {
        // summation
        rtn.eqFormat = SUMMATION;
        NSString *pathToImage = [[NSString alloc] initWithString:[[NSBundle mainBundle] pathForImageResource:@"summation.png"]];
        NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 50, 50)];
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:pathToImage];
        [imageView setImage:image];
        [rtn setEqImageView:imageView];
    }
    else if([array[0] isEqual: @"INTEGRATION"]) {
        // integration
        rtn.eqFormat = INTEGRATION;
        NSString *pathToImage = [[NSString alloc] initWithString:[[NSBundle mainBundle] pathForImageResource:@"integration.png"]];
        NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 50, 50)];
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:pathToImage];
        [imageView setImage:image];
        [rtn setEqImageView:imageView];
    }
    else if([array[0] isEqual: @"LOGBASE"]) {
        // logbase
        rtn.eqFormat = LOGBASE;
        NSString *pathToImage = [[NSString alloc] initWithString:[[NSBundle mainBundle] pathForImageResource:@"log.png"]];
        NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 50, 50)];
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:pathToImage];
        [imageView setImage:image];
        [rtn setEqImageView:imageView];
    }
    else if([array[0] isEqual: @"NORMAL"]) {
        rtn.eqFormat = NORMAL;
    }
    
    for(int i=1; i<array.count; i++) {
        [rtn.eqChildren addObject:[self constructComponentByArray:array[i] parent:rtn]];
    }
    
    return rtn;
}

- (void) deleteKeyPressed {
    if(self.eq.childWithEndCursor != -1) {
        [self deleteHighlighted];
    }
    else {
        EquationFieldComponent *componentWithCursor = self.eq;
        while(componentWithCursor.childWithStartCursor != -1) {
            componentWithCursor = componentWithCursor.eqChildren[componentWithCursor.childWithStartCursor];
        }
        if(componentWithCursor.startCursorLocation == -1) {
            // error
            return;
        }
        
        NSString *strA;
        if(componentWithCursor.startCursorLocation == 0) {
            // delete a component
            if(componentWithCursor.eqFormat == LEAF) {
                // highlight component to left
                // todo
            }
            else {
                // highlight self
                // todo
            }
        }
        else {
            // delete a single character
            strA = [componentWithCursor.eqTextField.stringValue substringToIndex:componentWithCursor.startCursorLocation-1];
            NSString *strB = [componentWithCursor.eqTextField.stringValue substringFromIndex:componentWithCursor.startCursorLocation];
            NSString *newString = [NSString stringWithFormat:@"%@%@", strA, strB];
            NSDictionary *attr = [componentWithCursor.eqTextField.attributedStringValue attributesAtIndex:0 effectiveRange:nil];
            componentWithCursor.eqTextField.attributedStringValue = [[NSAttributedString alloc] initWithString:newString attributes:attr];
            componentWithCursor.startCursorLocation--;
            [self completeRecalculation];
        }
    }
}

- (void) deleteHighlighted {
    // todo
}

- (BOOL) insertDivision {
    EquationFieldComponent *componentWithCursor = self.eq;
    while(componentWithCursor.childWithStartCursor != -1) {
        componentWithCursor = componentWithCursor.eqChildren[componentWithCursor.childWithStartCursor];
    }
    if(componentWithCursor.startCursorLocation == -1) {
        // error
        return false;
    }
    
    NSString *strA;
    NSString *strB;
    NSDictionary *attr;
    
    if([componentWithCursor.eqTextField.stringValue isEqual: @""]) {
        strA = @"";
        strB = @"";
        attr = @{NSFontAttributeName : [self.fontManager getFont:componentWithCursor.frame.size.height-1]};
    }
    else {
        strA = [componentWithCursor.eqTextField.stringValue substringToIndex:componentWithCursor.startCursorLocation];
        strB = [componentWithCursor.eqTextField.stringValue substringFromIndex:componentWithCursor.startCursorLocation];
        attr = [componentWithCursor.eqTextField.attributedStringValue attributesAtIndex:0 effectiveRange:nil];
    }
    
    componentWithCursor.eqFormat = NORMAL;
    
    [componentWithCursor.eqChildren addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor]];
    [componentWithCursor.eqChildren[0] setEqFormat: LEAF];
    [componentWithCursor.eqChildren[0] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
    [componentWithCursor.eqChildren[0] eqTextField].stringValue = strA;
    
    [componentWithCursor.eqChildren addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor]];
    [componentWithCursor.eqChildren[1] setEqFormat:DIVISION];
    [[componentWithCursor.eqChildren[1] eqChildren] addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor.eqChildren[1]]];
    [[componentWithCursor.eqChildren[1] eqChildren][0] setEqFormat:LEAF];
    [[componentWithCursor.eqChildren[1] eqChildren][0] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
    [[componentWithCursor.eqChildren[1] eqChildren][0] eqTextField].attributedStringValue = [[NSAttributedString alloc] initWithString:@"" attributes:attr];
    [[componentWithCursor.eqChildren[1] eqChildren] addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor.eqChildren[1]]];
    [[componentWithCursor.eqChildren[1] eqChildren][1] setEqFormat:LEAF];
    [[componentWithCursor.eqChildren[1] eqChildren][1] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
    [[componentWithCursor.eqChildren[1] eqChildren][1] eqTextField].attributedStringValue = [[NSAttributedString alloc] initWithString:@"" attributes:attr];
    
    [componentWithCursor.eqChildren addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor]];
    [componentWithCursor.eqChildren[2] setEqFormat: LEAF];
    [componentWithCursor.eqChildren[2] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
    [componentWithCursor.eqChildren[2] eqTextField].stringValue = strB;
    componentWithCursor.startCursorLocation = -1;
    componentWithCursor.childWithStartCursor = 1;
    [componentWithCursor.eqChildren[1] setChildWithStartCursor:0];
    
    [[componentWithCursor.eqChildren[1] eqChildren][0] setStartCursorLocation:0];
    
    [self.eq simplifyStructure];
    
    return true;
}

- (BOOL) insertSuperscript {
    EquationFieldComponent *componentWithCursor = self.eq;
    while(componentWithCursor.childWithStartCursor != -1) {
        componentWithCursor = componentWithCursor.eqChildren[componentWithCursor.childWithStartCursor];
    }
    if(componentWithCursor.startCursorLocation == -1) {
        // error
        return false;
    }
    
    NSString *strA;
    NSString *strB;
    NSDictionary *attr;
    
    if([componentWithCursor.eqTextField.stringValue isEqual: @""]) {
        strA = @"";
        strB = @"";
        attr = @{NSFontAttributeName : [self.fontManager getFont:componentWithCursor.frame.size.height-1]};
    }
    else {
        strA = [componentWithCursor.eqTextField.stringValue substringToIndex:componentWithCursor.startCursorLocation];
        strB = [componentWithCursor.eqTextField.stringValue substringFromIndex:componentWithCursor.startCursorLocation];
        attr = [componentWithCursor.eqTextField.attributedStringValue attributesAtIndex:0 effectiveRange:nil];
    }
    
    componentWithCursor.eqFormat = NORMAL;
    
    [componentWithCursor.eqChildren addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor]];
    [componentWithCursor.eqChildren[0] setEqFormat: LEAF];
    [componentWithCursor.eqChildren[0] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
    [componentWithCursor.eqChildren[0] eqTextField].stringValue = strA;
    
    [componentWithCursor.eqChildren addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor]];
    [componentWithCursor.eqChildren[1] setEqFormat:SUPERSCRIPT];
    [[componentWithCursor.eqChildren[1] eqChildren] addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor.eqChildren[1]]];
    [[componentWithCursor.eqChildren[1] eqChildren][0] setEqFormat:LEAF];
    [[componentWithCursor.eqChildren[1] eqChildren][0] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
    [[componentWithCursor.eqChildren[1] eqChildren][0] eqTextField].attributedStringValue = [[NSAttributedString alloc] initWithString:@"" attributes:attr];
    
    [componentWithCursor.eqChildren addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor]];
    [componentWithCursor.eqChildren[2] setEqFormat: LEAF];
    [componentWithCursor.eqChildren[2] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
    [componentWithCursor.eqChildren[2] eqTextField].stringValue = strB;
    
    componentWithCursor.startCursorLocation = -1;
    componentWithCursor.childWithStartCursor = 1;
    [componentWithCursor.eqChildren[1] setChildWithStartCursor:0];
    [[componentWithCursor.eqChildren[1] eqChildren][0] setStartCursorLocation:0];
    
    [self.eq simplifyStructure];
    
    return true;
}

- (BOOL) insertSquareroot {
    EquationFieldComponent *componentWithCursor = self.eq;
    while(componentWithCursor.childWithStartCursor != -1) {
        componentWithCursor = componentWithCursor.eqChildren[componentWithCursor.childWithStartCursor];
    }
    if(componentWithCursor.startCursorLocation == -1) {
        // error
        return false;
    }
    
    NSString *strA;
    NSString *strB;
    NSDictionary *attr;
    
    if([componentWithCursor.eqTextField.stringValue isEqual: @""]) {
        strA = @"";
        strB = @"";
        attr = @{NSFontAttributeName : [self.fontManager getFont:componentWithCursor.frame.size.height-1]};
    }
    else {
        strA = [componentWithCursor.eqTextField.stringValue substringToIndex:componentWithCursor.startCursorLocation];
        strB = [componentWithCursor.eqTextField.stringValue substringFromIndex:componentWithCursor.startCursorLocation];
        attr = [componentWithCursor.eqTextField.attributedStringValue attributesAtIndex:0 effectiveRange:nil];
    }
    
    componentWithCursor.eqFormat = NORMAL;
    
    [componentWithCursor.eqChildren addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor]];
    [componentWithCursor.eqChildren[0] setEqFormat: LEAF];
    [componentWithCursor.eqChildren[0] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
    [componentWithCursor.eqChildren[0] eqTextField].stringValue = strA;
    
    [componentWithCursor.eqChildren addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor]];
    [componentWithCursor.eqChildren[1] setEqFormat:SQUAREROOT];
    [[componentWithCursor.eqChildren[1] eqChildren] addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor.eqChildren[1]]];
    [[componentWithCursor.eqChildren[1] eqChildren][0] setEqFormat:LEAF];
    [[componentWithCursor.eqChildren[1] eqChildren][0] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
    [[componentWithCursor.eqChildren[1] eqChildren][0] eqTextField].attributedStringValue = [[NSAttributedString alloc] initWithString:@"" attributes:attr];
    
    NSString *pathToRootImage = [[NSString alloc] initWithString:[[NSBundle mainBundle] pathForImageResource:@"root.png"]];
    NSImageView *rootImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 50, 50)];
    NSImage *rootImage = [[NSImage alloc] initWithContentsOfFile:pathToRootImage];
    [rootImageView setImage:rootImage];
    [componentWithCursor.eqChildren[1] setEqImageView:rootImageView];
    
    [componentWithCursor.eqChildren addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor]];
    [componentWithCursor.eqChildren[2] setEqFormat: LEAF];
    [componentWithCursor.eqChildren[2] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
    [componentWithCursor.eqChildren[2] eqTextField].stringValue = strB;
    
    componentWithCursor.startCursorLocation = -1;
    componentWithCursor.childWithStartCursor = 1;
    [componentWithCursor.eqChildren[1] setChildWithStartCursor:0];
    [[componentWithCursor.eqChildren[1] eqChildren][0] setStartCursorLocation:0];
    
    [self.eq simplifyStructure];
    
    return true;
}

- (BOOL) insertSummation {
    EquationFieldComponent *componentWithCursor = self.eq;
    while(componentWithCursor.childWithStartCursor != -1) {
        componentWithCursor = componentWithCursor.eqChildren[componentWithCursor.childWithStartCursor];
    }
    if(componentWithCursor.startCursorLocation == -1) {
        // error
        return false;
    }
    
    NSString *strA;
    NSString *strB;
    NSDictionary *attr;
    
    if([componentWithCursor.eqTextField.stringValue isEqual: @""]) {
        strA = @"";
        strB = @"";
        attr = @{NSFontAttributeName : [self.fontManager getFont:componentWithCursor.frame.size.height-1]};
    }
    else {
        strA = [componentWithCursor.eqTextField.stringValue substringToIndex:componentWithCursor.startCursorLocation];
        strB = [componentWithCursor.eqTextField.stringValue substringFromIndex:componentWithCursor.startCursorLocation];
        attr = [componentWithCursor.eqTextField.attributedStringValue attributesAtIndex:0 effectiveRange:nil];
    }
    
    componentWithCursor.eqFormat = NORMAL;
    
    [componentWithCursor.eqChildren addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor]];
    [componentWithCursor.eqChildren[0] setEqFormat: LEAF];
    [componentWithCursor.eqChildren[0] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
    [componentWithCursor.eqChildren[0] eqTextField].stringValue = strA;
    
    [componentWithCursor.eqChildren addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor]];
    [componentWithCursor.eqChildren[1] setEqFormat:SUMMATION];
    [[componentWithCursor.eqChildren[1] eqChildren] addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor.eqChildren[1]]];
    [[componentWithCursor.eqChildren[1] eqChildren][0] setEqFormat:LEAF];
    [[componentWithCursor.eqChildren[1] eqChildren][0] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
    [[componentWithCursor.eqChildren[1] eqChildren][0] eqTextField].attributedStringValue = [[NSAttributedString alloc] initWithString:@"" attributes:attr];
    [[componentWithCursor.eqChildren[1] eqChildren] addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor.eqChildren[1]]];
    [[componentWithCursor.eqChildren[1] eqChildren][1] setEqFormat:LEAF];
    [[componentWithCursor.eqChildren[1] eqChildren][1] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
    [[componentWithCursor.eqChildren[1] eqChildren][1] eqTextField].attributedStringValue = [[NSAttributedString alloc] initWithString:@"" attributes:attr];
    [[componentWithCursor.eqChildren[1] eqChildren] addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor.eqChildren[1]]];
    [[componentWithCursor.eqChildren[1] eqChildren][2] setEqFormat:LEAF];
    [[componentWithCursor.eqChildren[1] eqChildren][2] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
    [[componentWithCursor.eqChildren[1] eqChildren][2] eqTextField].attributedStringValue = [[NSAttributedString alloc] initWithString:@"" attributes:attr];
    
    NSString *pathToRootImage = [[NSString alloc] initWithString:[[NSBundle mainBundle] pathForImageResource:@"summation.png"]];
    NSImageView *rootImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 50, 50)];
    NSImage *rootImage = [[NSImage alloc] initWithContentsOfFile:pathToRootImage];
    [rootImageView setImage:rootImage];
    [componentWithCursor.eqChildren[1] setEqImageView:rootImageView];
    
    [componentWithCursor.eqChildren addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor]];
    [componentWithCursor.eqChildren[2] setEqFormat: LEAF];
    [componentWithCursor.eqChildren[2] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
    [componentWithCursor.eqChildren[2] eqTextField].stringValue = strB;
    
    componentWithCursor.startCursorLocation = -1;
    componentWithCursor.childWithStartCursor = 1;
    [componentWithCursor.eqChildren[1] setChildWithStartCursor:0];
    [[componentWithCursor.eqChildren[1] eqChildren][0] setStartCursorLocation:0];
    
    [self.eq simplifyStructure];
    
    return true;
}

- (BOOL) insertIntegration {
    EquationFieldComponent *componentWithCursor = self.eq;
    while(componentWithCursor.childWithStartCursor != -1) {
        componentWithCursor = componentWithCursor.eqChildren[componentWithCursor.childWithStartCursor];
    }
    if(componentWithCursor.startCursorLocation == -1) {
        // error
        return false;
    }
    
    NSString *strA;
    NSString *strB;
    NSDictionary *attr;
    
    if([componentWithCursor.eqTextField.stringValue isEqual: @""]) {
        strA = @"";
        strB = @"";
        attr = @{NSFontAttributeName : [self.fontManager getFont:componentWithCursor.frame.size.height-1]};
    }
    else {
        strA = [componentWithCursor.eqTextField.stringValue substringToIndex:componentWithCursor.startCursorLocation];
        strB = [componentWithCursor.eqTextField.stringValue substringFromIndex:componentWithCursor.startCursorLocation];
        attr = [componentWithCursor.eqTextField.attributedStringValue attributesAtIndex:0 effectiveRange:nil];
    }
    
    componentWithCursor.eqFormat = NORMAL;
    
    [componentWithCursor.eqChildren addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor]];
    [componentWithCursor.eqChildren[0] setEqFormat: LEAF];
    [componentWithCursor.eqChildren[0] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
    [componentWithCursor.eqChildren[0] eqTextField].stringValue = strA;
    
    [componentWithCursor.eqChildren addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor]];
    [componentWithCursor.eqChildren[1] setEqFormat:INTEGRATION];
    [[componentWithCursor.eqChildren[1] eqChildren] addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor.eqChildren[1]]];
    [[componentWithCursor.eqChildren[1] eqChildren][0] setEqFormat:LEAF];
    [[componentWithCursor.eqChildren[1] eqChildren][0] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
    [[componentWithCursor.eqChildren[1] eqChildren][0] eqTextField].attributedStringValue = [[NSAttributedString alloc] initWithString:@"" attributes:attr];
    [[componentWithCursor.eqChildren[1] eqChildren] addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor.eqChildren[1]]];
    [[componentWithCursor.eqChildren[1] eqChildren][1] setEqFormat:LEAF];
    [[componentWithCursor.eqChildren[1] eqChildren][1] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
    [[componentWithCursor.eqChildren[1] eqChildren][1] eqTextField].attributedStringValue = [[NSAttributedString alloc] initWithString:@"" attributes:attr];
    [[componentWithCursor.eqChildren[1] eqChildren] addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor.eqChildren[1]]];
    [[componentWithCursor.eqChildren[1] eqChildren][2] setEqFormat:LEAF];
    [[componentWithCursor.eqChildren[1] eqChildren][2] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
    [[componentWithCursor.eqChildren[1] eqChildren][2] eqTextField].attributedStringValue = [[NSAttributedString alloc] initWithString:@"" attributes:attr];
    
    NSString *pathToRootImage = [[NSString alloc] initWithString:[[NSBundle mainBundle] pathForImageResource:@"integration.png"]];
    NSImageView *intImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 50, 50)];
    NSImage *intImage = [[NSImage alloc] initWithContentsOfFile:pathToRootImage];
    [intImageView setImage:intImage];
    [componentWithCursor.eqChildren[1] setEqImageView:intImageView];
    
    [componentWithCursor.eqChildren addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor]];
    [componentWithCursor.eqChildren[2] setEqFormat: LEAF];
    [componentWithCursor.eqChildren[2] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
    [componentWithCursor.eqChildren[2] eqTextField].stringValue = strB;
    
    componentWithCursor.startCursorLocation = -1;
    componentWithCursor.childWithStartCursor = 1;
    [componentWithCursor.eqChildren[1] setChildWithStartCursor:0];
    [[componentWithCursor.eqChildren[1] eqChildren][0] setStartCursorLocation:0];
    
    [self.eq simplifyStructure];
    
    return true;
}

- (BOOL) insertCharacter: (NSString*) str {
    BOOL success;
    if([str isEqual: @"/"]) {
        success = [self insertDivision];
    }
    else if([str isEqual: @"^"]) {
        success = [self insertSuperscript];
    }
    else if([str isEqual: @"√"]) {
        success = [self insertSquareroot];
    }
    else if([str isEqual: @"∑"]) {
        success = [self insertSummation];
    }
    else if([str isEqual: @"∫"]) {
        success = [self insertIntegration];
    }
    else if([str isEqual: @""]) {
        // do nothing with weird characters
        success = false;
    }
    else {
        // normal character
        EquationFieldComponent *componentWithCursor = self.eq;
        while(componentWithCursor.childWithStartCursor != -1) {
            componentWithCursor = componentWithCursor.eqChildren[componentWithCursor.childWithStartCursor];
        }
        if(componentWithCursor.startCursorLocation == -1) {
            // error
            return false;
        }
        
        NSString *strA = [componentWithCursor.eqTextField.stringValue substringToIndex:componentWithCursor.startCursorLocation];
        NSString *strB = [componentWithCursor.eqTextField.stringValue substringFromIndex:componentWithCursor.startCursorLocation];
        NSString *newStr = [[NSString alloc] initWithFormat:@"%@%@%@", strA, str, strB];
        double fontSize = componentWithCursor.frame.size.height-1;
        NSDictionary *attr = @{NSFontAttributeName : [self.fontManager getFont:fontSize]};
        componentWithCursor.eqTextField.attributedStringValue = [[NSAttributedString alloc] initWithString:newStr attributes:attr];
        componentWithCursor.startCursorLocation++;
        success = true;
        if(componentWithCursor.startCursorLocation >= 3) {
            if([[componentWithCursor.eqTextField.stringValue substringWithRange:NSMakeRange(componentWithCursor.startCursorLocation-3, 3)] isEqual: @"log"]) {
                NSString *strA = [componentWithCursor.eqTextField.stringValue substringToIndex:componentWithCursor.startCursorLocation-3];
                NSString *strB = [componentWithCursor.eqTextField.stringValue substringFromIndex:componentWithCursor.startCursorLocation];
                componentWithCursor.eqFormat = NORMAL;
                // todo
                
                [componentWithCursor.eqChildren addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor]];
                [componentWithCursor.eqChildren[0] setEqFormat: LEAF];
                [componentWithCursor.eqChildren[0] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
                [componentWithCursor.eqChildren[0] eqTextField].stringValue = strA;
                
                [componentWithCursor.eqChildren addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor]];
                [componentWithCursor.eqChildren[1] setEqFormat: LOGBASE];
                NSString *pathToLogImage = [[NSString alloc] initWithString:[[NSBundle mainBundle] pathForImageResource:@"log.png"]];
                NSImageView *logImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 50, 50)];
                NSImage *logImage = [[NSImage alloc] initWithContentsOfFile:pathToLogImage];
                [logImageView setImage:logImage];
                [componentWithCursor.eqChildren[1] setEqImageView:logImageView];
                [[componentWithCursor.eqChildren[1] eqChildren] addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor.eqChildren[1]]];
                [[componentWithCursor.eqChildren[1] eqChildren][0] setEqFormat: LEAF];
                [[componentWithCursor.eqChildren[1] eqChildren][0] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
                [[componentWithCursor.eqChildren[1] eqChildren] addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor.eqChildren[1]]];
                [[componentWithCursor.eqChildren[1] eqChildren][1] setEqFormat: LEAF];
                [[componentWithCursor.eqChildren[1] eqChildren][1] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
                
                [componentWithCursor.eqChildren addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:options parent:componentWithCursor]];
                [componentWithCursor.eqChildren[2] setEqFormat: LEAF];
                [componentWithCursor.eqChildren[2] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
                [componentWithCursor.eqChildren[2] eqTextField].stringValue = strB;
                
                componentWithCursor.startCursorLocation = -1;
                componentWithCursor.childWithStartCursor = 1;
                [componentWithCursor.eqChildren[1] setChildWithStartCursor:0];
                [[componentWithCursor.eqChildren[1] eqChildren][0] setStartCursorLocation:0];
            }
        }
    }
    
    [self completeRecalculation];
    [self.cursor show];
    
    return success;
}

- (void) leftArrowPressed {
    NSMutableArray *descendants = [[NSMutableArray alloc] init];
    [descendants addObject:self.eq];
    while([descendants[descendants.count-1] childWithStartCursor] != -1) {
        [descendants addObject:[descendants[descendants.count-1] eqChildren][[descendants[descendants.count-1] childWithStartCursor]]];
    }
    
    EquationFieldComponent *componentWithCursor = descendants[descendants.count-1];
    
    if(componentWithCursor.startCursorLocation == -1) {
        return;
    }
    [self.cursor show];
    if(componentWithCursor.startCursorLocation == 0) {
        // appeal to parent for cursor to be moved left
        componentWithCursor.startCursorLocation = -1;
        EquationFieldComponent *parent;
        int i;
        for(i=2; i<=descendants.count; i++) {
            parent = descendants[descendants.count - i];
            if(parent.childWithStartCursor != 0) {
                break;
            }
        }
        
        if(i == descendants.count+1 && parent.childWithStartCursor == 0) {
            // as left as we can go
            componentWithCursor.startCursorLocation = 0;
            return;
        }
        
        for(i=2; i<=descendants.count; i++) {
            parent = descendants[descendants.count - i];
            if(parent.childWithStartCursor != 0) {
                break;
            }
            parent.childWithStartCursor = -1;
        }
        
        parent.childWithStartCursor--;
        
        [self giveCursorToRightMostChild:parent.eqChildren[parent.childWithStartCursor]];
    }
    else {
        componentWithCursor.startCursorLocation--;
        [self adjustCursorLocation];
    }
}

- (void) rightArrowPressed {
    NSMutableArray *descendants = [[NSMutableArray alloc] init];
    [descendants addObject:self.eq];
    while([descendants[descendants.count-1] childWithStartCursor] != -1) {
        [descendants addObject:[descendants[descendants.count-1] eqChildren][[descendants[descendants.count-1] childWithStartCursor]]];
    }
    
    EquationFieldComponent *componentWithCursor = descendants[descendants.count-1];
    
    if(componentWithCursor.startCursorLocation == -1) {
        return;
    }
    [self.cursor show];
    
    if(componentWithCursor.startCursorLocation == componentWithCursor.eqTextField.stringValue.length) {
        // appeal to parent for cursor to be moved right
        componentWithCursor.startCursorLocation = -1;
        EquationFieldComponent *parent;
        int i;
        
        for(i=2; i<=descendants.count; i++) {
            parent = descendants[descendants.count - i];
            if(parent.childWithStartCursor != (int) parent.eqChildren.count-1) {
                break;
            }
        }
        
        if(i == descendants.count+1 && parent.childWithStartCursor == parent.eqChildren.count-1) {
            // as right as we can go
            componentWithCursor.startCursorLocation = (int) componentWithCursor.eqTextField.stringValue.length;
            return;
        }
        
        for(i=2; i<=descendants.count; i++) {
            parent = descendants[descendants.count - i];
            if(parent.childWithStartCursor != (int) parent.eqChildren.count-1) {
                break;
            }
            parent.childWithStartCursor = -1;
        }
        
        parent.childWithStartCursor++;
        [self giveCursorToLeftMostChild:parent.eqChildren[parent.childWithStartCursor]];
    }
    else {
        componentWithCursor.startCursorLocation++;
        [self adjustCursorLocation];
    }
}

- (void) giveCursorToRightMostChild: (EquationFieldComponent*) eq {
    EquationFieldComponent *current = eq;
    while(current.eqChildren.count != 0) {
        
        current.childWithStartCursor = (int) current.eqChildren.count-1;
        current = current.eqChildren[current.childWithStartCursor];
    }
    current.startCursorLocation = (int) current.eqTextField.stringValue.length;
    [self adjustCursorLocation];
}

- (void) giveCursorToLeftMostChild: (EquationFieldComponent*) eq {
    EquationFieldComponent *current = eq;
    while(current.eqChildren.count != 0) {
        current.childWithStartCursor = 0;
        current = current.eqChildren[0];
    }
    current.startCursorLocation = 0;
    [self adjustCursorLocation];
}

- (void) adjustCursorLocation {
    EquationFieldComponent *componentWithCursor = self.eq;
    double xpos = self.eq.frame.origin.x;
    double ypos = self.eq.frame.origin.y;
    
    while(componentWithCursor.childWithStartCursor != -1) {
        componentWithCursor = componentWithCursor.eqChildren[componentWithCursor.childWithStartCursor];
        xpos += componentWithCursor.frame.origin.x;
        ypos += componentWithCursor.frame.origin.y;
    }
    
    if(componentWithCursor.startCursorLocation == -1) {
        return;
    }
    NSString *str = [componentWithCursor.eqTextField.stringValue substringToIndex:componentWithCursor.startCursorLocation];
    double newWidthOfCursor = 2;
    if(componentWithCursor.eqTextField.attributedStringValue.length != 0) {
        NSDictionary *attr = [componentWithCursor.eqTextField.attributedStringValue attributesAtIndex:0 effectiveRange:nil];
        xpos += [[NSAttributedString alloc] initWithString:str attributes:attr].size.width;
    }
    self.cursor.frame = NSMakeRect(xpos - newWidthOfCursor/2, ypos, newWidthOfCursor, componentWithCursor.frame.size.height);
}

- (BOOL) setStartCursorToEq: (double) x y: (double) y {
    [self.cursor show];
    if(x >=0 && x <= self.eq.frame.size.width-100 && y >= self.eq.frame.origin.y && y <= self.eq.frame.origin.y+self.eq.frame.size.height) {
        BOOL success = [self.eq setStartCursorToEq:x y:y];
        if(success) {
            [self.eq resetAllCursorPointers];
            [self.eq setStartCursorToEq:x y:y];
            [self adjustCursorLocation];
        }
        return success;
    }
    else if(x >= self.eq.frame.size.width-100) {
        [self.eq resetAllCursorPointers];
        EquationFieldComponent *current = self.eq;
        while(current.eqChildren.count != 0) {
            current.childWithStartCursor = (int) current.eqChildren.count - 1;
            current = current.eqChildren[current.eqChildren.count-1];
        }
        current.startCursorLocation = (int) current.eqTextField.stringValue.length;
        [self adjustCursorLocation];
        return true;
    }
    else if(self.eq.eqFormat == LEAF && self.eq.startCursorLocation == -1) {
        self.eq.startCursorLocation = 0;
        [self adjustCursorLocation];
        return true;
    }
    else if(self.eq.eqFormat != LEAF && self.eq.childWithStartCursor == -1) {
        EquationFieldComponent *current = self.eq;
        while(current.eqChildren.count != 0) {
            current.childWithStartCursor = 0;
            current = current.eqChildren[0];
        }
        current.startCursorLocation = 0;
        [self adjustCursorLocation];
        return true;
    }
    return false;
}

@end
