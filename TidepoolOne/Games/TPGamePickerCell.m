//
//  TPGamePickerCell.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/25/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPGamePickerCell.h"

@interface TPGamePickerCell()
{
    
}
@end

@implementation TPGamePickerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.cellImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 102)];
        [self addSubview:self.cellImageView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
