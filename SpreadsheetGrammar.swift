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

class GRAssignment : GrammarRule {
    let abs = GRAbsoluteCell()
    let sign = GRLiteral(literal: ":=")
    let expr = GRExpression()
    let spread = GRSpreadsheet()
    
    
    init() {
        super.init(rhsRule: [abs,sign,expr,spread])
    }
    
    override func parse(input: String) -> String? {
        let rest = super.parse(input: input)
        
        var strExpr : String = ""
        if let range = input.range(of: ":= ") {
            strExpr = input.substring(from: range.upperBound) // Splitting the input string in order to get the expression (not the calculatedValue)
        }
        
        var key = abs.row.stringValue!
        key.append(abs.col.stringValue!) // Absolute cell doesnt currently make abs.stringValue = A1 have to do it manually
        
        
        self.dictionaryValue[key] = String(expr.calculatedValue!.description)
        self.dictionaryExpr[key] = strExpr
        
        
        print("DictionaryExpr for A2: \(String(describing: self.dictionaryExpr[key]!))")
        
        print("DictionaryValue for A2: \(String(describing: self.dictionaryValue[key]!))")
        
        return rest
    }
}

class GRPrint : GrammarRule{
    let printValue = GRLiteral(literal: "print_value")
    let printExpr = GRLiteral(literal: "print_expr")
    let expr = GRAbsoluteCell()
    let spread = GRSpreadsheet()
    
    init() {
        super.init(rhsRules: [[printValue,expr,spread],[printExpr,expr,spread]])
    }
    
    override func parse(input: String) -> String? {
        
        let rest = super.parse(input:input)
        
        
        
        return rest
    }
    
    
}


/// A GrammarRule for handling: Expression -> Integer ExpressionTail
class GRExpression : GrammarRule {
    let num = GRProductTerm()
    let exprTail = GRExpressionTail()

    init(){
        super.init(rhsRule: [num, exprTail])
    }
    override func parse(input: String) -> String? {
        
        let rest = super.parse(input:input)
        
        if num.calculatedValue != nil {
            
            self.calculatedValue = num.calculatedValue!
            
            if exprTail.calculatedValue != nil {
                self.calculatedValue = num.calculatedValue! + exprTail.calculatedValue!
            }
            
            if exprTail.calculatedValue == nil {
                self.calculatedValue = num.calculatedValue!
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
        super.init(rhsRules: [[plus,product],[Epsilon.theEpsilon]])
    }
    
    override func parse(input: String) -> String? {
            if var rest = super.parse(input: input) {
                

                if rest == input {
                    self.calculatedValue = nil
                    self.stringValue = nil
                    return rest
                }
                
                self.calculatedValue = product.calculatedValue!
                
                let exprTail = GRExpressionTail()
                rest = exprTail.parse(input: rest)!
                
                if exprTail.calculatedValue != nil {
                
                    self.calculatedValue = product.calculatedValue! + exprTail.calculatedValue!
                    
                } else {
                    self.calculatedValue = product.calculatedValue!
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
        super.init(rhsRules: [[times,value],[Epsilon.theEpsilon]])
    }
    
    override func parse(input: String) -> String? {
        if var rest = super.parse(input: input) {
            
            //checks if ProductTermTail is an Epsilon
            if rest == input {
                self.stringValue = nil
                self.calculatedValue = nil
                return rest
            }

            //else check if there is another ProductTermTail

            let productTail = GRProductTermTail()
            rest = productTail.parse(input: rest)!
            
            //if there is, make self equal to the product of the both of you
            if (productTail.calculatedValue != nil) {
                self.calculatedValue = value.calculatedValue! * productTail.calculatedValue!
            } else {
                //else make self equal just your GRValue
                self.calculatedValue = value.calculatedValue!
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



