//
//  RepeatingAssignmentsTVC.h
//  PurduePlanner
//
//  Created by Aaron Peters on 5/5/14.
//  Copyright (c) 2014 Aaron Peters. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

#include "ManageRepeatingAssignmentViewController.h"
#include "AddRepeatingAssignmentViewController.h"

@interface RepeatingAssignmentsTVC : UITableViewController

@property (strong, nonatomic) NSMutableArray *assignmentArray;
@property (nonatomic) int dayOfWeek;
@property (strong, nonatomic) NSString *assignmentsDatabasePath;
@property (nonatomic) sqlite3 *assignmentsDB;

@end
