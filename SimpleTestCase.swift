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
    let assignment1 = GRAssignment()
    let assignment2 = GRAssignment()
    let assignment3 = GRAssignment()
    let assignment4 = GRAssignment()
    let assignment5 = GRAssignment()
    
    let print1 = GRPrint()
    let print2 = GRPrint()
    let print3 = GRPrint()
    let print4 = GRPrint()
    
    parseInput(rule: assignment1, input: "A1 := 1")
    parseInput(rule: assignment2, input: "A2 := \"covefe\"")
    parseInput(rule: print1, input: "print_expr A1")
    parseInput(rule: print1, input: "print_value A1")
    parseInput(rule: print2, input: "print_expr A2")
    parseInput(rule: print2, input: "print_value A2")
    parseInput(rule: assignment4, input: "A2 := 2")
    parseInput(rule: assignment3, input: "A3 := A1 + A2")
    parseInput(rule: print3, input: "print_expr A3")
    parseInput(rule: print3, input: "print_value A3")
    parseInput(rule: assignment5, input: "A1 := r1c0 + 1") //should be reupdating the value of A3 but isnt
    parseInput(rule: print4, input: "print_value A3")
    

}
