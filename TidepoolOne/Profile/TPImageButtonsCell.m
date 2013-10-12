//
//  TPImageButtonsCell.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/7/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPImageButtonsCell.h"

@interface TPImageButtonsCell()
{
    NSMutableArray *_buttons;
}
@end

@implementation TPImageButtonsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.exclusiveSelect = YES;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)setButtonImages:(NSArray *)buttonImages
{
    if ([buttonImages isEqualToArray:_buttonImages]) {
        return;
    }
    _buttonImages = buttonImages;
    for (UIButton *button in _buttons) {
        [button removeFromSuperview];
    }
    _buttons = [@[] mutableCopy];
    if (_buttonImages) {
        float buttonHeight = self.bounds.size.height;
        float buttonOffset = 10;
        float buttonWidth = (self.bounds.size.width - 20) / _buttonImages.count;
        for (int i=0;i<_buttonImages.count;i++) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i*buttonWidth + buttonOffset, 0, buttonWidth, buttonHeight)];
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            id item = _buttonImages[i];
            if ([item isKindOfClass:[UIImage class]]) {
                UIImage *buttonImage = _buttonImages[i];
                [button setImage:buttonImage forState:UIControlStateNormal];
            } else if ([item isKindOfClass:[NSArray class]]) {
                NSArray *buttonImageStates = _buttonImages[i];
                [button setImage:buttonImageStates[0] forState:UIControlStateNormal];
                [button setImage:buttonImageStates[1] forState:UIControlStateSelected];
            }
            [self addSubview:button];
            [_buttons addObject:button];
        }
    }
}

-(void)buttonPressed:(UIButton *)sender
{
    for (int i=0;i<_buttons.count;i++) {
        UIButton *button = _buttons[i];
        if (sender != button) {
            button.selected = NO;
        } else {
            sender.selected = !sender.selected;
            if ([self.delegate respondsToSelector:@selector(buttonWasChosenWithIndex:selected:inCell:)]) {
                [self.delegate buttonWasChosenWithIndex:i selected:sender.selected inCell:self];
            }
            if (self.values) {
                NSString *value = nil;
                if (sender.selected) {
                    value = self.values[i];
                }
                if ([self.delegate respondsToSelector:@selector(valueWasChosen:inCell:)]) {
                    [self.delegate valueWasChosen:value inCell:self];
                }
            }
        }
    }
}

-(void)setCurrentValue:(NSString *)currentValue
{
    _currentValue = currentValue;
    if (currentValue) {
        if ([_values containsObject:currentValue]) {
            int index = [_values indexOfObject:currentValue];
            UIButton *button = _buttons[index];
            button.selected = YES;
        }
    }
}

@end
