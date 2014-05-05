//
//  SettingsViewController.h
//  PurduePlanner
//
//  Created by Aaron Peters on 4/30/14.
//  Copyright (c) 2014 Aaron Peters. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

#include <Parse/Parse.h>
#include "RepeatingAssignmentsTVC.h"

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *settingsDB;
@property (strong, nonatomic) NSString *assignmentsDatabasePath;
@property (nonatomic) sqlite3 *assignmentsDB;

@property (strong, nonatomic) NSMutableDictionary *daysAndAssignments;

- (IBAction)saveData:(id)sender;

@end
