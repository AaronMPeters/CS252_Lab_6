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
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        NSLog(@"Logged in with userID of %@", currentUser.objectId);
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
    [self createOrAccessDatabase];
    [self findContactWithName:@"Aaron Peters"];
}

- (IBAction)assignmentDescriptionDidEnd:(id)sender
{
    
}

#pragma mark - SQLite3 methods

- (void)createOrAccessDatabase
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
        
        if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt =
            "CREATE TABLE IF NOT EXISTS SETTINGS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, MAJOR TEXT, YEAR TEXT)";
            
            if (sqlite3_exec(_contactDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"%@", @"Failed to create table");
            }
            else
            {
                NSLog(@"%@", @"Successfully created table");
            }
            sqlite3_close(_contactDB);
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
    sqlite3_stmt    *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO SETTINGS (name, major, year) VALUES (\"%@\", \"%@\", \"%@\")",
                               _nameTextField.text, _majorTextField.text, _yearTextField.text];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_contactDB, insert_stmt,
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
        sqlite3_close(_contactDB);
    }
}

- (void)findContactWithName:(NSString *)name
{
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT major, year FROM settings WHERE name=\"%@\"",
                              name];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_contactDB,
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
                NSLog(@"%@", @"Match Found");
            } else {
                NSLog(@"%@", @"Match Not Found");
                _yearTextField.text = @"";
                _majorTextField.text = @"";
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(_contactDB);
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
    cell.detailTextLabel.text = @"0";
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Manage Repeating Assignments";
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
