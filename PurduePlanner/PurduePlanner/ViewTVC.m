//
//  ViewTVC.m
//  PurduePlanner
//
//  Created by Aaron Peters on 4/23/14.
//  Copyright (c) 2014 Aaron Peters. All rights reserved.
//

#import "ViewTVC.h"
#import <Parse/Parse.h>

#define NUM_ROWS 6
#warning The following asssumes the user wants the next day to start at 10:00 UTC :
#define NEW_DAY 6

@interface ViewTVC ()

@end

@implementation ViewTVC

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
    _num_rows = 0;
    _lock = [[NSConditionLock alloc] initWithCondition:0];
    _array_ready = NO;
    
    [self getAssignmentDataFromParseServer];
    
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
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (void)getAssignmentDataFromParseServer
{    
    _assignments = [[NSMutableArray alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:@"Assignments"];
    [query orderByDescending:@"priority"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    //[query whereKey:@"assignment_name" equalTo:@"Test Assignment"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (!error) {
        // The find succeeded.
        NSLog(@"Successfully retrieved %lu scores.", (unsigned long)[objects count]);
        // Do something with the found objects
        for (PFObject *object in objects) {
            //BOOL sameDate = [self isSameDayWithToday:[NSDate date] due:object.createdAt];
            BOOL sameDate = [self isSameDayWithToday:object[@"today"] due:object[@"due"]];
            if (sameDate)
                [_assignments addObject:object[@"assignment_name"]];
            
            //NSLog(@"%hhd", sameDate);
        }
        [self.tableView reloadData];
    } else {
        // Log details of the failure
        NSLog(@"Error: %@ %@", error, [error userInfo]);
    }
    }];
}

- (BOOL)isSameDayWithToday:(NSDate*)date1 due:(NSDate*)date2
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    //return [comp1 day] == [comp2 day] && [comp1 month] == [comp2 month] && [comp1 year]  == [comp2 year];
    // Date 1 is TODAY and Date 2 is DUE_DATE:
    
    if ([comp1 year] == [comp2 year]){
        // Dates are in same year:
        if ([comp1 month] == [comp2 month]) {
            // Dates are in same month:
            if ([comp1 day] == [comp2 day]) {
                // Dates are in same calendar day, so they must match. Return YES:
                return YES;
            } else
            /* 
             Dates are not in same calendar day.
             Next, must check if due date is on the next calender day in the same month.
             If it is, check to see if due date's hours are before 10:00 UTC.
                If so, RETURN YES:
             */
                return ([comp2 day] - [comp1 day] == 1) && ([comp2 hour] < NEW_DAY);
            
        } else {
            /*
                Dates are not in the same calendar month.
                First, check to see if the due month is one month after today's month:
                If it is, check to see if due date's day is 1:
                If it is, check to see if due date's hours are before 10:00 UTC.
                    If so, RETURN YES:
             */
            return ([comp2 month] - [comp1 month] == 1) && ([comp2 day] == 1) && ([comp2 hour] < NEW_DAY);
        }
    }
    else {
        /*
         Dates are not in the same calendar year.
         First, check to see if the due year is one year after today's year:
         If it is, check to see if the due month is one month after today's month:
         If it is, check to see if due date's day is 1:
         If it is, check to see if due date's hours are before 10:00 UTC.
            If so, RETURN YES:
         */
        return ([comp2 year] - [comp1 year] == 1) && ([comp2 month] - [comp1 month] == 1) && ([comp2 day] == 1) && ([comp2 hour] < NEW_DAY);
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if ([_assignments count])
        cell.textLabel.text = [_assignments objectAtIndex:0];
    return cell;
        
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Today";
            break;
        case 1:
            return @"Tomorrow";
            break;
            
        default:
            return 0;
            break;
    }
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
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
