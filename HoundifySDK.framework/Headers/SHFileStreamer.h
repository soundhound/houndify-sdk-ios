//
//  SHFileStreamer.h
//  SHHound
//
//  Created by Cyril Austin on 12/10/15.
//  Copyright © 2015 SoundHound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHAudioDestinationProtocol.h"

#pragma mark - SHFileStreamerDataFormat

typedef NS_ENUM(NSUInteger, SHFileStreamerDataFormat)
{
    SHFileStreamerDataFormatJSON,
    SHFileStreamerDataFormatXML
};

#pragma mark - SHFileStreamerDelegate

@protocol SHFileStreamer;

@protocol SHFileStreamerDelegate<NSObject>

@required

- (void)fileStreamerDidComplete:(id<SHFileStreamer>)fileStreamer;

@optional

- (void)fileStreamer:(id<SHFileStreamer>)fileStreamer didReceiveData:(NSData*)data
    format:(SHFileStreamerDataFormat)format;
- (void)fileStreamer:(id<SHFileStreamer>)fileStreamer didReceiveAudioData:(NSData*)data;
- (void)fileStreamer:(id<SHFileStreamer>)fileStreamer didFailWithError:(NSError*)error;

@end

#pragma mark - SHHTTPSocketFileStreamer

@protocol SHFileStreamer<SHAudioDestination>

@property(nonatomic, weak) id<SHFileStreamerDelegate> delegate;

@property(nonatomic, assign, readonly) NSUInteger statusCode;
@property(nonatomic, strong, readonly) NSDictionary* responseHeaders;

- (void)appendBytes:(const UInt8*)bytes length:(NSUInteger)length;
- (void)replaceExtraHeaders:(NSDictionary*)extraHeaders;
- (void)replaceByteLength:(NSUInteger)length withData:(NSData*)data;
- (void)start;
- (void)cancel;
- (void)close;
- (void)restart;

@end
