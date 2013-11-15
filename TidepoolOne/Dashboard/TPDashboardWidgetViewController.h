//
//  TPDashboardWidgetViewController.h
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 9/13/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPDashboardWidgetViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSDictionary *user;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSMutableArray *results;
@property (strong, nonatomic) NSString *badgePrefix;

@property (weak, nonatomic) UITableView *tableView;


-(void)downloadResultswithCompletionHandlersSuccess:(void(^)())successBlock andFailure:(void(^)())failureBlock;
;
-(void)reset;
-(void)getMoreResults;
-(NSDictionary *)getAggregateScoreOfType:(NSString *)type fromArray:(NSArray *)array;
@end
