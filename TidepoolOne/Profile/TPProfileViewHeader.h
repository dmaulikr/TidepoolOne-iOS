//
//  TPProfileViewHeader.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/6/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface TPProfileViewHeader : UIView

@property (weak, nonatomic) IBOutlet UIImageView *badgeImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *personalityTypeLabel;
@property (weak, nonatomic) IBOutlet UITextView *blurbLabel;
@property (weak, nonatomic) IBOutlet UIView *chartView;

@end
