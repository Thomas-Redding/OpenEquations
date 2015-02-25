//
//  EquationField.m
//  EquationEditor
//
//  Created by Thomas Redding on 1/11/15.
//  Copyright (c) 2015 Thomas Redding. All rights reserved.
//

#import "EquationField.h"

@implementation EquationField

int cursorCounter = 0;

- (EquationField*) initWithFont: (FontManager*) f {
    self = [super init];
    self.fontManager = f;
    self.options = [[EquationFieldOptions alloc] init];
    self.minFontSize = 95;
    
    [self setWantsLayer:YES];
    double shade = 1; // system background: 0.905882353;
    self.layer.backgroundColor = ([NSColor colorWithCalibratedRed:shade green:shade blue:shade alpha:0.0]).CGColor;
    
    double size = 50;
    NSDictionary *attr = @{NSFontAttributeName : [self.fontManager getFont:size]};
    
    self.eq = [[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:self.options parent:nil];
    self.eq.eqFormat = NORMAL;
    [self.eq.eqChildren addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:self.options parent:self.eq]];
    [self.eq.eqChildren[0] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
    [self.eq.eqChildren[0] setEqFormat:LEAF];
    [self.eq.eqChildren[0] eqTextField].attributedStringValue = [[NSAttributedString alloc] initWithString:@"3∫+" attributes:attr];
    
    [self.eq.eqChildren addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:self.options parent:self.eq]];
    [self.eq.eqChildren[1] setEqFormat:DIVISION];
    [[self.eq.eqChildren[1] eqChildren] addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:self.options parent:self.eq.eqChildren[1]]];
    [[self.eq.eqChildren[1] eqChildren][0] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
    [[self.eq.eqChildren[1] eqChildren][0] setEqFormat:LEAF];
    // add ∫
    [[self.eq.eqChildren[1] eqChildren][0] eqTextField].attributedStringValue = [[NSAttributedString alloc] initWithString:@"" attributes:attr];
    
    [[self.eq.eqChildren[1] eqChildren] addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:self.options parent:self.eq.eqChildren[1]]];
    [[self.eq.eqChildren[1] eqChildren][1] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
    [[self.eq.eqChildren[1] eqChildren][1] setEqFormat:LEAF];
    // add ∫
    [[self.eq.eqChildren[1] eqChildren][1] eqTextField].attributedStringValue = [[NSAttributedString alloc] initWithString:@"" attributes:attr];
    
    [self.eq.eqChildren addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:self.options parent:self.eq]];
    [self.eq.eqChildren[2] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
    [self.eq.eqChildren[2] setEqFormat:LEAF];
    [self.eq.eqChildren[2] eqTextField].attributedStringValue = [[NSAttributedString alloc] initWithString:@"" attributes:attr];

    [self addSubview:self.eq];
    [self.eq addDescendantsToSubview];
    
    self.cursor = [[EquationCursor alloc] init];
    [self addSubview:self.cursor];
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0] setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

- (void) completeRecalculation {
    // make preliminary size requests
    [self.eq makeSizeRequest:self.options.maxFontSize];
    double ratio = fmin(self.frame.size.width/self.eq.frame.size.width, self.frame.size.height/self.eq.frame.size.height);
    if(ratio > 1) {
        ratio = 1;
    }
    
    // set minimum font size to 24 pt
    self.options.minFontSizeAsRatioOfMaxFontSize = (self.minFontSize/ratio)/self.options.maxFontSize;
    
    // if minimum font size is too big to fit in the view, use the highest minimum font size that does fit
    if(self.options.minFontSizeAsRatioOfMaxFontSize > 1) {
        self.options.minFontSizeAsRatioOfMaxFontSize = 1;
    }
    
    // make final size requests
    [self.eq makeSizeRequest:self.options.maxFontSize];
    ratio = fmin(self.frame.size.width/self.eq.frame.size.width, self.frame.size.height/self.eq.frame.size.height);
    if(ratio > 1) {
        ratio = 1;
    }
    
    // finish recalculation
    [self.eq grantSizeRequest: NSMakeRect(1, (self.frame.size.height - self.eq.frame.size.height * ratio)/2, self.eq.frame.size.width * ratio, self.eq.frame.size.height * ratio)];
    [self.eq completeMinorComponentShifts];
    [self adjustCursorLocation];
    [self.eq addDescendantsToSubview];
}

