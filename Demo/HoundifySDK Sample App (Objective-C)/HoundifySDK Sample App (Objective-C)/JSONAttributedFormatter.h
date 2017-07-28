//
//  JSONAttributedFormatter.h
//  SHHound
//
//  Created by Cyril MacDonald on 2015-08-06.
//  Copyright (c) 2015 SoundHound. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - JSONAttributedFormatterStyle

@interface JSONAttributedFormatterStyle : NSObject

@property(nonatomic, strong) UIFont* font;
@property(nonatomic, strong) UIColor* braceColor;
@property(nonatomic, strong) UIColor* keyColor;
@property(nonatomic, strong) UIColor* numberColor;
@property(nonatomic, strong) UIColor* booleanColor;

@end

#pragma mark - JSONAttributedFormatter

@interface JSONAttributedFormatter : NSObject

+ (NSAttributedString*)attributedStringFromObject:(id)object
    style:(JSONAttributedFormatterStyle*)style;

@end
