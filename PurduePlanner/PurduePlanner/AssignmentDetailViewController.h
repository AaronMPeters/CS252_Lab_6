//
//  AssignmentDetailViewController.h
//  PurduePlanner
//
//  Created by Aaron Peters on 4/27/14.
//  Copyright (c) 2014 Aaron Peters. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <Parse/Parse.h>

@interface AssignmentDetailViewController : UIViewController

@property (strong, nonatomic) NSString *objectId;
@property (weak, nonatomic) IBOutlet UITextField *assignmentDescriptionTextField;
@property (weak, nonatomic) IBOutlet UIButton *editAssignmentButton;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *deleteAssignmentButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *progressSegmentedControl;

@end