- (NSString*) toLaTeX {
    return [self.eq toLaTeX];
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
    else {
        // insert character
        if(self.eq.childWithEndCursor != -1) {
            // something is currently highlighted
        }
        else {
            [self insertCharacter:theEvent.characters];
        }
    }
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

- (void) rightMouseDown: (NSEvent*) theEvent {
    // mouse drop-down menu
}

- (void) resetCursorRects
{
    [self addCursorRect:self.frame cursor:[NSCursor IBeamCursor]];
}

// OTHER (HELPER) FUNCTIONS

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

- (void) insertCharacter: (NSString*) str {
    EquationFieldComponent *componentWithCursor = self.eq;
    while(componentWithCursor.childWithStartCursor != -1) {
        componentWithCursor = componentWithCursor.eqChildren[componentWithCursor.childWithStartCursor];
    }
    if(componentWithCursor.startCursorLocation == -1) {
        // error
        return;
    }
    
    if([str  isEqual: @"/"]) {
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
        
        [componentWithCursor.eqChildren addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:self.options parent:componentWithCursor]];
        [componentWithCursor.eqChildren[0] setEqFormat: LEAF];
        [componentWithCursor.eqChildren[0] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
        [componentWithCursor.eqChildren[0] eqTextField].stringValue = strA;
        
        [componentWithCursor.eqChildren addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:self.options parent:componentWithCursor]];
        [componentWithCursor.eqChildren[1] setEqFormat:DIVISION];
        [[componentWithCursor.eqChildren[1] eqChildren] addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:self.options parent:componentWithCursor.eqChildren[1]]];
        [[componentWithCursor.eqChildren[1] eqChildren][0] setEqFormat:LEAF];
        [[componentWithCursor.eqChildren[1] eqChildren][0] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
        [[componentWithCursor.eqChildren[1] eqChildren][0] eqTextField].attributedStringValue = [[NSAttributedString alloc] initWithString:@"" attributes:attr];
        [[componentWithCursor.eqChildren[1] eqChildren] addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:self.options parent:componentWithCursor.eqChildren[1]]];
        [[componentWithCursor.eqChildren[1] eqChildren][1] setEqFormat:LEAF];
        [[componentWithCursor.eqChildren[1] eqChildren][1] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
        [[componentWithCursor.eqChildren[1] eqChildren][1] eqTextField].attributedStringValue = [[NSAttributedString alloc] initWithString:@"" attributes:attr];
        
        [componentWithCursor.eqChildren addObject:[[EquationFieldComponent alloc] initWithFontManagerOptionsAndParent:self.fontManager options:self.options parent:componentWithCursor]];
        [componentWithCursor.eqChildren[2] setEqFormat: LEAF];
        [componentWithCursor.eqChildren[2] setEqTextField:[[EquationTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)]];
        [componentWithCursor.eqChildren[2] eqTextField].stringValue = strB;
        
        componentWithCursor.startCursorLocation = -1;
        componentWithCursor.childWithStartCursor = 1;
        [componentWithCursor.eqChildren[1] setChildWithStartCursor:0];
        [[componentWithCursor.eqChildren[1] eqChildren][0] setStartCursorLocation:0];
    }
    else {
        // normal character
        NSString *strA = [componentWithCursor.eqTextField.stringValue substringToIndex:componentWithCursor.startCursorLocation];
        NSString *strB = [componentWithCursor.eqTextField.stringValue substringFromIndex:componentWithCursor.startCursorLocation];
        NSString *newStr = [[NSString alloc] initWithFormat:@"%@%@%@", strA, str, strB];
        double fontSize = componentWithCursor.frame.size.height-1;
        NSDictionary *attr = @{NSFontAttributeName : [self.fontManager getFont:fontSize]};
        componentWithCursor.eqTextField.attributedStringValue = [[NSAttributedString alloc] initWithString:newStr attributes:attr];
        componentWithCursor.startCursorLocation++;
    }
    [self completeRecalculation];
    [self.cursor show];
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
        current = current.eqChildren[eq.eqChildren.count-1];
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
    if(x >=0 && x <= self.eq.frame.size.width && y >= self.eq.frame.origin.y && y <= self.eq.frame.origin.y+self.eq.frame.size.height) {
        [self.cursor show];
        BOOL success = [self.eq setStartCursorToEq:x y:y];
        if(success) {
            [self.eq resetAllCursorPointers];
            [self.eq setStartCursorToEq:x y:y];
            [self adjustCursorLocation];
        }
        return success;
    }
    else if(x >= self.eq.frame.size.width) {
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
    return false;
}

@end
