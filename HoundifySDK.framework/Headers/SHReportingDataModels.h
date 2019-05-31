//
//  SHReportingDataModels.h
//  SHHound
//
//  Created by Cyril Austin on 10/8/15.
//  Copyright © 2015 SoundHound. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - SHReportingSearchMetrics

@interface SHReportingSearchMetrics : NSObject

@property(nonatomic, assign) BOOL voice;
@property(nullable, nonatomic, copy) NSString *startSearchMethod;
@property(nullable, nonatomic, copy) NSString *stopSearchMethod;
@property(nullable, nonatomic, copy) NSString *stopSearchState;
@property(nullable, nonatomic, copy) NSString *searchSubmitMethod;
@property(nullable, nonatomic, copy) NSString *textSearchSource;
@property(nonatomic, assign, readonly) NSUInteger transcriptionTotalCount;
@property(nonatomic, assign, readonly) NSUInteger transcriptionUniqueCount;
@property(nonatomic, assign) NSUInteger recentSearchesTotalCount;
@property(nonatomic, assign) NSUInteger recentSearchesDisplayCount;
@property(nullable, nonatomic, assign) NSString *recentSearchSelectionType;
@property(nonatomic, assign) NSInteger recentSearchSelectionIndex;
@property(nonatomic, assign) BOOL recentSearchModifiedBoolean;
@property(nullable, nonatomic, strong) NSDate* startDate;
@property(nullable, nonatomic, strong) NSDate* stopDate;
@property(nullable, nonatomic, strong) NSDate* responseDate;
@property(nullable, nonatomic, strong) NSDate* parseCompleteDate;
@property(nullable, nonatomic, strong) NSDate* displayCompleteDate;
@property(nullable, nonatomic, copy) NSString* contentType;
@property(nullable, nonatomic, copy) NSString* subContentType;
@property(nullable, nonatomic, copy) NSString* requestId;
@property(nullable, nonatomic, copy) NSString* responseId;
@property(nullable, nonatomic, copy) NSString* queryText;
@property(nullable, nonatomic, copy) NSString* expectedTranscription;
@property(nullable, nonatomic, copy, readonly) NSString* transcriptionText;
@property(nullable, nonatomic, copy) NSString* screenName;
@property(nonatomic, assign) BOOL audioDetected;

- (void)addPartialTranscription:(NSString* _Nullable)partialTranscription;

@end
