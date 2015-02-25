//
//  EquationFieldComponent.m
//  EquationEditor
//
//  Created by Thomas Redding on 1/16/15.
//  Copyright (c) 2015 Thomas Redding. All rights reserved.
//

#import "EquationFieldComponent.h"

@implementation EquationFieldComponent

double heightRatio = -1;

- (EquationFieldComponent*)initWithFontManagerOptionsAndParent:(FontManager*)f options: (EquationFieldOptions*) o parent: (EquationFieldComponent*) p {
    self = [super init];
    
    self.options = o;
    self.parent = p;
    self.fontManager = f;
    
    self.frame = NSMakeRect(0, 0, 0, 0);
    self.eqFormat = UNDEFINED;
    self.eqChildren = [[NSMutableArray alloc] init];
    self.childWithStartCursor = -1;
    self.childWithEndCursor = -1;
    self.startCursorLocation = -1;
    self.endCursorLocation = -1;
    
    self.layer.borderColor = [NSColor orangeColor].CGColor;
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    // draw static features
    if(self.eqFormat == DIVISION) {
        double thickness = self.frame.size.height/25;
        [[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1.0] setFill];
        NSRectFill(NSMakeRect(0, [self.eqChildren[1] frame].size.height-thickness, self.frame.size.width, thickness));
    }
    else if(self.eqFormat == LEAF) {
        /*
        [[NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:0.5] setFill];
        NSRectFill(dirtyRect);
        */
    }
    
    bool showBoundaries = false;
    if(showBoundaries) {
        double borderWidth = 2;
        [[NSColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:1] setFill];
        NSRectFill(NSMakeRect(dirtyRect.origin.x, dirtyRect.origin.y, dirtyRect.size.width, borderWidth));
        NSRectFill(NSMakeRect(dirtyRect.origin.x, dirtyRect.origin.y+dirtyRect.size.height-borderWidth, dirtyRect.size.width, borderWidth));
        NSRectFill(NSMakeRect(dirtyRect.origin.x, dirtyRect.origin.y, borderWidth, dirtyRect.size.height));
        NSRectFill(NSMakeRect(dirtyRect.origin.x+dirtyRect.size.width-borderWidth, dirtyRect.origin.y, borderWidth, dirtyRect.size.height));
    }
    
    
    // draw highlighting
    // todo
    
    [super drawRect:dirtyRect];
}

- (void) makeSizeRequest: (double) fontSize {
    for(int i=0; i<self.eqChildren.count; i++) {
        [self.eqChildren[i] makeSizeRequest:fontSize];
    }
    if(self.eqFormat == LEAF) {
        NSString *str = self.eqTextField.stringValue;
        NSDictionary *attr = @{NSFontAttributeName : [self.fontManager getFont:fontSize]};
        self.eqTextField.attributedStringValue = [[NSAttributedString alloc] initWithString:str attributes:attr];
        NSSize size = [self.eqTextField.attributedStringValue size];
        self.heightRatio = 0.5;
        if([self.eqTextField.stringValue isEqual: @""]) {
            // empty leaf
            if(self.parent.eqFormat == DIVISION) {
                size.width = fontSize;
            }
            else {
                size.width = fontSize/4;
            }
        }
        self.frame = NSMakeRect(self.frame.origin.x, self.frame.origin.y, size.width, fontSize);
    }
    else if(self.eqFormat == NORMAL) {
        double width = 0;
        double heightAbove = 0;
        double heightBelow = 0;
        for(int i=0; i<self.eqChildren.count; i++) {
            width += [self.eqChildren[i] frame].size.width;
            if([self.eqChildren[i] frame].size.height * [self.eqChildren[i] heightRatio] > heightBelow) {
                heightBelow = [self.eqChildren[i] frame].size.height * [self.eqChildren[i] heightRatio];
            }
            if([self.eqChildren[i] frame].size.height * (1-[self.eqChildren[i] heightRatio]) > heightAbove) {
                heightAbove = [self.eqChildren[i] frame].size.height * (1-[self.eqChildren[i] heightRatio]);
            }
        }
        self.heightRatio = heightBelow/(heightAbove+heightBelow);
        self.frame = NSMakeRect(self.frame.origin.x, self.frame.origin.y, width, heightAbove+heightBelow);
    }
    else if(self.eqFormat == DIVISION) {
        double width = fmax([self.eqChildren[0] frame].size.width, [self.eqChildren[1] frame].size.width);
        double height = [self.eqChildren[0] frame].size.height + [self.eqChildren[1] frame].size.height;
        self.heightRatio = [self.eqChildren[1] frame].size.height / height;
        self.frame = NSMakeRect(self.frame.origin.x, self.frame.origin.y, width, height);
    }
}

