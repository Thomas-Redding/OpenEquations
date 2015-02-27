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
    // set default values
    self.maxFontSize = 99;
    self.superscriptDecayRate = 0.6;
    self.divisionDecayRate = 0.8;
    self.squarerootDecayRate = 0.95;
    self.summationDecayRate = 0.6;
    self.integrationDecayRate = 0.6;
    self.minFontSizeAsRatioOfMaxFontSize = 0.2;
    self.squarerootVerticalPaddingFontSizeRatio = 0.05;
    
    self.minSizeOfSummationSymbolRelativeToTermHeight = 0.8;
    self.minSizeOfIntegrationSymbolRelativeToTermHeight = 0.8;
    
    self.fontSizeToLeafA = 1.11;
    self.fontSizeToLeafB = 0.02;
    self.horizontalPaddingFontSizeRatio = 0.05;
    return self;
}

@end
