//
//  EquationFieldOptions.h
//  EquationEditor
//
//  Created by Thomas Redding on 2/20/15.
//  Copyright (c) 2015 Thomas Redding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EquationFieldOptions : NSObject

@property double maxFontSize;
@property double divisionDecayRate;
@property double minFontSizeAsRatioOfMaxFontSize;


// leafHeight = A * fontSize
// move EquationTextField up "B * fontSize" pixels
@property double fontSizeToLeafA;
@property double fontSizeToLeafB;
/*
 latinmodern-math:          A = 1.111   B = 0.000
 STIXMathJax_Main-Italic:   B = 1.111   B = 0.100
*/

@end
