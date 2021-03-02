//
//  SHError.h
//  SHHound
//
//  Created by Cyril Austin on 3/18/15.
//  Copyright (c) 2015 SoundHound. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Error domains

extern NSString* SHHoundErrorDomain;
extern NSString* SHHTTPErrorDomain;

#pragma mark - SHHoundErrorCode

typedef NS_ENUM(NSUInteger, SHHoundErrorCode)
{
    SHHoundErrorCodeNone,
    SHHoundErrorCodeCancelled,
    SHHoundErrorCodeOffline,
    SHHoundErrorCodeNotSuccessful,
};

#pragma mark - HTTPErrorForCode

extern NSError* HTTPErrorForCode(NSUInteger statusCode);

extern BOOL SHErrorIsEqual(NSError* error, NSString* domain, NSInteger code);
