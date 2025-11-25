//
//  HoundSDKServerDataModelCategories.h
//  SHHound
//
//  Created by Jeff Weitzel on 9/25/17.
//  Copyright © 2017 SoundHound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HoundifySDK/HoundSDKServerDataModels.h>

#pragma mark - HoundDataCommandResult(DomainUsage)

@interface HoundDataCommandResult(DomainUsage)

@property(nonatomic, strong, nullable) NSArray<HoundDataHoundServerDomainUsage *>* domainUsage;

@end

#pragma mark - HoundDataCommandResult(PrivateParentClass)

NS_ASSUME_NONNULL_BEGIN

@interface HoundDataCommandResult (PrivateParentClass)

+ (Class _Nullable)privateClassForDictionary:(NSDictionary*)dictionary;

@end

NS_ASSUME_NONNULL_END
