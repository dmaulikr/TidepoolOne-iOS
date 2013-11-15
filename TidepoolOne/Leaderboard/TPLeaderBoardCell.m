//
//  TPLeaderBoardCell.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/21/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPLeaderBoardCell.h"

@implementation TPLeaderBoardCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setIsSelf:(BOOL)isSelf
{
    _isSelf = isSelf;
    if (isSelf) {
        self.pointsContainerView.backgroundColor = self.userContainerView.backgroundColor = [UIColor colorWithRed:153/255. green:171/255. blue:206/255. alpha:0.5];
        self.usernameLabel.textColor = self.scoreLabel.textColor = self.pointsLabel.textColor = [UIColor whiteColor];
    } else {
        self.pointsContainerView.backgroundColor = self.userContainerView.backgroundColor = [UIColor  colorWithWhite:1.0 alpha:0.5];
        self.usernameLabel.textColor = self.scoreLabel.textColor = self.pointsLabel.textColor = [UIColor blackColor];
    }
}

@end
