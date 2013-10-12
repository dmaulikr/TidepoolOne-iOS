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
    NSMutableArray *_uploadQueue;
    TPOAuthClient *_oauthClient;
}
@end

@implementation TPUploadQueue

-(id)init
{
    self = [super init];
    if (self) {
        _oauthClient = [TPOAuthClient sharedClient];
        _uploadQueue = [NSMutableArray array];
    }
    return self;
}


-(void)add:(NSDictionary *)item
{
    [_uploadQueue addObject:item];
}


-(void)clear
{
    [_uploadQueue removeAllObjects];
}

-(void)performOperations
{
    if (_uploadQueue.count) {
        [_oauthClient postPath:@"/test" parameters:_uploadQueue[0] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [_uploadQueue removeObjectAtIndex:0];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"unable to upload");
        }];
    }
}

@end