//
//  TPConnectionsCell.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/7/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPConnectionsCell.h"

@interface TPConnectionsCell() <UIAlertViewDelegate>
{
    UIImageView *_imageView;
    UILabel *_label;
}
@end

@implementation TPConnectionsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            _switchIndicator = [[UISwitch alloc] initWithFrame:CGRectMake(230, 10, 40, 40)];
        } else {
            _switchIndicator = [[UISwitch alloc] initWithFrame:CGRectMake(250, 5, 40, 40)];
        }

        [_switchIndicator addTarget:self action:@selector(connectionSwitched:) forControlEvents:UIControlEventTouchUpInside];
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.backgroundColor = [UIColor clearColor];
        [self addSubview:_imageView];
        [self addSubview:_switchIndicator];
        [self addSubview:_label];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setProvider:(NSString *)provider
{
    _provider = provider;
    if (provider) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"connection-%@.png",provider]];
        _imageView.image = image;
        _imageView.frame = CGRectMake(10, (self.bounds.size.height - image.size.height) / 2, image.size.width, image.size.height);
        _imageView.backgroundColor = [UIColor clearColor];
        _label.text = provider;
        _label.frame = CGRectMake(image.size.width + 20, 0, self.bounds.size.width - 100, self.bounds.size.height);
    }
}

-(void)connectionSwitched:(UISwitch *)sender
{
    BOOL value = sender.on;
    sender.on = !sender.on; // keep value as the old one still
    if (value) {
        [self.delegate connectionsCell:self tryingToSetConnectionStateTo:YES];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete connection" message:@"Are you sure you want to delete this connection" delegate:self cancelButtonTitle:@"Don't delete" otherButtonTitles:@"Yes, delete", nil];
        alertView.delegate = self;
        [alertView show];
    }
}

#pragma mark UIAlertViewDelegate methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        _switchIndicator.on = YES;
    }
    if (buttonIndex == 1) {
        _switchIndicator.on = NO;
        [self.delegate connectionsCell:self tryingToSetConnectionStateTo:NO];
    }
}


@end
