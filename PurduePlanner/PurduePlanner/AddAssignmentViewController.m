//
//  AddAssignmentViewController.m
//  PurduePlanner
//
//  Created by Aaron Peters on 4/26/14.
//  Copyright (c) 2014 Aaron Peters. All rights reserved.
//

#import "AddAssignmentViewController.h"

@interface AddAssignmentViewController ()

@property (weak, nonatomic) IBOutlet UIButton *addAssignmentButton;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextField *assignmentDescriptionTextField;

@end

@implementation AddAssignmentViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addAssignmentClick:(id)sender
{
    int len = (int)[[_assignmentDescriptionTextField text] length];
    if (len == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hang on..."
                                                        message:@"Please don't enter a blank assignment!"
                                                       delegate:nil
                                              cancelButtonTitle:@"Try Again"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [_assignmentDescriptionTextField resignFirstResponder];
    [self addAssignment];
}

- (IBAction)assignmentDescriptionDidEnd:(id)sender
{
    
}

- (void)resetUI
{
    _assignmentDescriptionTextField.text = @"";
    _datePicker.date = [NSDate date];
}

- (void)addAssignment
{
    PFObject *assignment = [PFObject objectWithClassName:@"Assignments"];
    assignment[@"assignment_name"] = [_assignmentDescriptionTextField text];
    assignment[@"due"] = [_datePicker date];
    assignment[@"complete"] = @NO;
    
#warning This should be the current user when in production:
    NSString *objectId = @"F9klQH1aRG";
    PFUser *user = [PFQuery getUserObjectWithId:objectId];
    assignment[@"user"] = user;
    
    //[assignment saveInBackground];
    [assignment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self resetUI];
        } else {
            // Log details of the failure
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops..."
                                                            message:@"It looks like there was a problem saving your assigment. Please try again later."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
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
