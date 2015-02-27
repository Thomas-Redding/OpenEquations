//
//  EquationFieldComponentType.h
//  EquationEditor
//
//  Created by Thomas Redding on 1/21/15.
//  Copyright (c) 2015 Thomas Redding. All rights reserved.
//

#ifndef EquationEditor_EquationFieldComponentType_h
#define EquationEditor_EquationFieldComponentType_h

typedef enum {
    UNDEFINED,
    LEAF,
    NORMAL,
    DIVISION,
    SUPERSCRIPT,
    SQUAREROOT,
    SUMMATION,
    INTEGRATION,
    
    LOGBASE
} EquationFieldComponentType;

#endif