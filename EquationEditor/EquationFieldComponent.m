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

- (EquationFieldComponent*) initWithFontManagerOptionsAndParent:(FontManager*)f options: (EquationFieldOptions*) o parent: (EquationFieldComponent*) p {
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

- (void) drawRect:(NSRect)dirtyRect {
    // draw static features
    if(self.eqFormat == DIVISION) {
        double thickness = self.relativeSize*self.requestGrantRatio*self.options.maxFontSize/40;
        [[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1.0] setFill];
        NSRectFill(NSMakeRect(0, [self.eqChildren[1] frame].size.height-thickness/2, self.frame.size.width-100, thickness));
    }
    else if(self.eqFormat == SQUAREROOT) {
        double thickness = self.frame.size.height/40;
        double x = self.frame.size.height * (self.eqImageView.image.size.width/self.eqImageView.image.size.height);
        x -= self.frame.size.height * 0.03;
        [[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1.0] setFill];
        NSRectFill(NSMakeRect(x, self.frame.size.height-thickness, self.frame.size.width-x-100, thickness));
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
    self.relativeSize = fontSize/self.options.maxFontSize;
    
    // recurse over children
    if(self.eqFormat == NORMAL) {
        for(int i=0; i<self.eqChildren.count; i++) {
            [self.eqChildren[i] makeSizeRequest:fontSize];
        }
    }
    else if(self.eqFormat == DIVISION) {
        double newFontSize = fontSize * self.options.divisionDecayRate;
        if(newFontSize < self.options.maxFontSize * self.options.minFontSizeAsRatioOfMaxFontSize) {
            newFontSize = self.options.maxFontSize * self.options.minFontSizeAsRatioOfMaxFontSize;
        }
        [self.eqChildren[0] makeSizeRequest:newFontSize];
        [self.eqChildren[1] makeSizeRequest:newFontSize];
    }
    else if(self.eqFormat == SUPERSCRIPT) {
        double newFontSize = fontSize * self.options.superscriptDecayRate;
        if(newFontSize < self.options.maxFontSize * self.options.minFontSizeAsRatioOfMaxFontSize) {
            newFontSize = self.options.maxFontSize * self.options.minFontSizeAsRatioOfMaxFontSize;
        }
        [self.eqChildren[0] makeSizeRequest:newFontSize];
    }
    else if(self.eqFormat == SQUAREROOT) {
        double newFontSize = fontSize * self.options.squarerootDecayRate;
        if(newFontSize < self.options.maxFontSize * self.options.minFontSizeAsRatioOfMaxFontSize) {
            newFontSize = self.options.maxFontSize * self.options.minFontSizeAsRatioOfMaxFontSize;
        }
        [self.eqChildren[0] makeSizeRequest:newFontSize];
    }
    else if(self.eqFormat == SUMMATION) {
        double newFontSize = fontSize * self.options.squarerootDecayRate;
        if(newFontSize < self.options.maxFontSize * self.options.minFontSizeAsRatioOfMaxFontSize) {
            newFontSize = self.options.maxFontSize * self.options.minFontSizeAsRatioOfMaxFontSize;
        }
        [self.eqChildren[0] makeSizeRequest:newFontSize];   // bottom
        [self.eqChildren[1] makeSizeRequest:newFontSize];   // top
        [self.eqChildren[2] makeSizeRequest:fontSize];      // term
    }
    
    // do own calculations
    if(self.eqFormat == LEAF) {
        NSString *str = self.eqTextField.stringValue;
        NSDictionary *attr = @{NSFontAttributeName : [self.fontManager getFont:fontSize]};
        self.eqTextField.attributedStringValue = [[NSAttributedString alloc] initWithString:str attributes:attr];
        NSSize size = [self.eqTextField.attributedStringValue size];
        self.heightRatio = 0.5;
        if([self.eqTextField.stringValue isEqual: @""]) {
            // empty leaf
            
            if(self.parent.eqFormat == DIVISION || self.parent.eqFormat == SUPERSCRIPT || self.parent.eqFormat == SQUAREROOT) {
                size.width = fontSize;
            }
            else {
                size.width = 0;
            }
        }
        self.frame = NSMakeRect(self.frame.origin.x, self.frame.origin.y, size.width, fontSize);
    }
    else if(self.eqFormat == DIVISION) {
        double width = fmax([self.eqChildren[0] frame].size.width, [self.eqChildren[1] frame].size.width);
        double height = [self.eqChildren[0] frame].size.height + [self.eqChildren[1] frame].size.height;
        self.heightRatio = [self.eqChildren[1] frame].size.height / height;
        self.frame = NSMakeRect(self.frame.origin.x, self.frame.origin.y, width, height);
    }
    else if(self.eqFormat == SUPERSCRIPT) {
        double childWidth = [self.eqChildren[0] frame].size.width;
        double childHeight = [self.eqChildren[0] frame].size.height;
        self.heightRatio = 0;
        self.frame = NSMakeRect(0, 0, childWidth, childHeight);
    }
    else if(self.eqFormat == SQUAREROOT) {
        double childWidth = [self.eqChildren[0] frame].size.width;
        double childHeight = [self.eqChildren[0] frame].size.height;
        double imageHeight = childHeight*(1+self.options.squarerootVerticalPaddingFontSizeRatio);
        double imageWidth = (self.eqImageView.image.size.width/self.eqImageView.image.size.height) * imageHeight;
        self.heightRatio = 0.5;
        self.frame = NSMakeRect(0, 0, childWidth+imageWidth, imageHeight);
    }
    else if(self.eqFormat == SUMMATION) {
        // todo
        /*
        double bottomWidth = [self.eqChildren[0] frame].size.width;
        double bottomHeight = [self.eqChildren[0] frame].size.height;
        double topWidth = [self.eqChildren[1] frame].size.width;
        double topHeight = [self.eqChildren[1] frame].size.height;
        double termWidth = [self.eqChildren[2] frame].size.width;
        double termHeight = [self.eqChildren[2] frame].size.height;
        
        
        double sumImageHeight = fmax(termHeight - (bottomHeight+topHeight), termHeight/2);
        double sumImageWidth = (self.eqImageView.image.size.width/self.eqImageView.image.size.height) * sumImageHeight;
        self.heightRatio = 0.5;
        self.frame = NSMakeRect(0, 0, fmax(fmax(bottomWidth, topWidth), sumImageWidth) + termWidth ,fmax(bottomHeight+sumImageHeight+topHeight, termHeight));
         */
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
}

- (void) grantSizeRequest: (NSRect) rect {
    self.requestGrantRatio = rect.size.width / self.frame.size.width;
    self.frame = rect;
    
    if(self.eqFormat == LEAF) {
        NSString *str = self.eqTextField.stringValue;
        double fontSize = self.frame.size.height/self.options.fontSizeToLeafA;
        NSDictionary *attr = @{NSFontAttributeName : [self.fontManager getFont:fontSize]};
        self.eqTextField.attributedStringValue = [[NSAttributedString alloc] initWithString:str attributes:attr];
        self.eqTextField.frame = NSMakeRect(0, 0, rect.size.width, rect.size.height + fontSize * self.options.fontSizeToLeafB);
    }
    else if(self.eqFormat == NORMAL) {
        double newX = 0;
        double centerY = self.heightRatio * self.frame.size.height;
        for(int i=0; i<self.eqChildren.count; i++) {
            if([self.eqChildren[i] eqFormat] == SUPERSCRIPT) {
                NSSize oldSize = [self.eqChildren[i] frame].size;
                double heightOfLastChild = 0;
                if(i == 0) {
                    NSLog(@"ERROR - SUPERSCRIPT IS RIGHT-MOST CHILD");
                }
                else {
                    heightOfLastChild = [self.eqChildren[i-1] frame].size.height;
                }
                [self.eqChildren[i] grantSizeRequest:NSMakeRect(newX, heightOfLastChild/2, oldSize.width * self.requestGrantRatio, oldSize.height * self.requestGrantRatio)];
                newX += [self.eqChildren[i] frame].size.width;
            }
            else {
                NSSize oldSize = [self.eqChildren[i] frame].size;
                double childHeightRatio = [self.eqChildren[i] heightRatio];
                [self.eqChildren[i] grantSizeRequest:NSMakeRect(newX, centerY-oldSize.height * self.requestGrantRatio * childHeightRatio, oldSize.width * self.requestGrantRatio, oldSize.height * self.requestGrantRatio)];
                newX += [self.eqChildren[i] frame].size.width;
            }
        }
    }
    else if(self.eqFormat == DIVISION) {
        if([self.eqChildren[0] frame].size.width < [self.eqChildren[1] frame].size.width) {
            // bottom is larger
            double centerAdjustment = self.requestGrantRatio * ([self.eqChildren[1] frame].size.width - [self.eqChildren[0] frame].size.width)/2;
            NSSize oldSize = [self.eqChildren[1] frame].size;
            [self.eqChildren[1] grantSizeRequest:NSMakeRect(0, 0, oldSize.width * self.requestGrantRatio, oldSize.height * self.requestGrantRatio)];
            oldSize = [self.eqChildren[0] frame].size;
            double newY = [self.eqChildren[1] frame].size.height;
            [self.eqChildren[0] grantSizeRequest:NSMakeRect(centerAdjustment, newY, oldSize.width * self.requestGrantRatio, oldSize.height * self.requestGrantRatio)];
        }
        else {
            // top is larger
            double centerAdjustment = self.requestGrantRatio * ([self.eqChildren[0] frame].size.width - [self.eqChildren[1] frame].size.width)/2;
            NSSize oldSize = [self.eqChildren[1] frame].size;
            [self.eqChildren[1] grantSizeRequest:NSMakeRect(centerAdjustment, 0, oldSize.width * self.requestGrantRatio, oldSize.height * self.requestGrantRatio)];
            oldSize = [self.eqChildren[0] frame].size;
            double newY = [self.eqChildren[1] frame].size.height;
            [self.eqChildren[0] grantSizeRequest:NSMakeRect(0, newY, oldSize.width * self.requestGrantRatio, oldSize.height * self.requestGrantRatio)];
        }
    }
    else if(self.eqFormat == SUPERSCRIPT) {
        double centerY = self.heightRatio * self.frame.size.height;
        NSSize oldSize = [self.eqChildren[0] frame].size;
        [self.eqChildren[0] grantSizeRequest:NSMakeRect(0, centerY, oldSize.width * self.requestGrantRatio, oldSize.height * self.requestGrantRatio)];
    }
    else if(self.eqFormat == SQUAREROOT) {
        double rootImageHeight = self.frame.size.height;
        double rootImageWidth = (self.eqImageView.image.size.width/self.eqImageView.image.size.height) * rootImageHeight;
        double childHeight = self.frame.size.height / (1 + self.options.squarerootVerticalPaddingFontSizeRatio);
        [self.eqChildren[0] grantSizeRequest:NSMakeRect(rootImageWidth, 0, self.frame.size.width - rootImageWidth, childHeight)];
        self.eqImageView.frame = NSMakeRect(0, 0, rootImageWidth, rootImageHeight);
    }
    else if(self.eqFormat == SUMMATION) {
        // todo
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
    else if(self.eqFormat == SQUAREROOT) {
        [self addSubview:self.eqImageView];
    }
}

- (BOOL) setStartCursorToEq: (double) x y: (double) y {
    x -= self.frame.origin.x;
    y -= self.frame.origin.y;
    if(self.eqFormat == LEAF) {
        self.childWithStartCursor = -1;
        self.startCursorLocation = 0;
        NSDictionary *attr = @{NSFontAttributeName : [self.fontManager getFont:self.eqTextField.frame.size.height/self.options.fontSizeToLeafA]};
        double xpos = 0;
        [self.eqTextField setContainsCursor:true];
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
    else if(self.eqFormat == DIVISION) {
        if(y >= self.heightRatio*self.frame.size.height) {
            BOOL success = [self.eqChildren[0] setStartCursorToEq:x y:y];
            if(success) {
                self.childWithStartCursor = 0;
                return true;
            }
            else {
                self.childWithStartCursor = -1;
            }
        }
        else {
            BOOL success = [self.eqChildren[1] setStartCursorToEq:x y:y];
            if(success) {
                self.childWithStartCursor = 1;
                return true;
            }
            else {
                self.childWithStartCursor = -1;
            }
        }
    }
    else if(self.eqFormat == SUPERSCRIPT) {
        BOOL success = [self.eqChildren[0] setStartCursorToEq:x y:y];
        if(success) {
            self.childWithStartCursor = 0;
            return true;
        }
        else {
            self.childWithStartCursor = -1;
        }
    }
    else if(self.eqFormat == SQUAREROOT) {
        BOOL success = [self.eqChildren[0] setStartCursorToEq:x y:y];
        if(success) {
            self.childWithStartCursor = 0;
            return true;
        }
        else {
            self.childWithStartCursor = -1;
        }
    }
    else if(self.eqFormat == NORMAL){
        for(int i=0; i<self.eqChildren.count; i++) {
            if(x >= [self.eqChildren[i] frame].origin.x && x <= [self.eqChildren[i] frame].origin.x + [self.eqChildren[i] frame].size.width-100) {
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
    else if(self.eqFormat == SUPERSCRIPT) {
        return [NSString stringWithFormat:@"^{%@}",[self.eqChildren[0] toLaTeX]];
    }
    else if(self.eqFormat == SQUAREROOT) {
        return [NSString stringWithFormat:@"\\sqrt{%@}",[self.eqChildren[0] toLaTeX]];
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
            if(self.parent.eqFormat == DIVISION || self.parent.eqFormat == SUPERSCRIPT || self.parent.eqFormat == SQUAREROOT) {
                width = self.frame.size.height;
            }
            else {
                width = 0;
            }
        }
        else {
            width = [self.eqTextField.attributedStringValue size].width + [self.eqTextField.attributedStringValue size].height*self.options.horizontalPaddingFontSizeRatio;
        }
    }
    else if(self.eqFormat == DIVISION) {
        width = fmax([self.eqChildren[0] frame].size.width, [self.eqChildren[1] frame].size.width);
    }
    else if(self.eqFormat == SUPERSCRIPT) {
        width = [self.eqChildren[0] frame].size.width;
    }
    else if(self.eqFormat == SQUAREROOT) {
        double childWidth = [self.eqChildren[0] frame].size.width;
        double childHeight = [self.eqChildren[0] frame].size.height;
        double rootImageHeight = childHeight*(1+self.options.squarerootVerticalPaddingFontSizeRatio);
        double rootImageWidth = (self.eqImageView.image.size.width/self.eqImageView.image.size.height) * rootImageHeight;
        self.frame = NSMakeRect(0, 0, childWidth+rootImageWidth, rootImageHeight);
        width = childWidth + rootImageWidth;
    }
    else if(self.eqFormat == NORMAL) {
        for(int i=0; i<self.eqChildren.count; i++) {
            NSRect frame = [self.eqChildren[i] frame];
            [self.eqChildren[i] setFrame:NSMakeRect(width, frame.origin.y, frame.size.width, frame.size.height)];
            width += [self.eqChildren[i] frame].size.width;
        }
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
    if(self.eqFormat == LEAF) {
        [self.eqTextField setContainsCursor:false];
    }
}

- (void) simplifyStructure {
    /*
    for(int i=1; i<self.eqChildren.count; i++) {
        [self.eqChildren[i] simplifyStructure];
    }
    
    if(self.eqFormat == NORMAL) {
        // combine with child NORMALs
        for(int i=0; i<self.eqChildren.count; i++) {
            if([self.eqChildren[i] eqFormat] == NORMAL) {
                // combine with child NORMALs
                if(self.childWithStartCursor == i) {
                    self.childWithStartCursor += [self.eqChildren[i] childWithStartCursor] + 1;
                }
                else if(self.childWithStartCursor > i) {
                    self.childWithStartCursor += (int) [self.eqChildren[i] eqChildren].count;
                }
                
                for(int j=0; j<[self.eqChildren[i] eqChildren].count; j++) {
                    [self.eqChildren insertObject:[self.eqChildren[i] eqChildren][j] atIndex:i+j+1];
                }
                [self.eqChildren removeObjectAtIndex:i];
                i--;
            }
        }
        
        // combine adjacent LEAFs
        for(int i=1; i<self.eqChildren.count; i++) {
            if([self.eqChildren[i-1] eqFormat] == LEAF && [self.eqChildren[i] eqFormat] == LEAF) {
                // combine adjacent LEAFs
                NSMutableString *str = [[NSMutableString alloc] initWithString:[self.eqChildren[i-1] eqTextField].stringValue];
                [str appendString:[self.eqChildren[i] eqTextField].stringValue];
                NSDictionary *attr = @{NSFontAttributeName : [self.fontManager getFont:self.eqTextField.frame.size.height/self.options.fontSizeToLeafA]};
                [self.eqChildren[i-1] eqTextField].attributedStringValue = [[NSAttributedString alloc] initWithString:str attributes:attr];
                [self.eqChildren removeObjectAtIndex:i];
                i--;
            }
        }
    }
    */
}

- (void) addHundredToWidth {
    for(int i=0; i<self.eqChildren.count; i++) {
        [self.eqChildren[i] addHundredToWidth];
    }
    self.frame = NSMakeRect(self.frame.origin.x, self.frame.origin.y, self.frame.size.width+100, self.frame.size.height);
    self.eqTextField.frame = NSMakeRect(self.eqTextField.frame.origin.x, self.eqTextField.frame.origin.y, self.eqTextField.frame.size.width+100, self.eqTextField.frame.size.height);
}

- (void) deleteMyChildren {
    //
}

@end
