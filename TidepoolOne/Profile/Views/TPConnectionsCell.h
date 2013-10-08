//
//  TPConnectionsCell.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/7/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPConnectionsCell;

@protocol TPConnectionsCellDelegate<NSObject>
-(void)connectionsCell:(TPConnectionsCell *)cell tryingToSetConnectionStateTo:(BOOL)connected;
@end

@interface TPConnectionsCell : UITableViewCell

@property (nonatomic, strong) NSString *provider;
@property (nonatomic, strong) UISwitch *switchIndicator;
@property (nonatomic, weak) id<TPConnectionsCellDelegate> delegate;

@end
