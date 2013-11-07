//
//  TPEchoResultViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/23/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPEchoResultViewController.h"

@interface TPEchoResultViewController ()
{
    NSDictionary *_result;
}
@end

@implementation TPEchoResultViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews
{
    [self.scrollView setContentSize:CGSizeMake(320, 630)];
}


-(void)setResult:(NSDictionary *)result
{
    _result = result;
    if (result) {
        self.badgeImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"resultsbadge-%@.png", result[@"badge"][@"character"]]];
        self.badgeTitleLabel.text = result[@"badge"][@"character"];
        self.blurbView.text = result[@"badge"][@"description"];
        self.scoreLabel.text = [NSString stringWithFormat:@"%@", result[@"attention_score"]];
        
        self.points_1.text = [NSString stringWithFormat:@"%@", result[@"calculations"][@"stage_scores"][0][@"score"]];
        self.longestSequence_1.text = [NSString stringWithFormat:@"%@", result[@"calculations"][@"stage_scores"][0][@"highest"]];
        
        self.points_2.text = [NSString stringWithFormat:@"%@", result[@"calculations"][@"stage_scores"][1][@"score"]];
        self.longestSequence_2.text = [NSString stringWithFormat:@"%@", result[@"calculations"][@"stage_scores"][1][@"highest"]];

    }
}


@end
