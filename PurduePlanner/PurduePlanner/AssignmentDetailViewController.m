//
//  AssignmentDetailViewController.m
//  PurduePlanner
//
//  Created by Aaron Peters on 4/27/14.
//  Copyright (c) 2014 Aaron Peters. All rights reserved.
//

#import "AssignmentDetailViewController.h"

@interface AssignmentDetailViewController ()

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
    [self getInfoFromServer];
    // Do any additional setup after loading the view.
}

- (IBAction)editAssignmentButtonDidPress:(id)sender
{
    PFQuery *query = [PFQuery queryWithClassName:@"Assignments"];
    [query getObjectInBackgroundWithId:_objectId block:^(PFObject *assignment, NSError *error) {
        assignment[@"assignment_name"] = _assignmentDescriptionTextField.text;
        assignment[@"due"] = [_datePicker date];
        int selected = _progressSegmentedControl.selectedSegmentIndex;
        if (selected)
            assignment[@"complete"] = @YES;
        else
            assignment[@"complete"] = @NO;
        [assignment saveInBackground];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (IBAction)deleteButtonDidPress:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Really Delete?" message:@"This action cannot be undone." delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel", nil];
    [alert show];
}

- (void)getInfoFromServer
{
    PFQuery *query = [PFQuery queryWithClassName:@"Assignments"];
    [query getObjectInBackgroundWithId:_objectId block:^(PFObject *assignment, NSError *error) {
        _assignmentDescriptionTextField.text = assignment[@"assignment_name"];
        _datePicker.date = assignment[@"due"];
        NSNumber *num = [NSNumber numberWithBool:[assignment[@"complete"] boolValue]];
        int i = [num intValue];
        [_progressSegmentedControl setSelectedSegmentIndex:i];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        PFQuery *query = [PFQuery queryWithClassName:@"Assignments"];
        [query getObjectInBackgroundWithId:_objectId block:^(PFObject *assignment, NSError *error) {
            [assignment delete];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

@end
