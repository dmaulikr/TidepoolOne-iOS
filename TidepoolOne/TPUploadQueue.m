//
//  TPUploadQueue.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/17/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPUploadQueue.h"
#import "TPOAuthClient.h"

@interface TPUploadQueue()
{
    NSMutableArray *uploadQueue;
    TPOAuthClient *oauthClient;
}
@end

@implementation TPUploadQueue

-(id)init
{
    self = [super init];
    if (self) {
        oauthClient = [TPOAuthClient sharedClient];
        uploadQueue = [NSMutableArray array];
    }
    return self;
}


-(void)add:(NSDictionary *)item
{
    [uploadQueue addObject:item];
}


-(void)clear
{
    [uploadQueue removeAllObjects];
}

-(void)performOperations
{
    if (uploadQueue.count) {
        [oauthClient postPath:@"/test" parameters:uploadQueue[0] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [uploadQueue removeObjectAtIndex:0];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"unable to upload");
        }];
    }
}
@end
