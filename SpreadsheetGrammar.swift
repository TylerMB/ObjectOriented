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
    let myGRAssign = GRAssignment()
    let myGRPrint = GRPrint()
    
    init(){
        super.init(rhsRules: [[myGRAssign],[myGRPrint], [Epsilon.theEpsilon]])
        
    }
    override func parse(input: String) -> String? {
        var rest = super.parse(input: input)
        
        GrammarRule.currentCell.stringValue = nil
        if rest != nil, rest != input {
            let spread = GRSpreadsheet()
            rest = spread.parse(input: rest!)
        }
        return rest
    }
}

class GRAssignment : GrammarRule {
    
    let sign = GRLiteral(literal: ":=")
    let expr = GRExpression()
    let currCell = GRAbsoluteCell()

    init() {
        super.init(rhsRule: [currCell,sign,expr])
    }
    
    override func parse(input: String) -> String? {
        
        let rest = super.parse(input: input)
        var strExpr : String = ""
        var key : String = ""
        if rest != nil {
            if let range = input.range(of: ":= ") {
                strExpr = input.substring(from: range.upperBound) // Splitting the input string in order to get the expression (not the calculatedValue)
                if let range1 = strExpr.range(of: rest!) {
                    strExpr = strExpr.substring(to: range1.lowerBound)
                }
            }
        }
        if currCell.stringValue != nil {
            _ = GrammarRule.currentCell.parse(input: currCell.stringValue!)
            GrammarRule.currentCell.stringValue = currCell.stringValue!
            GrammarRule.currentCell.col.stringValue = currCell.col.stringValue!
            GrammarRule.currentCell.row.stringValue = currCell.row.stringValue!
            key = GrammarRule.currentCell.stringValue!
        }
        
        if expr.calculatedValue != nil {
            GrammarRule.dictionaryValue[key] = String(expr.calculatedValue!.description)
            GrammarRule.dictionaryExpr[key] = strExpr
            GrammarRule.dictionaryWorking[key] = strExpr
            
            
            //If there is an relative cell to unwrap
            if expr.num.value.ref.rel.row.stringValue != nil && expr.num.value.ref.rel.col.stringValue != nil {
                //If there is a relative cell in the expression to convert to absolute
                if (GrammarRule.dictionaryWorking[key]?.contains("r\(expr.num.value.ref.rel.row.stringValue!)c\(expr.num.value.ref.rel.col.stringValue!)"))! {
                    //Then convert the relative cell to an absolute cell in the working dictionary
                    GrammarRule.dictionaryWorking[key] = GrammarRule.dictionaryWorking[key]?.replacingOccurrences(of: "r\(expr.num.value.ref.rel.row.stringValue!)c\(expr.num.value.ref.rel.col.stringValue!)", with: "key")
                }
            }
            
            
            for (updateThisKey, expr) in GrammarRule.dictionaryExpr {
                if expr.contains(key) {
                    if key == updateThisKey || GrammarRule.dictionaryExpr[key]!.contains(updateThisKey) && GrammarRule.dictionaryExpr[updateThisKey]!.contains(key)  {
                        print("recursion occured")
                    } else {
                        let update = GRAssignment()
                        _ = update.parse(input: "\(updateThisKey) := \(expr)")
                    }
                }
            }
        }
        if expr.stringValue != nil {
            self.stringValue = expr.stringValue!
            GrammarRule.dictionaryValue[key] = String(expr.stringValue!)
            GrammarRule.dictionaryExpr[key] = strExpr
        }
        if rest != nil {
            let spreadsheet = GRSpreadsheet()
            _ = spreadsheet.parse(input: rest!)
        }
        return rest
    }
    
}

class GRPrint : GrammarRule{
    let printValue = GRLiteral(literal: "print_value")
    let printExpr = GRLiteral(literal: "print_expr")
    let abs = GRAbsoluteCell()
    
    init() {
        super.init(rhsRules: [[printValue,abs],[printExpr,abs]])
    }
    
