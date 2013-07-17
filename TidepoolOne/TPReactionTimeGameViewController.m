//
//  TPReactionTimeGameViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 7/17/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPReactionTimeGameViewController.h"
#import "TPReactionTimeGameCircleView.h"
#import "TPUploadQueue.h"

@interface TPReactionTimeGameViewController ()
{
    TPUploadQueue *_uploadQueue;
    TPReactionTimeGameCircleView *_circleView;
}
@end

@implementation TPReactionTimeGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _uploadQueue = [[TPUploadQueue alloc] init];
    _circleView = [[TPReactionTimeGameCircleView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_circleView];
    NSDictionary *event;
    event = @{@"event_type":@"0",
              @"module":@"reaction_time",
              @"stage":@"0",
              @"sequence_type":@"simple",
              @"record_time":@"32624354352",
              @"event_desc":@"test_started",
              @"color_sequence":@"yellow",
              @"game_id":@"23",
              @"user_id":@"112",
              };
    [_uploadQueue add:event];
    [_uploadQueue performOperations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupGameWithDefinitions:(NSDictionary *)dictionary
{
    _circleView.sequence = dictionary[@"stages"][1][@"sequence"];
}

@end
