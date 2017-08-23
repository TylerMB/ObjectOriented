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
    let num = GRProductTerm()
    let exprTail = GRExpressionTail()

    init(){
        super.init(rhsRule: [num,exprTail])
    }
    override func parse(input: String) -> String? {
        
        let rest = super.parse(input:input)
        
        if num.calculatedValue != nil {
            
            self.calculatedValue = num.calculatedValue!
            
            if exprTail.calculatedValue != nil {
                self.calculatedValue = num.calculatedValue! + exprTail.calculatedValue!
            }
            return rest
        }
        return nil
    }
}


/// A GrammarRule for handling: ExpressionTail -> "+" Integer
class GRExpressionTail : GrammarRule {
    let plus = GRLiteral(literal: "+")
    let product = GRProductTerm()
    
    init(){
        super.init(rhsRule: [plus,product])
    }
    
    override func parse(input: String) -> String? {
        
            if var rest = super.parse(input: input) {
                
                
                
                if product.calculatedValue == nil {
                    self.calculatedValue = 0
                    return rest
                }
                
                self.calculatedValue = product.calculatedValue!
                
                let exprTail = GRExpressionTail()
                if !rest.isEmpty {
                    rest = exprTail.parse(input: rest)!
                    if (exprTail.calculatedValue != nil) {
                        self.calculatedValue = product.calculatedValue! + exprTail.calculatedValue!
                    }

                }
                
                
                
                
                
                
            return rest
        }
        return nil
    }
}








class GRProductTerm : GrammarRule {
    let value = GRValue()
    let productTail = GRProductTermTail()
    
    
    init(){
        super.init(rhsRule: [value,productTail])
    }

    override func parse(input: String) -> String? {
        
        if let rest = super.parse(input: input ) {
            
            if value.calculatedValue != nil {
                
                self.calculatedValue = value.calculatedValue!
                
                if productTail.calculatedValue != nil {
                    self.calculatedValue = value.calculatedValue! * productTail.calculatedValue!
                }
                
                
                
                return rest
            }
        }
        return nil
    }
}



class GRProductTermTail : GrammarRule {
    let times = GRLiteral(literal: "*")
    let value = GRValue()
    
    init(){
        super.init(rhsRules: [[times,value], [Epsilon.theEpsilon]])
    }
    
    override func parse(input: String) -> String? {
        
        if var rest = super.parse(input: input) {
            
            
            
            if value.calculatedValue == nil {
                self.calculatedValue = 1
                return rest
            }
            
            self.calculatedValue = value.calculatedValue!
            
            let productTail = GRProductTermTail()
            
            
            rest = productTail.parse(input: rest)!
            
            
            if (productTail.calculatedValue != nil) {
                self.calculatedValue = value.calculatedValue! * productTail.calculatedValue!
            }
            //rules parsed so now send the rest of the string
            return rest
        }
        //the rules failed, so return nil to indicate failure
        return nil
    }
}

class GRAbsoluteCell : GrammarRule {
    let row = GRColumnLabel()
    let col = GRPositiveInteger()
    
    init() {
        super.init(rhsRule: [row,col])
    }
    
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            self.stringValue?.append(row.stringValue!)
            self.stringValue?.append(col.stringValue!)
            return rest
        }
        return nil
    }
}


class GRRelativeCell : GrammarRule {
    let r = GRLiteral(literal: "r")
    let c = GRLiteral(literal: "c")
    let row = GRInteger()
    let col = GRInteger()
    
    init() {
        super.init(rhsRule: [r,row,c,col])
    }
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            self.stringValue?.append(r.stringValue!)
            self.stringValue?.append(row.stringValue!)
            self.stringValue?.append(c.stringValue!)
            self.stringValue?.append(col.stringValue!)
            return rest
        }
        return nil
    }
}

class GRCellReference : GrammarRule {
    let abs = GRAbsoluteCell()
    let rel = GRRelativeCell()

    
    init() {
        super.init(rhsRules: [[abs],[rel]])
    }
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            if abs.stringValue != nil {
                self.stringValue?.append(abs.stringValue!)
            } else if rel.stringValue != nil {
                self.stringValue?.append(rel.stringValue!)
            }
            return rest
        }
        return nil
    }
}


class GRValue : GrammarRule {
    let val = GRInteger()
    let ref = GRCellReference()
    
    
    init() {
        super.init(rhsRules: [[val],[ref]])
    }
    
    
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            if val.calculatedValue != nil {
                self.calculatedValue = val.calculatedValue!
            } else if ref.stringValue != nil {
                self.stringValue = ref.stringValue!
            }
            return rest
        }
        return nil
    }
}


class GRQoutedString : GrammarRule {
    let quote = GRLiteral(literal: "\"")
    let string = GRStringNoQuote()
    
    
    init() {
        super.init(rhsRule: [quote, string, quote])
    }
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            self.stringValue?.append(quote.stringValue!)
            self.stringValue?.append(string.stringValue!)
            self.stringValue?.append(quote.stringValue!)
            return rest
        }
        return nil
    }
}



