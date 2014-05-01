//
//  WeekViewController.m
//  PurduePlanner
//
//  Created by Aaron Peters on 4/26/14.
//  Copyright (c) 2014 Aaron Peters. All rights reserved.
//

#import "WeekViewController.h"

#define MAX_DAYS 21  // Maximum days in the calendar
#define DAYS_IN_WEEK 7;

@interface WeekViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *calendarCollectionView;
@property (weak, nonatomic) IBOutlet UITableView *assignmentTable;

@end

@implementation WeekViewController {
    NSMutableArray *array;
    int current_date;
    int todays_date;
    BOOL finished;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES animated:YES ];
    
    _daysAndAssignments = [[NSMutableDictionary alloc] init];
    current_date = -1;
    finished = NO;
    _assignments = [[NSMutableArray alloc] init];
    _times = [[NSMutableArray alloc] init];
    _ids = [[NSMutableArray alloc] init];
    _completeStatuses = [[NSMutableArray alloc] init];
    [self.assignmentTable reloadData];
    [self getInformationFromServer];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* How to use dicitonaries: 
     
    NSDictionary *dict = @{ @"alpha" : @[@"1", @"2", @"3"], @"beta" : @[@"one", @"two", @"three"] };
    NSLog(@"%@", [[dict objectForKey:@"beta"] objectAtIndex:1]);
    
    NSMutableDictionary *mut = [[NSMutableDictionary alloc] init];
    [mut setObject:@[@"1", @"2", @"3"] forKey:@"alpha"];
    NSLog(@"%@", [[dict objectForKey:@"alpha"] objectAtIndex:1]);
     
     */
    
    array = [[NSMutableArray alloc] init];
    [array addObject:@"Su"];
    [array addObject:@"M"];
    [array addObject:@"T"];
    [array addObject:@"W"];
    [array addObject:@"R"];
    [array addObject:@"F"];
    [array addObject:@"Sa"];
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getInformationFromServer
{
    NSDate *date = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date];
    
    todays_date = (int)[comp1 day];
    
    /* Force the date to rewind to the Sunday of the current week */
    if ([comp1 weekday] > 1){
        date = [date dateByAddingTimeInterval:-60*60*24*([comp1 weekday] - 1)];
    }
    
    comp1 = [calendar components:unitFlags fromDate:date];
    _start_date = (int)[comp1 day];
    _start_month = (int)[comp1 month];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Assignments"];
    [query orderByAscending:@"due"];
    [query whereKey:@"due" greaterThanOrEqualTo:date];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSDate *comparDate = date;
            int lcv = 0, incr_count = 0;
            NSMutableArray *temp = [[NSMutableArray alloc] init];
#warning not implementing first on month correctly. Look at assignment: Math due on May 01
            while (lcv < [objects count] && incr_count < MAX_DAYS){
                PFObject *obj = [objects objectAtIndex:lcv];
                if ([ViewTVC isSameDayWithToday:comparDate due:obj[@"due"]]){
                    [temp addObject:obj];
                    NSLog(@"%@", obj[@"assignment_name"]);
                    lcv++;
                }
                else {
                    if ([temp count] > 0){
                        NSDateComponents* comp = [calendar components:unitFlags fromDate:comparDate];
                        NSLog(@"%ld", (long)[comp day]);
                        NSString *strFromInt = [NSString stringWithFormat:@"%d",[comp day]];
                        [_daysAndAssignments setObject:temp forKey:strFromInt];
                        temp = [[NSMutableArray alloc] init];
                        NSLog(@"%@", _daysAndAssignments);
                    }
                    comparDate = [comparDate dateByAddingTimeInterval:60*60*24];
                    incr_count++;
                }
            }
            finished = YES;
            [self.calendarCollectionView reloadData];
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

#pragma mark Collection View Methods

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return MAX_DAYS / DAYS_IN_WEEK;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return DAYS_IN_WEEK;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    UILabel *labelDate = (UILabel *)[cell viewWithTag:100];
    UILabel *labelCount = (UILabel *)[cell viewWithTag:200];
    
    [cell.layer setBorderWidth:1.0f];
    [cell.layer setBorderColor:[UIColor whiteColor].CGColor];
    [cell.layer setCornerRadius:5.0f];
    
    if (finished){
        if (current_date == -1)
            current_date = _start_date;
        
        NSString *strFromInt = [NSString stringWithFormat:@"%d", current_date];
        labelDate.text = strFromInt;
        NSArray *temp = [_daysAndAssignments objectForKey:strFromInt];
        int count = [temp count];
        if (count > 0)
            [labelCount setTextColor:[UIColor redColor]];
        else
            [labelCount setTextColor:[UIColor darkGrayColor]];
        
        if (current_date == todays_date)
            [cell.layer setBorderWidth:3.0f];
        
        strFromInt = [NSString stringWithFormat:@"%d", count];
        labelCount.text = strFromInt;
        current_date ++;
        
        if ([ViewTVC isLastDayofMonthWithDay:current_date-1 andMonth:_start_month]){
            current_date = 1;
        }
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [self.calendarCollectionView cellForItemAtIndexPath:indexPath];
    UILabel *labelDate = (UILabel *)[cell viewWithTag:100];
    NSString *tag = labelDate.text;
    
    [cell.layer setBorderColor:[UIColor redColor].CGColor];
    
    int date = [labelDate.text intValue];
    if (date == todays_date)
        [cell.layer setBorderWidth:3.0f];
    else
        [cell.layer setBorderWidth:2.0f];
    
    _assignments = [[NSMutableArray alloc] init];
    _times = [[NSMutableArray alloc] init];
    _ids = [[NSMutableArray alloc] init];
    _completeStatuses = [[NSMutableArray alloc] init];
    
    NSArray *objects = [_daysAndAssignments objectForKey:tag];
    if (objects){
        for (PFObject * assignment in objects){
            [_ids addObject:assignment.objectId];
            [_assignments addObject:assignment[@"assignment_name"]];
            [_times addObject:[ViewTVC getTimeRepresentationWithDate:assignment[@"due"]]];
            [_completeStatuses addObject:assignment[@"complete"]];
        }
    }
    [self.assignmentTable reloadData];
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [self.calendarCollectionView cellForItemAtIndexPath:indexPath];
    UILabel *labelDate = (UILabel *)[cell viewWithTag:100];
    int date = [labelDate.text intValue];
    if (date == todays_date)
        [cell.layer setBorderWidth:3.0f];
    else
        [cell.layer setBorderWidth:1.0f];
    
    [cell.layer setBorderColor:[UIColor whiteColor].CGColor];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_assignments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_MonthView" forIndexPath:indexPath];
    
    if ([_assignments count]){
        cell.detailTextLabel.text = [_times objectAtIndex:indexPath.row];
        cell.textLabel.text = [_assignments objectAtIndex:indexPath.row];
        NSNumber *num = [NSNumber numberWithBool:[[_completeStatuses objectAtIndex:indexPath.row] boolValue]];
        int i = [num intValue];
        if (i)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Assignments";
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueIdentifier = [segue identifier];
    NSIndexPath *indexPath = [self.assignmentTable indexPathForCell:sender];
    if([segueIdentifier isEqualToString:@"MonthAssignmentSegue"]){
        [[self navigationController] setNavigationBarHidden:NO animated:YES];
        AssignmentDetailViewController *detailController = (AssignmentDetailViewController *)[segue destinationViewController];
            detailController.objectId = [_ids objectAtIndex:indexPath.row];
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
