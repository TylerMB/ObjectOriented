//
//  SpreadsheetGrammar.swift
//  COSC346 Assignment 1
//
//  Created by Tyler Baker & Ash Cochrane on 24/07/17.
//  Copyright © 2017 Tyler Baker & Ash Cochrane. All rights reserved.
//

import Foundation


/** The top-level GrammarRule.
 This GrammarRule handles Spreadsheet -> Assignment | Print | Epsilon
 */
class GRSpreadsheet : GrammarRule {
    let myGRAssign = GRAssignment()
    let myGRPrint = GRPrint()
    
    init(){
        super.init(rhsRules: [[myGRAssign],[myGRPrint], [Epsilon.theEpsilon]])
        
    }
    /*
     Overrides and then calls super's parse function. This recursively calls GRSpreadsheet
     while there is still remaining input that hasn't failed to parse.
     - Parameter input: the remaining string to be processed
     - Returns: the resulting string after parsing
     */
    override func parse(input: String) -> String? {
        var rest = super.parse(input: input)
        //empties the global current cell before each recurive instantiation
        GrammarRule.currentCell.stringValue = nil
        if rest != nil, rest != input {
            let spread = GRSpreadsheet()
            rest = spread.parse(input: rest!)
        }
        return rest
    }
}

/*
 The Assignment GrammarRule.
 Deals with cells having their contents modified. Assignment -> AbsoluteCell := Expression Spreadsheet
 */
class GRAssignment : GrammarRule {
    
    let sign = GRLiteral(literal: ":=")
    let expr = GRExpression()
    let currCell = GRAbsoluteCell()
    
    init() {
        super.init(rhsRule: [currCell,sign,expr])
    }
    /*
     Overrides and then calls super's parse function. The global current cell is 
     also updated and dictionary contents.
     - Parameter input: the remaining string to be processed
     - Returns: the resulting string after parsing
     */
    override func parse(input: String) -> String? {
        var rest = super.parse(input: input)
        var strExpr : String = ""
        var key : String = ""
        if rest != nil {
            //splits the input into expression and remainder.
            if let range = input.range(of: ":= ") {
                strExpr = input.substring(from: range.upperBound) // shaves the literal and working cell off
                if let range1 = strExpr.range(of: rest!) {
                    strExpr = strExpr.substring(to: range1.lowerBound) // shaves the remaining input off, leaving just expression
                }
            }
        }
        //updates the current cell
        if currCell.stringValue != nil {
            _ = GrammarRule.currentCell.parse(input: currCell.stringValue!)
            GrammarRule.currentCell.stringValue = currCell.stringValue!
            GrammarRule.currentCell.col.stringValue = currCell.col.stringValue!
            GrammarRule.currentCell.row.stringValue = currCell.row.stringValue!
            key = GrammarRule.currentCell.stringValue!
        }
        //updates the dictionaries
        if expr.calculatedValue != nil {
            GrammarRule.dictionaryValue[key] = String(expr.calculatedValue!.description)
            GrammarRule.dictionaryExpr[key] = strExpr
            GrammarRule.dictionaryWorking[key] = strExpr
            //If there is an relative cell to unwrap
            if expr.num.value.ref.rel.row.stringValue != nil && expr.num.value.ref.rel.col.stringValue != nil {
                //If there is a relative cell in the expression to convert to absolute
                if (GrammarRule.dictionaryWorking[key]?.contains("r\(expr.num.value.ref.rel.row.stringValue!)c\(expr.num.value.ref.rel.col.stringValue!)"))! {
                    //Then convert the relative cell to an absolute cell in the working dictionary
                    GrammarRule.dictionaryWorking[key] = GrammarRule.dictionaryWorking[key]?.replacingOccurrences(of: "r\(expr.num.value.ref.rel.row.stringValue!)c\(expr.num.value.ref.rel.col.stringValue!)", with: expr.num.value.ref.rel.stringValue!)
                }
            }
            // prevents technicalites such as assigning a value to itself repetitively
            // and other loops i.e. A1 := A2 && A2 := A1
            for (updateThisKey, expr) in GrammarRule.dictionaryWorking {
                if expr.contains(key) {
                    if key == updateThisKey || GrammarRule.dictionaryWorking[key]!.contains(updateThisKey) && GrammarRule.dictionaryWorking[updateThisKey]!.contains(key)  {
                    } else {
                        let update = GRAssignment()
                        _ = update.parse(input: "\(updateThisKey) := \(expr)")
                    }
                }
            }
        }
        //deals with quoted string assignments
        if expr.stringValue != nil {
            self.stringValue = expr.stringValue!
            GrammarRule.dictionaryValue[key] = String(expr.stringValue!)
            GrammarRule.dictionaryExpr[key] = strExpr
        }
        //clears the current cell after use
        GrammarRule.currentCell.stringValue = nil
        if rest != nil {
            let spreadsheet = GRSpreadsheet()
            rest = spreadsheet.parse(input: rest!)
        }
        return rest
    }
}

