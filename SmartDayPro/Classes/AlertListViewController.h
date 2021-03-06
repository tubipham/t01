//
//  AlertListViewController.h
//  SmartCal
//
//  Created by MacBook Pro on 8/2/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;
//@class GuideWebView;

@interface AlertListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	UITableView *alertTableView;
	
	Task *taskEdit;
	
    UISegmentedControl *locationTypeSegmented;
    UILabel *etaLabel;
    
    BOOL isDone;
}

@property (nonatomic, assign) Task *taskEdit;
@property (nonatomic, retain) NSMutableArray *locationList;

@end
