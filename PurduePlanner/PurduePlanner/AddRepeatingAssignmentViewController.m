//
//  AddRepeatingAssignmentViewController.m
//  PurduePlanner
//
//  Created by Aaron Peters on 5/5/14.
//  Copyright (c) 2014 Aaron Peters. All rights reserved.
//

#import "AddRepeatingAssignmentViewController.h"

@interface AddRepeatingAssignmentViewController ()

@end

@implementation AddRepeatingAssignmentViewController{
    NSArray *daysOfWeek;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    daysOfWeek = @[@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"];    
    [_dayPickerView selectRow:_dayOfWeek inComponent:0 animated:YES];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}

- (IBAction)saveAssignment:(id)sender
{
    int day = [_dayPickerView selectedRowInComponent:0];
    [self saveDataToAssignmentsWithName:_assignmentTextField.text andDay:day];
    
    if (day == _dayOfWeek)
        [_delegate addDataToA:_assignmentTextField.text];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIPickerView Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [daysOfWeek count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [daysOfWeek objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    //Here, like the table view you can get the each section of each row if you've multiple sections
    //NSLog(@"Selected Color: %@. Index of selected color: %i", [arrayColors objectAtIndex:row], row);
    
    //Now, if you want to navigate then;
    // Say, OtherViewController is the controller, where you want to navigate:
    
}

#pragma mark - SQLite3 methods

- (void)saveDataToAssignmentsWithName:(NSString *)assignment andDay:(int)day
{
    sqlite3_stmt    *statement;
    const char *dbpath = [_assignmentsDatabasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_assignmentsDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO ASSIGNMENTS (assignment, day) VALUES (\"%@\", \"%d\")",
                               assignment, day];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_assignmentsDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"%@", @"Added assignment with success");
        } else {
            NSLog(@"%@", @"Failed to add contact");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_assignmentsDB);
    }
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

@end
