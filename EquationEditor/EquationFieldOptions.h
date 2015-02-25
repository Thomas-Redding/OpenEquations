//
//  EquationFieldOptions.h
//  EquationEditor
//
//  Created by Thomas Redding on 2/20/15.
//  Copyright (c) 2015 Thomas Redding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EquationFieldOptions : NSObject

@property double maxFontSize;           // the maximum font size that will be displayed (should never exceed 99)
@property double divisionDecayRate;     // ratio between the font-size of the numerator (denominator) to the text surrounding the fraction
@property double superscriptDecayRate;  // ratio between the font-size of a superscript to the text to its left
@property double minFontSizeAsRatioOfMaxFontSize;   // how small the smallest font-size can be as a ratio of the largest currently displayed font size


// These two variables are used to make adjustments in formating due to different font choices
// (Height of Leaf) = A * (Font-Size)
// (Y-Position of EquationTextField) = B * (Font-Size) + (Y-Position of Leaf)
@property double fontSizeToLeafA;
@property double fontSizeToLeafB;
/*
 EXAMPLES:
 latinmodern-math:          A = 1.11    B = 0.02
 STIXMathJax_Main-Italic:   B = 1.11    B = 0.10
*/

@end
