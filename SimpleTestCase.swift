//
//  TestCase.swift
//  Spreadsheet
//
//  Created by Ashton Cochrane on 28/08/17.
//  Copyright © 2017 Tyler Baker. All rights reserved.
//

import Foundation

func parseInput(rule:GrammarRule, input:String) {
    _ = rule.parse(input: input)
}

func run() {
    let spreadsheet = GRSpreadsheet()
    let spreadsheet3 = GRSpreadsheet()
    let spreadsheet4 = GRSpreadsheet()
    
    

    print("-- Test 1 --")
    var test: String = "A1 := \"hello\" print_expr A1 A2 := \"goodbye\" print_expr A2 A3 := \"goodbye\"+\"goodbye\" print_expr A3"
    parseInput(rule: spreadsheet, input: test)
    
    
    
    test = "A1 := 11 A2 := 12 A3 := 13 A4 := 14 A5 := 15 print_expr A1 print_expr A2 print_expr A3 print_value A4 print_expr A5 A6 := r-5c0+r-4c0+r-3c0+r-2c0+r-1c0 A7 := \"A6 is sum\" print_expr A7 print_expr A6 print_value A6"
    print("-- Test 3 --")
    parseInput(rule: spreadsheet3, input: test)
    
    test = "C2 := 1+2 print_value C2 C1 := r1c0+1 print_value C1"
    print("-- Test 4 --")
    parseInput(rule: spreadsheet4, input: test)
    
    test = "C2 := 1+2 print_value C2 C1 := r1c0+1 print_value C1 C2 := 2+2 print_value C2 print_value C1"
    print("-- Test 4 --")
    parseInput(rule: spreadsheet4, input: test)
    
    
//    parseInput(rule: spreadsheet, input: "A2 := 15")
//    parseInput(rule: print1, input: "print_value A1")
//    parseInput(rule: print1, input: "print_value A2")
//    parseInput(rule: spreadsheet, input: "A3 := A1 + A2")
//    parseInput(rule: print1, input: "print_expr A3")
//    parseInput(rule: print1, input: "print_value A3")
//    print("-- Test 2 --")
//    parseInput(rule: spreadsheet, input: "A2 := 100")
//    parseInput(rule: print1, input: "print_value A1")
//    parseInput(rule: print1, input: "print_expr A3")
//    parseInput(rule: print1, input: "print_value A3")
//    print("-- Test 3 --")
//    parseInput(rule: spreadsheet, input: "A1 := \"coffee\"")
//    parseInput(rule: print1, input: "print_value A1")
//    parseInput(rule: print1, input: "print_expr A1")
//    parseInput(rule: spreadsheet, input: "A3 := 2*5+2*A2")    
//    parseInput(rule: print1, input: "print_expr A3")
//    parseInput(rule: print1, input: "print_value A3")
//    

}
