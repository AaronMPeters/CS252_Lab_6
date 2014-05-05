//
//  RepeatingAssignmentsTVC.m
//  PurduePlanner
//
//  Created by Aaron Peters on 5/5/14.
//  Copyright (c) 2014 Aaron Peters. All rights reserved.
//

#import "RepeatingAssignmentsTVC.h"

@interface RepeatingAssignmentsTVC ()

@end

@implementation RepeatingAssignmentsTVC

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
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_assignmentArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"assignmentCell" forIndexPath:indexPath];
    cell.textLabel.text = [_assignmentArray objectAtIndex:indexPath.row];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Manage Assignments";
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueIdentifier = [segue identifier];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if([segueIdentifier isEqualToString:@"editRepeatSegue"]){
        ManageRepeatingAssignmentViewController *detailController = (ManageRepeatingAssignmentViewController *)[segue destinationViewController];
        detailController.assignment = [_assignmentArray objectAtIndex:indexPath.row];
        detailController.dayOfWeek = _dayOfWeek;
        detailController.assignmentsDB = _assignmentsDB;
        detailController.assignmentsDatabasePath = _assignmentsDatabasePath;
        detailController.title = [NSString stringWithFormat:(@"Edit Assignment")];
    }
    else if([segueIdentifier isEqualToString:@"addRepeatingSegue"]){
        AddRepeatingAssignmentViewController  *detailController = (AddRepeatingAssignmentViewController *)[segue destinationViewController];
        detailController.dayOfWeek = _dayOfWeek;
        detailController.assignmentsDB = _assignmentsDB;
        detailController.assignmentsDatabasePath = _assignmentsDatabasePath;
    }
}


@end
