//
//  ViewTVC.h
//  PurduePlanner
//
//  Created by Aaron Peters on 4/23/14.
//  Copyright (c) 2014 Aaron Peters. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewTVC : UITableViewController

@property (nonatomic) int num_rows;
@property (strong, nonatomic) NSMutableArray *assignments;
@property (nonatomic) NSConditionLock *lock;
@property (nonatomic) BOOL array_ready;

@end
