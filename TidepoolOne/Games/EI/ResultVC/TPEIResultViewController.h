//
//  TPEIResultViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPResultViewController.h"

@interface TPEIResultViewController : TPResultViewController

@property (weak, nonatomic) IBOutlet UIImageView *badgeImageView;
@property (weak, nonatomic) IBOutlet TPTextView *blurbView;
@property (weak, nonatomic) IBOutlet TPLabel *finishTimeLabel;
@property (weak, nonatomic) IBOutlet TPLabel *instantReplaysLabel;
@property (weak, nonatomic) IBOutlet TPLabel *correctLabel;
@property (weak, nonatomic) IBOutlet TPLabel *incorrectLabel;

@end
