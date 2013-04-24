//
//  AbstractSDViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 12/4/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AbstractActionViewController.h"

@class Task;

@class ContentView;
@class MiniMonthView;
@class FocusView;
@class MovableView;
@class TaskView;
@class NoteView;
@class PlanView;

@class PageAbstractViewController;
/*@class CalendarViewController;
@class SmartListViewController;
@class NoteViewController;
@class CategoryViewController;
*/
@interface AbstractSDViewController : AbstractActionViewController
{
    //ContentView *contentView;

    UIView *optionView;
    UIImageView *optionImageView;    
    
    MiniMonthView *miniMonthView;
    FocusView *focusView;
    
    //MovableView *activeView;
    
    PageAbstractViewController *viewCtrlers[4];
}

//@property (nonatomic, retain) Task *task2Link;

@property (nonatomic, readonly) MiniMonthView *miniMonthView;
@property (nonatomic, readonly) FocusView *focusView;
@property (nonatomic, readonly) ContentView *contentView;

/*
- (CalendarViewController *) getCalendarViewController;
- (SmartListViewController *) getSmartListViewController;
- (NoteViewController *) getNoteViewController;
- (CategoryViewController *) getCategoryViewController;
*/

- (void) refreshView;
- (void) setNeedsDisplay;
- (void) resetAllData;
- (void) refreshData;
- (void) hideDropDownMenu;
- (void) hidePopover;
- (void) hidePreview;
- (void) deselect;
- (void) scrollToDate:(NSDate *)date;
- (void) jumpToDate:(NSDate *)date;
- (void) applyFilter;
//- (Task *) getActiveTask;

- (void) enableActions:(BOOL)enable onView:(MovableView *)view;
- (void) enableCategoryActions:(BOOL)enable onView:(PlanView *)view;

//- (void) editItem:(Task *)item;
//- (void) editItem:(Task *)item inRect:(CGRect)inRect;
//- (void) editItem:(Task *)item inView:(TaskView *)inView;
- (void) starTaskInView:(TaskView *)taskView;
- (void) markDoneTaskInView:(TaskView *)view;

//- (void) deleteTask;
//- (void) copyTask;
//- (void) markDoneTask;
//-(void) createTaskFromNote:(Task *)fromNote;

- (void) deleteCategory;
- (void) copyCategory;

//- (void) copyLink;
//- (void) pasteLink;

- (NSString *) showTaskWithOption:(id)sender;
- (NSString *) showNoteWithOption:(id)sender;
- (NSString *) showProjectWithOption:(id)sender;

- (void) autoPush;
- (void) backup;
- (void) sync;

@end
