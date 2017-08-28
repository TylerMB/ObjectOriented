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
    
    let sign = GRLiteral(literal: ":=")
    let expr = GRExpression()
    let spread = GRSpreadsheet()
    let currentCell = GrammarRule.currentCell
    
    
    
    init() {
        super.init(rhsRule: [currentCell,sign,expr,spread])
    }
    
    override func parse(input: String) -> String? {
        let rest = super.parse(input: input)
        
        var strExpr : String = ""
        if let range = input.range(of: ":= ") {
            strExpr = input.substring(from: range.upperBound) // Splitting the input string in order to get the expression (not the calculatedValue)
        }
        _ = GrammarRule.currentCell.parse(input: currentCell.stringValue!)
        GrammarRule.currentCell.stringValue = currentCell.stringValue!
        GrammarRule.currentCell.col.stringValue = currentCell.col.stringValue!
        GrammarRule.currentCell.row.stringValue = currentCell.row.stringValue!
        let key = GrammarRule.currentCell.stringValue!
        
        GrammarRule.dictionaryValue[key] = String(expr.calculatedValue!.description)
        GrammarRule.dictionaryExpr[key] = strExpr
        
        print("DictionaryExpr for \(key): \(String(describing: GrammarRule.dictionaryExpr[key]!))")
        
        print("DictionaryValue for \(key): \(String(describing: GrammarRule.dictionaryValue[key]!))")
        
        return rest
    }
}

class GRPrint : GrammarRule{
    let printValue = GRLiteral(literal: "print_value")
    let printExpr = GRLiteral(literal: "print_expr")
    let abs = GRAbsoluteCell()
    let spread = GRSpreadsheet()
    
    init() {
        super.init(rhsRules: [[printValue,abs,spread],[printExpr,abs,spread]])
    }
    
    override func parse(input: String) -> String? {
        
        let rest = super.parse(input:input)
        
        
        if input.characters.contains("v") {
            
            var key = abs.col.stringValue!
            key.append(abs.row.stringValue!)
            print(key)
            
            print("DictionaryValue for \(key): \(String(describing: GrammarRule.dictionaryValue[key]!))")
            
        } else if input.characters.contains("e") {
            
            var key = abs.row.stringValue!
            key.append(abs.col.stringValue!)
            
            print("DictionaryExpr for \(key): \(String(describing: GrammarRule.dictionaryExpr[key]!))")
        }
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
    let col = GRColumnLabel()
    let row = GRPositiveInteger()
    
    init() {
        super.init(rhsRule: [col,row])
    }
    
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            self.stringValue = col.stringValue!
            self.stringValue?.append(row.stringValue!)
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
            self.stringValue = r.stringValue!
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
                self.stringValue = abs.stringValue!
            } else if rel.stringValue != nil {
                

                
                
                //an array of the letters in the the column label for the current cell
                var colChars: Array = Array(GrammarRule.currentCell.col.stringValue!.characters)
                //an empty array of numbers that the label will be converted into
                var colVals: Array = [Int](repeating: 0, count: colChars.count)
                //an alphabet of letters matching a number value 1-26
                let alphabet = [" ","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q",
                                "R","S","T","U","V","W","X","Y","Z"]
                
              
                //reverse through the characters of the label assigning values
                //reversed so that the last number is the highest valued letter
                //makes it easy to add and delete the final letter
                var count = 0
                for index in stride(from: colChars.count-1, to: -1, by: -1) {
                    colVals[count] = alphabet.index(of: String(colChars[index]))!
                    count += 1
                }
                
                //adds the r0c0 value to the lowest valued letter
                colVals[0] += rel.col.calculatedValue!
                
                //for each of the indexs in the column values
                for index in 0...(colVals.count-1) {
                    //if it is greater than 26 (while loop to deal with r0c52)
                    //27,1 -> 1,2
                    while colVals[index] > 26 {
                        //reduce that index value
                        colVals[index] -= 26
                        if (index+1) < (colVals.count-1) {
                            //increase the value of the next letter
                            colVals[index+1] += 1
                        } else {
                            //or add one if it doesnt exist
                            colVals.append(1)
                        }
                    }
                    //if letter is less than 'A', increase the value and reduce the value of the next letter
                    while colVals[index] < 1 {
                        colVals[index] += 26
                        if (index+1) < (colVals.count-1) {
                            colVals[index+1] -= 1
                        } else {
                            colVals[index] = 0
                        }
                    }
                }
                //works through the array dealing with 0 values, if the highest valued letter is 0, deletes it
                for index in 0...(colVals.count-1) {
                    
                    if colVals[index] == 0 {
                        if index == colVals.count-1 {
                            colVals = Array(colVals.dropLast(1))
                        } else {
                            colVals[index] += 26
                            colVals[index+1] -= 1
                        }
                    }
                    //works through the calculated values and reverses it back into colChars, with the addition done
                    count = (colVals.count-1)
                    if index <= (colChars.count-1) {
                        colChars[index] = Character(alphabet[colVals[count]])
                        count -= 1
                    } else {
                        colChars.append(Character(alphabet[colVals[count]]))
                        count -= 1
                    }
                    
                }
                print(colVals)
                print(colChars)
                print(alphabet)
                
                var relCell = ""
                //builds the relativeCell final location as an absouteCell
                for index in 0...(colChars.count-1) {
                    relCell.append(colChars[index])
                }
                //adds the row number to the column label, with the addition of the relative row
                relCell.append(String(GrammarRule.currentCell.row.calculatedValue!+rel.row.calculatedValue!))
                self.stringValue = relCell
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
                self.stringValue = nil
                
                
            } else if ref.stringValue != nil {
                
                self.calculatedValue = Int(GrammarRule.dictionaryValue[ref.stringValue!]!)
                self.stringValue = nil
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



