//
//  TPLabel.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/3/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPLabel.h"

@implementation TPLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.fontSize = 20.0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.fontSize = self.font.pointSize;
    }
    return self;
}

-(void)setCentered:(BOOL)centered
{
    _centered = centered;
    if (_centered) {
        self.textAlignment = NSTextAlignmentCenter;
    } else {
        self.textAlignment = NSTextAlignmentLeft;
    }
}

-(void)setCorrectFont
{
    NSArray *fonts = @[@"Karla-Regular", @"Karla-Bold",@"Karla-Italic", @"dummy", @"Karla-BoldItalic"];
    int fontChoice = _bold + 2*_italic;
    self.font = [UIFont fontWithName:fonts[fontChoice] size:_fontSize];
}

-(void)setBold:(BOOL)bold
{
    _bold = bold;
    [self setCorrectFont];
}

-(void)setItalic:(BOOL)italic
{
    _italic = italic;
    [self setCorrectFont];    
}

-(void)setFontSize:(float)fontSize
{
    _fontSize = fontSize;
    [self setCorrectFont];
}

@end
