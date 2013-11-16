//
//  TPEchoGameViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPGameViewController.h"
#import "TPEchoGame.h"
@interface TPEchoGameViewController : TPGameViewController

@property (strong, nonatomic) TPEchoGame *gameObject;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIView *gameStartView;


@end