- (void) grantSizeRequest: (NSRect) rect {
    double ratio = rect.size.width / self.frame.size.width;
    self.frame = rect;
    
    if(self.eqFormat == LEAF) {
        NSString *str = self.eqTextField.stringValue;
        double fontSize = self.frame.size.height * 0.90;
        NSDictionary *attr = @{NSFontAttributeName : [self.fontManager getFont:fontSize]};
        self.eqTextField.attributedStringValue = [[NSAttributedString alloc] initWithString:str attributes:attr];
        self.eqTextField.frame = NSMakeRect(0, 0, rect.size.width+100, rect.size.height);
    }
    else if(self.eqFormat == NORMAL) {
        double newX = 0;
        double centerY = self.heightRatio * self.frame.size.height;
        for(int i=0; i<self.eqChildren.count; i++) {
            NSSize oldSize = [self.eqChildren[i] frame].size;
            double childHeightRatio = [self.eqChildren[i] heightRatio];
            [self.eqChildren[i] grantSizeRequest:NSMakeRect(newX, centerY-oldSize.height * ratio * childHeightRatio, oldSize.width * ratio, oldSize.height * ratio)];
            newX += [self.eqChildren[i] frame].size.width;
        }
        
    }
    else if(self.eqFormat == DIVISION) {
        if([self.eqChildren[0] frame].size.width < [self.eqChildren[1] frame].size.width) {
            // bottom is larger
            double centerAdjustment = ratio * ([self.eqChildren[1] frame].size.width - [self.eqChildren[0] frame].size.width)/2;
            NSSize oldSize = [self.eqChildren[1] frame].size;
            [self.eqChildren[1] grantSizeRequest:NSMakeRect(0, 0, oldSize.width * ratio, oldSize.height * ratio)];
            oldSize = [self.eqChildren[0] frame].size;
            double newY = [self.eqChildren[1] frame].size.height;
            [self.eqChildren[0] grantSizeRequest:NSMakeRect(centerAdjustment, newY, oldSize.width * ratio, oldSize.height * ratio)];
        }
        else {
            // top is larger
            double centerAdjustment = ratio * ([self.eqChildren[0] frame].size.width - [self.eqChildren[1] frame].size.width)/2;
            NSSize oldSize = [self.eqChildren[1] frame].size;
            [self.eqChildren[1] grantSizeRequest:NSMakeRect(centerAdjustment, 0, oldSize.width * ratio, oldSize.height * ratio)];
            oldSize = [self.eqChildren[0] frame].size;
            double newY = [self.eqChildren[1] frame].size.height;
            [self.eqChildren[0] grantSizeRequest:NSMakeRect(0, newY, oldSize.width * ratio, oldSize.height * ratio)];
        }
    }
}

- (void) addDescendantsToSubview {
    [self setSubviews:[[NSArray alloc] init]];
    for(int i=0; i<self.eqChildren.count; i++) {
        [self addSubview:self.eqChildren[i]];
        [self.eqChildren[i] addDescendantsToSubview];
    }
    if(self.eqFormat == LEAF) {
        [self addSubview:self.eqTextField];
    }
}

- (BOOL) setStartCursorToEq: (double) x y: (double) y {
    x -= self.frame.origin.x;
    y -= self.frame.origin.y;
    if(self.eqFormat == LEAF) {
        self.childWithStartCursor = -1;
        self.startCursorLocation = 0;
        NSDictionary *attr = @{NSFontAttributeName : [self.fontManager getFont:self.eqTextField.frame.size.height]};
        double xpos = 0;
        for(int i=0; i<=self.eqTextField.stringValue.length; i++) {
            double width = [[[NSAttributedString alloc] initWithString:[self.eqTextField.stringValue substringToIndex:i] attributes:attr] size].width;
            if((xpos + width)/2 <= x) {
                self.startCursorLocation = i;
            }
            else {
                return true;
            }
            xpos = width;
        }
        return true;
    }
    else {
        for(int i=0; i<self.eqChildren.count; i++) {
            if(x >= [self.eqChildren[i] frame].origin.x && y >= [self.eqChildren[i] frame].origin.y && x <= [self.eqChildren[i] frame].origin.x + [self.eqChildren[i] frame].size.width && y <= [self.eqChildren[i] frame].origin.y + [self.eqChildren[i] frame].size.height) {
                BOOL success = [self.eqChildren[i] setStartCursorToEq:x y:y];
                if(success) {
                    self.childWithStartCursor = i;
                    return true;
                }
                else {
                    self.childWithStartCursor = -1;
                }
            }
        }
    }
    return false;
}

- (NSString*) toLaTeX {
    if(self.eqFormat == LEAF) {
        return self.eqTextField.stringValue;
    }
    else if(self.eqFormat == NORMAL) {
        NSMutableString *str = [[NSMutableString alloc] init];
        for(int i=0; i<self.eqChildren.count; i++) {
            [str appendString:[self.eqChildren[i] toLaTeX]];
        }
        return str;
    }
    else if(self.eqFormat == DIVISION) {
        return [NSString stringWithFormat:@"\\frac{%@}{%@}",[self.eqChildren[0] toLaTeX], [self.eqChildren[1] toLaTeX]];
    }
    else {
        // error
        return @"";
    }
}

// this function simply shifts components left-and-right in order to correct for rounding-errors
- (void) completeMinorComponentShifts {
    for(int i=0; i<self.eqChildren.count; i++) {
        [self.eqChildren[i] completeMinorComponentShifts];
    }
    
    double width = 0;
    if(self.eqFormat == LEAF) {
        
        if([self.eqTextField.stringValue isEqual: @""]) {
            // empty leaf
            if(self.parent.eqFormat == DIVISION) {
                width = self.frame.size.height;
            }
            else {
                width = self.frame.size.height/4;
            }
        }
        else {
            width = [self.eqTextField.attributedStringValue size].width;
        }
    }
    else if(self.eqFormat == NORMAL) {
        for(int i=0; i<self.eqChildren.count; i++) {
            NSRect frame = [self.eqChildren[i] frame];
            [self.eqChildren[i] setFrame:NSMakeRect(width, frame.origin.y, frame.size.width, frame.size.height)];
            width += [self.eqChildren[i] frame].size.width;
        }
    }
    else if(self.eqFormat == DIVISION) {
        width = fmax([self.eqChildren[0] frame].size.width, [self.eqChildren[1] frame].size.width);
    }
    else {
        // error
    }
    
    self.frame = NSMakeRect(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
}

- (void) resetAllCursorPointers {
    for(int i=0; i<self.eqChildren.count; i++) {
        [self.eqChildren[i] resetAllCursorPointers];
    }
    self.childWithStartCursor = -1;
    self.childWithEndCursor = -1;
    self.startCursorLocation = -1;
    self.endCursorLocation = -1;
}

@end
