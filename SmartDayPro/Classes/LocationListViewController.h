//
//  LocationListViewController.h
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 10/25/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;

@interface LocationListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    UILabel *hintLable;
	UITableView *locationsTableView;
    NSMutableArray *locationList;
    
    //Task *taskEdit;
}

@property (nonatomic, retain) NSMutableArray *locationList;
//@property (nonatomic, assign) Project *project;
//@property (nonatomic, assign) Task *task;
@property (nonatomic, assign) Task *taskEdit;

@end
