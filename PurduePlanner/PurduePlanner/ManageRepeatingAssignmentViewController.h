//
//  ManageRepeatingAssignmentViewController.h
//  PurduePlanner
//
//  Created by Aaron Peters on 5/5/14.
//  Copyright (c) 2014 Aaron Peters. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface ManageRepeatingAssignmentViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) NSString *assignmentsDatabasePath;
@property (nonatomic) sqlite3 *assignmentsDB;

@property (strong, nonatomic) NSArray *assignmentArray;
@property (strong, nonatomic) NSString *assignment;
@property (nonatomic) int dayOfWeek;

@property (weak, nonatomic) IBOutlet UITextField *assignmentTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *dayPickerView;

@end
