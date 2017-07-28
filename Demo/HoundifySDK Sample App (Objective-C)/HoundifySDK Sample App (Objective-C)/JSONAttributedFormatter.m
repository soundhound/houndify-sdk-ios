//
//  JSONAttributedFormatter.m
//  SHHound
//
//  Created by Cyril MacDonald on 2015-08-06.
//  Copyright (c) 2015 SoundHound. All rights reserved.
//

#import "JSONAttributedFormatter.h"

#pragma mark - JSONAttributedFormatterTokenType

typedef NS_ENUM(NSUInteger, JSONAttributedFormatterTokenType)
{
    JSONAttributedFormatterTokenTypeBrace,
    JSONAttributedFormatterTokenTypeSeparator,
    JSONAttributedFormatterTokenTypeNewLine,
    JSONAttributedFormatterTokenTypeKey,
    JSONAttributedFormatterTokenTypeString,
    JSONAttributedFormatterTokenTypeNumber,
    JSONAttributedFormatterTokenTypeBoolean,
    JSONAttributedFormatterTokenTypeNull
};

#pragma mark - JSONAttributedFormatterStyle

@implementation JSONAttributedFormatterStyle

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.font = [UIFont fontWithName:@"Menlo-Regular" size:9.0];
        self.braceColor = [UIColor colorWithRed:0.11 green:0.00 blue:0.81 alpha:1.0];
        self.keyColor = [UIColor colorWithRed:0.77 green:0.10 blue:0.09 alpha:1.0];
        self.numberColor = [UIColor colorWithRed:0.11 green:0.00 blue:0.81 alpha:1.0];
        self.booleanColor = [UIColor colorWithRed:0.67 green:0.05 blue:0.57 alpha:1.0];
    }
    
    return self;
}

@end

#pragma mark - JSONAttributedFormatter

@implementation JSONAttributedFormatter

+ (NSAttributedString*)attributedStringFromObject:(id)object
    style:(JSONAttributedFormatterStyle*)style
{
    if (!style)
    {
        style = [[JSONAttributedFormatterStyle alloc] init];
    }
    
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] init];
    
    [JSONAttributedFormatter
        appendAttributedStringForObject:object
        toAttributedString:attributedString
        indentLevel:0
        style:style];
    
    return attributedString;
}

+ (void)appendAttributedStringForObject:(id)object
    toAttributedString:(NSMutableAttributedString*)attributedString
    indentLevel:(NSInteger)indentLevel
    style:(JSONAttributedFormatterStyle*)style
{
    if ([object isKindOfClass:NSDictionary.class])
    {
        NSDictionary* dictionary = object;
        
        [JSONAttributedFormatter appendString:@"{"
            toString:attributedString
            indentLevel:indentLevel
            tokenType:JSONAttributedFormatterTokenTypeBrace
            style:style];
        
        [JSONAttributedFormatter appendString:@"\n"
            toString:attributedString
            indentLevel:indentLevel
            tokenType:JSONAttributedFormatterTokenTypeNewLine
            style:style];
        
        indentLevel++;
        
        NSArray* keys = dictionary.allKeys;
        
        for (NSString* key in keys)
        {
            id value = dictionary[key];
            
            [JSONAttributedFormatter appendString:key
                toString:attributedString
                indentLevel:indentLevel
                tokenType:JSONAttributedFormatterTokenTypeKey
                style:style];
            
            [JSONAttributedFormatter appendString:@" : "
                toString:attributedString
                indentLevel:indentLevel
                tokenType:JSONAttributedFormatterTokenTypeSeparator
                style:style];
            
            [JSONAttributedFormatter
                appendAttributedStringForObject:value
                toAttributedString:attributedString
                indentLevel:indentLevel
                style:style];
            
            if (key != keys.lastObject)
            {
                [JSONAttributedFormatter appendString:@","
                    toString:attributedString
                    indentLevel:indentLevel
                    tokenType:JSONAttributedFormatterTokenTypeSeparator
                    style:style];
            }
            
            [JSONAttributedFormatter appendString:@"\n"
                toString:attributedString
                indentLevel:indentLevel
                tokenType:JSONAttributedFormatterTokenTypeNewLine
                style:style];
        }
        
        indentLevel--;
        
        [JSONAttributedFormatter appendString:@"}"
            toString:attributedString
            indentLevel:indentLevel
            tokenType:JSONAttributedFormatterTokenTypeBrace
            style:style];
    }
    else if ([object isKindOfClass:NSArray.class])
    {
        NSArray* array = object;
        
        [JSONAttributedFormatter appendString:@"["
            toString:attributedString
            indentLevel:indentLevel
            tokenType:JSONAttributedFormatterTokenTypeBrace
            style:style];
        
        [JSONAttributedFormatter appendString:@"\n"
            toString:attributedString
            indentLevel:indentLevel
            tokenType:JSONAttributedFormatterTokenTypeNewLine
            style:style];
        
        indentLevel++;
        
        for (id value in array)
        {
            [JSONAttributedFormatter
                appendAttributedStringForObject:value
                toAttributedString:attributedString
                indentLevel:indentLevel
                style:style];
            
            if (value != array.lastObject)
            {
                [JSONAttributedFormatter appendString:@","
                    toString:attributedString
                    indentLevel:indentLevel
                    tokenType:JSONAttributedFormatterTokenTypeSeparator
                    style:style];
            }
            
            [JSONAttributedFormatter appendString:@"\n"
                toString:attributedString
                indentLevel:indentLevel
                tokenType:JSONAttributedFormatterTokenTypeNewLine
                style:style];
        }
        
        indentLevel--;
        
        [JSONAttributedFormatter appendString:@"]"
            toString:attributedString
            indentLevel:indentLevel
            tokenType:JSONAttributedFormatterTokenTypeBrace
            style:style];
    }
    else if ([object isKindOfClass:NSString.class])
    {
        [JSONAttributedFormatter appendString:object
            toString:attributedString
            indentLevel:indentLevel
            tokenType:JSONAttributedFormatterTokenTypeString
            style:style];
    }
    else if ([object isKindOfClass:NSNumber.class])
    {
        NSNumber* number = object;
        
        if (strcmp(number.objCType, @encode(BOOL)) == 0)
        {
            if (number.boolValue)
            {
                [JSONAttributedFormatter appendString:@"true"
                    toString:attributedString
                    indentLevel:indentLevel
                    tokenType:JSONAttributedFormatterTokenTypeNumber
                    style:style];
            }
            else
            {
                [JSONAttributedFormatter appendString:@"false"
                    toString:attributedString
                    indentLevel:indentLevel
                    tokenType:JSONAttributedFormatterTokenTypeNumber
                    style:style];
            }
        }
        else
        {
            [JSONAttributedFormatter appendString:number.stringValue
                toString:attributedString
                indentLevel:indentLevel
                tokenType:JSONAttributedFormatterTokenTypeNumber
                style:style];
        }
    }
    else if ([object isKindOfClass:NSNull.class])
    {
        [JSONAttributedFormatter appendString:@"null"
            toString:attributedString
            indentLevel:indentLevel
            tokenType:JSONAttributedFormatterTokenTypeNull
            style:style];
    }
}

