//
//  HoundDataCommandResult-Extras.swift
//  HoundifySDK Sample App (Swift)
//
//  Created by Jeff Weitzel on 4/22/19.
//  Copyright © 2019 SoundHound. All rights reserved.
//

import Foundation
import HoundifySDK

// This file provides some examples of how get information from
// a HoundDataCommandResult for your application

// NOTE: For simplicity, these examples make use of a keyPath array subscript
// to pull values from deep inside the command result dictionaries.
// This subscript is not part of the SDK. See the Dictionary extension at the
// bottom of this file.

extension HoundDataCommandResult {
    func exampleResultText() -> NSAttributedString? {
        
        if isTipCalculatorResult {
            return tipCalculatorResultText()
        }
        
        if isClientClearScreenCommand {
            return clearScreenResultText()
        }
        
        // Many domains that return purely informational results return
        // a CommandResult subclass called InformationCommand
        // These in turn contain an array of response objects called "InformationNuggets"
        // which, like, CommandResults, have a hierarchy of subtypes.
        // See the TimeInLocationInformationNugget below.
        if let informationCommand = self as? HoundDataInformationCommand {
            return informationCommand.informationNuggets.first?.exampleResultText()
        }
        
        return nil
    }
    
    // MARK: - TipCalculatorShowResultsCommand Example
    
    // To run this example, try the query "What is a twenty percent tip on seventy-five dollars?"
    // Make sure the "Tip Calculator" domain is enabled in your Houndify Dashboard
    // while you try this example.
    
    // See https://docs.houndify.com/reference/TipCalculatorShowResultsCommand for information
    // about the fields in this response.
    
    var isTipCalculatorResult: Bool {
        // All the dictionaries in a Houndify response can be mapped to Object-Oriented
        // Classes, and feature inheritance

        // To determine the "subclass" of CommandResult you've received, first check its
        // commandKind field. Check docs.houndify.com for the commandKind values for
        // your enabled domains. For a direct CommandResult subclass, this will be described
        // as its "Parent Key Value"
        
        guard commandKind == "TipCalculatorCommand" else {
            return false
        }
        
        // Your CommandResult subclass maybe be more than one level of hierarchy down from
        // CommandResult. Houndify dictionaries contain a field called the Parent Key which
        // indicates subclass type. The Parent Key field  for TipCalculatorCommand is
        // "TipCalculatorCommandKind".
        guard let tipCalculatorCommandKind = self["TipCalculatorCommandKind"] as? String else {
            return false
        }
        
        // If the key "TipCalculatorCommandKind" has the value "TipCalculatorShowResultsCommand"
        // That tells us this dictionary is a TipCalculatorShowResultsCommand
        return tipCalculatorCommandKind == "TipCalculatorShowResultsCommand"
    }
    
    func tipCalculatorResultText() -> NSAttributedString? {
        
        guard
            let nativeData = self["NativeData"] as? [String: Any],
            let moneySymbol = nativeData[["TipCalculatorInputData", "BillAmount", "Symbol"]] as? String,
            let billAmount = nativeData[["TipCalculatorInputData", "BillAmount", "Amount"]] as? Double,
            let tipPercentage = nativeData[["TipCalculatorInputData", "TipPercentage"]] as? Double,
            let tipAmount = nativeData[["TipAmountResult", "Amount"]] as? Double
        else {
            return nil
        }
        
        var string = "Bill:\t\t\t\(moneySymbol)\(billAmount)\n"
        string +=    "Percent:\t\(tipPercentage)%\n"
        string +=    "Tip:\t\t\t\(moneySymbol)\(tipAmount)"
        
        let font = UIFont.boldSystemFont(ofSize: 24)
        
        return NSAttributedString(string: string, attributes: [.font : font])
    }
    
    // MARK: - ClientClearScreenCommand Example
    
    // To run this example, try the query "Clear the Screen". Make sure the "Client Control"
    // domain is enabled in your Houndify Dashboard while you try this example.
    
    var isClientClearScreenCommand: Bool {
        guard commandKind == "ClientCommand" else {
            return false
        }
        
        guard let clientCommandKind = self["ClientCommandKind"] as? String else {
            return false
        }

        return clientCommandKind == "ClientClearScreenCommand"
    }
    
    func clearScreenResultText() ->  NSAttributedString? {
        return NSAttributedString(string: "")
    }
}

extension HoundDataInformationNugget {
    func exampleResultText() -> NSAttributedString? {
        if isTimeInLocation {
            return timeInLocationResultText()
        }
        
        return nil
    }
    
    // MARK: - TimeInLocationInformationNugget Example
    
    // To run this example, try the query "What time is it?". Make sure the "Date and Time"
    // domain is enabled in your Houndify Dashboard while you try this example.
    
    var isTimeInLocation: Bool {
        guard nuggetKind == "DateAndTime" else {
            return false
        }
        
        guard let dateAndTimeNuggetKind = self["DateAndTimeNuggetKind"] as? String else {
            return false
        }
        
        return dateAndTimeNuggetKind == "TimeInLocation"
    }
    
    func timeInLocationResultText() ->  NSAttributedString? {
        guard
            let locationsAndTimes = self["DestinationLocationsAndTimes"] as? [[String: [String: Any]]],
            let dateTimeDict = locationsAndTimes.first?["DateTimeSpec"]?["DateAndTime"] as? [String: Any],
            let hour = dateTimeDict[["Time", "Hour"]] as? Int,
            let minute = dateTimeDict[["Time", "Minute"]] as? Int,
            let second = dateTimeDict[["Time", "Second"]] as? Int
            else {
                return nil
        }
        
        let timeString = String(format: "The time is %02d:%02d:%02d", hour, minute, second)
        
        let font = UIFont.boldSystemFont(ofSize: 24)
        
        return NSAttributedString(string: timeString, attributes: [.font : font])
    }
}

// This extension provides a low rent means of extracting values from deep inside
// a command result data structure. By all means, use something more sophisticated in
// your own application.
extension Dictionary where Key == String, Value == Any {
    subscript(keyPath: [String]) -> Any? {
        var currentValue: Any? = self
        
        for pathStep in keyPath {
            guard let dict = currentValue as? [String: Any] else {
                return nil
            }
            
            currentValue = dict[pathStep]
        }
        
        return currentValue
    }
}
