//
//  TPSettingsViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/6/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPSettingsViewController.h"
#import "TPOAuthClient.h"

@interface TPSettingsViewController ()

@end

@implementation TPSettingsViewController

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
    self.title = @"Settings";
    self.sections = @[@"Notifications", @"General"];
    self.rowsInSections = @[@[@"Add new"],@[@"Log Out", @"Privacy", @"Terms", @"Feedback", @"About TidePool",]];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.rowsInSections[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = self.rowsInSections[indexPath.section][indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
    self.rowsInSections = @[@[@"Add new"],@[@"Log Out", @"Privacy", @"Terms", @"Feedback", @"About TidePool",]];
    NSString *action = self.rowsInSections[indexPath.section][indexPath.row];
    if ([action isEqualToString:@"Log Out"]) {
        [[TPOAuthClient sharedClient] logout];
        self.tabBarController.selectedIndex = 0;
        [self.navigationController popViewControllerAnimated:YES];        
    } else if ([action isEqualToString:@"Log Out"]) {
    } else if ([action isEqualToString:@"Log Out"]) {
    } else if ([action isEqualToString:@"Log Out"]) {
    } else if ([action isEqualToString:@"Log Out"]) {
    } else if ([action isEqualToString:@"Log Out"]) {
    } else if ([action isEqualToString:@"Log Out"]) {
    } else if ([action isEqualToString:@"Log Out"]) {
    } else if ([action isEqualToString:@"Log Out"]) {
    } else if ([action isEqualToString:@"Log Out"]) {
    } else if ([action isEqualToString:@"Log Out"]) {
    } else if ([action isEqualToString:@"Log Out"]) {
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.sections[section];
}

@end
