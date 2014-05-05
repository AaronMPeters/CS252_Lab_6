//
//  SettingsViewController.m
//  PurduePlanner
//
//  Created by Aaron Peters on 4/30/14.
//  Copyright (c) 2014 Aaron Peters. All rights reserved.
//

#import "SettingsViewController.h"

#define NUM_DAYS_IN_WEEK 7

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *majorTextField;
@property (weak, nonatomic) IBOutlet UITextField *yearTextField;
@property (weak, nonatomic) IBOutlet UITableView *assignmentTable;
@end

@implementation SettingsViewController{
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
    
    //_daysAndAssignments = [[NSMutableDictionary alloc] init];
    
    [self createOrAccessSettingsDatabase];
    [self createOrAccessAssignmentsDatabase];
    //[self saveDataToAssignmentsWithName:@"Test2" andDay:0];
    //[self updateFromAssignmentsWithName:@"Test2" andDay:0 withNewName:@"Hello World" andNewDay:6];
    /*for (int i = 0; i < NUM_DAYS_IN_WEEK; i++) {
        //[self saveDataToAssignmentsWithName:[NSString stringWithFormat:(@"TestDay: %d"), i] andDay:i];
        [self findFromAssignmentsWithDay:i];
    }*/
    //NSLog(@"%@", _daysAndAssignments);
    //[self findFromAssignmentsWithDay:0];
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        [currentUser refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            NSLog(@"Logged in with userID of %@ and name of %@", currentUser.objectId, currentUser[@"name"]);
            [self findContactFromSettingsWithName:currentUser[@"name"]];
        }];
    } else {
        NSLog(@"%@", @"Not logged in");
        [PFUser logInWithUsernameInBackground:@"peter177" password:@"PSSWRD"
                                        block:^(PFUser *user, NSError *error) {
                                            if (user) {
                                                NSLog(@"%@", @"Now logged in");
                                            } else {
                                                NSLog(@"%@", @"Error logging in");
                                            }
                                        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    _daysAndAssignments = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < NUM_DAYS_IN_WEEK; i++) {
        //[self saveDataToAssignmentsWithName:[NSString stringWithFormat:(@"TestDay: %d"), i] andDay:i];
        [self findFromAssignmentsWithDay:i];
    }
}

- (IBAction)assignmentDescriptionDidEnd:(id)sender
{
}

#pragma mark - SQLite3 methods for Settings DB

- (void)createOrAccessSettingsDatabase
{
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    _databasePath = [[NSString alloc]
                     initWithString: [docsDir stringByAppendingPathComponent:
                                      @"settings2.db"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: _databasePath ] == NO)
    {
        const char *dbpath = [_databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &_settingsDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt =
            "CREATE TABLE IF NOT EXISTS SETTINGS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, MAJOR TEXT, YEAR TEXT)";
            
            if (sqlite3_exec(_settingsDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"%@", @"Failed to create table");
            }
            else
            {
                NSLog(@"%@", @"Successfully created table");
            }
            sqlite3_close(_settingsDB);
        } else {
            NSLog(@"%@", @"Failed to open/create database");
        }
    }
    else
    {
        NSLog(@"%@", @"Table already exists. Status OK");
    }
}

- (IBAction)saveData:(id)sender
{
    [self saveDataToSettings];
}

- (void)saveDataToSettings
{
    sqlite3_stmt    *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_settingsDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO SETTINGS (name, major, year) VALUES (\"%@\", \"%@\", \"%@\")",
                               _nameTextField.text, _majorTextField.text, _yearTextField.text];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_settingsDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"%@", @"Contact added");
            _nameTextField.text = @"";
            _majorTextField.text = @"";
            _yearTextField.text = @"";
        } else {
            NSLog(@"%@", @"Failed to add contact");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_settingsDB);
    }
}

- (void)findContactFromSettingsWithName:(NSString *)name
{
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &_settingsDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT major, year FROM settings WHERE name=\"%@\"",
                              name];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_settingsDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *majorField = [[NSString alloc]
                                          initWithUTF8String:
                                          (const char *) sqlite3_column_text(
                                                                             statement, 0)];
                _majorTextField.text = majorField;
                NSString *yearField = [[NSString alloc]
                                        initWithUTF8String:(const char *)
                                        sqlite3_column_text(statement, 1)];
                _yearTextField.text = yearField;
                _nameTextField.text = name;
                NSLog(@"%@", @"Match Found");
            } else {
                NSLog(@"%@", @"Match Not Found");
                _yearTextField.text = @"";
                _majorTextField.text = @"";
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(_settingsDB);
    }
}

#pragma mark - SQLite3 methods for Assignments DB

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

- (void)findFromAssignmentsWithDay:(int)day
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
        NSString *strFromInt = [NSString stringWithFormat:@"%d",day];
        [_daysAndAssignments setObject:temp forKey:strFromInt];
        //NSLog(@"%@", _daysAndAssignments);
        if (day == NUM_DAYS_IN_WEEK - 1)
            [self.assignmentTable reloadData];
    }
}

- (void)updateFromAssignmentsWithName:(NSString *)assignment andDay:(int)day withNewName:(NSString *)newAssignment andNewDay:(int)newDay
{
    sqlite3_stmt    *statement;
    const char *dbpath = [_assignmentsDatabasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_assignmentsDB) == SQLITE_OK)
    {
        
        NSString *updateSQL = [NSString stringWithFormat:
                               @"UPDATE assignments SET assignment=\"%@\", day=\"%d\" WHERE assignment=\"%@\" AND day=\"%d\"", newAssignment, newDay, assignment, day];
                               /*UPDATE Customers
                               SET ContactName='Alfred Schmidt', City='Hamburg'
                               WHERE CustomerName='Alfreds Futterkiste';
                               @"INSERT INTO ASSIGNMENTS (assignment, day) VALUES (\"%@\", \"%d\")",
                               assignment, day];*/
        
        const char *update_stmt = [updateSQL UTF8String];
        sqlite3_prepare_v2(_assignmentsDB, update_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"%@", @"Updated assignment with success");
        } else {
            NSLog(@"%@", @"Failed to update assignment");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_assignmentsDB);
    }
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
    return NUM_DAYS_IN_WEEK;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RepeatingAssignmentCell" forIndexPath:indexPath];
    cell.textLabel.text = [daysOfWeek objectAtIndex:indexPath.row];
    
    NSString *strFromInt = [NSString stringWithFormat:@"%d",indexPath.row];
    NSArray *array = [_daysAndAssignments objectForKey:strFromInt];
    strFromInt = [NSString stringWithFormat:@"%d",[array count]];
    cell.detailTextLabel.text = strFromInt;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Manage Repeating Assignments";
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueIdentifier = [segue identifier];
    NSIndexPath *indexPath = [self.assignmentTable indexPathForCell:sender];
    if([segueIdentifier isEqualToString:@"RepeatingAssignmentSegue"]){
        RepeatingAssignmentsTVC *detailController = (RepeatingAssignmentsTVC *)[segue destinationViewController];
        detailController.assignmentsDB = _assignmentsDB;
        detailController.assignmentsDatabasePath = _assignmentsDatabasePath;
        detailController.dayOfWeek = indexPath.row;
        NSString *strFromInt = [NSString stringWithFormat:@"%d",indexPath.row];
        detailController.title = [NSString stringWithFormat:(@"Manage %@"), [daysOfWeek objectAtIndex:indexPath.row]];
        detailController.assignmentArray = [_daysAndAssignments objectForKey:strFromInt];
    }
}


@end
