//
//  ViewTVC.h
//  PurduePlanner
//
//  Created by Aaron Peters on 4/23/14.
//  Copyright (c) 2014 Aaron Peters. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#include "AssignmentDetailViewController.h"

@interface ViewTVC : UITableViewController

@property (strong, nonatomic) NSMutableArray *assignments;
@property (strong, nonatomic) NSMutableArray *times;
@property (strong, nonatomic) NSMutableArray *completeStatuses;
@property (strong, nonatomic) NSMutableArray *ids;

@property (strong, nonatomic) NSMutableArray *assignmentsTmrw;
@property (strong, nonatomic) NSMutableArray *timesTmrw;
@property (strong, nonatomic) NSMutableArray *completeStatusesTmrw;
@property (strong, nonatomic) NSMutableArray *ids_tmrw;

+ (BOOL)isSameDayWithToday:(NSDate*)date1 due:(NSDate*)date2;
+ (BOOL)isLastDayofMonthWithDate:(NSDate*)date;
+ (BOOL)isLastDayofMonthWithDay:(int)date andMonth:(int)month;
+ (NSString *)getTimeRepresentationWithDate:(NSDate *)date;

@end
