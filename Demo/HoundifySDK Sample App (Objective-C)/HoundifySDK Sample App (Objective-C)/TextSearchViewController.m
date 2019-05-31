//
//  TextSearchViewController.m
//  HoundifySDK Sample App (Objective-C)
//
//  Created by Cyril Austin on 5/20/15.
//  Copyright (c) 2015 SoundHound, Inc. All rights reserved.
//

#import "TextSearchViewController.h"
#import "JSONAttributedFormatter.h"
#import "HoundDataCommandResult+Extras.h"
@import HoundifySDK;

#pragma mark - TextSearchViewController

@interface TextSearchViewController()<UISearchBarDelegate, HoundTextSearchQueryDelegate>

@property(nonatomic, strong) IBOutlet UISearchBar* searchBar;
@property(nonatomic, strong) IBOutlet UITextView* textView;

@property(nonatomic, strong) HoundTextSearchQuery *query;

@end

@implementation TextSearchViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)textSearchFor:(NSString *)searchText
{
    self.searchBar.text = [NSString stringWithFormat:@"Searching: %@", searchText];
    
    [self.query cancel];
    
    self.query = [[HoundTextSearch instance] newTextSearchWithSearchText:searchText];
    
    self.query.delegate = self;
    
    // An example of how to use RequestInfo: set the location to SoundHound HQ.
    // a real application, of course, one would use location services to determine
    // the device's location.
    
    self.query.requestInfoBuilder.latitude = 37.4089054;
    self.query.requestInfoBuilder.longitude = -121.9849621;
    self.query.requestInfoBuilder.positionTime = lround([[NSDate date] timeIntervalSince1970]);
    self.query.requestInfoBuilder.positionHorizontalAccuracy = 10.0;

    [self.query startWithCompletion:nil];
}

#pragma mark - HoundTextSearchQueryDelegate

- (void)houndTextSearchQuery:(HoundTextSearchQuery * _Nonnull)query didReceiveSearchResult:(HoundDataHoundServer * _Nonnull)houndServer dictionary:(NSDictionary * _Nonnull)dictionary
{
    [self.searchBar resignFirstResponder];
    
    // Domains that work with client features often return incomplete results that need
    // to be completed by the application before they are ready to use. See this method for
    // an example
    [self tryUpdateQueryResponse:query];
    
    HoundDataCommandResult *commandResult = houndServer.allResults.firstObject;
    
    // This sample app includes more detailed examples of how to use a CommandResult
    // for some queries. See HoundDataCommandResult-Extras.m
    NSAttributedString *specialExampleText = [commandResult exampleResultText];

    if (specialExampleText) {
        self.textView.attributedText = specialExampleText;
    } else {
        self.textView.attributedText = [JSONAttributedFormatter
                                        attributedStringFromObject:dictionary
                                        style:nil];
    }
    
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = nil;
    self.query = nil;
}

- (void)houndTextSearchQuery:(HoundTextSearchQuery * _Nonnull)query didFailWithError:(NSError * _Nonnull)error
{
    [self.searchBar resignFirstResponder];
    
    self.textView.text = [NSString stringWithFormat:@"%@ (%d)\n%@",
                          error.domain,
                          (int)error.code,
                          error.localizedDescription
                          ];
    
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = nil;
    self.query = nil;
}

- (void)houndTextSearchQueryDidCancel:(HoundTextSearchQuery * _Nonnull)query
{
    self.textView.text = @"Canceled";
    
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = nil;
    self.query = nil;
}

#pragma mark - Client Integration Example

- (void)tryUpdateQueryResponse:(HoundTextSearchQuery *)query
{
    // Some HoundServer responses need information from the client before they are "complete"
    // For more general information, start here: https://www.houndify.com/docs#dynamic-responses
    
    // In this example, let's look at ClientClearScreenCommand. Make sure the "Client Control"
    // domain is enabled in your Houndify Dashboard while you try this example, and type
    // "Clear the screen" to try it.
    
    // First, let's make sure we've got a ClientClearScreenCommand to work with.
    HoundDataCommandResult *commandResult = query.response.allResults.firstObject;
    
    // See HoundDataCommandResult-Extras.m for the implementation of isClientClearScreenCommand
    if (!commandResult.isClientClearScreenCommand) {
        return;
    }
    
    // ClientClearScreenCommand arrives from the server with a spoken response of
    // "This client does not support clearing the screen." by default.
    // This is because houndify does not know whether your application can clear
    // the screen when the command is received.
    
    // Let us suppose for the sake of this example that we'll only consider it a success
    // if the screen has contents to clear.
    
    if (self.textView.text.length > 0) {
        
        // CommandResult comes with a DynamicResponse in the clientActionSucceededResult
        // field which contains updates for the success case.
        // Use Hound.handleDynamicResponse to copy values from clientActionSucceeded
        // to the command result, and to update the conversation state.
        [Hound handleDynamicResponse:commandResult.clientActionSucceededResult
              andUpdateCommandResult:commandResult];
        
        // Now the spoken response is "Screen is now cleared."
    } else {
        [Hound handleDynamicResponse:commandResult.clientActionFailedResult
              andUpdateCommandResult:commandResult];
        
        // Now the spoken response is, "I couldn't clear the screen."
        
        // Just for fun, let's add our own explanation.
        commandResult.spokenResponse = [commandResult.spokenResponse stringByAppendingString:@" There was nothing to clear."];
    }
    
    // Also, since we're clearing screen and can't see the written response,
    // let's speak the response.
    [query speakResponse];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    
    // Don't permit a new search to begin while the old one is running.
    if (self.query) {
        return;
    }
        
    NSString* searchText = searchBar.text;
    
    if (searchText.length > 0) {
        [self textSearchFor:searchText];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar*)searchBar
{
    [searchBar resignFirstResponder];
    
    [self.query cancel];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
}

@end
