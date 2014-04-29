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

@end

@implementation WeekViewController {
    NSMutableArray *array;
    int current_date;
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
    _daysAndAssignments = [[NSMutableDictionary alloc] init];
    current_date = -1;
    finished = NO;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)getInformationFromServer
{
    NSDate *date = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date];
    
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
    return [array count]; //MAX_DAYS;
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
        
        strFromInt = [NSString stringWithFormat:@"%d", count];
        labelCount.text = strFromInt;
        current_date ++;
        
        if ([ViewTVC isLastDayofMonthWithDay:current_date-1 andMonth:_start_month]){
            current_date = 1;
        }
    }
    
    return cell;
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
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_MonthView" forIndexPath:indexPath];
    cell.textLabel.text = @"Text";
    return cell;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Assignments";
}

@end
