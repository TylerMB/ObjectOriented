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

// If command line arguments are given, then try to interpret them as filenames, reading them and parsing them in sequence.
// Note that output requested in the specification should be generated during the parsing process: for example, successfully parsing a Print will produce output. Your code should not produce any other output when parsing a string read from a file.
if CommandLine.arguments.count>1 {
    var filenames = CommandLine.arguments
    filenames.removeFirst() // first argument is the name of the executable
    
    func stderrPrint(_ message:String) {
        let stderr = FileHandle.standardError
        stderr.write(message.data(using: String.Encoding.utf8)!)
    }
    
    for filename in filenames {
        do {
            let filecontents : String = try String.init(contentsOfFile: filename)
            let aGRSpreadsheet = GRSpreadsheet()
            if let remainder = aGRSpreadsheet.parse(input: filecontents) {
                if remainder != "" {
                    stderrPrint("Parsing left remainder [\(remainder)].\n")
                }
            }
        } catch {
            stderrPrint("Error opening and reading file with filename [\(filename)].\n")
        }
    }
    
} else {
    func testGrammarRule(rule:GrammarRule, input:String) {
        if let remainingInput = rule.parse(input: input){
            print("Was able to parse input=\"\(input)\", with remainingInput=\"\(remainingInput)\"")
        } else {
            print("Was unable to parse input=\"\(input)\"")
        }
    }
    print("Simple Test Case: ")
    run()
}

