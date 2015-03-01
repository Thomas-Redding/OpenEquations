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
    self.shouldBeCompletelyHighlighted = false;
    self.highlightLeafLeft = -1;
    self.highlightLeafRight = -1;
    
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
    
    if(self.shouldBeCompletelyHighlighted) {
        [[NSColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.1] setFill];
        NSRectFill(NSMakeRect(dirtyRect.origin.x, dirtyRect.origin.y, dirtyRect.size.width-100, dirtyRect.size.height));
    }
    else if(self.eqFormat == LEAF && (self.highlightLeafLeft != -1 || self.highlightLeafRight != -1)) {
        NSDictionary *attr = @{NSFontAttributeName : [self.fontManager getFont:self.frame.size.height/self.options.fontSizeToLeafA]};
        double x = [[[NSAttributedString alloc] initWithString:[self.eqTextField.stringValue substringToIndex:self.highlightLeafLeft] attributes:attr] size].width;
        NSSize size = [[[NSAttributedString alloc] initWithString:[self.eqTextField.stringValue substringWithRange:NSMakeRange(self.highlightLeafLeft, self.highlightLeafRight-self.highlightLeafLeft)] attributes:attr] size];
        [[NSColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.1] setFill];
        NSRectFill(NSMakeRect(self.eqTextField.frame.origin.x+x, self.eqTextField.frame.origin.y, size.width, size.height));
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
        double newFontSize = fontSize * self.options.summationDecayRate;
        if(newFontSize < self.options.maxFontSize * self.options.minFontSizeAsRatioOfMaxFontSize) {
            newFontSize = self.options.maxFontSize * self.options.minFontSizeAsRatioOfMaxFontSize;
        }
        [self.eqChildren[0] makeSizeRequest:newFontSize];   // bottom
        [self.eqChildren[1] makeSizeRequest:newFontSize];   // top
        [self.eqChildren[2] makeSizeRequest:fontSize];      // term
    }
    else if(self.eqFormat == INTEGRATION) {
        double newFontSize = fontSize * self.options.integrationDecayRate;
        if(newFontSize < self.options.maxFontSize * self.options.minFontSizeAsRatioOfMaxFontSize) {
            newFontSize = self.options.maxFontSize * self.options.minFontSizeAsRatioOfMaxFontSize;
        }
        [self.eqChildren[0] makeSizeRequest:newFontSize];   // bottom
        [self.eqChildren[1] makeSizeRequest:newFontSize];   // top
        [self.eqChildren[2] makeSizeRequest:fontSize];      // term
    }
    else if(self.eqFormat == LOGBASE) {
        double newFontSize = fontSize * self.options.logbaseDecayRate;
        if(newFontSize < self.options.maxFontSize * self.options.minFontSizeAsRatioOfMaxFontSize) {
            newFontSize = self.options.maxFontSize * self.options.minFontSizeAsRatioOfMaxFontSize;
        }
        [self.eqChildren[0] makeSizeRequest:newFontSize];   // base
        [self.eqChildren[1] makeSizeRequest:fontSize];      // term
    }
    else if(self.eqFormat == PARENTHESES) {
        [self.eqChildren[0] makeSizeRequest:fontSize];
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
        double bottomWidth = [self.eqChildren[0] frame].size.width;
        double bottomHeight = [self.eqChildren[0] frame].size.height;
        double topWidth = [self.eqChildren[1] frame].size.width;
        double topHeight = [self.eqChildren[1] frame].size.height;
        double termWidth = [self.eqChildren[2] frame].size.width;
        double termHeight = [self.eqChildren[2] frame].size.height;
        double imageHeight = fmax(termHeight - (bottomHeight+topHeight), termHeight*self.options.minSizeOfSummationSymbolRelativeToTermHeight);
        double imageWidth = (self.eqImageView.image.size.width/self.eqImageView.image.size.height) * imageHeight;
        
        double heightAbove = fmax(imageHeight/2 + topHeight, termHeight * (1-[self.eqChildren[2] heightRatio]));
        double heightBelow = fmax(imageHeight/2 + bottomHeight, termHeight * [self.eqChildren[2] heightRatio]);
        self.heightRatio = heightBelow/(heightAbove+heightBelow);
        
        self.frame = NSMakeRect(0, 0, fmax(fmax(bottomWidth, topWidth), imageWidth) + termWidth , heightAbove+heightBelow);
    }
    else if(self.eqFormat == INTEGRATION) {
        double bottomWidth = [self.eqChildren[0] frame].size.width;
        double bottomHeight = [self.eqChildren[0] frame].size.height;
        double topWidth = [self.eqChildren[1] frame].size.width;
        double topHeight = [self.eqChildren[1] frame].size.height;
        double termWidth = [self.eqChildren[2] frame].size.width;
        double termHeight = [self.eqChildren[2] frame].size.height;
        
        double imageHeight = fmax(termHeight - (bottomHeight+topHeight), termHeight*self.options.minSizeOfSummationSymbolRelativeToTermHeight);
        double imageWidth = (self.eqImageView.image.size.width/self.eqImageView.image.size.height) * imageHeight;
        
        double heightAbove = fmax(imageHeight/2 + topHeight, termHeight * (1-[self.eqChildren[2] heightRatio]));
        double heightBelow = fmax(imageHeight/2 + bottomHeight, termHeight * [self.eqChildren[2] heightRatio]);
        self.heightRatio = heightBelow/(heightAbove+heightBelow);
        
        self.frame = NSMakeRect(0, 0, fmax(fmax(bottomWidth, topWidth), imageWidth) + termWidth , heightAbove+heightBelow);
    }
    else if(self.eqFormat == LOGBASE) {
        double bottomWidth = [self.eqChildren[0] frame].size.width;
        double bottomHeight = [self.eqChildren[0] frame].size.height;
        double termWidth = [self.eqChildren[1] frame].size.width;
        double termHeight = [self.eqChildren[1] frame].size.height;
        double imageHeight = termHeight * self.options.sizeOfLogSymbolRelativeToTermHeight;
        double imageWidth = (self.eqImageView.image.size.width/self.eqImageView.image.size.height) * imageHeight;
        
        double heightBelow = fmax(termHeight * [self.eqChildren[1] heightRatio], bottomHeight);
        double heightAbove = termHeight * (1-[self.eqChildren[1] heightRatio]);
        self.heightRatio = heightBelow/(heightBelow + heightAbove);
        double width = imageWidth+bottomWidth+termWidth;
        
        self.frame = NSMakeRect(0, 0, width, heightBelow + heightAbove);
    }
    else if(self.eqFormat == PARENTHESES) {
        double childWidth = [self.eqChildren[0] frame].size.width;
        double childHeight = [self.eqChildren[0] frame].size.height;
        double imageHeight = childHeight;
        double imageWidth = (self.eqImageView.image.size.width/self.eqImageView.image.size.height) * imageHeight;
        self.heightRatio = [self.eqChildren[0] heightRatio];
        self.frame = NSMakeRect(0, 0, imageWidth+childWidth+imageWidth, childHeight);
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
                double positionOfLastChild = 0;
                if(i == 0) {
                    NSLog(@"ERROR - SUPERSCRIPT IS RIGHT-MOST CHILD");
                }
                else {
                    heightOfLastChild = [self.eqChildren[i-1] frame].size.height;
                    positionOfLastChild = [self.eqChildren[i-1] frame].origin.y;
                }
                [self.eqChildren[i] grantSizeRequest:NSMakeRect(newX, positionOfLastChild+heightOfLastChild/2, oldSize.width * self.requestGrantRatio, oldSize.height * self.requestGrantRatio)];
                newX += [self.eqChildren[i] frame].size.width;
            }
            else {
                NSSize oldSize = [self.eqChildren[i] frame].size;
                double childHeightRatio = [self.eqChildren[i] heightRatio];
                [self.eqChildren[i] grantSizeRequest:NSMakeRect(newX, centerY - oldSize.height * self.requestGrantRatio * childHeightRatio, oldSize.width * self.requestGrantRatio, oldSize.height * self.requestGrantRatio)];
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
        // double centerY = self.heightRatio * self.frame.size.height;
        // NSSize oldSize = [self.eqChildren[0] frame].size;
        [self.eqChildren[0] grantSizeRequest:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
    }
    else if(self.eqFormat == SQUAREROOT) {
        double rootImageHeight = self.frame.size.height;
        double rootImageWidth = (self.eqImageView.image.size.width/self.eqImageView.image.size.height) * rootImageHeight;
        double childHeight = self.frame.size.height / (1 + self.options.squarerootVerticalPaddingFontSizeRatio);
        [self.eqChildren[0] grantSizeRequest:NSMakeRect(rootImageWidth, 0, self.frame.size.width - rootImageWidth, childHeight)];
        self.eqImageView.frame = NSMakeRect(0, 0, rootImageWidth, rootImageHeight);
    }
    else if(self.eqFormat == SUMMATION) {
        double bottomWidth = [self.eqChildren[0] frame].size.width * self.requestGrantRatio;
        double bottomHeight = [self.eqChildren[0] frame].size.height * self.requestGrantRatio;
        double topWidth = [self.eqChildren[1] frame].size.width * self.requestGrantRatio;
        double topHeight = [self.eqChildren[1] frame].size.height * self.requestGrantRatio;
        double termWidth = [self.eqChildren[2] frame].size.width * self.requestGrantRatio;
        double termHeight = [self.eqChildren[2] frame].size.height * self.requestGrantRatio;
        double imageHeight = fmax(termHeight - (bottomHeight+topHeight), termHeight * self.options.minSizeOfSummationSymbolRelativeToTermHeight);
        double imageWidth = (self.eqImageView.image.size.width/self.eqImageView.image.size.height) * imageHeight;
        
        double maxWidth = fmax(fmax(bottomWidth, topWidth), imageWidth);
        
        double centerY = fmax(bottomHeight + imageHeight/2, termHeight * [self.eqChildren[1] heightRatio]);
        
        self.eqImageView.frame = NSMakeRect(maxWidth/2-imageWidth/2, centerY-imageHeight/2, imageWidth, imageHeight);
        [self.eqChildren[0] grantSizeRequest:NSMakeRect(maxWidth/2-bottomWidth/2, centerY-bottomHeight-imageHeight/2, bottomWidth, bottomHeight)];
        [self.eqChildren[1] grantSizeRequest:NSMakeRect(maxWidth/2-topWidth/2, centerY+imageHeight/2, topWidth, topHeight)];
        [self.eqChildren[2] grantSizeRequest:NSMakeRect(maxWidth, (bottomHeight+imageHeight+topHeight)/2 - termHeight * [self.eqChildren[1] heightRatio], termWidth, termHeight)];
        self.frame = NSMakeRect(0, 0, fmax(fmax(bottomWidth, topWidth), imageWidth) + termWidth ,fmax(bottomHeight+imageHeight+topHeight, termHeight));
    }
    else if(self.eqFormat == INTEGRATION) {
        double bottomWidth = [self.eqChildren[0] frame].size.width * self.requestGrantRatio;
        double bottomHeight = [self.eqChildren[0] frame].size.height * self.requestGrantRatio;
        double topWidth = [self.eqChildren[1] frame].size.width * self.requestGrantRatio;
        double topHeight = [self.eqChildren[1] frame].size.height * self.requestGrantRatio;
        double termWidth = [self.eqChildren[2] frame].size.width * self.requestGrantRatio;
        double termHeight = [self.eqChildren[2] frame].size.height * self.requestGrantRatio;
        double imageHeight = fmax(termHeight - (bottomHeight+topHeight), termHeight * self.options.minSizeOfSummationSymbolRelativeToTermHeight);
        double imageWidth = (self.eqImageView.image.size.width/self.eqImageView.image.size.height) * imageHeight;
        
        double maxWidth = fmax(fmax(bottomWidth, topWidth), imageWidth);
        
        double centerY = fmax(bottomHeight + imageHeight/2, termHeight * [self.eqChildren[1] heightRatio]);
        
        self.eqImageView.frame = NSMakeRect(maxWidth/2-imageWidth/2, centerY-imageHeight/2, imageWidth, imageHeight);
        [self.eqChildren[0] grantSizeRequest:NSMakeRect(maxWidth/2-bottomWidth/2, centerY-bottomHeight-imageHeight/2, bottomWidth, bottomHeight)];
        [self.eqChildren[1] grantSizeRequest:NSMakeRect(maxWidth/2-topWidth/2, centerY+imageHeight/2, topWidth, topHeight)];
        [self.eqChildren[2] grantSizeRequest:NSMakeRect(maxWidth, (bottomHeight+imageHeight+topHeight)/2 - termHeight * [self.eqChildren[1] heightRatio], termWidth, termHeight)];
        self.frame = NSMakeRect(0, 0, fmax(fmax(bottomWidth, topWidth), imageWidth) + termWidth ,fmax(bottomHeight+imageHeight+topHeight, termHeight));
    }
    else if(self.eqFormat == LOGBASE) {
        double bottomWidth = [self.eqChildren[0] frame].size.width * self.requestGrantRatio;
        double bottomHeight = [self.eqChildren[0] frame].size.height * self.requestGrantRatio;
        double termWidth = [self.eqChildren[1] frame].size.width * self.requestGrantRatio;
        double termHeight = [self.eqChildren[1] frame].size.height * self.requestGrantRatio;
        double imageHeight = termHeight * self.options.sizeOfLogSymbolRelativeToTermHeight;
        double imageWidth = (self.eqImageView.image.size.width/self.eqImageView.image.size.height) * imageHeight;
        
        double heightBelow = fmax(termHeight * [self.eqChildren[1] heightRatio], bottomHeight);
        
        self.eqImageView.frame = NSMakeRect(0, heightBelow-imageHeight/2, imageWidth, imageHeight);
        [self.eqChildren[0] grantSizeRequest:NSMakeRect(imageWidth, heightBelow-bottomHeight, bottomWidth, bottomHeight)];
        [self.eqChildren[1] grantSizeRequest:NSMakeRect(imageWidth+bottomWidth, heightBelow-termHeight*[self.eqChildren[1] heightRatio], termWidth, termHeight)];
    }
    else if(self.eqFormat == PARENTHESES) {
        double childWidth = [self.eqChildren[0] frame].size.width * self.requestGrantRatio;
        double childHeight = [self.eqChildren[0] frame].size.height * self.requestGrantRatio;
        double imageHeight = childHeight;
        double imageWidth = (self.eqImageView.image.size.width/self.eqImageView.image.size.height) * imageHeight;
        
        self.eqImageView.frame = NSMakeRect(0, 0, imageWidth, imageHeight);
        self.eqImageViewB.frame = NSMakeRect(imageWidth+childWidth, 0, imageWidth, imageHeight);
        [self.eqChildren[0] grantSizeRequest:NSMakeRect(imageWidth, 0, childWidth, childHeight)];
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
    else if(self.eqFormat == SQUAREROOT || self.eqFormat == SUMMATION || self.eqFormat == INTEGRATION || self.eqFormat == LOGBASE) {
        [self addSubview:self.eqImageView];
    }
    else if(self.eqFormat == PARENTHESES) {
        [self addSubview:self.eqImageView];
        [self addSubview:self.eqImageViewB];
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
    else if(self.eqFormat == SUMMATION) {
        double leftWidth = fmax(fmax([self.eqChildren[0] frame].size.width-100, [self.eqChildren[1] frame].size.width-100), self.eqImageView.frame.size.width);
        if(x < leftWidth) {
            if(y < [self.eqChildren[0] frame].size.height + self.eqImageView.frame.size.height/2) {
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
        else {
            BOOL success = [self.eqChildren[2] setStartCursorToEq:x y:y];
            if(success) {
                self.childWithStartCursor = 2;
                return true;
            }
            else {
                self.childWithStartCursor = -1;
            }
        }
    }
    else if(self.eqFormat == INTEGRATION) {
        double leftWidth = fmax(fmax([self.eqChildren[0] frame].size.width-100, [self.eqChildren[1] frame].size.width-100), self.eqImageView.frame.size.width);
        if(x < leftWidth) {
            if(y < [self.eqChildren[0] frame].size.height + self.eqImageView.frame.size.height/2) {
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
        else {
            BOOL success = [self.eqChildren[2] setStartCursorToEq:x y:y];
            if(success) {
                self.childWithStartCursor = 2;
                return true;
            }
            else {
                self.childWithStartCursor = -1;
            }
        }
    }
    else if(self.eqFormat == INTEGRATION) {
        if(x < self.eqImageView.frame.size.width+[self.eqChildren[0] frame].size.width) {
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
    else if(self.eqFormat == PARENTHESES){
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
        return [NSString stringWithFormat:@"\\frac{%@}{%@}", [self.eqChildren[0] toLaTeX], [self.eqChildren[1] toLaTeX]];
    }
    else if(self.eqFormat == SUPERSCRIPT) {
        return [NSString stringWithFormat:@"^{%@}", [self.eqChildren[0] toLaTeX]];
    }
    else if(self.eqFormat == SQUAREROOT) {
        return [NSString stringWithFormat:@"\\sqrt{%@}", [self.eqChildren[0] toLaTeX]];
    }
    else if(self.eqFormat == SUMMATION) {
        return [NSString stringWithFormat:@"\\sum^{%@}_{%@}{%@}", [self.eqChildren[0] toLaTeX], [self.eqChildren[1] toLaTeX], [self.eqChildren[2] toLaTeX]];
    }
    else if(self.eqFormat == INTEGRATION) {
        return [NSString stringWithFormat:@"\\int^{%@}_{%@}{%@}", [self.eqChildren[0] toLaTeX], [self.eqChildren[1] toLaTeX], [self.eqChildren[2] toLaTeX]];
    }
    else if(self.eqFormat == LOGBASE) {
        return [NSString stringWithFormat:@"\\log_{%@}{%@}", [self.eqChildren[0] toLaTeX], [self.eqChildren[1] toLaTeX]];
    }
    else if(self.eqFormat == PARENTHESES) {
        return [NSString stringWithFormat:@"\\left(%@\\right)", [self.eqChildren[0] toLaTeX]];
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
    else if(self.eqFormat == SUMMATION) {
        double leftWidth = fmax(fmax([self.eqChildren[0] frame].size.width, [self.eqChildren[1] frame].size.width), self.eqImageView.frame.size.width);
        width = leftWidth + [self.eqChildren[2] frame].size.width;
    }
    else if(self.eqFormat == INTEGRATION) {
        double leftWidth = fmax(fmax([self.eqChildren[0] frame].size.width, [self.eqChildren[1] frame].size.width), self.eqImageView.frame.size.width);
        width = leftWidth + [self.eqChildren[2] frame].size.width;
    }
    else if(self.eqFormat == LOGBASE) {
        width = self.eqImageView.frame.size.width + [self.eqChildren[0] frame].size.width + [self.eqChildren[1] frame].size.width;
    }
    else if(self.eqFormat == NORMAL) {
        for(int i=0; i<self.eqChildren.count; i++) {
            NSRect frame = [self.eqChildren[i] frame];
            [self.eqChildren[i] setFrame:NSMakeRect(width, frame.origin.y, frame.size.width, frame.size.height)];
            width += [self.eqChildren[i] frame].size.width;
        }
    }
    else if(self.eqFormat == PARENTHESES) {
        width = self.eqImageView.frame.size.width + [self.eqChildren[0] frame].size.width + self.eqImageViewB.frame.size.width;
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
    for(int i=1; i<self.eqChildren.count; i++) {
        [self.eqChildren[i] simplifyStructure];
    }
    
    if(self.eqFormat == NORMAL) {
        // combine with child NORMALs
        for(int i=0; i<self.eqChildren.count; i++) {
            if([self.eqChildren[i] eqFormat] == NORMAL) {
                // combine with child NORMALs
                if(self.childWithStartCursor != -1 && self.childWithStartCursor >= i) {
                    self.childWithStartCursor += [self.eqChildren[i] childWithStartCursor];
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

- (NSArray*) toArray {
    if(self.eqFormat == LEAF) {
        return [[NSArray alloc] initWithObjects:self.eqTextField.stringValue, nil];
    }
    
    NSMutableArray *rtn = [[NSMutableArray alloc] init];
    
    // DIV, SUP, SQU, SUM, INT, LOG
    if(self.eqFormat == DIVISION) {
        [rtn addObject:@"DIVISION"];
    }
    else if(self.eqFormat == SUPERSCRIPT) {
        [rtn addObject:@"SUPERSCRIPT"];
    }
    else if(self.eqFormat == SQUAREROOT) {
        [rtn addObject:@"SQUAREROOT"];
    }
    else if(self.eqFormat == SUMMATION) {
        [rtn addObject:@"SUMMATION"];
    }
    else if(self.eqFormat == INTEGRATION) {
        [rtn addObject:@"INTEGRATION"];
    }
    else if(self.eqFormat == LOGBASE) {
        [rtn addObject:@"LOGBASE"];
    }
    else if(self.eqFormat == PARENTHESES) {
        [rtn addObject:@"PARENTHESES"];
    }
    else if(self.eqFormat == NORMAL) {
        [rtn addObject:@"NORMAL"];
    }
    
    for(int i=0; i<self.eqChildren.count; i++) {
        [rtn addObject:[self.eqChildren[i] toArray]];
    }
    
    return rtn;
}

- (void) callAllDrawRects {
    [self setNeedsDisplay:true];
    for(int i=0; i<self.eqChildren.count; i++) {
        [self.eqChildren[i] callAllDrawRects];
    }
}

- (void) calculateHighlights: (int) condition isStartLeft: (int) isStartLeft {
    /*
     condition:
     0 - highlight nothing
     1 - highlight some things (recurse)
     2 - highlight everything
     
     if 0 or 1:
        recurse saying "don't highlight", because the parent (self) will take care of it
     
     
     isStartLeft:
     -1 - startCursor is right of endCursor (in another child)
     0 - no info
     1 - startCursor is left of endCursor (in another child)
    */
    
    if(condition == 0) {
        self.shouldBeCompletelyHighlighted = false;
        if(self.eqFormat == LEAF) {
            self.highlightLeafLeft = -1;
            self.highlightLeafRight = -1;
        }
        for(int i=0; i<self.eqChildren.count; i++) {
            [self.eqChildren[i] calculateHighlights:0 isStartLeft:isStartLeft];
        }
    }
    else if(condition == 2) {
        self.shouldBeCompletelyHighlighted = true;
        if(self.eqFormat == LEAF) {
            self.highlightLeafLeft = -1;
            self.highlightLeafRight = -1;
        }
        for(int i=0; i<self.eqChildren.count; i++) {
            [self.eqChildren[i] calculateHighlights:0 isStartLeft:isStartLeft];
        }
    }
    else {
        if(self.eqFormat == LEAF) {
            if(isStartLeft == 1) {
                if(self.startCursorLocation == -1 && self.endCursorLocation == -1) {
                    self.highlightLeafLeft = -1;
                    self.highlightLeafRight = -1;
                }
                if(self.startCursorLocation == -1 && self.endCursorLocation != -1) {
                    self.highlightLeafLeft = 0;
                    self.highlightLeafRight = self.endCursorLocation;
                }
                else if(self.endCursorLocation == -1 && self.startCursorLocation != -1) {
                    self.highlightLeafLeft = self.startCursorLocation;
                    self.highlightLeafRight = (int) self.eqTextField.stringValue.length;
                }
                else {
                    self.highlightLeafLeft = fmin(self.startCursorLocation, self.endCursorLocation);
                    self.highlightLeafRight = fmax(self.startCursorLocation, self.endCursorLocation);
                }
            }
            else {
                if(self.startCursorLocation == -1 && self.endCursorLocation == -1) {
                    self.highlightLeafLeft = -1;
                    self.highlightLeafRight = -1;
                }
                if(self.startCursorLocation == -1 && self.endCursorLocation != -1) {
                    self.highlightLeafLeft = self.endCursorLocation;
                    self.highlightLeafRight = (int) self.eqTextField.stringValue.length;
                }
                else if(self.endCursorLocation == -1 && self.startCursorLocation != -1) {
                    self.highlightLeafLeft = 0;
                    self.highlightLeafRight = self.startCursorLocation;
                }
                else {
                    self.highlightLeafLeft = fmin(self.startCursorLocation, self.endCursorLocation);
                    self.highlightLeafRight = fmax(self.startCursorLocation, self.endCursorLocation);
                }
            }
        }
        for(int i=0; i<self.eqChildren.count; i++) {
            if(self.childWithStartCursor < i && i < self.childWithEndCursor && self.childWithStartCursor != -1 && self.childWithEndCursor != -1) {
                [self.eqChildren[i] calculateHighlights: 2 isStartLeft:isStartLeft];
            }
            else if(self.childWithStartCursor > i && i > self.childWithEndCursor && self.childWithStartCursor != -1 && self.childWithEndCursor != -1) {
                [self.eqChildren[i] calculateHighlights: 2 isStartLeft:isStartLeft];
            }
            else if(i == self.childWithStartCursor || i == self.childWithEndCursor) {
                if(self.childWithStartCursor < self.childWithEndCursor) {
                    [self.eqChildren[i] calculateHighlights: 1 isStartLeft: 1];
                }
                else {
                    [self.eqChildren[i] calculateHighlights: 1 isStartLeft: -1];
                }
            }
            else {
                [self.eqChildren[i] calculateHighlights: 0 isStartLeft:0];
            }
        }
    }
}

- (void) highlightLeft {
    if(self.eqFormat == LEAF) {
        if(self.endCursorLocation == -1) {
            // start highlighting
            if(self.startCursorLocation > 0) {
                self.endCursorLocation = self.startCursorLocation - 1;
                EquationFieldComponent *eq = self;
                while(eq.parent != nil) {
                    for(int i=0; i<eq.parent.eqChildren.count; i++) {
                        if(eq.parent.eqChildren[i] == eq) {
                            eq.parent.childWithEndCursor = i;
                            break;
                        }
                    }
                    eq = eq.parent;
                }
                return;
            }
        }
        else {
            // continue highlighting
            if(self.endCursorLocation > 0) {
                self.endCursorLocation--;
                return;
            }
            else {
                self.endCursorLocation = -1;
            }
        }
        
        int isLastLeaf = true;
        EquationFieldComponent *eq = self;
        while(eq.parent != nil) {
            if(eq.parent.eqChildren[0] == eq) {
                // I am the last child
            }
            else {
                isLastLeaf = false;
                break;
            }
            eq = eq.parent;
        }
        
        if(!isLastLeaf) {
            eq = self;
            while(eq.parent != nil) {
                eq = eq.parent;
                if(eq.childWithEndCursor == 0) {
                    eq.childWithEndCursor = -1;
                }
                else {
                    while(eq.childWithEndCursor > 0) {
                        eq.childWithEndCursor--;
                        if([eq.eqChildren[eq.childWithEndCursor] eqFormat] == LEAF) {
                            eq = eq.eqChildren[eq.childWithEndCursor];
                            break;
                        }
                    }
                    if(eq.eqFormat == LEAF) {
                        break;
                    }
                }
            }
            while(eq.eqChildren.count != 0) {
                eq.childWithEndCursor = 0;
                eq = eq.eqChildren[eq.childWithEndCursor];
            }
            eq.endCursorLocation = (int) eq.eqTextField.stringValue.length;
        }
        else {
            self.endCursorLocation = 0;
        }
    }
    else {
        // pass it on to children
        if(self.childWithEndCursor == -1) {
            // start highlighting
            [self.eqChildren[self.childWithStartCursor] highlightLeft];
        }
        else {
            // continue highlighting
            [self.eqChildren[self.childWithEndCursor] highlightLeft];
        }
    }
}

- (void) highlightRight {
    if(self.eqFormat == LEAF) {
        if(self.endCursorLocation == -1) {
            // start highlighting
            if(self.startCursorLocation < self.eqTextField.stringValue.length) {
                self.endCursorLocation = self.startCursorLocation + 1;
                EquationFieldComponent *eq = self;
                while(eq.parent != nil) {
                    for(int i=0; i<eq.parent.eqChildren.count; i++) {
                        if(eq.parent.eqChildren[i] == eq) {
                            eq.parent.childWithEndCursor = i;
                            break;
                        }
                    }
                    eq = eq.parent;
                }
                return;
            }
        }
        else {
            // continue highlighting
            if(self.endCursorLocation < self.eqTextField.stringValue.length) {
                self.endCursorLocation++;
                return;
            }
            else {
                self.endCursorLocation = -1;
            }
        }
        
        int isLastLeaf = true;
        EquationFieldComponent *eq = self;
        while(eq.parent != nil) {
            if(eq.parent.eqChildren[eq.parent.eqChildren.count-1] == eq) {
                // I am the last child
            }
            else {
                isLastLeaf = false;
                break;
            }
            eq = eq.parent;
        }
        
        if(!isLastLeaf) {
            eq = self;
            while(eq.parent != nil) {
                eq = eq.parent;
                if(eq.childWithEndCursor == eq.eqChildren.count-1) {
                    eq.childWithEndCursor = -1;
                }
                else {
                    while(eq.childWithEndCursor < self.eqChildren.count-1) {
                        eq.childWithEndCursor++;
                        if([eq.eqChildren[eq.childWithEndCursor] eqFormat] == LEAF) {
                            eq = eq.eqChildren[eq.childWithEndCursor];
                            break;
                        }
                    }
                    if(eq.eqFormat == LEAF) {
                        break;
                    }
                }
            }
            
            while(eq.eqChildren.count != 0) {
                eq.childWithEndCursor = (int) eq.eqChildren.count - 1;
                eq = eq.eqChildren[eq.childWithEndCursor];
            }
            
            eq.endCursorLocation = 0;
        }
        else {
            self.endCursorLocation = (int) self.eqTextField.stringValue.length;
        }
    }
    else {
        // pass it on to children
        if(self.childWithEndCursor == -1) {
            // start highlighting
            [self.eqChildren[self.childWithStartCursor] highlightRight];
        }
        else {
            // continue highlighting
            [self.eqChildren[self.childWithEndCursor] highlightRight];
        }
    }
}

- (void) undoHighlighting {
    self.childWithStartCursor = -1;
    self.childWithEndCursor = -1;
    self.startCursorLocation = -1;
    self.endCursorLocation = -1;
    self.shouldBeCompletelyHighlighted = false;
    self.highlightLeafLeft = -1;
    self.highlightLeafRight = -1;
    
    for(int i=0; i<self.eqChildren.count; i++) {
        [self.eqChildren[i] undoHighlighting];
    }
}

- (void) setEndCursorEq: (double) x y: (double) y {
    x -= self.frame.origin.x;
    y -= self.frame.origin.y;
    if(self.eqFormat == LEAF) {
        self.childWithEndCursor = -1;
        self.endCursorLocation = 0;
        NSDictionary *attr = @{NSFontAttributeName : [self.fontManager getFont:self.eqTextField.frame.size.height/self.options.fontSizeToLeafA]};
        double xpos = 0;
        [self.eqTextField setContainsCursor:true];
        for(int i=0; i<=self.eqTextField.stringValue.length; i++) {
            double width = [[[NSAttributedString alloc] initWithString:[self.eqTextField.stringValue substringToIndex:i] attributes:attr] size].width;
            if((xpos + width)/2 <= x) {
                self.endCursorLocation = i;
            }
            else {
                return;
            }
            xpos = width;
        }
        return;
    }
    else if(self.eqFormat == DIVISION) {
        if(y >= self.heightRatio*self.frame.size.height) {
            [self.eqChildren[0] setEndCursorEq:x y:y];
        }
        else {
            [self.eqChildren[1] setEndCursorEq:x y:y];
        }
    }
    else if(self.eqFormat == SUPERSCRIPT) {
        [self.eqChildren[0] setEndCursorEq:x y:y];
    }
    else if(self.eqFormat == SQUAREROOT) {
        [self.eqChildren[0] setEndCursorEq:x y:y];
    }
    else if(self.eqFormat == SUMMATION) {
        double leftWidth = fmax(fmax([self.eqChildren[0] frame].size.width-100, [self.eqChildren[1] frame].size.width-100), self.eqImageView.frame.size.width);
        if(x < leftWidth) {
            if(y < [self.eqChildren[0] frame].size.height + self.eqImageView.frame.size.height/2) {
                [self.eqChildren[0] setEndCursorEq:x y:y];
            }
            else {
                [self.eqChildren[1] setEndCursorEq:x y:y];
            }
        }
        else {
            [self.eqChildren[2] setEndCursorEq:x y:y];
        }
    }
    else if(self.eqFormat == INTEGRATION) {
        double leftWidth = fmax(fmax([self.eqChildren[0] frame].size.width-100, [self.eqChildren[1] frame].size.width-100), self.eqImageView.frame.size.width);
        if(x < leftWidth) {
            if(y < [self.eqChildren[0] frame].size.height + self.eqImageView.frame.size.height/2) {
                [self.eqChildren[0] setEndCursorEq:x y:y];
            }
            else {
                [self.eqChildren[1] setEndCursorEq:x y:y];
            }
        }
        else {
            [self.eqChildren[2] setEndCursorEq:x y:y];
        }
    }
    else if(self.eqFormat == INTEGRATION) {
        if(x < self.eqImageView.frame.size.width+[self.eqChildren[0] frame].size.width) {
            [self.eqChildren[0] setEndCursorEq:x y:y];
        }
        else {
            [self.eqChildren[1] setEndCursorEq:x y:y];
        }
    }
    else if(self.eqFormat == PARENTHESES){
        [self.eqChildren[0] setEndCursorEq:x y:y];
    }
    else if(self.eqFormat == NORMAL){
        for(int i=0; i<self.eqChildren.count; i++) {
            if(x >= [self.eqChildren[i] frame].origin.x && x <= [self.eqChildren[i] frame].origin.x + [self.eqChildren[i] frame].size.width-100) {
                [self.eqChildren[i] setEndCursorEq:x y:y];
            }
        }
    }
}

@end
