//
//  TPProfileViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/6/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPProfileViewController.h"
#import "TPSettingsViewController.h"
#import "TPProfileViewHeader.h"
#import "TPOAuthClient.h"
#import <AttributedMarkdown/markdown_lib.h>
#import <AttributedMarkdown/markdown_peg.h>
#import "TPPolarChartView.h"

@interface TPProfileViewController ()
{
    TPOAuthClient *_oauthClient;
    UIImageView *_imageView;
}
@end

@implementation TPProfileViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _oauthClient = [TPOAuthClient sharedClient];
    [_oauthClient getPath:@"api/v1/users/-/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self parseResponse:responseObject];
        NSLog([responseObject description]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog([error description]);
    }];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = @"My Profile";
    self.rightButton.target = self;
    self.rightButton.action = @selector(showSettings);
    
    
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.tableView.backgroundView = _imageView;

    
    NSArray *nibItems = [[NSBundle mainBundle] loadNibNamed:@"TPProfileViewHeader" owner:nil options:nil];
    NSLog([nibItems description]);
    TPProfileViewHeader *profileHeaderView;
    for (id item in nibItems) {
        if ([item isKindOfClass:[TPProfileViewHeader class]]) {
            profileHeaderView = item;
        }
    }
    self.tableView.tableHeaderView = profileHeaderView;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
//    TPPolarChartView *polar = [[TPPolarChartView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
//    [cell.contentView addSubview:polar];
//    self.data = @[@4,@5,@10,@3,@6];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

-(void)showSettings
{
    TPSettingsViewController *settingsVC = [[TPSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:settingsVC animated:YES];
}

-(void)showProfileScreen
{
}

-(void)setPersonalityType:(NSDictionary *)personalityType
{
    _personalityType = personalityType;
    if (_personalityType) {
        TPProfileViewHeader *profileHeaderView = self.tableView.tableHeaderView;
        _imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"bg-%@.jpg",_personalityType[@"profile_description"][@"display_id"]]];
        
        profileHeaderView.nameLabel.text = _personalityType[@"profile_description"][@"name"];
        profileHeaderView.badgeImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"badge-%@.png",_personalityType[@"profile_description"][@"display_id"]]];
        profileHeaderView.personalityTypeLabel.text =  _personalityType[@"profile_description"][@"name"];
        profileHeaderView.blurbLabel.attributedText = [self parsedFromMarkdown:_personalityType[@"profile_description"][@"one_liner"]];
        TPPolarChartView *polarChartView = profileHeaderView.chartView;
        NSMutableArray *big5Values = [NSMutableArray array];
        NSArray *keys = @[@"openness",@"conscientiousness",@"extraversion",@"agreeableness",@"neuroticism",];
        for (NSString *key in keys) {
            [big5Values addObject:_personalityType[@"big5_score"][key]];
        }
        polarChartView.data = big5Values;
    }
}

-(void)parseResponse:(NSDictionary *)response
{
    self.personalityType = response[@"data"][@"personality"];
}

-(NSAttributedString *)parsedFromMarkdown:(NSString *)rawText
{
    // start with a raw markdown string
//    rawText = @"Hello, world. *This* is native Markdown.";
    
    // create a font attribute for emphasized text
    UIFont *strongFont = [UIFont fontWithName:@"Karla-Bold" size:15.0];
    
    // create a color attribute for paragraph text
    UIColor *emColor = [UIColor blueColor];
    
    // create a dictionary to hold your custom attributes for any Markdown types
    NSDictionary *attributes = @{
                                 @(STRONG): @{NSFontAttributeName : strongFont,},
                                 @(EMPH): @{NSForegroundColorAttributeName : emColor,}
                                 };    
    // parse the markdown
    NSAttributedString *prettyText = markdown_to_attr_string(rawText,0,attributes);
    
    return prettyText;
//    // assign it to a view object
//    myTextView.attributedText = prettyText;

}


@end
