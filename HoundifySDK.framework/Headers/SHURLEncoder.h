//
//  SHURLEncoder.h
//  SHHound
//
//  Created by Cyril Austin on 10/8/15.
//  Copyright © 2015 SoundHound. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - SHURLEncoder

@interface SHURLEncoder : NSObject

+ (NSString* _Nonnull)RFC3986EncodedStringForString:(NSString* _Nonnull)string;

@end