    override func parse(input: String) -> String? {
        
        let rest = super.parse(input:input)
        
        if rest == input {
            self.calculatedValue = nil
            self.stringValue = nil
            return rest
        }
        
        if self.printValue.stringValue != nil {
            
            var key = abs.col.stringValue!
            key.append(abs.row.stringValue!)
            
            if GrammarRule.dictionaryValue[key] != nil {
            print("Value of cell \(key) is \(String(describing: GrammarRule.dictionaryValue[key]!))")
            } else {
                print("Value of cell \(key) is 0")
            }
        } else if self.printExpr.stringValue != nil {
            
            
            var key = abs.col.stringValue!
            key.append(abs.row.stringValue!)
            
            if GrammarRule.dictionaryExpr[key] != nil {
            print("Expression in cell \(key) is \(String(describing: GrammarRule.dictionaryExpr[key]!))")
            } else {
                print("Expression in cell \(key) is 0")
                }
        }
        return rest
    }
}



/// A GrammarRule for handling: Expression -> Integer ExpressionTail
class GRExpression : GrammarRule {
    let num = GRProductTerm()
    let exprTail = GRExpressionTail()
    let quote = GRQoutedString()
    
    init(){
        super.init(rhsRules: [[num, exprTail],[quote]])
    }
    override func parse(input: String) -> String? {
        let rest = super.parse(input:input)
        if exprTail.calculatedValue != nil && num.calculatedValue != nil{
            self.calculatedValue = num.calculatedValue! + exprTail.calculatedValue!
            self.stringValue = nil
            return rest
        } else if num.calculatedValue != nil {
            self.calculatedValue = num.calculatedValue!
            self.stringValue = nil
            return rest
        }
        
        if quote.stringValue != nil && exprTail.stringValue != nil {
            self.stringValue = quote.stringValue!
            self.stringValue!.append(exprTail.stringValue!)
            self.calculatedValue = nil
            return rest
        } else if quote.stringValue != nil {
            self.stringValue = quote.stringValue!
            self.calculatedValue = nil
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
            let exprTail = GRExpressionTail()
            rest = exprTail.parse(input: rest)!
            
            if  product.calculatedValue != nil && exprTail.calculatedValue != nil {
                self.calculatedValue = product.calculatedValue! + exprTail.calculatedValue!
                self.stringValue = nil
                return rest
            } else if product.calculatedValue != nil {
                self.calculatedValue = product.calculatedValue!
                self.stringValue = nil
                return rest
            }
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
            
            if productTail.calculatedValue != nil && value.calculatedValue != nil {
                self.calculatedValue = value.calculatedValue! * productTail.calculatedValue!
            } else if value.calculatedValue != nil {
                self.calculatedValue = value.calculatedValue!
            }
            return rest
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
            if (value.calculatedValue != nil && productTail.calculatedValue != nil) {
                self.calculatedValue = value.calculatedValue! * productTail.calculatedValue!
            } else if value.calculatedValue != nil {
                //else make self equal just your GRValue
                self.calculatedValue = value.calculatedValue!
            }
            return rest
        }
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
            colVals[0] += col.calculatedValue!
            
            for index in 0...(colVals.count-1) {
                //if it is greater than 26 (while loop to deal with r0c52)
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
                    if index == (colVals.count-1) {
                        if colVals[index] == 0 {
                            colVals = Array(colVals.dropLast(1))
                        } else {
                            print("Error: Reference out of bounds")
                            self.stringValue = nil
                            return nil
                        }
                    } else {
                        colVals[index] += 26
                        colVals[index+1] -= 1
                    }
                }
            }
            count = (colVals.count-1)
            //works through the calculated values and reverses it back into colChars, with the addition done
            for index in 0...(colVals.count-1) {
                if index <= (colChars.count-1) {
                    colChars[index] = Character(alphabet[colVals[count]])
                    count -= 1
                } else {
                    colChars.append(Character(alphabet[colVals[count]]))
                    count -= 1
                }
            }
            self.stringValue = ""
            //builds the relativeCell final location as an absouteCell
            for index in 0...(colChars.count-1) {
                self.stringValue!.append(colChars[index])
            }
            //adds the row number to the column label, with the addition of the relative row
            self.stringValue!.append(String(GrammarRule.currentCell.row.calculatedValue!+row.calculatedValue!))
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
                self.stringValue = rel.stringValue!
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
                if GrammarRule.dictionaryExpr[ref.stringValue!] == nil {
                    GrammarRule.dictionaryValue[ref.stringValue!] = "0"
                    GrammarRule.dictionaryExpr[ref.stringValue!] = ""
                } else {
                    self.calculatedValue = Int(GrammarRule.dictionaryValue[ref.stringValue!]!)
                }
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
            self.stringValue = quote.stringValue!
            self.stringValue?.append(string.stringValue!)
            self.stringValue?.append(quote.stringValue!)
            return rest
        }
        return nil
    }
}



