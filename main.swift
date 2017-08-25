//
//  main.swift
//  COSC346 Assignment 1
//
//  Created by David Eyers on 24/07/17.
//  Copyright © 2017 David Eyers. All rights reserved.
//
//  Some basic tests that aim to assist understanding of the GrammarRules.
//  As noted, this code should be replaced by you doing something better.


import Foundation


print("Adding Travis commit")

func testGrammarRule(rule:GrammarRule, input:String) {
    if let remainingInput = rule.parse(input: input){
        print("Was able to parse input=\"\(input)\", with remainingInput=\"\(remainingInput)\"")
    } else {
        print("Was unable to parse input=\"\(input)\"")
    }
}

print("\n\n--- Test GRAssignment parsing ---")

let myGRAssignment = GRAssignment()
let myGRAssignment1 = GRAssignment()
let myGRAssignment2 = GRAssignment()
// should parse the complete string
testGrammarRule(rule: myGRAssignment,input:"A1 := 1 + 2")
print("\n----- New GRAssignment -----\n")
testGrammarRule(rule: myGRAssignment1,input:"A2 := 5*3")
print("\n----- New GRAssignment -----\n")
testGrammarRule(rule: myGRAssignment2,input:"A3 := 3+5*2")





print("\n\n--- Test GRInteger parsing ---")

let myGRInteger = GRInteger()
// should parse the complete string
testGrammarRule(rule: myGRInteger,input:"-2")
// should parse just the initial integer
testGrammarRule(rule: myGRInteger,input:"  1200-r3f")
// should not be able to be parsed
testGrammarRule(rule: myGRInteger,input:"NaN")


print("\n\n--- Test GRPositiveInteger parsing ---")
let myGRPositiveInteger = GRPositiveInteger()

// should parse the complete string
testGrammarRule(rule: myGRPositiveInteger,input:"-2")
// should parse just the initial integer
testGrammarRule(rule: myGRPositiveInteger,input:"  1200-r3f")
// should not be able to be parsed
testGrammarRule(rule: myGRPositiveInteger,input:"NaN")

print("\n\n--- Test GRCellReference parsing ---")
let myGRCellReference = GRCellReference()

// should parse the complete string
testGrammarRule(rule: myGRCellReference,input:"-2")
// should parse just the initial integer
testGrammarRule(rule: myGRCellReference,input:"AA12")
// should not be able to be parsed
testGrammarRule(rule: myGRCellReference,input:"N5N")
// should parse just the initial integer
testGrammarRule(rule: myGRCellReference,input:"r3c8sa")

print("\n\n--- Test GRValue parsing ---")
let myGRValue = GRValue()

// should parse the complete string
testGrammarRule(rule: myGRValue,input:"-2")
// should parse just the initial integer
testGrammarRule(rule: myGRValue,input:"AA12")
// should not be able to be parsed
testGrammarRule(rule: myGRValue,input:"N5N")
// should parse just the initial integer
testGrammarRule(rule: myGRValue,input:"r3c8sa")
// should parse just the initial integer
testGrammarRule(rule: myGRValue,input:"132sa")
// should parse just the initial integer
testGrammarRule(rule: myGRValue,input:"A13sa")
// should parse just the initial integer
testGrammarRule(rule: myGRValue,input:"rc8sa")






print("\n\n--- Test GRAbsoluteCell parsing ---")
let myGRAbsoluteCell = GRAbsoluteCell()

// should parse the complete string
testGrammarRule(rule: myGRAbsoluteCell,input:"A1")
// should parse just the initial integer
testGrammarRule(rule: myGRAbsoluteCell,input:"  AA12")
// should not be able to be parsed
testGrammarRule(rule: myGRAbsoluteCell,input:"N5N")
// should parse just the initial integer
testGrammarRule(rule: myGRAbsoluteCell,input:"  b13")

print("\n\n--- Test GRRelativeCell parsing ---")
let myGRRelativeCell = GRRelativeCell()

// should parse the complete string
testGrammarRule(rule: myGRRelativeCell,input:"-2")
// should parse just the initial integer
testGrammarRule(rule: myGRRelativeCell,input:"r1c0")
// should not be able to be parsed
testGrammarRule(rule: myGRRelativeCell,input:"N5N")
// should parse just the initial integer
testGrammarRule(rule: myGRRelativeCell,input:"r8c3hj")


print("\n\n--- Test GRColumnLabel parsing ---")
let myGRColumnLabel = GRColumnLabel()

// should parse the complete string
testGrammarRule(rule: myGRColumnLabel,input:"-2")
// should parse just the initial integer
testGrammarRule(rule: myGRColumnLabel,input:"  AA12")
// should not be able to be parsed
testGrammarRule(rule: myGRColumnLabel,input:"NaN")


print("\n\n--- Test GRLiteral parsing ----")
let bGRLiteral = GRLiteral(literal: ":=")
testGrammarRule(rule: bGRLiteral,input:" := ")
testGrammarRule(rule: bGRLiteral,input:" := 1")

print("\n\n--- Test GRStringNoQuote parsing ----")
let bGRStringNoQuote = GRStringNoQuote()
testGrammarRule(rule: bGRStringNoQuote,input: "2")
testGrammarRule(rule: bGRStringNoQuote,input:"b+a")
testGrammarRule(rule: bGRStringNoQuote,input: "\"covefe\"")
if let result = bGRStringNoQuote.parse(input: "\"covefe\"") {
    // if the parsing was successful, then an GRExpression should contain a calculatedValue, hence the (not ideal) unsafe optional forcing here.
    print("string no quote value is \(bGRStringNoQuote.stringValue!)")
}
testGrammarRule(rule: bGRStringNoQuote,input:"")

