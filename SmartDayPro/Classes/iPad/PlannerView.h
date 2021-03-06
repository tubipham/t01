//
//  PlannerView.h
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 3/11/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlannerHeaderView;
//@class PlannerWeekHeaderView;
@class PlannerMonthView;

@interface PlannerView : UIView {
    
    PlannerHeaderView *headerView;
    PlannerMonthView *monthView;
}
@property (nonatomic, readonly) PlannerHeaderView *headerView;
@property (nonatomic, readonly) PlannerMonthView *monthView;

- (void)shiftTime: (int) mode;
- (void) moveToPoint:(CGPoint) point;
- (void)goToday;
- (void)goToDate: (NSDate *) dt;

//- (void) changeFrame:(CGRect)frm;
- (void) switchView:(NSInteger)mode;
@end
