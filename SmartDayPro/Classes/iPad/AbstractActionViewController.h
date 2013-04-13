//
//  AbstractActionViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 4/10/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;
@class MovableView;
@class ContentView;
@class AbstractMonthCalendarView;
@class FocusView;
@class MiniMonthView;

@class CalendarViewController;
@class SmartListViewController;
@class NoteViewController;
@class CategoryViewController;

@interface AbstractActionViewController : UIViewController
{
    ContentView *contentView;
    
    MovableView *activeView;
    
    Task *actionTask;
    Task *actionTaskCopy;
}

@property (nonatomic, retain) Task *task2Link;

@property (nonatomic, readonly) ContentView *contentView;

- (CalendarViewController *) getCalendarViewController;
- (SmartListViewController *) getSmartListViewController;
- (NoteViewController *) getNoteViewController;
- (CategoryViewController *) getCategoryViewController;
- (AbstractMonthCalendarView *)getMonthCalendarView;
- (FocusView *) getFocusView;
- (MiniMonthView *) getMiniMonth;

- (void) updateTask:(Task *)task withTask:(Task *)taskCopy;
- (void) changeItem:(Task *)task;

- (void) convertRE2Task:(NSInteger)option task:(Task *)task;
- (void) convert2Task:(Task *)task;
- (void) changeTime:(Task *)task time:(NSDate *)time;

@end
