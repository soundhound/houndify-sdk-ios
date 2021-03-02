//
//  HoundSDKServerDataModelCategories.h
//  SHHound
//
//  Created by Jeff Weitzel on 9/25/17.
//  Copyright © 2017 SoundHound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoundSDKServerDataModels.h"

#pragma mark - HoundDataCommandResult(DomainUsage)

@interface HoundDataCommandResult(DomainUsage)

@property(nonatomic, strong, nullable) NSArray<HoundDataHoundServerDomainUsage *>* domainUsage;

@end

