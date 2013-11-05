//
//  TPLeaderBoardCell.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/21/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPLeaderBoardCell : UITableViewCell
@property (weak, nonatomic) IBOutlet TPLabelBold *scoreLabel;
@property (weak, nonatomic) IBOutlet TPLabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userProfilePicture;
@property (weak, nonatomic) IBOutlet UIImageView *badgeImageView;
@property (weak, nonatomic) IBOutlet TPLabelBold *badgeTitleLabel;

@end
