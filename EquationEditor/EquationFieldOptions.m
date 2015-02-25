//
//  EquationFieldOptions.m
//  EquationEditor
//
//  Created by Thomas Redding on 2/20/15.
//  Copyright (c) 2015 Thomas Redding. All rights reserved.
//

#import "EquationFieldOptions.h"

@implementation EquationFieldOptions

- (EquationFieldOptions*) init {
    // should never exceed 99 is a hard-maximum
    self.maxFontSize = 99;
    self.divisionDecayRate = 0.8;
    self.minFontSizeAsRatioOfMaxFontSize = 0.3;
    return self;
}

@end