/*
 The Print GrammarRule.
 Deals with printing the value or expression of a cell.
 Print -> print_value Expression Spreadsheet | print_expr Expression Spreadsheet
 */
class GRPrint : GrammarRule{
    let printValue = GRLiteral(literal: "print_value")
    let printExpr = GRLiteral(literal: "print_expr")
    let abs = GRAbsoluteCell()
    
    init() {
        super.init(rhsRules: [[printValue,abs],[printExpr,abs]])
    }
    /*
     Overrides and then calls super's parse function. This func prints either the calculated value
     or the expression contained within a cell.
     - Parameter input: the remaining string to be processed
     - Returns: the resulting string after parsing
     */
    override func parse(input: String) -> String? {
        let rest = super.parse(input:input)
        //deals with print_value
        if self.printValue.stringValue != nil {
            var key = abs.col.stringValue!
            key.append(abs.row.stringValue!)
            //prints the dictionary value or a default of "0"
            if GrammarRule.dictionaryValue[key] != nil {
                print("Value of cell \(key) is \(String(describing: GrammarRule.dictionaryValue[key]!))")
            } else {
                print("Value of cell \(key) is 0")
            }
            //deals with print_expr
        } else if self.printExpr.stringValue != nil {
            var key = abs.col.stringValue!
            key.append(abs.row.stringValue!)
            //prints the dictionary expression or a default of "0"
            if GrammarRule.dictionaryExpr[key] != nil {
                print("Expression in cell \(key) is \(String(describing: GrammarRule.dictionaryExpr[key]!))")
            } else {
                print("Expression in cell \(key) is 0")
            }
        }
        return rest
    }
}



/*
 The Expression GrammarRule.
 This class deals with Expression -> ProductTerm ExpressionTail | QuotedString
 Calculations are completed before being assigned to calculatedValue.
 */
class GRExpression : GrammarRule {
    let num = GRProductTerm()
    let exprTail = GRExpressionTail()
    let quote = GRQoutedString()
    let quoteTail = GRQuoteTail()
    let subTail = GRSubstitutionTail()
    
