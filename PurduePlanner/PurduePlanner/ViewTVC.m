//
//  ViewTVC.m
//  PurduePlanner
//
//  Created by Aaron Peters on 4/23/14.
//  Copyright (c) 2014 Aaron Peters. All rights reserved.
//

#import "ViewTVC.h"

#warning The following asssumes the user wants the next day to start at 10:00 UTC :
#define NEW_DAY 6
#define DAYS_IN_WEEK 7

@interface ViewTVC ()

@end

@implementation ViewTVC{
    NSMutableDictionary *repeatingAssignments;
}

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
    [self createOrAccessAssignmentsDatabase];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self resetArrays];
    
    NSDate *date = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit;
    NSDateComponents* comp = [calendar components:unitFlags fromDate:date];
    
    NSArray *today = [self getRepeatingAssignmentsFromDatabaseWithDay:[comp weekday] - 1];
    for (NSString * assignment in today) {
        [_assignments addObject:assignment];
        [_times addObject:[ViewTVC getTimeRepresentationWithDate:date]];
        [_completeStatuses addObject:@NO];
        [_ids addObject:@"REPEATING"];
    }
    NSArray *tmrw = [self getRepeatingAssignmentsFromDatabaseWithDay:[comp weekday]];
    for (NSString * assignment in tmrw) {
        [_assignmentsTmrw addObject:assignment];
        [_timesTmrw addObject:[ViewTVC getTimeRepresentationWithDate:date]];
        [_completeStatusesTmrw addObject:@NO];
        [_ids_tmrw addObject:@"REPEATING"];
    }
    
    [self getAssignmentDataFromParseServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma SQLite3 Methods

- (void)createOrAccessAssignmentsDatabase
{
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    _assignmentsDatabasePath = [[NSString alloc]
                                initWithString: [docsDir stringByAppendingPathComponent:
                                                 @"assignments.db"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: _assignmentsDatabasePath ] == NO)
    {
        const char *dbpath = [_assignmentsDatabasePath UTF8String];
        
        if (sqlite3_open(dbpath, &_assignmentsDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt =
            "CREATE TABLE IF NOT EXISTS ASSIGNMENTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, ASSIGNMENT TEXT, DAY INTEGER)";
            
            if (sqlite3_exec(_assignmentsDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
                NSLog(@"%@", @"Failed to create table");
            else
                NSLog(@"%@", @"Successfully created table");
            
            sqlite3_close(_assignmentsDB);
        } else
            NSLog(@"%@", @"Failed to open/create database");
    }
    else
        NSLog(@"%@", @"Table already exists. Status OK");
}

- (NSMutableArray*)getRepeatingAssignmentsFromDatabaseWithDay:(int)day
{
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    const char *dbpath = [_assignmentsDatabasePath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &_assignmentsDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT assignment FROM assignments WHERE day=\"%d\"",
                              day];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_assignmentsDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *assignmentField = [[NSString alloc]
                                             initWithUTF8String:(const char *)
                                             sqlite3_column_text(statement, 0)];
                //NSLog(@"Assignment Found with Name: %@", assignmentField);
                [temp addObject:assignmentField];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(_assignmentsDB);
        //NSLog(@"%@", _daysAndAssignments);
    }
    return temp;
}


# pragma mark - parse methods

- (void)resetArrays
{
    _assignments = [[NSMutableArray alloc] init];
    _times = [[NSMutableArray alloc] init];
    _ids = [[NSMutableArray alloc] init];
    _completeStatuses = [[NSMutableArray alloc] init];
    
    _assignmentsTmrw = [[NSMutableArray alloc] init];
    _timesTmrw = [[NSMutableArray alloc] init];
    _ids_tmrw = [[NSMutableArray alloc] init];
    _completeStatusesTmrw = [[NSMutableArray alloc] init];
}

- (void)getAssignmentDataFromParseServer
{
    PFQuery *query = [PFQuery queryWithClassName:@"Assignments"];
    [query orderByAscending:@"due"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu scores.", (unsigned long)[objects count]);
            // Do something with the found objects
            for (PFObject *object in objects) {
                NSDate *today = [NSDate date];
                BOOL sameDate = [ViewTVC isSameDayWithToday:today due:object[@"due"]];
                if (sameDate){
                    [_assignments addObject:object[@"assignment_name"]];
                    [_times addObject:[ViewTVC getTimeRepresentationWithDate:object[@"due"]]];
                    [_completeStatuses addObject:object[@"complete"]];
                    [_ids addObject:object.objectId];
                }
                else {
                    NSDate *tmrwDate = [today dateByAddingTimeInterval:60*60*24];
                    BOOL tomorrow = [ViewTVC isSameDayWithToday:tmrwDate due:object[@"due"]];
                    if (tomorrow){
                        [_assignmentsTmrw addObject:object[@"assignment_name"]];
                        [_timesTmrw addObject:[ViewTVC getTimeRepresentationWithDate:object[@"due"]]];
                        [_completeStatusesTmrw addObject:object[@"complete"]];
                        [_ids_tmrw addObject:object.objectId];
                    }
                }
            }
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
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
    switch (section) {
        case 0:
            return [_assignments count];
            break;
        case 1:
            return [_assignmentsTmrw count];
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    BOOL isRepeat = [[_ids objectAtIndex:indexPath.row] isEqualToString:@"REPEATING"];
    if (isRepeat){
        cell = [tableView dequeueReusableCellWithIdentifier:@"RepeatingCell" forIndexPath:indexPath];
        cell.textLabel.textColor=[UIColor blueColor]; //according to you
        UIFont *myFont = [ UIFont fontWithName: @"Arial" size: 16.0 ];
        cell.textLabel.font  = myFont;
    }
    else
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (indexPath.section == 0 && [_assignments count]){
        cell.detailTextLabel.text = [_times objectAtIndex:indexPath.row];
        cell.textLabel.text = [_assignments objectAtIndex:indexPath.row];
        if (!isRepeat){
            NSNumber *num = [NSNumber numberWithBool:[[_completeStatuses objectAtIndex:indexPath.row] boolValue]];
            int i = [num intValue];
            if (i)
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            else
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else if (indexPath.section == 1 && [_assignmentsTmrw count]){
        cell.detailTextLabel.text = [_timesTmrw objectAtIndex:indexPath.row];
        cell.textLabel.text = [_assignmentsTmrw objectAtIndex:indexPath.row];
        
        if (!isRepeat){
            NSNumber *num = [NSNumber numberWithBool:[[_completeStatusesTmrw objectAtIndex:indexPath.row] boolValue]];
            int i = [num intValue];
            if (i)
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            else
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    return cell;
        
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Due Tonight";
            break;
        case 1:
            return @"Due Tomorrow";
            break;
            
        default:
            return 0;
            break;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        int section = (int)indexPath.section;
        int row = (int)indexPath.row;
        NSString *objectId;
        if (section == 0)
            objectId = _ids[row];
        else
            objectId = _ids_tmrw[row];
        
        PFQuery *query = [PFQuery queryWithClassName:@"Assignments"];
        [query getObjectInBackgroundWithId:objectId block:^(PFObject *assignment, NSError *error) {
            [assignment delete];
            [self resetArrays];
            [self getAssignmentDataFromParseServer];
            //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
        
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

#pragma mark - public data methods

+ (NSString *)getTimeRepresentationWithDate:(NSDate *)date
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"hh:mm a"];
    
    
    NSString *dateString = [format stringFromDate:date];
    return dateString;
    
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date];
    
    int hour = (int)[comp1 hour];
    int minute = (int)[comp1 minute];
    NSString *time = [[NSString alloc] initWithFormat:@"%d:%d", hour, minute];
    return time;
}

+ (BOOL)isLastDayofMonthWithDate:(NSDate*)date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date];
    
    int month = (int)[comp1 month];
    int day = (int)[comp1 day];
    //NSLog(@"%d/%d", month, day);
    
    if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12)
        return day == 31;
    else if (month != 2)
        return day == 30;
    else if ([self isYearLeapYearFromDate:date])
        return day == 29;
    else
        return day == 28;
    
    return NO;
}

+ (BOOL)isLastDayofMonthWithDay:(int)date andMonth:(int)month andYear:(int)year
{
    int day = date;
    //NSLog(@"%d/%d", month, day);
    
    if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12)
        return day == 31;
    else if (month != 2)
        return day == 30;
    else if ([self isLeapYearFromYear:year])
        return day == 29;
    else
        return day == 28;
    
    return NO;
}

+ (BOOL)isLeapYearFromYear:(int)year
{
    return (( year%100 != 0) && (year%4 == 0)) || year%400 == 0;
}

+ (BOOL)isYearLeapYearFromDate:(NSDate *)aDate
{
    NSInteger year = [self yearFromDate:aDate];
    return [self isLeapYearFromYear:year];
}

+ (NSInteger)yearFromDate:(NSDate *)aDate
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy";
    NSInteger year = [[dateFormatter stringFromDate:aDate] integerValue];
    return year;
}

+ (int)getLastDayOfMonthWithMonth:(int)month andYear:(int)year
{
    if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12)
        return 31;
    else if (month != 2)
        return 30;
    else if ([ViewTVC isLeapYearFromYear:year])
        return 29;
    else
        return 28;
    
    return NO;
}

+ (BOOL)isSameDayWithToday:(NSDate*)date1 due:(NSDate*)date2
{
    // Date 1 is TODAY and Date 2 is DUE_DATE:
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    if ([comp1 year] == [comp2 year]){
        // Dates are in same year:
        if ([comp1 month] == [comp2 month]) {
            // Dates are in same month:
            if ([comp1 day] == [comp2 day]) {
                // Dates are in same calendar day, make sure they are both below or above NEW_DAY threshold:
                return ([comp1 hour] < NEW_DAY && [comp2 hour] < NEW_DAY) || ([comp1 hour] >= NEW_DAY && [comp2 hour] >= NEW_DAY);
            } else {
                //Dates are not in same calendar day
                if ([comp1 day] > [comp2 day])
                    return [comp1 day] - [comp2 day] == 1 && [comp1 hour] < NEW_DAY && [comp2 hour] >= NEW_DAY;
                
                //else return if due date is tomorrow and due date's due time is less than NEW_DAY time and today's date is after NEW_DAY threshold
                return [comp2 day] - [comp1 day] == 1 && [comp2 hour] < NEW_DAY && [comp1 hour] >= NEW_DAY;
            }
            
        } else {
            /*
             Dates are not in the same calendar month.
             First, check to see if the due month is one month after today's month:
             If it is, check to see if due date's day is 1 and date1 is last of month:
             If it is, check to see if due date's hours are before NEW_DAY threshold and today's hours are after NEW_DAY threshold:
             If so, RETURN YES:
             */
            if ([comp1 day] > [comp2 day])
                return ([comp2 month] - [comp1 month] == 1) && [self isLastDayofMonthWithDate:date1] && [comp2 day] == 1 && [comp2 hour] < NEW_DAY && [comp1 hour] >= NEW_DAY;
            
            //else return if due date is tomorrow and due date's due time is less than NEW_DAY time and today's date is after NEW_DAY threshold
            return ([comp1 month] - [comp2 month] == 1) && [self isLastDayofMonthWithDate:date2] && [comp1 day] == 1 && [comp1 hour] < NEW_DAY && [comp2 hour] >= NEW_DAY;
            
            //return ([comp2 month] - [comp1 month] == 1) && [self isLastDayofMonthWithDate:date1] && [comp2 day] == 1 && [comp2 hour] < NEW_DAY && [comp1 hour] >= NEW_DAY;
        }
    }
    else {
        /*
         Dates are not in the same calendar year.
         First, check to see if the due year is one year after today's year:
         If it is, check to see if the due month is January and today's month is December:
         If it is, check to see if due date's day is 1 and date1 is last of month:
         If it is, check to see if due date's hours are before NEW_DAY threshold and today's hours are after NEW_DAY threshold:
         If so, RETURN YES:
         */
        return ([comp2 year] - [comp1 year] == 1) && [comp2 month] == 1 && [comp1 month] == 12 && [self isLastDayofMonthWithDate:date1] && [comp2 day] == 1 && [comp2 hour] < NEW_DAY && [comp1 hour] >= NEW_DAY;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueIdentifier = [segue identifier];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if([segueIdentifier isEqualToString:@"AssignmentSegue"]){
        AssignmentDetailViewController *detailController = (AssignmentDetailViewController *)[segue destinationViewController];
        if (indexPath.section)
            detailController.objectId = [_ids_tmrw objectAtIndex:indexPath.row];
        else
            detailController.objectId = [_ids objectAtIndex:indexPath.row];
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
