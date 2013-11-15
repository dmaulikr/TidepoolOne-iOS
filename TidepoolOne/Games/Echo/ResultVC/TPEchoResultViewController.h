//
//  TPEchoResultViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPResultViewController.h"

@interface TPEchoResultViewController : TPResultViewController

@property (weak, nonatomic) IBOutlet UIImageView *badgeImageView;
@property (weak, nonatomic) IBOutlet TPLabelBold *scoreLabel;
@property (weak, nonatomic) IBOutlet UITextView *blurbView;
@property (weak, nonatomic) IBOutlet TPLabelBold *badgeTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *longestSequence_1;
@property (weak, nonatomic) IBOutlet UILabel *longestSequence_2;

@property (weak, nonatomic) IBOutlet TPLabelBold *points_1;

@property (weak, nonatomic) IBOutlet TPLabelBold *points_2;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIButton *playAgainButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@end
