//
//  HoundDataCommandResult+Extras.m
//  HoundifySDK Sample App (Objective-C)
//
//  Created by Jeff Weitzel on 4/25/19.
//  Copyright © 2019 SoundHound. All rights reserved.
//

#import "HoundDataCommandResult+Extras.h"

// This file provides some examples of how get information from
// a HoundDataCommandResult for your application

// See below for implementation.
@interface HoundDataInformationNugget (Extras)

- (NSAttributedString *)exampleResultText;

@end

@implementation HoundDataCommandResult (Extras)

- (NSAttributedString *)exampleResultText
{
    if ([self isTipCalculatorResult]) {
        return [self tipCalculatorResultText];
    }
    
    if (self.isClientClearScreenCommand) {
        return [self clearScreenResultText];
    }
    
    // Many domains that return purely informational results return
    // a CommandResult subclass called InformationCommand
    // These in turn contain an array of response objects called "InformationNuggets"
    // which, like, CommandResults, have a hierarchy of subtypes.
    // See the TimeInLocationInformationNugget below.
    if ([self isKindOfClass:[HoundDataInformationCommand class]]) {
        HoundDataInformationCommand *informationCommand = (HoundDataInformationCommand *)self;
        
        // While we are using the first information nugget in this example, all the
        // nuggets in the informationNuggets array are pertinent.
        return [informationCommand.informationNuggets.firstObject exampleResultText];
    }
    
    return nil;
}

#pragma mark - TipCalculatorShowResultsCommand Example

// To run this example, try the query "What is a twenty percent tip on seventy-five dollars?"
// Make sure the "Tip Calculator" domain is enabled in your Houndify Dashboard
// while you try this example.

// See https://docs.houndify.com/reference/TipCalculatorShowResultsCommand for information
// about the fields in this response.

- (BOOL)isTipCalculatorResult
{
    // All the dictionaries in a Houndify response can be mapped to Object-Oriented
    // Classes, and feature inheritance
    
    // To determine the "subclass" of CommandResult you've received, first check its
    // commandKind field. Check docs.houndify.com for the commandKind values for
    // your enabled domains. For a direct CommandResult subclass, this will be described
    // as its "Parent Key Value"
    
    if (![self.commandKind isEqual:@"TipCalculatorCommand"]) {
        return NO;
    }
    
    // Your CommandResult subclass maybe be more than one level of hierarchy down from
    // CommandResult. Houndify dictionaries contain a field called the Parent Key which
    // indicates subclass type. The Parent Key field  for TipCalculatorCommand is
    // "TipCalculatorCommandKind".

    // If the key "TipCalculatorCommandKind" has the value "TipCalculatorShowResultsCommand"
    // That tells us this dictionary is a TipCalculatorShowResultsCommand

    return [self[@"TipCalculatorCommandKind"] isEqual: @"TipCalculatorShowResultsCommand"];
}

- (NSAttributedString *)tipCalculatorResultText
{
    NSDictionary *billAmountDict = self[@"NativeData"][@"TipCalculatorInputData"][@"BillAmount"];
    
    NSString *moneySymbol = billAmountDict[@"Symbol"];
    double billAmount = [billAmountDict[@"Amount"] doubleValue];
    double tipPercentage = [self[@"NativeData"][@"TipCalculatorInputData"][@"TipPercentage"] doubleValue];
    double tipAmount = [self[@"NativeData"][@"TipAmountResult"][@"Amount"] doubleValue];

    NSString *tipString = [NSString stringWithFormat:@"Bill:\t\t\t%@%.2f\nPercent:\t%f%%\nTip:\t\t\t%@%.2f", moneySymbol, billAmount, tipPercentage, moneySymbol, tipAmount];
    
    UIFont *font = [UIFont boldSystemFontOfSize:24.0];
    
    return [[NSAttributedString alloc] initWithString:tipString
                                           attributes:@{NSFontAttributeName: font}];
}

#pragma mark - ClientClearScreenCommand Example

// To run this example, try the query "Clear the Screen". Make sure the "Client Control"
// domain is enabled in your Houndify Dashboard while you try this example.

- (BOOL)isClientClearScreenCommand
{
    return [self.commandKind isEqual:@"ClientCommand"] &&
           [self[@"ClientCommandKind"] isEqual: @"ClientClearScreenCommand"];
}

- (NSAttributedString *)clearScreenResultText
{
    return [[NSAttributedString alloc] initWithString:@""];
}

@end

#pragma mark HoundDataInformationNugget Category implementation

@implementation HoundDataInformationNugget (Extras)

- (NSAttributedString *)exampleResultText
{
    if ([self isTimeInLocation]) {
        return [self timeInLocationResultText];
    }
    
    return nil;
}

#pragma mark - TimeInLocationInformationNugget Example

// To run this example, try the query "What time is it?". Make sure the "Date and Time"
// domain is enabled in your Houndify Dashboard while you try this example.

- (BOOL)isTimeInLocation
{
    if (![self.nuggetKind isEqual:@"DateAndTime"]) {
        return NO;
    }

    return [self[@"DateAndTimeNuggetKind"] isEqual: @"TimeInLocation"];
}

- (NSAttributedString *)timeInLocationResultText
{
    NSDictionary *timeDict = [self[@"DestinationLocationsAndTimes"] firstObject][@"DateTimeSpec"][@"DateAndTime"][@"Time"];
    
    int hour = [timeDict[@"Hour"] intValue];
    int minute = [timeDict[@"Minute"] intValue];
    int second = [timeDict[@"Second"] intValue];
    
    NSString *timeString = [NSString stringWithFormat:@"The time is %02d:%02d:%02d", hour, minute, second];
    
    UIFont *font = [UIFont boldSystemFontOfSize:24.0];
    
    return [[NSAttributedString alloc] initWithString:timeString
                                           attributes:@{NSFontAttributeName: font}];

}
@end
