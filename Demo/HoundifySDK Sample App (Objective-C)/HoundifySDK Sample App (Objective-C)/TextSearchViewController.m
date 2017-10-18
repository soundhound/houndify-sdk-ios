//
//  TextSearchViewController.m
//  HoundifySDK Sample App (Objective-C)
//
//  Created by Cyril Austin on 5/20/15.
//  Copyright (c) 2015 SoundHound, Inc. All rights reserved.
//

#import "TextSearchViewController.h"
#import "JSONAttributedFormatter.h"
@import HoundifySDK;

#pragma mark - TextSearchViewController

@interface TextSearchViewController()<UISearchBarDelegate>

@property(nonatomic, strong) IBOutlet UISearchBar* searchBar;
@property(nonatomic, strong) IBOutlet UITextView* textView;

@end

@implementation TextSearchViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)textSearchFor:(NSString *)query
{
    [[HoundTextSearch instance] searchWithQuery:query
                                    requestInfo:nil
                              completionHandler:
     
     ^(NSError * _Nullable error, NSString * _Nonnull query, HoundDataHoundServer * _Nullable houndServer, NSDictionary<NSString *,id> * _Nullable dictionary, NSDictionary<NSString *,id> * _Nullable requestInfo) {
         if (error) {
             // Handle error
             
             self.textView.text = [NSString stringWithFormat:@"%@ (%d)\n%@",
                                   error.domain,
                                   (int)error.code,
                                   error.localizedDescription
                                   ];
         } else if (houndServer) {
             // Display response JSON
             
             self.textView.attributedText = [JSONAttributedFormatter
                                             attributedStringFromObject:dictionary
                                             style:nil];
             
             // Print out requestInfo
             
             NSLog(@"RequestInfo: %@", requestInfo);
         }
     }];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    [searchBar resignFirstResponder];
    
    self.textView.text = nil;
    
    NSString* query = searchBar.text;
    
    if (query.length > 0) {
        [self textSearchFor:query];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar*)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
}

- (void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)searchText
{
    if (searchText.length == 0)
    {
        self.textView.text = nil;
    }
}

@end
