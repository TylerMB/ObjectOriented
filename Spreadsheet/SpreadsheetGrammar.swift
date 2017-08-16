//
//  SpreadsheetGrammar.swift
//  COSC346 Assignment 1
//
//  Created by David Eyers on 24/07/17.
//  Copyright © 2017 David Eyers. All rights reserved.
//

import Foundation

// Simplified example grammar
// (Rules are also shown next to their parsing classes, in this file)
//
// Spreadsheet -> Expression | Epsilon
// Expression -> Integer ExpressionTail
// ExpressionTail -> [+] Integer
//
// This code shows the key aspects of recursive descent parsing. Also, note how the object oriented structure matches the grammar. Having said that, this code is by no means optimal / neat / nice!

/** The top-level GrammarRule.
 This GrammarRule handles Spreadsheet -> Expression | Epsilon
 Note that it uses the GrammarRule's default parse method
 */
class GRSpreadsheet : GrammarRule {
    let myGRExpression = GRExpression()
    init(){
        super.init(rhsRules: [[myGRExpression], [Epsilon.theEpsilon]])
    }
}

/// A GrammarRule for handling: Expression -> Integer ExpressionTail
class GRExpression : GrammarRule {
    let num = GRInteger()
    let exprTail = GRExpressionTail()

    init(){
        super.init(rhsRule: [num,exprTail])
    }
    override func parse(input: String) -> String? {
        let rest = super.parse(input:input)
        if rest != nil {
            self.calculatedValue = num.calculatedValue! + exprTail.calculatedValue!
        }
        return rest
    }
}

/// A GrammarRule for handling: ExpressionTail -> "+" Integer
class GRExpressionTail : GrammarRule {
    let plus = GRLiteral(literal: "+")
    let num = GRInteger()
    
    init(){
        super.init(rhsRule: [plus,num])
    }
    
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            self.calculatedValue =  Int(num.stringValue!)
            return rest
        }
        return nil
    }
}

class GRRelativeCell : GrammarRule {
    let row = GRInteger()
    let col = GRInteger()
    
    init() {
        super.in
    }
    
}


