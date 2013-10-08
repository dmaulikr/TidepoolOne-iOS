//
//  TPConnectionsCell.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/7/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPConnectionsCell.h"

@interface TPConnectionsCell()
{
    UIImageView *_imageView;
    UISwitch *_switch;
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
        _switch = [[UISwitch alloc] initWithFrame:CGRectMake(250, 5, 40, 40)];
        [_switch addTarget:self action:@selector(connectionSwitched:) forControlEvents:UIControlEventValueChanged];
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:_imageView];
        [self addSubview:_switch];
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
        _label.text = provider;
        _label.frame = CGRectMake(image.size.width + 20, 0, self.bounds.size.width - 100, self.bounds.size.height);
    }
}

-(void)connectionSwitched:(UISwitch *)sender
{
    BOOL value = sender.on;
    if (value) {
        
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Delete connection" message:@"Are you sure you want to delete this connection" delegate:self cancelButtonTitle:@"Don't delete" otherButtonTitles:@"Yes, delete", nil] show];
    }
}

@end
