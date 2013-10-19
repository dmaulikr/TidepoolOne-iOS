//
//  TPInviteFriendsViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 10/18/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPInviteFriendsViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>

@interface TPInviteFriendsViewController () <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
{
    NSArray *_groups;
    NSArray *_fields;
}
@end

@implementation TPInviteFriendsViewController

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    _groups = @[@"Invite", @"Find"];
    _fields = @[
                @[@"Email", @"Facebook", @"Text"],
                @[@"Contacts", @"Facebook"],
                ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return _groups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_fields[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = _fields[indexPath.section][indexPath.row];
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _groups[section];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            //invite
        {
            switch (indexPath.row) {
                case 0://email
                {
                    if ([MFMailComposeViewController canSendMail])
                    {
                        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
                        mailer.mailComposeDelegate = self;
                        [mailer setSubject:@"A Message from MobileTuts+"];
                        NSArray *toRecipients = [NSArray arrayWithObjects:@"fisrtMail@example.com", @"secondMail@example.com", nil];
                        [mailer setToRecipients:toRecipients];
                        UIImage *myImage = [UIImage imageNamed:@"mobiletuts-logo.png"];
                        NSData *imageData = UIImagePNGRepresentation(myImage);
                        [mailer addAttachmentData:imageData mimeType:@"image/png" fileName:@"mobiletutsImage"];
                        NSString *emailBody = @"Have you seen the MobileTuts+ web site?";
                        [mailer setMessageBody:emailBody isHTML:NO];
                        [self presentViewController:mailer animated:YES completion:nil];
                    }
                    else
                    {
                        [[[UIAlertView alloc] initWithTitle:@"Failure"
                                                    message:@"Your device doesn't support the composer sheet"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil] show];
                    }
                    
                    
                }
                    break;
                case 1://facebook
                {
                    
                }
                    break;
                case 2://text
                {
                    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
                    if([MFMessageComposeViewController canSendText])
                    {
                        controller.body = @"The body of the SMS you want";
                        controller.messageComposeDelegate = self;
                        [self presentViewController:controller animated:YES completion:nil];
                    } else {
                        [[[UIAlertView alloc] initWithTitle:@"Failure"
                                                    message:@"Your device doesn't support sending messages"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil] show];
                    }
                    
                    
                }
                    break;
                default:
                    break;
            }
            //find
        case 1:
            {
                switch (indexPath.row) {
                    case 0://contacts
                    {
                        
                    }
                        break;
                    case 1://facebook
                    {
                        
                    }
                        break;
                    default:
                        break;
                }
                
            }
            break;
            
        default:
            break;
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [controller dismissViewControllerAnimated:YES completion:^{
    }];
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:^{
    }];
    
}

@end
