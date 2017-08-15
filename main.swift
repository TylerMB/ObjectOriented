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

print("The code in main.swift is just a basic exercise of the classes that you have been provided with. It is not an example of well structured and/or thoroughly tested code, so you should probably replace it with an improved version!")

func testGrammarRule(rule:GrammarRule, input:String) {
    if let remainingInput = rule.parse(input: input){
        print("Was able to parse input=\"\(input)\", with remainingInput=\"\(remainingInput)\"")
    } else {
        print("Was unable to parse input=\"\(input)\"")
    }
}

print("--- Test GRInteger parsing")
let myGRInteger = GRInteger()
// should parse the complete string
testGrammarRule(rule: myGRInteger,input:"2")
// should parse just the initial integer
testGrammarRule(rule: myGRInteger,input:"  1200r3f")
// should not be able to be parsed
testGrammarRule(rule: myGRInteger,input:"NaN")

print("--- Test GRLiteral parsing")
let bGRLiteral = GRLiteral(literal: "b")
testGrammarRule(rule: bGRLiteral,input:"2")
testGrammarRule(rule: bGRLiteral,input:" b+a")

print("--- Test GRExpression parsing hello")
let myExpr = GRExpression()
testGrammarRule(rule: myExpr, input: " 1+ 2  ")
if let result = myExpr.parse(input: " 1 + 2 ") {
    // if the parsing was successful, then an GRExpression should contain a calculatedValue, hence the (not ideal) unsafe optional forcing here.
    print("myExpr.calculatedValue is \(myExpr.calculatedValue!)")
}

print("--- Test GRSpreadsheet parsing")
let mySpreadsheet = GRSpreadsheet()
testGrammarRule(rule: mySpreadsheet, input: " 1+ 3 ")
testGrammarRule(rule: mySpreadsheet, input: "An epsilon GRSpreadsheet match")
