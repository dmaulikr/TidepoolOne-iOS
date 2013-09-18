//
//  TPProfileHeaderView.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/6/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface TPProfileHeaderView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *badgeImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *personalityTypeLabel;
@property (weak, nonatomic) IBOutlet TPTextView *blurbLabel;
@property (weak, nonatomic) IBOutlet UIView *chartView;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@end
