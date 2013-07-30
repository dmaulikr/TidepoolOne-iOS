//
//  TPUploadQueue.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/17/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPUploadQueue : NSObject

-(void)add:(NSDictionary *)item;
-(void)clear;
-(void)performOperations;

@end