    init(){
        super.init(rhsRules: [[num, exprTail],[num,subTail],[quote, quoteTail]])
    }
    /*
     Overrides and then calls super's parse function. This func computes the expression recursively,
     or if the expression is a quote it can work as a sentence builder.
     - Parameter input: the remaining string to be processed
     - Returns: the resulting string after parsing
     */
    override func parse(input: String) -> String? {
        let rest = super.parse(input:input)
        //deals with numerical expressions
        if subTail.calculatedValue != nil && num.calculatedValue != nil{
            self.calculatedValue = num.calculatedValue! - subTail.calculatedValue!
            self.stringValue = nil
            return rest
        } else if exprTail.calculatedValue != nil && num.calculatedValue != nil{
            self.calculatedValue = num.calculatedValue! + exprTail.calculatedValue!
            self.stringValue = nil
            return rest
        } else if num.calculatedValue != nil {
            self.calculatedValue = num.calculatedValue!
            self.stringValue = nil
            return rest
        }
        //deals with basic quoted expressions
        if quote.stringValue != nil && quoteTail.stringValue != nil {
            self.stringValue = quote.stringValue!
            self.stringValue!.append(quoteTail.stringValue!)
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

/*
 The QuoteTail GrammarRule.
 This class is supplementary and deals with stringing quotes together.
 */
class GRQuoteTail : GrammarRule {
    let plus = GRLiteral(literal: "+")
    let quote = GRQoutedString()
    
    init(){
        super.init(rhsRules: [[plus,quote],[Epsilon.theEpsilon]])
    }
    /*
     Overrides and then calls super's parse function. This func checks recursively if
     there are additional quotes in an expression and appends them.
     - Parameter input: the remaining string to be processed
     - Returns: the resulting string after parsing
     */
    override func parse(input: String) -> String? {
        if var rest = super.parse(input: input) {
            //terminates recursion if rest fails to parse
            if rest == input {
                self.calculatedValue = nil
                self.stringValue = nil
                return rest
            }
            let quoteTail = GRQuoteTail()
            rest = quoteTail.parse(input: rest)!
            //deals with additional quote tails
            if  quote.stringValue != nil && quoteTail.stringValue != nil {
                self.stringValue = quote.stringValue!
                self.stringValue!.append(quoteTail.stringValue!)
                self.calculatedValue = nil
                return rest
            //deals with with end case quoteTail
            } else if quote.stringValue != nil {
                self.stringValue = quote.stringValue!
                self.calculatedValue = nil
                return rest
            }
        }
        return nil
    }
}


/*
 The ExpressionTail GrammarRule.
 This class deals with addition. ExpressionTail -> + ProductTerm ExpressionTail | Epsilon
 */
class GRExpressionTail : GrammarRule {
    let plus = GRLiteral(literal: "+")
    let product = GRProductTerm()
    
    init(){
        super.init(rhsRules: [[plus,product],[Epsilon.theEpsilon]])
    }
    /*
     Overrides and then calls super's parse function. This func checks recursively if
     there are additional components in an expression and appends them.
     - Parameter input: the remaining string to be processed
     - Returns: the resulting string after parsing
     */
    override func parse(input: String) -> String? {
        if var rest = super.parse(input: input) {
            //terminates recursion if rest fails to parse
            if rest == input {
                self.calculatedValue = nil
                self.stringValue = nil
                return rest
            }
            let exprTail = GRExpressionTail()
            rest = exprTail.parse(input: rest)!
            //deals with additional expressionTails
            if  product.calculatedValue != nil && exprTail.calculatedValue != nil {
                self.calculatedValue = product.calculatedValue! + exprTail.calculatedValue!
                self.stringValue = nil
                return rest
                //deals with the end case
            } else if product.calculatedValue != nil {
                self.calculatedValue = product.calculatedValue!
                self.stringValue = nil
                return rest
            }
        }
        return nil
    }
}

/*
 The SubstitutionTail GrammarRule.
 This class is suplimentary and deals with subtraction
 */
class GRSubstitutionTail : GrammarRule {
    let minus = GRLiteral(literal: "-")
    let product = GRProductTerm()
    
    init(){
        super.init(rhsRules: [[minus,product],[Epsilon.theEpsilon]])
    }
    /*
     Overrides and then calls super's parse function. This func checks recursively if
     there are subtraction components in an expression and negates them.
     - Parameter input: the remaining string to be processed
     - Returns: the resulting string after parsing
     */
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
                self.calculatedValue = product.calculatedValue! - exprTail.calculatedValue!
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

/*
 The ProductTerm GrammarRule.
 This class deals with ProductTerm -> Value ProductTermTail
 Multiplications are completed before being assigned to calculatedValue.
 */
class GRProductTerm : GrammarRule {
    let value = GRValue()
    let productTail = GRProductTermTail()
    
    init(){
        super.init(rhsRule: [value,productTail])
    }
    /*
     Overrides and then calls super's parse function. This func checks if
     there is a ProductTermTail in an expression and forms a product with it.
     - Parameter input: the remaining string to be processed
     - Returns: the resulting string after parsing
     */
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



/*
 The ProductTermTail GrammarRule.
 This class deals with multiplication tails. ProductTermTail -> * Value ProductTermTail | Epsilon
 */
class GRProductTermTail : GrammarRule {
    let times = GRLiteral(literal: "*")
    let value = GRValue()
    
    init(){
        super.init(rhsRules: [[times,value],[Epsilon.theEpsilon]])
    }
    /*
     Overrides and then calls super's parse function. This func checks recursively if
     there are additional poductTermTails in an expression and forms a product with them.
     - Parameter input: the remaining string to be processed
     - Returns: the resulting string after parsing
     */
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

/*
 The AbsoluteCell GrammarRule.
 This class is a direct reference to a cell. AbsoluteCell -> ColumnLabel RowNumber
 */
class GRAbsoluteCell : GrammarRule {
    let col = GRColumnLabel()
    let row = GRPositiveInteger()
    
    init() {
        super.init(rhsRule: [col,row])
    }
    /*
     Overrides and then calls super's parse function. This func combines a GRColumnLabel
     and a GRPositiveInteger to form a cell, then initilises it to 0, if it hasn't been discovered.
     - Parameter input: the remaining string to be processed
     - Returns: the resulting string after parsing
     */
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            self.stringValue = col.stringValue!
            self.stringValue?.append(row.stringValue!)
            if GrammarRule.dictionaryValue[self.stringValue!] == nil  {
                GrammarRule.dictionaryWorking[self.stringValue!] = "0"
                GrammarRule.dictionaryExpr[self.stringValue!] = "0"
                GrammarRule.dictionaryValue[self.stringValue!] = "0"
            }
            return rest
        }
        return nil
    }
}

/*
 The RelativeCell GrammarRule.
 This class converts an indirect cell reference to 
 a direct reference to a cell. RelativeCell -> r Integer c Integer
 */
class GRRelativeCell : GrammarRule {
    let r = GRLiteral(literal: "r")
    let c = GRLiteral(literal: "c")
    let row = GRInteger()
    let col = GRInteger()
    
    init() {
        super.init(rhsRule: [r,row,c,col])
    }
    /*
     Overrides and then calls super's parse function. This func converts a column label to
     integer to calculate the relative cell. Saved in the format of an AbsoluteCell
     - Parameter input: the remaining string to be processed
     - Returns: the resulting string after parsing
     */
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

/*
 The CellReference GrammarRule.
 This class is an umbrella class of both cell reference types.
 CellReference → AbsoluteCell | RelativeCell
 */
class GRCellReference : GrammarRule {
    let abs = GRAbsoluteCell()
    let rel = GRRelativeCell()
    
    init() {
        super.init(rhsRules: [[abs],[rel]])
    }
    /*
     Overrides and then calls super's parse function. Sets itself to either form of
     cell reference.
     - Parameter input: the remaining string to be processed
     - Returns: the resulting string after parsing
     */
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            if abs.stringValue != nil {
                self.stringValue = abs.stringValue!
            } else {
                self.stringValue = rel.stringValue!
            }
            return rest
        }
        return nil
    }
}

/*
 The Value GrammarRule.
 This class holds the value of both cell types and Integers.
 Value -> CellReference | Integer
 */
class GRValue : GrammarRule {
    let val = GRInteger()
    let ref = GRCellReference()
    
    init() {
        super.init(rhsRules: [[val],[ref]])
    }
    
    /*
     Overrides and then calls super's parse function. Sets itself to the value of a
     cell reference or GRInteger.
     - Parameter input: the remaining string to be processed
     - Returns: the resulting string after parsing
     */
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

/*
 The QuotedString GrammarRule.
 This class contains a String within quotation marks.
 QuotedString -> " StringNoQuote "
 */
class GRQoutedString : GrammarRule {
    let quote = GRLiteral(literal: "\"")
    let string = GRStringNoQuote()
    
    init() {
        super.init(rhsRule: [quote, string, quote])
    }
    /*
     Overrides and then calls super's parse function. Contains a String within
     quotation marks.
     - Parameter input: the remaining string to be processed
     - Returns: the resulting string after parsing
     */
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



