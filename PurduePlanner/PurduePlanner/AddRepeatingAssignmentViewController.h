//
//  AddRepeatingAssignmentViewController.h
//  PurduePlanner
//
//  Created by Aaron Peters on 5/5/14.
//  Copyright (c) 2014 Aaron Peters. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface AddRepeatingAssignmentViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *assignmentTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *dayPickerView;

@property (strong, nonatomic) NSString *assignmentsDatabasePath;
@property (nonatomic) sqlite3 *assignmentsDB;

@property (nonatomic) int dayOfWeek;

@end
