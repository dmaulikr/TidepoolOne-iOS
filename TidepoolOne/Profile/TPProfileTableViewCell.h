//
//  TPProfileTableViewCell.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/8/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPProfileTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *rightTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *centerTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *ribbonImageView;

@end
