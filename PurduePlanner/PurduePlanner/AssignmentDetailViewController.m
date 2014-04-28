//
//  AssignmentDetailViewController.m
//  PurduePlanner
//
//  Created by Aaron Peters on 4/27/14.
//  Copyright (c) 2014 Aaron Peters. All rights reserved.
//

#import "AssignmentDetailViewController.h"

@interface AssignmentDetailViewController ()
@property (weak, nonatomic) IBOutlet UITextField *assignmentDescriptionTextField;
@property (weak, nonatomic) IBOutlet UIButton *editAssignmentButton;
@property (weak, nonatomic) IBOutlet UISwitch *completeSwitch;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *deleteAssignmentButton;

@end

@implementation AssignmentDetailViewController

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
    // Do any additional setup after loading the view.
}

- (IBAction)editAssignmentButtonDidPress:(id)sender
{
    
}

- (IBAction)deleteButtonDidPress:(id)sender
{
    
}

@end
