//
//  PlannerFirstViewController.m
//  PurduePlanner
//
//  Created by Aaron Peters on 4/22/14.
//  Copyright (c) 2014 Aaron Peters. All rights reserved.
//

#import "PlannerFirstViewController.h"
#import <Parse/Parse.h>

@interface PlannerFirstViewController ()

@end

@implementation PlannerFirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addAssignment];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addAssignment
{
    PFObject *gameScore = [PFObject objectWithClassName:@"GameScore"];
    gameScore[@"score"] = @1337;
    gameScore[@"playerName"] = @"Sean Plott";
    gameScore[@"cheatMode"] = @NO;
    [gameScore saveInBackground];
    
    
    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    testObject[@"foo"] = @"bar";
    [testObject saveInBackground];
}


@end
