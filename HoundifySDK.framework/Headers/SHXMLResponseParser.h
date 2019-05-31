//
//  SHXMLResponseParser.h
//  SHHound
//
//  Created by Cyril Austin on 9/11/15.
//  Copyright (c) 2015 SoundHound. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - SHXMLResponseParserDelegate

@class SHXMLResponseParser;

@protocol SHXMLResponseParserDelegate<NSObject>

- (void)XMLResponseParser:(SHXMLResponseParser*)parser didFailWithError:(NSError*)error;
- (void)XMLResponseParserDidComplete:(SHXMLResponseParser*)parser;

@end

#pragma mark - SHXMLResponseParser

@interface SHXMLResponseParser : NSObject

@property(nonatomic, weak) id<SHXMLResponseParserDelegate> delegate;

@property(nonatomic, copy) NSString* tagName;

@property(nonatomic, strong, readonly) NSError* error;

@property(nonatomic, strong) id userInfo;

- (void)write:(NSData*)data;
- (void)complete;

- (NSDictionary*)root;

@end
