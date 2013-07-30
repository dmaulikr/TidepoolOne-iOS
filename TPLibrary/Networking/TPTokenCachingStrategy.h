//
//  TPTokenCachingStrategy.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/19/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "FBSessionTokenCachingStrategy.h"
//#import <Face
@interface TPTokenCachingStrategy : FBSessionTokenCachingStrategy

@property (nonatomic, strong) NSString *thirdPartySessionId;

@end
