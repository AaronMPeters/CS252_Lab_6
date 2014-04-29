//
//  WeekViewController.h
//  PurduePlanner
//
//  Created by Aaron Peters on 4/26/14.
//  Copyright (c) 2014 Aaron Peters. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#include "ViewTVC.h"

@interface WeekViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableDictionary *daysAndAssignments;
@property (nonatomic) int start_date;
@property (nonatomic) int start_month;

@end