print("\n\n--- Test GRExpression parsing ----")
let myExpr = GRExpression()
testGrammarRule(rule: myExpr, input: " 1")
if let result = myExpr.parse(input: " 1 ") {
    // if the parsing was successful, then an GRExpression should contain a calculatedValue, hence the (not ideal) unsafe optional forcing here.
    print("myExpr.calculatedValue is \(myExpr.calculatedValue!)")
}
let myExpr1 = GRExpression()
testGrammarRule(rule: myExpr1, input: " 3 * 2 + 7 ")
if let result = myExpr1.parse(input: " 3 * 2 + 7 ") {
    // if the parsing was successful, then an GRExpression should contain a calculatedValue, hence the (not ideal) unsafe optional forcing here.
    print("myExpr.calculatedValue is \(myExpr1.calculatedValue!)")
}
let myExpr2 = GRExpression()
testGrammarRule(rule: myExpr2, input: " 3 + 2 * 7 ")
if let result = myExpr2.parse(input: " 3 + 2 * 7 ") {
    // if the parsing was successful, then an GRExpression should contain a calculatedValue, hence the (not ideal) unsafe optional forcing here.
    print("myExpr.calculatedValue is \(myExpr2.calculatedValue!)")
}
let myExpr3 = GRExpression()
testGrammarRule(rule: myExpr3, input: "2 + 3 * 2 * 7 + 3")
if let result = myExpr3.parse(input: "2 + 3 * 2 * 7 + 3 ") {
    // if the parsing was successful, then an GRExpression should contain a calculatedValue, hence the (not ideal) unsafe optional forcing here.
    print("myExpr.calculatedValue is \(myExpr3.calculatedValue!)")
}
let myExpr4 = GRExpression()
testGrammarRule(rule: myExpr4, input: " 3 * 2 + 7 * 0 * 3 ")
if let result = myExpr4.parse(input: " 3 * 2 + 7 * 0 * 3") {
    // if the parsing was successful, then an GRExpression should contain a calculatedValue, hence the (not ideal) unsafe optional forcing here.
    print("myExpr.calculatedValue is \(myExpr4.calculatedValue!)")
}

let myExpr5 = GRExpression()
testGrammarRule(rule: myExpr5, input: " 3 * 2 * 7 + 3 ")
if let result = myExpr5.parse(input: " 3 * 2 * 7 + 3") {
    // if the parsing was successful, then an GRExpression should contain a calculatedValue, hence the (not ideal) unsafe optional forcing here.
    print("myExpr.calculatedValue is \(myExpr5.calculatedValue!)")
}



print("\n\n--- Test GRProductTerm parsing ----")
let myProduct = GRProductTerm()
let myProduct1 = GRProductTerm()
let myProduct2 = GRProductTerm()
let myProduct3 = GRProductTerm()
let myProduct4 = GRProductTerm()
testGrammarRule(rule: myProduct, input: " 3  ")
if let result = myProduct.parse(input: "3") {
    // if the parsing was successful, then an GRExpression should contain a calculatedValue, hence the (not ideal) unsafe optional forcing here.
    print("myProduct.calculatedValue is \(myProduct.calculatedValue!)")
}
testGrammarRule(rule: myProduct2, input: " 3* 2 *4 +5 ")
if let result = myProduct2.parse(input: " 3 * 2 *4 +5") {
    // if the parsing was successful, then an GRExpression should contain a calculatedValue, hence the (not ideal) unsafe optional forcing here.
    print("myProduct.calculatedValue is \(myProduct2.calculatedValue!)")
}
testGrammarRule(rule: myProduct3, input: " 7+12 ")
if let result = myProduct3.parse(input: " 7+12") {
    // if the parsing was successful, then an GRExpression should contain a calculatedValue, hence the (not ideal) unsafe optional forcing here.
    print("myProduct.calculatedValue is \(myProduct3.calculatedValue!)")
}
testGrammarRule(rule: myProduct4, input: " 17 ")
if let result = myProduct4.parse(input: " 17") {
    // if the parsing was successful, then an GRExpression should contain a calculatedValue, hence the (not ideal) unsafe optional forcing here.
    print("myProduct.calculatedValue is \(myProduct4.calculatedValue!)")
}
let myProduct5 = GRProductTerm()
testGrammarRule(rule: myProduct5, input: " 17 + 5 * 3 ")
if let result = myProduct5.parse(input: " 17 + 5 * 3") {
    // if the parsing was successful, then an GRExpression should contain a calculatedValue, hence the (not ideal) unsafe optional forcing here.
    print("myProduct.calculatedValue is \(myProduct5.calculatedValue!)")
}
let myProduct6 = GRProductTerm()
testGrammarRule(rule: myProduct6, input: " 17 * 5")
if let result = myProduct6.parse(input: " 17 * 5") {
    // if the parsing was successful, then an GRExpression should contain a calculatedValue, hence the (not ideal) unsafe optional forcing here.
    print("myProduct.calculatedValue is \(myProduct6.calculatedValue!)")
}
let myProduct7 = GRProductTerm()
testGrammarRule(rule: myProduct7, input: " 17 + 5")
if let result = myProduct7.parse(input: " 17 + 5") {
    // if the parsing was successful, then an GRExpression should contain a calculatedValue, hence the (not ideal) unsafe optional forcing here.
    print("myProduct.calculatedValue is \(myProduct7.calculatedValue!)")
}


print("\n\n--- Test GRSpreadsheet parsing ----")
let mySpreadsheet = GRSpreadsheet()
testGrammarRule(rule: mySpreadsheet, input: " 1+ 3 ")
testGrammarRule(rule: mySpreadsheet, input: "An epsilon GRSpreadsheet match")