+ (void)appendString:(NSString*)string
    toString:(NSMutableAttributedString*)attributedString
    indentLevel:(NSInteger)indentLevel
    tokenType:(JSONAttributedFormatterTokenType)tokenType
    style:(JSONAttributedFormatterStyle*)style
{
    /*
        Rules:
        
        * Format keys red
        * Format number values blue
        * Format booleans pink
        * Format {, [, ], and } blue
    */

    NSString* substring = nil;
    UIFont* font = style.font;
    UIColor* textColor = nil;
    
    switch (tokenType)
    {
        case JSONAttributedFormatterTokenTypeBrace:
            substring = string;
            textColor = style.braceColor;
            break;
        case JSONAttributedFormatterTokenTypeSeparator:
            substring = string;
            textColor = UIColor.blackColor;
            break;
        case JSONAttributedFormatterTokenTypeNewLine:
            substring = string;
            textColor = UIColor.blackColor;
            break;
        case JSONAttributedFormatterTokenTypeKey:
            substring = [NSString stringWithFormat:@"\"%@\"", string];
            textColor = style.keyColor;
            break;
        case JSONAttributedFormatterTokenTypeString:
            substring = [NSString stringWithFormat:@"\"%@\"", string];
            textColor = UIColor.blackColor;
            break;
        case JSONAttributedFormatterTokenTypeNumber:
            substring = string;
            textColor = style.numberColor;
            break;
        case JSONAttributedFormatterTokenTypeBoolean:
            substring = string;
            textColor = style.booleanColor;
            break;
        case JSONAttributedFormatterTokenTypeNull:
            substring = string;
            textColor = UIColor.blackColor;
            break;
    }
    
    if (substring && font && textColor)
    {
        static NSMutableDictionary* attributedSubstringCache = nil;
        
        if (!attributedSubstringCache)
        {
            attributedSubstringCache = [NSMutableDictionary dictionary];
        }
        
        NSAttributedString* attributedSubstring = attributedSubstringCache[@(tokenType)][string];
        
        if (!attributedSubstring)
        {
            attributedSubstring = [[NSAttributedString alloc]
                initWithString:substring
                attributes:@{
                    NSFontAttributeName: font,
                    NSForegroundColorAttributeName: textColor
                }
            ];
            
            if (!attributedSubstringCache[@(tokenType)])
            {
                attributedSubstringCache[@(tokenType)] = [NSMutableDictionary dictionary];
            }
            
            attributedSubstringCache[@(tokenType)][string] = attributedSubstring;
        }
        
        BOOL indent = NO;
        
        if (attributedString.length == 0)
        {
            indent = YES;
        }
        else if ([attributedString.string characterAtIndex:attributedString.string.length - 1] == '\n')
        {
            indent = YES;
        }
        
        if (indent)
        {
            static NSMutableDictionary* indentStringCache = nil;
            
            if (!indentStringCache)
            {
                indentStringCache = [NSMutableDictionary dictionary];
            }
            
            NSAttributedString* attributedIndentString = indentStringCache[@(indentLevel)];
            
            if (!attributedIndentString)
            {
                NSMutableString* indentString = [NSMutableString string];
                
                NSUInteger indentCount = 2 * indentLevel;
                
                for (NSUInteger indentIndex = 0; indentIndex < indentCount; indentIndex++)
                {
                    [indentString appendString:@" "];
                }
                
                attributedIndentString = [[NSAttributedString alloc]
                    initWithString:indentString
                    attributes:@{
                        NSFontAttributeName: font,
                        NSForegroundColorAttributeName: UIColor.blackColor
                    }
                ];
                
                indentStringCache[@(indentLevel)] = attributedIndentString;
            }
            
            [attributedString appendAttributedString:attributedIndentString];
        }
        
        [attributedString appendAttributedString:attributedSubstring];
    }
}

@end
