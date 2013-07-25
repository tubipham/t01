//
//  AbstractActionViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 4/10/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "AbstractActionViewController.h"

#import "Common.h"
#import "Settings.h"
#import "Task.h"
#import "Project.h"

#import "SDWSync.h"
#import "TDSync.h"
#import "EKSync.h"
#import "EKReminderSync.h"

#import "TaskManager.h"
#import "TaskLinkManager.h"
#import "ProjectManager.h"
#import "DBManager.h"
#import "BusyController.h"
#import "TimerManager.h"

#import "TaskView.h"
#import "PlanView.h"
#import "ContentView.h"
#import "FocusView.h"
#import "MiniMonthView.h"
#import "PlannerBottomDayCal.h"

#import "CalendarViewController.h"
#import "SmartListViewController.h"
#import "CategoryViewController.h"
#import "NoteViewController.h"
#import "AbstractMonthCalendarView.h"

#import "TaskDetailTableViewController.h"
#import "TaskReadonlyDetailViewController.h"
#import "NoteDetailTableViewController.h"
#import "ProjectEditViewController.h"
#import "DetailViewController.h"
#import "iPadTagListViewController.h"
#import "CalendarSelectionTableViewController.h"
#import "TimerViewController.h"
#import "MenuTableViewController.h"
#import "SeekOrCreateViewController.h"

#import "SDNavigationController.h"

#import "SmartCalAppDelegate.h"
#import "PlannerViewController.h"
#import "PlannerMonthView.h"
#import "iPadViewController.h"

extern BOOL _isiPad;

BOOL _autoPushPending = NO;

extern iPadViewController *_iPadViewCtrler;

@interface AbstractActionViewController ()

@end

@implementation AbstractActionViewController
@synthesize contentView;

@synthesize popoverCtrler;

@synthesize actionTaskCopy;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    if (self = [super init])
    {
        activeView = nil;
        
        self.task2Link = nil;
        self.actionTaskCopy = nil;
        
        self.popoverCtrler = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(miniMonthResize:)
                                                     name:@"MiniMonthResizeNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(calendarDayReady:)
                                                     name:@"CalendarDayReadyNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reconcileLinks:)
                                                     name:@"LinkChangeNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(taskChanged:)
                                                     name:@"TaskCreatedNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(taskChanged:)
                                                     name:@"TaskChangeNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(eventChanged:)
                                                     name:@"EventChangeNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(noteChanged:)
                                                     name:@"NoteChangeNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(ekSyncComplete:)
                                                     name:@"EKSyncCompleteNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(ekReminderSyncComplete:)
                                                     name:@"EKReminderSyncCompleteNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tdSyncComplete:)
                                                     name:@"TDSyncCompleteNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sdwSyncComplete:)
                                                     name:@"SDWSyncCompleteNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadAlerts:)
                                                     name:@"AlertPostponeChangeNotification" object:nil];
        
    }
    
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.task2Link = nil;
    self.actionTaskCopy = nil;
    
    self.popoverCtrler = nil;    
    
    [super dealloc];
}


- (CalendarViewController *) getCalendarViewController
{
    return nil;
}

- (SmartListViewController *) getSmartListViewController
{
    return nil;
}

- (NoteViewController *) getNoteViewController
{
    return nil;
}

- (CategoryViewController *) getCategoryViewController
{
    return nil;
}

- (AbstractMonthCalendarView *)getMonthCalendarView
{
    return nil;
}

- (AbstractMonthCalendarView *)getPlannerMonthCalendarView
{
    return nil;
}

- (FocusView *) getFocusView
{
    return nil;
}

- (PlannerBottomDayCal *) getPlannerDayCalendarView
{
    return nil;
}

- (void) hidePopover
{
	if (self.popoverCtrler != nil && [self.popoverCtrler isPopoverVisible])
	{
		[self.popoverCtrler dismissPopoverAnimated:NO];
	}
	
}
-(void) deselect
{
    if (activeView != nil)
    {
        [CATransaction begin];
        [activeView doSelect:NO];
        [CATransaction commit];
    }

    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
    
    [self hidePopover];
    
    activeView = nil;
    
    /*
    PageAbstractViewController *ctrlers[4] = {
        [self getCalendarViewController],
        [self getSmartListViewController],
        [self getNoteViewController],
        [self getCategoryViewController]
    };
    
    for (int i=0; i<4; i++)
    {
        PageAbstractViewController *ctrler = ctrlers[i];
        
        [ctrler deselect];
    }*/
    
    [[self getCalendarViewController] deselect]; //remove outline if event is resized
}

- (Task *) getActiveTask
{
    if (activeView != nil && [activeView isKindOfClass:[MovableView class]])
    {
        return ((TaskView *) activeView).task;
    }
    
    return nil;
}

- (Project *) getActiveProject
{
    if (activeView != nil && [activeView isKindOfClass:[PlanView class]])
    {
        return ((PlanView *) activeView).project;
    }
    
    return nil;
}

- (BOOL) checkControllerActive:(NSInteger)index
{
    //0:Calendar, 1:Tasks, 2:Notes, 3:Projects
    return NO;
}

-(void)shrinkEnd
{
    if (optionView != nil && [optionView superview])
    {
        optionView.hidden = YES;
    }
}

- (void) hideDropDownMenu
{
	if (!optionView.hidden)
	{
        CGPoint p = optionView.frame.origin;
        p.x += optionView.frame.size.width/2;
        
		[Common animateShrinkView:optionView toPosition:p target:self shrinkEnd:@selector(shrinkEnd)];
	}
}

- (void) showOptionMenu
{
    BOOL menuVisible = !optionView.hidden;
    
    if (!menuVisible)
	{
		optionView.hidden = NO;
		[contentView  bringSubviewToFront:optionView];
		
        [Common animateGrowViewFromPoint:optionView.frame.origin toPoint:CGPointMake(optionView.frame.origin.x, optionView.frame.origin.y + optionView.bounds.size.height/2) forView:optionView];
	}
}

#pragma mark Refresh
- (void) setNeedsDisplay
{
    PageAbstractViewController *ctrlers[4] = {
        [self getCalendarViewController],
        [self getSmartListViewController],
        [self getNoteViewController],
        [self getCategoryViewController]
    };
    
    for (int i=0; i<4; i++)
    {
        PageAbstractViewController *ctrler = ctrlers[i];
        
        [ctrler setNeedsDisplay];
        
        if ([ctrler isKindOfClass:[CalendarViewController class]])
        {
            CalendarViewController *calCtrler = [self getCalendarViewController];
            [calCtrler refreshADEPane];
        }
        
    }
    
    FocusView *focusView = [self getFocusView];
    
    if (focusView != nil)
    {
        [focusView setNeedsDisplay];
    }
}

- (void) refreshView
{
    PageAbstractViewController *ctrlers[4] = {
        [self getCalendarViewController],
        [self getSmartListViewController],
        [self getNoteViewController],
        [self getCategoryViewController]
    };
    
    for (int i=0; i<4; i++)
    {
        PageAbstractViewController *ctrler = ctrlers[i];
        
        if ([ctrler respondsToSelector:@selector(refreshView)])
        {
            [ctrler refreshView];
        }
    }
    
    FocusView *focusView = [self getFocusView];
    
    if (focusView != nil)
    {
        [focusView refreshView];
    }
}

- (void) refreshData
{
    if ([self checkControllerActive:2])
    {
        NoteViewController *noteCtrler = [self getNoteViewController];
    
        [noteCtrler loadAndShowList];
    }
    
    if ([self checkControllerActive:3])
    {
        CategoryViewController *catCtrler = [self getCategoryViewController];
        
        [catCtrler loadAndShowList];
    }
    
    FocusView *focusView = [self getFocusView];
    
    if (focusView != nil && [focusView checkExpanded])
    {
        [focusView refreshData];
    }
    
    AbstractMonthCalendarView *calView = [self getMonthCalendarView];
    
    [calView refresh];
    
    PlannerMonthView *plannerCalView = (PlannerMonthView *)[self getPlannerMonthCalendarView];
    
    [plannerCalView refresh];
    [plannerCalView refreshOpeningWeek:nil];
    
    //PlannerBottomDayCal *planerDayCal = [self getPlannerDayCalendarView];
    //[planerDayCal refreshLayout];
}

- (void) resetAllData
{
    TaskManager *tm = [TaskManager getInstance];
    ProjectManager *pm = [ProjectManager getInstance];
    DBManager *dbm = [DBManager getInstance];
    Settings *settings = [Settings getInstance];
    
    [settings refreshTimeZone];
    
    [pm initProjectList:[dbm getProjects]];
    
    [tm initData];
    
    [[self getMiniMonth] initCalendar:[NSDate date]];
    
    [self refreshData];
    
    [_iPadViewCtrler refreshFilterStatus];
    
    self.task2Link = nil;
}

- (void) refreshADE
{
    AbstractMonthCalendarView *calView = [self getMonthCalendarView];
    AbstractMonthCalendarView *plannerCalView = [self getPlannerMonthCalendarView];
    
    [calView refreshADEView];
    [plannerCalView refreshADEView];
    
    [[self getCalendarViewController] refreshADEPane];
}

- (void) applyFilter
{
    TaskManager *tm = [TaskManager getInstance];
    
    NSDate *dt = [tm.today copy];
    
    [tm initCalendarData:dt];
    [tm initSmartListData];
    
    [dt release];

    /*
    [miniMonthView initCalendar:tm.today];
    
    NoteViewController *noteCtrler = [self getNoteViewController];
    [noteCtrler loadAndShowList];
    
    CategoryViewController *catCtrler = [self getCategoryViewController];
    [catCtrler loadAndShowList];
    */
    
    [self refreshData];
}

#pragma mark Top Toolbar Actions

- (void) showCategory
{
    [self hidePopover];
    
    CalendarSelectionTableViewController *ctrler = [[CalendarSelectionTableViewController alloc] init];
    
    self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:ctrler] autorelease];
    
    [ctrler release];
    
    
    CGRect frm = CGRectMake(100, 0, 20, 10);
    
    [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void) showTag
{
    [self hidePopover];
    
    iPadTagListViewController *ctrler = [[iPadTagListViewController alloc] init];
    
    self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:ctrler] autorelease];
    
    [ctrler release];
    
    CGRect frm = CGRectMake(180, 0, 20, 10);
    
    [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
}

- (void) showTimer
{
    TimerManager *timer = [TimerManager getInstance];
    
    Task *task = [self getActiveTask];
    
    if (task.original != nil && ![task isREException])
    {
        task = task.original;
    }
    
    [[task retain] autorelease];
    
    [self deselect];
    
    if (task != nil && [task isTask])
    {
        if (![timer checkActivated:task])
        {
            timer.taskToActivate = task;
        }
        
        //[self deselect];
    }
    else
    {
        Settings *settings = [Settings getInstance];
        
        Task *todo = [[[Task alloc] init] autorelease];
        
        todo.project = settings.taskDefaultProject;
        todo.name = _newItemText;
        todo.listSource = SOURCE_TIMER;
        
        timer.taskToActivate = todo;
    }
    
    TimerViewController *ctrler = [[TimerViewController alloc] init];
    
    self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:ctrler] autorelease];
    
    [ctrler release];
    
    CGRect frm = CGRectMake(370, 0, 20, 10);
    
    [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void) showSettingMenu
{
    MenuTableViewController *ctrler = [[MenuTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:ctrler] autorelease];
	[self.popoverCtrler setPopoverContentSize:CGSizeMake(250, 210)];
    
    [ctrler release];
    
    CGRect frm = CGRectMake(40, 0, 20, 10);
    
    [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

#pragma mark Action Menu
- (void)showActionMenu:(TaskView *)view
{
    Task *task = view.task;
    
    if ([task isShared])
    {
        return;
    }
    
    NSInteger pk = (task.original != nil && ![task isREException]?task.original.primaryKey:task.primaryKey);
    
    BOOL calendarTask = ([task isTask] && task.original != nil);
    
    contentView.actionType = calendarTask?ACTION_TASK_EDIT:([task isNote]?ACTION_NOTE_EDIT:ACTION_ITEM_EDIT);
    contentView.tag = pk;
    
    CGRect frm = view.frame;
    frm.origin = [view.superview convertPoint:frm.origin toView:contentView];
    
    UIMenuController *menuCtrler = [UIMenuController sharedMenuController];
    
    [contentView becomeFirstResponder];
    [menuCtrler setTargetRect:frm inView:contentView];
    [menuCtrler setMenuVisible:YES animated:YES];
}

- (void) enableActions:(BOOL)enable onView:(MovableView *)view
{
	if ([[BusyController getInstance] checkSyncBusy])
    {
        return;
    }
    
    BOOL showAction = activeView != view;
    
    [self deselect];
    
    if (showAction)
    {
        /*
        UIMenuController *menuCtrler = [UIMenuController sharedMenuController];
        
        if (enable)
        {
            [self performSelector:@selector(showActionMenu:) withObject:view afterDelay:0];
        }
        else
        {
            [menuCtrler setMenuVisible:NO animated:YES];
        }
        */
        
        activeView = enable?view:nil;
        
        if (activeView != nil)
        {
            [activeView doSelect:YES];
        }
    }
    else
    {
        activeView = nil;
    }
}

- (void)showProjectActionMenu:(PlanView *)view
{
    if ([view.project isShared])
    {
        return;
    }
    
    contentView.actionType = ACTION_CATEGORY_EDIT;
    
    CGRect frm = view.frame;
    frm.origin = [view.superview convertPoint:frm.origin toView:contentView];
    
    UIMenuController *menuCtrler = [UIMenuController sharedMenuController];
    
    [contentView becomeFirstResponder];
    [menuCtrler setTargetRect:frm inView:contentView];
    [menuCtrler setMenuVisible:YES animated:YES];
}

- (void) enableCategoryActions:(BOOL)enable onView:(PlanView *)view
{
	if ([[BusyController getInstance] checkSyncBusy])
    {
        return;
    }
    
    if (activeView != nil)
    {
        [activeView doSelect:NO];
    }
    
    if (activeView != view)
    {
        /*
        UIMenuController *menuCtrler = [UIMenuController sharedMenuController];
        
        if (enable)
        {
            [self performSelector:@selector(showProjectActionMenu:) withObject:view afterDelay:0];
        }
        else
        {
            [menuCtrler setMenuVisible:NO animated:YES];
        }*/
        
        activeView = enable?view:nil;
        
        if (activeView != nil)
        {
            [activeView doSelect:YES];
        }
    }
    else
    {
        activeView = nil;
    }
}


#pragma mark Views

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Seek&Create
- (void) showSeekOrCreate:(NSString *)text
{
    if (self.popoverCtrler != nil && ![self.popoverCtrler isPopoverVisible])
    {
        [self.popoverCtrler dismissPopoverAnimated:YES];
        
        self.popoverCtrler = nil;
    }
    
    if (self.popoverCtrler != nil && [self.popoverCtrler.contentViewController isKindOfClass:[SeekOrCreateViewController class]])
    {
        if ([text isEqualToString:@""])
        {
            [self.popoverCtrler dismissPopoverAnimated:YES];
        }
        else
        {
            SeekOrCreateViewController *ctrler = (SeekOrCreateViewController *) self.popoverCtrler.contentViewController;
            
            [ctrler search:text];
        }
    }
    else if (![text isEqualToString:@""])
    {
        [self.popoverCtrler dismissPopoverAnimated:NO];
        
        SeekOrCreateViewController *ctrler = [[SeekOrCreateViewController alloc] init];
        
        [ctrler search:text];
        
        self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:ctrler] autorelease];
        [self.popoverCtrler setPopoverContentSize:CGSizeMake(320, 440)];
        
        [ctrler release];
        
        CGRect frm = CGRectMake(600, 0, 20, 10);
        
        [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

- (void) createItem:(NSInteger)index title:(NSString *)title
{
    //[self.popoverCtrler dismissPopoverAnimated:NO];
    
    TaskManager *tm = [TaskManager getInstance];
    Settings *settings = [Settings getInstance];
    
    Task *task = [[[Task alloc] init] autorelease];
    task.name = title;
    task.listSource = SOURCE_NONE;
    
    //UIViewController *ctrler = nil;
    
    switch (index)
    {
        case 0:
        {
            task.type = TYPE_TASK;
            task.startTime = [settings getWorkingStartTimeForDate:tm.today];
            
            switch (tm.taskTypeFilter)
            {
                case TASK_FILTER_STAR:
                {
                    task.status = TASK_STATUS_PINNED;
                }
                    break;
                case TASK_FILTER_DUE:
                {
                    task.deadline = [settings getWorkingEndTimeForDate:tm.today];
                }
                    break;
            }
            
            /*
            TaskDetailTableViewController *taskCtrler = [[TaskDetailTableViewController alloc] init];
            taskCtrler.task = task;
            
            ctrler = taskCtrler;*/
        }
            break;
        case 1:
        {
            task.type = TYPE_EVENT;
            
            task.timeZoneId = [Settings findTimeZoneID:[NSTimeZone defaultTimeZone]];
            
            task.startTime = [Common dateByRoundMinute:15 toDate:tm.today];
            task.endTime = [Common dateByAddNumSecond:3600 toDate:task.startTime];
            
            /*
            TaskDetailTableViewController *taskCtrler = [[TaskDetailTableViewController alloc] init];
            taskCtrler.task = task;
            
            ctrler = taskCtrler;*/
        }
            break;
        case 2:
        {
            task.type = TYPE_NOTE;
            //task.listSource = SOURCE_NOTE;
            task.note = title;
            
            task.startTime = [Common dateByRoundMinute:15 toDate:tm.today];
            
            /*
            NoteDetailTableViewController *noteCtrler = [[NoteDetailTableViewController alloc] init];
            noteCtrler.note = task;
            
            ctrler = noteCtrler;*/
            
        }
            break;
    }
	
    /*
	SDNavigationController *navController = [[SDNavigationController alloc] initWithRootViewController:ctrler];
	[ctrler release];
	
	self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
	
	[navController release];
    
    CGRect frm = CGRectMake(600, 0, 20, 10);
    
    [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];*/
    
    [_iPadViewCtrler editItemDetail:task];
}

#pragma mark Edit
/*
- (void) editItem:(Task *)item
{
    if ([item isNote])
    {
        NoteDetailTableViewController *ctrler = [[NoteDetailTableViewController alloc] init];
        ctrler.note = item;
        
        [self.navigationController pushViewController:ctrler animated:YES];
        [ctrler release];
    }
    else
    {
        TaskDetailTableViewController *ctrler = [[TaskDetailTableViewController alloc] init];
        
        ctrler.task = item;
        
        [self.navigationController pushViewController:ctrler animated:YES];
        [ctrler release];
    }
}
*/
- (void) editItem:(Task *)item
{
    if (self.popoverCtrler != nil && [self.popoverCtrler.contentViewController isKindOfClass:[SDNavigationController class]])
    {
        if ([item isNote])
        {
            NoteDetailTableViewController *ctrler = [[NoteDetailTableViewController alloc] init];
            ctrler.note = item;
            
            [self.popoverCtrler.contentViewController pushViewController:ctrler animated:YES];
            [ctrler release];
        }
        else if ([item isShared])
        {
            TaskReadonlyDetailViewController *ctrler = [[TaskReadonlyDetailViewController alloc] init];
            
            ctrler.task = item;
            
            [self.popoverCtrler.contentViewController pushViewController:ctrler animated:YES];
            [ctrler release];
        }
        else
        {
            TaskDetailTableViewController *ctrler = [[TaskDetailTableViewController alloc] init];
            
            ctrler.task = item;
            
            [self.popoverCtrler.contentViewController pushViewController:ctrler animated:YES];
            [ctrler release];
        }
    }
    else
    {
        if ([item isNote])
        {
            NoteDetailTableViewController *ctrler = [[NoteDetailTableViewController alloc] init];
            ctrler.note = item;
            
            [self.navigationController pushViewController:ctrler animated:YES];
            [ctrler release];
        }
        else if ([item isShared])
        {
            TaskReadonlyDetailViewController *ctrler = [[TaskReadonlyDetailViewController alloc] init];
            
            ctrler.task = item;
            
            [self.popoverCtrler.contentViewController pushViewController:ctrler animated:YES];
            [ctrler release];
        }
        else
        {
            TaskDetailTableViewController *ctrler = [[TaskDetailTableViewController alloc] init];
            
            ctrler.task = item;
            
            [self.navigationController pushViewController:ctrler animated:YES];
            [ctrler release];
        }

    }
}

- (void) editItem:(Task *)task inRect:(CGRect)inRect
{
    if (!_isiPad)
    {
        [self editItem:task];
        
        return;
    }
    
    [self.popoverCtrler dismissPopoverAnimated:NO];
    
    UIViewController *ctrler = nil;
    
    if ([task isNote])
    {
        NoteDetailTableViewController *noteCtrler = [[NoteDetailTableViewController alloc] init];
        noteCtrler.note = task;
        
        ctrler = noteCtrler;
    }
    else if ([task isShared])
    {
        TaskReadonlyDetailViewController *taskCtrler = [[TaskReadonlyDetailViewController alloc] init];
        
        taskCtrler.task = task;
        
        ctrler = taskCtrler;
    }
    else
    {
        TaskDetailTableViewController *taskCtrler = [[TaskDetailTableViewController alloc] init];
        taskCtrler.task = task;
        
        ctrler = taskCtrler;
    }
    
	SDNavigationController *navController = [[SDNavigationController alloc] initWithRootViewController:ctrler];
	[ctrler release];
	
	self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
	
	[navController release];
    
    //[self.popoverCtrler presentPopoverFromRect:inRect inView:contentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    if (task.listSource == SOURCE_PLANNER_CALENDAR) {
        if (inRect.origin.x <= ctrler.view.frame.size.width) {
            [self.popoverCtrler presentPopoverFromRect:inRect inView:contentView permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
        } else {
            [self.popoverCtrler presentPopoverFromRect:inRect inView:contentView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
        }
    } else {
        [self.popoverCtrler presentPopoverFromRect:inRect inView:contentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

/*
- (void) editItem:(Task *)item inView:(TaskView *)inView
{
    [self editItem:item];
}
*/

- (void) editItem:(Task *)item inView:(TaskView *)inView
{
    if (!_isiPad)
    {
        [self editItem:item];
        
        return;
    }
    
    /*
    UIViewController *editCtrler = nil;
    
    if ([item isNote])
    {
        NoteDetailTableViewController *ctrler = [[NoteDetailTableViewController alloc] init];
        
        ctrler.note = item;
        
        editCtrler = ctrler;
    }
    else if ([item isShared])
    {
        TaskReadonlyDetailViewController *ctrler = [[TaskReadonlyDetailViewController alloc] init];
        
        ctrler.task = item;
        
        editCtrler = ctrler;
    }
    else
    {
        TaskDetailTableViewController *ctrler = [[TaskDetailTableViewController alloc] init];
        
        ctrler.task = item;
        
        editCtrler = ctrler;
    }
	
    if (editCtrler != nil)
    {
        [self hidePopover];
        
        SDNavigationController *navController = [[SDNavigationController alloc] initWithRootViewController:editCtrler];
        [editCtrler release];
        
        self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
        
        [navController release];
        
        CGRect frm = [inView.superview convertRect:inView.frame toView:contentView];

        if (item.listSource == SOURCE_PLANNER_CALENDAR) {
            if (frm.origin.x <= editCtrler.view.frame.size.width) {
                [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
            } else {
                [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
            }
        } else {
            [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:item.listSource == SOURCE_CALENDAR || item.listSource == SOURCE_FOCUS?UIPopoverArrowDirectionLeft:UIPopoverArrowDirectionRight animated:YES];
        }
    }*/
    
    if (inView != nil)
    {
        [self enableActions:YES onView:inView]; //to make activeView not nil to do actions
    }
    
    [_iPadViewCtrler editItemDetail:item];
}

- (void) editCategory:(Project *) project
{
	ProjectEditViewController *ctrler = [[ProjectEditViewController alloc] init];
	
	ctrler.project = project;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

/*
- (void) editProject:(Project *)project inView:(PlanView *)inView
{
    [self editCategory:project];
}
*/
- (void) editProject:(Project *)project inView:(PlanView *)inView
{
    if (!_isiPad)
    {
        [self editCategory:project];
        
        return;
    }
    
    /*
    ProjectEditViewController *editCtrler = [[ProjectEditViewController alloc] init];
    editCtrler.project = project;
    
    SDNavigationController *navController = [[SDNavigationController alloc] initWithRootViewController:editCtrler];
    [editCtrler release];
    
    self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
    
    [navController release];
    
    CGRect frm = [inView.superview convertRect:inView.frame toView:contentView];
    
    [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    */
    
    [self enableCategoryActions:YES onView:inView]; //to make activeView not nil to do actions
    
    [_iPadViewCtrler editProjectDetail:project];
}

- (void) editProject:(Project *)project inRect:(CGRect)inRect
{
    if (!_isiPad)
    {
        [self editCategory:project];
        
        return;
    }
    
    ProjectEditViewController *editCtrler = [[ProjectEditViewController alloc] init];
    editCtrler.project = project;
    
    SDNavigationController *navController = [[SDNavigationController alloc] initWithRootViewController:editCtrler];
    [editCtrler release];
    
    self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
    
    [navController release];
    
    [self.popoverCtrler presentPopoverFromRect:inRect inView:contentView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    
}

#pragma mark Calendar Actions
- (void) scrollToDate:(NSDate *)date
{
    [self deselect];
    
    TaskManager *tm = [TaskManager getInstance];
    
    tm.today = date;
    
    MiniMonthView *mmView = [self getMiniMonth];
    
    if (mmView != nil)
    {
        [mmView highlight:date];
    }
    
    CalendarViewController *ctrler = [self getCalendarViewController];
    
    [ctrler refreshPanes];
}

- (void) jumpToDate:(NSDate *)date
{
    [self deselect];
    
    MiniMonthView *mmView = [self getMiniMonth];
    
    /*if (mmView != nil)
    {
        [mmView updateWeeks:date];
    }*/
    
    [[TaskManager getInstance] initCalendarData:date];

    if (mmView != nil)
    {
        [mmView highlight:date];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CalendarDayChangeNotification" object:nil]; //to refresh Calendar layout
}

#pragma mark Task Actions

- (void) reconcileItem:(Task *)item reSchedule:(BOOL)reSchedule
{
    CalendarViewController *calCtrler = [self getCalendarViewController];
    
    if (!reSchedule)
    {
        //don't need to refresh Calendar View and Task List when re-scheduling because they are refreshed when schedule is finished
        
        [calCtrler reconcileItem:item];
        
        SmartListViewController *taskCtrler = [self getSmartListViewController];
        
        [taskCtrler reconcileItem:item];
    }
    
    NoteViewController *noteCtrler = [self getNoteViewController];
    
    [noteCtrler reconcileItem:item];
    
    CategoryViewController *catCtrler = [self getCategoryViewController];
    
    [catCtrler reconcileItem:item];
    
    FocusView *focusView = [self getFocusView];
    
    if (focusView != nil)
    {
        [focusView reconcileItem:item];
    }
    
    AbstractMonthCalendarView *calView = [self getMonthCalendarView];
    AbstractMonthCalendarView *plannerCalView = [self getPlannerMonthCalendarView];

    [calView refresh];
    [plannerCalView refresh];
    [calCtrler refreshADEPane];
}

- (void) updateTask:(Task *)task withTask:(Task *)taskCopy
{
    TaskManager *tm = [TaskManager getInstance];
    
    // check Manual task on title
    //[taskCopy checkHasPinnedCharacterInTitle];
    //[taskCopy addAnchorInTitle];
    //BOOL isManual = [task isManual];
    
    actionTask = task;
    self.actionTaskCopy = taskCopy;
    
    BOOL reSchedule = NO;
    
    if (taskCopy.primaryKey == -1)
    {
        [task updateByTask:taskCopy];
        
        [tm addTask:task];
        
        reSchedule = YES;
    }
    else
    {
        BOOL reEdit = [task isREInstance];
        
        BOOL convertRE2Task = reEdit && [taskCopy isTask];
        
        if (convertRE2Task)
        {
            NSString *mss = [task isManual] ? _convertATaskIntoTaskConfirmation : _convertREIntoTaskConfirmation;
            NSString *headMss = [task isManual] ? _convertATaskIntoTaskHeader : _warningText;
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:headMss  message:mss delegate:self cancelButtonTitle:_cancelText otherButtonTitles:_onlyInstanceText, _allFollowingText, nil];
            
            alertView.tag = -13001;
            
            [alertView show];
            [alertView release];
            
            return;
        }
        else if (reEdit) //change RE
        {
            UIAlertView *changeREAlert= [[UIAlertView alloc] initWithTitle:_changeRETitleText  message:_changeREInstanceText delegate:self cancelButtonTitle:_cancelText otherButtonTitles:nil];
            changeREAlert.tag = -13000;
            [changeREAlert addButtonWithTitle:_onlyInstanceText];
            [changeREAlert addButtonWithTitle:_allEventsText];
            [changeREAlert addButtonWithTitle:_allFollowingText];
            [changeREAlert show];
            [changeREAlert release];
            
            return;
        }
        else
        {
            reSchedule = [tm updateTask:task withTask:taskCopy];
        }
    }
    // refresh smartlist
    /*if (isManual) {
        SmartListViewController *smartlistController = [self getSmartListViewController];
        [smartlistController refreshData];
    }*/
    
    [self reconcileItem:task reSchedule:reSchedule];
        
    [self deselect];
}

- (void) convertRE2Task:(NSInteger)option
{
    TaskManager *tm = [TaskManager getInstance];
    
    BOOL isADE = [actionTask isADE];
    
    Task *rt = [tm convertRE2Task:actionTask option:option];
    
    actionTaskCopy.primaryKey = rt.primaryKey;
    
    [tm updateTask:actionTask withTask:actionTaskCopy];
    
    MiniMonthView *mmView = [self getMiniMonth];
    
    if (mmView != nil)
    {
        [mmView refresh];
    }
    
    if (isADE)
    {
        [[self getCalendarViewController] refreshADEPane];
    }
}

- (void) deleteRE
{
    TaskManager *tm = [TaskManager getInstance];
    
    Task *task = [self getActiveTask];
    Task *rootRE = [tm findREByKey:task.primaryKey];
        
    [task retain];
    [rootRE retain];
    
    [self deselect];
    
    NSInteger pk = task.primaryKey;
    
    if (task.original != nil && ![task isREException])
    {
        pk = task.original.primaryKey;
    }
    
    if (pk == self.task2Link.primaryKey)
    {
        self.task2Link = nil;
    }
    
    if (rootRE != nil)
    {
        Task *instance = [[rootRE copy] autorelease];
        instance.original = rootRE;
        
        [tm deleteREInstance:instance deleteOption:2];

        [self reconcileItem:task reSchedule:YES];
    }
    
    [task release];
    [rootRE release];
}

-(void) deleteRE:(NSInteger)deleteOption
{
    Task *task = [self getActiveTask];

    [task retain];
        
    NSInteger pk = task.primaryKey;
    
    if (task.original != nil && ![task isREException])
    {
        pk = task.original.primaryKey;
    }
    
    if (pk == self.task2Link.primaryKey)
    {
        self.task2Link = nil;
    }
    
    [self deselect];
	
	[[TaskManager getInstance] deleteREInstance:task deleteOption:deleteOption];
    
    //CalendarViewController *calCtrler = [self getCalendarViewController];
    
    //[calCtrler refreshView];
    
    [self reconcileItem:task reSchedule:YES];
    
    [task release];
}

- (void) doDeleteTask
{
    TaskManager *tm = [TaskManager getInstance];
    
    Task *task = [self getActiveTask];

    [task retain];
    
    NSInteger pk = task.primaryKey;
    
    if (task.original != nil && ![task isREException])
    {
        pk = task.original.primaryKey;
    }
    
    if (pk == self.task2Link.primaryKey)
    {
        self.task2Link = nil;
    }

    [tm deleteTask:task];
    
    [self reconcileItem:task reSchedule:YES];
    
    [self deselect];
    
    [task release];
}

- (void) deleteTask
{
    Task *task = [self getActiveTask];
    
    if (task != nil)
    {
        if (task.primaryKey == -1 && task.original != nil && [task.original isRE]) //change RE
        {
            UIAlertView *deleteREAlert= [[UIAlertView alloc] initWithTitle:_deleteRETitleText  message:_deleteREInstanceText delegate:self cancelButtonTitle:_cancelText otherButtonTitles:nil];
            deleteREAlert.tag = -11000;
            [deleteREAlert addButtonWithTitle:_onlyInstanceText];
            [deleteREAlert addButtonWithTitle:_allEventsText];
            [deleteREAlert addButtonWithTitle:_allFollowingText];
            [deleteREAlert show];
            [deleteREAlert release];
        }
        else if ([[Settings getInstance] deleteWarning])
        {
            if ([task isRE])
            {
                UIAlertView *deleteREAlert= [[UIAlertView alloc] initWithTitle:_deleteRETitleText  message:_deleteAllInSeriesText delegate:self cancelButtonTitle:_cancelText otherButtonTitles:_okText, nil];
                deleteREAlert.tag = -12000;
                [deleteREAlert show];
                [deleteREAlert release];
            }
            else
            {
                NSString *msg = _itemDeleteText;
                NSInteger tag = -10000;
                
                UIAlertView *taskDeleteAlertView = [[UIAlertView alloc] initWithTitle:_itemDeleteTitle  message:msg delegate:self cancelButtonTitle:_cancelText otherButtonTitles:nil];
                
                taskDeleteAlertView.tag = tag;
                
                [taskDeleteAlertView addButtonWithTitle:_okText];
                [taskDeleteAlertView show];
                [taskDeleteAlertView release];
                
            }
        }
        else
        {
            [self doDeleteTask];
        }
    }
}

- (Task *) copyTask
{
    Task *ret = nil;
    
    Task *task = [self getActiveTask];
    
    if (task != nil)
    {
        [task retain];
        
        //CGRect frm = [activeView.superview convertRect:activeView.frame toView:contentView];
        
        [self deselect];
        
        Task *tmp = task;
        
        if (task.original != nil && ![task isREException])
        {
            tmp = task.original;
        }
        
        Task *taskCopy = [[tmp copy] autorelease];
        
        taskCopy.primaryKey = -1;
        taskCopy.name = ([tmp isNote]?taskCopy.name:[NSString stringWithFormat:@"%@ (copy)", taskCopy.name]);
        taskCopy.links = nil;
        taskCopy.listSource = tmp.listSource;
        
        if ([task isREException])
        {
            taskCopy.groupKey = -1;
            taskCopy.repeatData = nil;
            taskCopy.original = nil;
        }
        
        //[self editItem:taskCopy inRect:frm];
        
        [task release];
        
        ret = taskCopy;
    }
    
    return ret;
}

- (void) markDoneTask:(Task *)task
{
    AbstractMonthCalendarView *calView = [self getMonthCalendarView];
    AbstractMonthCalendarView *plannerCalView = [self getPlannerMonthCalendarView];
    
    TaskManager *tm = [TaskManager getInstance];
    
    NSDate *oldDeadline = [[task.deadline copy] autorelease];
    BOOL isRT = [task isRT];
    
    //[tm markDoneTask:task];
    /*NSDate *startTime = nil;
    if ([task isManual]) {
        startTime = [[task.startTime copy] autorelease];
    }*/
    
    if ([task isDone])
    {
        [tm unDone:task];
    }
    else
    {
        [tm markDoneTask:task];
    }
    
    /*if (startTime != nil) {
        [calView refreshCellByDate:startTime];
        // refresh planner day cal
        PlannerBottomDayCal *plannerDayCal = [self getPlannerDayCalendarView];
        [plannerDayCal refreshLayout];
    }*/
    
    if (oldDeadline != nil)
    {
        [calView refreshCellByDate:oldDeadline];
        [plannerCalView refreshCellByDate:oldDeadline];
        
        if ([Common daysBetween:oldDeadline sinceDate:tm.today] <= 0)
        {
            [[self getFocusView] refreshData];
        }
    }
    
    if ([self checkControllerActive:3])
    {
        CategoryViewController *ctrler = [self getCategoryViewController];
        
        if (ctrler.filterType == TYPE_TASK)
        {
            [ctrler loadAndShowList];
        }
    }
    
    if (isRT)
    {
        [calView refreshCellByDate:task.deadline];
        [plannerCalView refreshCellByDate:task.deadline];
    }
    
}

- (void) markDoneTask
{
    Task *task = [self getActiveTask];
    
    if (task != nil)
    {
        [task retain];
        
        [self deselect];
                
        [self markDoneTask:task];
        
        [task release];
    }
}

- (void) starTask
{
    Task *task = [self getActiveTask];
    
    if (task != nil)
    {
        [task retain];
        
        [self deselect];
        
        [[TaskManager getInstance] starTask:task];
        
        SmartListViewController *slViewCtrler = [self getSmartListViewController];
        
        [slViewCtrler setNeedsDisplay];
        
        CategoryViewController *ctrler = [self getCategoryViewController];
        
        if (task.listSource == SOURCE_CATEGORY)
        {
            [ctrler setNeedsDisplay];
            
            if ([self checkControllerActive:1])
            {
                [slViewCtrler refreshLayout];
            }
        }
        else if ([self checkControllerActive:3])
        {
            if (ctrler.filterType == TYPE_TASK)
            {
                [ctrler loadAndShowList];
            }
        }
        
        [task release];
    }
}

-(void) createTaskFromNote:(Task *)fromNote
{
    TaskManager *tm = [TaskManager getInstance];
    Settings *settings = [Settings getInstance];
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
    
    Task *note = fromNote != nil?fromNote:[self getActiveTask];
    
    if (note != nil)
    {
        [note retain];
        
        [self deselect];
        
        Task *task = [[Task alloc] init];
        
        task.startTime = [settings getWorkingStartTimeForDate:tm.today];
        
        switch (tm.taskTypeFilter)
        {
            case TASK_FILTER_STAR:
            {
                task.status = TASK_STATUS_PINNED;
            }
                break;
            case TASK_FILTER_DUE:
            {
                task.deadline = [settings getWorkingEndTimeForDate:tm.today];
            }
                break;
        }
        
        task.project = note.project;
        task.name = note.name;
        
        [tm addTask:task];
        
        NSInteger linkId = [tlm createLink:task.primaryKey destId:note.primaryKey];
        
        if (linkId != -1)
        {
            //edit in Category view
            task.links = [tlm getLinkIds4Task:task.primaryKey];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil]; //trigger sync for Link
        }
        
        [note release];
        
        [self reconcileItem:task reSchedule:YES];
    }
}

- (void) markDoneTaskInView:(TaskView *)view
{
    Task *task = view.task;
    
    AbstractMonthCalendarView *calView = [self getMonthCalendarView];
    
    AbstractMonthCalendarView *plannerCalView = [self getPlannerMonthCalendarView];
    
    [task retain];
    
    [self deselect];
    
    NSDate *oldDue = [[task.deadline copy] autorelease];
    BOOL isRT = [task isRT]; //note: task original could be removed from task list so need to store this information instead of directly call the method after done
    
    //BOOL isManual = [task isManual]; // for refesh minimonth
    
    TaskManager *tm = [TaskManager getInstance];
    
    if ([task isDone])
    {
        [tm unDone:task];
    }
    else
    {
        [tm markDoneTask:task];
    }
    
    if (oldDue != nil)
    {
        [calView refreshCellByDate:oldDue];
        [plannerCalView refreshCellByDate:oldDue];
        
        if ([Common daysBetween:oldDue sinceDate:tm.today] <= 0)
        {
            [[self getFocusView] refreshData];
        }
    }
    if ([self checkControllerActive:3])
    {
        CategoryViewController *ctrler = [self getCategoryViewController];
        
        if (ctrler.filterType == TYPE_TASK)
        {
            [ctrler loadAndShowList];
        }
    }
    
    if (isRT)
    {
        [calView refreshCellByDate:task.deadline];
        [plannerCalView refreshCellByDate:task.deadline];
        
        [view setNeedsDisplay];
    }
    
    /*if (isManual) {
        [calView refresh];
    }*/
    
    [task release];
}

- (void) starTaskInView:(TaskView *)taskView
{
	TaskManager *tm = [TaskManager getInstance];
	
	Task *task = taskView.task;
    
    [tm starTask:task];
    
    SmartListViewController *slViewCtrler = [self getSmartListViewController];
    
    [slViewCtrler setNeedsDisplay];
    
    /*
    CategoryViewController *catViewCtrler = [self getCategoryViewController];
    
    [catViewCtrler setNeedsDisplay];
    */
    CategoryViewController *ctrler = [self getCategoryViewController];

    if (task.listSource == SOURCE_CATEGORY)
    {
        [ctrler setNeedsDisplay];
        
        if ([self checkControllerActive:1])
        {
            [slViewCtrler refreshLayout];
        }
    }
    else if ([self checkControllerActive:3])
    {
        if (ctrler.filterType == TYPE_TASK)
        {
            [ctrler loadAndShowList];
        }
    }    
}

- (void) convertRE2Task:(NSInteger)option task:(Task *)task
{
    TaskManager *tm = [TaskManager getInstance];
    
    [tm convertRE2Task:task option:option];
    
    MiniMonthView *mmView = [self getMiniMonth];
    
    if (mmView != nil)
    {
        [mmView refresh];
    }
    
    PlannerBottomDayCal *plannerDayCal = [self getPlannerDayCalendarView];
    [plannerDayCal refreshLayout];
    
    [self reconcileItem:task reSchedule:YES];
}

- (void) convert2Task:(Task *)task
{
    Task *taskCopy = [[task copy] autorelease];
    
    taskCopy.type = TYPE_TASK;
    
    if (task.original != nil && ![task isREException])
    {
        task = task.original;
    }
    
    // check if this is STask
    if ([taskCopy isManual]) {
        [taskCopy setManual:NO];
    }
    
    TaskManager *tm = [TaskManager getInstance];
    
    [tm updateTask:task withTask:taskCopy];
        
    PlannerBottomDayCal *plannerDayCal = [self getPlannerDayCalendarView];
    [plannerDayCal refreshLayout];
    
    [self reconcileItem:task reSchedule:YES];
}

- (void) changeTime:(Task *)task time:(NSDate *)time
{
    TaskManager *tm = [TaskManager getInstance];
    
    [tm moveTime:[Common copyTimeFromDate:time toDate:tm.today] forEvent:task];
    
    [self reconcileItem:task reSchedule:YES];
}

-(void) changeTask:(Task *)task toProject:(NSInteger)prjKey
{
    TaskManager *tm = [TaskManager getInstance];
    DBManager *dbm = [DBManager getInstance];
    
    Task *slTask = [tm getTask2Update:task];
    
    if (slTask != nil)
    {
        slTask.project = prjKey;
        
        [slTask updateIntoDB:[dbm getDatabase]];
        
        NSMutableArray *list = [tm findScheduledTasks:slTask];
        
        for (Task *tmp in list)
        {
            tmp.project = prjKey;
        }
        
        [tm refreshTopTasks];
        [self setNeedsDisplay];
       
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
    }
    
    
    task.project = prjKey;
    
    [self reconcileItem:task reSchedule:NO];
}

-(void)quickAddEvent:(NSString *)name startTime:(NSDate *)startTime
{
	//////printf("quick add - %s, start: %s\n", [name UTF8String], [[startTime description] UTF8String]);
	
	Task *event = [[Task alloc] init];
	
	event.name = name;
	event.startTime = startTime;
	event.endTime = [Common dateByAddNumSecond:3600 toDate:event.startTime];
	
	event.type = TYPE_EVENT;
	
	[[TaskManager getInstance] addTask:event];
	    
    MiniMonthView *mmView = [self getMiniMonth];
	
    [mmView.calView refreshCellByDate:startTime];
	
	[self reconcileItem:event reSchedule:YES];
    
    [event release];
}

- (void) quickAddProject:(NSString *)name
{
    ProjectManager *pm = [ProjectManager getInstance];
    
    Project *project = [[Project alloc] init];
    project.name = name;
    project.type = TYPE_PLAN;
    
    [pm addProject:project];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EventChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
    
    CategoryViewController *ctrler = [self getCategoryViewController];
    
    [ctrler loadAndShowList];
    
    [project release];
}

- (void) quickAddItem:(NSString *)name type:(NSInteger)type
{
	TaskManager *tm = [TaskManager getInstance];
    Settings *settings = [Settings getInstance];

    Task *task = [[Task alloc] init];
    task.type = type;
    task.name = name;
    task.duration = tm.lastTaskDuration;
    task.project = tm.lastTaskProjectKey;
    
    task.startTime = type==TYPE_TASK? [settings getWorkingStartTimeForDate:tm.today]:[Common dateByRoundMinute:15 toDate:tm.today];
    task.endTime = [Common dateByAddNumSecond:3600 toDate:task.startTime];
    
    switch (tm.taskTypeFilter)
    {
        case TASK_FILTER_STAR:
        {
            task.status = TASK_STATUS_PINNED;
        }
            break;
        case TASK_FILTER_DUE:
        {
            task.deadline = [settings getWorkingEndTimeForDate:tm.today];
        }
            break;
    }
    
    [tm addTask:task];
    
    [self reconcileItem:task reSchedule:(type != TYPE_NOTE)];
    
    [task release];
}

- (void) moveTask2Top
{
    Task *task = [self getActiveTask];
    
    if (task != nil)
    {
        [task retain];
        
        [self deselect];
        
        [[TaskManager getInstance] moveTask2Top:task];
        
        if ([self checkControllerActive:3])
        {
            CategoryViewController *ctrler = [self getCategoryViewController];
            
            if (ctrler.filterType == TYPE_TASK)
            {
                [ctrler loadAndShowList];
            }
        }
        
        [task release];
    }
}

- (void) defer:(NSInteger)option
{
    Task *task = [self getActiveTask];
    
    if (task != nil)
    {
        [task retain];
        
        [self deselect];
        
        [[TaskManager getInstance] defer:task deferOption:option];
        
        if ([self checkControllerActive:3])
        {
            CategoryViewController *ctrler = [self getCategoryViewController];
            
            if (ctrler.filterType == TYPE_TASK)
            {
                [ctrler loadAndShowList];
            }
        }        
        
        [task release];
    }
}

- (void) deleteNote:(Task *)note
{
    DBManager *dbm = [DBManager getInstance];
    
    [note deleteFromDatabase:[dbm getDatabase]];
    
    [self reconcileItem:note reSchedule:NO];
}

#pragma mark Project Actions
- (void) doDeleteCategory:(BOOL) cleanFromDB
{
    Project *plan = [self getActiveProject];
    
    MiniMonthView *mmView = [self getMiniMonth];
    
	if (plan != nil)
	{
        TaskManager *tm = [TaskManager getInstance];
        
		[[ProjectManager getInstance] deleteProject:plan cleanFromDB:cleanFromDB];
		[tm initData];
		
        if (mmView != nil)
        {
            [mmView initCalendar:tm.today];
        }

		[self refreshData];
        
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EventChangeNotification" object:nil];
	}
    
    [self deselect];
}

- (void) deleteCategory
{
    Project *project = [self getActiveProject];
    
    if (project != nil)
    {
		if ([[Settings getInstance] taskDefaultProject] == project.primaryKey)
		{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_deleteWarningText message:_cannotDeleteDefaultProjectText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
			
			[alertView show];
			[alertView release];
		}
		else
		{
            UIActionSheet *deleteActionSheet = [[UIActionSheet alloc] initWithTitle:_deleteCategoryWarningText delegate:self cancelButtonTitle:_cancelText destructiveButtonTitle:_deleteText otherButtonTitles: nil];
            
            [deleteActionSheet showInView:contentView];
            
            [deleteActionSheet release];
		}
    }
}

- (Project *) copyCategory
{
    Task *ret = nil;
    
    Project *plan = [self getActiveProject];
    
	if (plan != nil)
	{
        Project *planCopy = [[plan copy] autorelease];
        
        //CGRect frm = [activeView.superview convertRect:activeView.frame toView:contentView];
        
        [self deselect];
        
        planCopy.name = [NSString stringWithFormat:@"%@ (copy)", plan.name];
        planCopy.primaryKey = -1;
        planCopy.ekId = @"";
        planCopy.tdId = @"";
        
        ret = planCopy;
        
        //[self editProject:planCopy inRect:frm];
	}
    
    return ret;
}


#pragma mark Link Actions
- (void) copyLink
{
    Task *task = [self getActiveTask];
    
    if (task.original != nil && ![task isREException])
    {
        self.task2Link = task.original;
    }
    else
    {
        self.task2Link = task;
    }
    
    [self deselect];
}

- (void) pasteLink
{
    Task *task = [self getActiveTask];
    
    task = (task.original != nil && ![task isREException])?task.original:task;
    
    [task retain];
    
    [self deselect];
    
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
    
    int linkId = [tlm createLink:task.primaryKey destId:self.task2Link.primaryKey];
    
    if (linkId != -1)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil]; //trigger sync for Link
    }
    
    [task release];
}

- (void)reconcileLinks:(NSNotification *)notification
{
    TaskManager *tm = [TaskManager getInstance];
    
    [tm reconcileLinks:notification.userInfo];
    
    PageAbstractViewController *ctrlers[4] = {
        [self getCalendarViewController],
        [self getSmartListViewController],
        [self getNoteViewController],
        [self getCategoryViewController]
    };
    
    for (int i=0; i<4; i++)
    {
        PageAbstractViewController *ctrler = ctrlers[i];
        
        [ctrler reconcileLinks:notification.userInfo];
        
        [ctrler setNeedsDisplay];
    }
    
    // refresh link icons in Planner Day Cal
    PlannerBottomDayCal *plannerDayCal = [self getPlannerDayCalendarView];
    if (plannerDayCal != nil) {
        [plannerDayCal reconcileLinks:notification.userInfo];
        [plannerDayCal setNeedsDisplay];
    }
    
    // refresh link planner month view
    PlannerMonthView *plannerMonthView = (PlannerMonthView *)[self getPlannerMonthCalendarView];
    if (plannerMonthView != nil) {
        [plannerMonthView reconcileLinks:notification.userInfo];
    }
    
    FocusView *focusView = [self getFocusView];
    
    if (focusView != nil)
    {
        [focusView reconcileLinks:notification.userInfo];
        
        [focusView setNeedsDisplay];
    }
}

#pragma mark Actions
- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{    
	if (alertVw.tag == -11000 && buttonIndex != 0) //not Cancel
	{
		[self deleteRE:buttonIndex];
	}
	if (alertVw.tag == -12000 && buttonIndex != 0)
	{
		[self deleteRE];	//all series
	}
	else if (alertVw.tag == -10000)
	{
		if (buttonIndex == 1)
		{
			[self doDeleteTask];
        }
    }
	else if (alertVw.tag == -10001 && buttonIndex != 0)
	{
		[self doDeleteCategory:(buttonIndex == 2)];
	}
	else if (alertVw.tag == -13000)
	{
		if (buttonIndex > 0)
		{
            BOOL isADE = ([actionTask isADE] || [actionTaskCopy isADE]);
            
            if (buttonIndex == 2) //all series
            {
                /*
                if ([actionTask.startTime compare:actionTaskCopy.startTime] == NSOrderedSame && [actionTask.endTime compare:actionTaskCopy.endTime] == NSOrderedSame && actionTask.timeZoneId == actionTaskCopy.timeZoneId) //user does not change time -> keep root time
                {
                    actionTaskCopy.startTime = actionTask.original.startTime;
                    actionTaskCopy.endTime = actionTask.original.endTime;
                }
                */
                
                if ([Common daysBetween:actionTask.startTime sinceDate:actionTaskCopy.startTime] == 0 && [Common daysBetween:actionTask.endTime sinceDate:actionTaskCopy.endTime] == 0 && actionTask.timeZoneId == actionTaskCopy.timeZoneId) //user does not change date -> keep root date
                {
                    actionTaskCopy.startTime = [Common copyTimeFromDate:actionTaskCopy.startTime toDate:actionTask.original.startTime];
                    actionTaskCopy.endTime = [Common copyTimeFromDate:actionTaskCopy.endTime toDate:actionTask.original.endTime];
                }
            }
            
			[[TaskManager getInstance] updateREInstance:actionTask withRE:actionTaskCopy updateOption:buttonIndex];
            
            [self reconcileItem:actionTask reSchedule:YES];
            
            if ([self isKindOfClass:[PlannerViewController class]]) {
                if (isADE) {
                    PlannerMonthView *plannerMonthView = (PlannerMonthView*)[self getPlannerMonthCalendarView];
                    // reload openning week
                    [plannerMonthView refreshOpeningWeek:nil];
                } else {
                    PlannerBottomDayCal *plannerDayCal = [self getPlannerDayCalendarView];
                    [plannerDayCal refreshLayout];
                }
            } /*else {
                MiniMonthView *mmView = [self getMiniMonth];
                
                if (isADE)
                {
                    [self refreshADE];
                }
                
                if (mmView != nil)
                {
                    [mmView refresh];
                }
            }*/
		}
        
        [self hidePopover];
	}
	else if (alertVw.tag == -13001)
	{
        if (buttonIndex != 0)
        {
            [self convertRE2Task:buttonIndex];
        }
        
        [self hidePopover];
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 1)
    {
        [self doDeleteCategory:NO];
    }
}

#pragma mark Sync & Backup
- (void) autoPush
{
    if (_autoPushPending)
    {
        TDSync *tdSync = [TDSync getInstance];
        SDWSync *sdwSync = [SDWSync getInstance];
        EKSync *ekSync = [EKSync getInstance];
        EKReminderSync *rmdSync = [EKReminderSync getInstance];
        
        Settings *settings = [Settings getInstance];
        
        if (settings.autoSyncEnabled && settings.autoPushEnabled)
        {
            //printf("Auto Push ...\n");
            
            if (settings.sdwSyncEnabled)
            {
                if (settings.sdwLastSyncTime == nil) //first sync
                {
                    //printf("[1] init sdw sync 2-way\n");
                    [sdwSync initBackgroundSync];
                }
                else
                {
                    //printf("task changed -> init sdw sync 1-way\n");
                    [sdwSync initBackgroundAuto1WaySync];
                }
            }
            else if (settings.ekSyncEnabled)
            {
                [ekSync initBackgroundAuto1WaySync];
            }
            else if (settings.tdSyncEnabled)
            {
                if (settings.tdLastSyncTime == nil) //first sync
                {
                    [tdSync initBackgroundSync];
                }
                else
                {
                    [tdSync initBackground1WaySync];
                }
            }
            else if (settings.rmdSyncEnabled)
            {
                if (settings.rmdLastSyncTime == nil) //first sync
                {
                    [rmdSync initBackgroundSync];
                }
                else
                {
                    [rmdSync initBackgroundAuto1WaySync];
                }
                
            }
        }
        
        _autoPushPending = NO;
    }
}

- (void) backup
{
    [self deselect];
    
    [SmartCalAppDelegate backupDB];
}

- (void) sync
{
    Settings *settings = [Settings getInstance];
    
    if (settings.syncEnabled)
    {
        if (settings.sdwSyncEnabled)
        {
            [[SDWSync getInstance] initBackgroundSync];
        }
        else if (settings.ekSyncEnabled)
        {
            [[EKSync getInstance] initBackgroundSync];
        }
        else if (settings.tdSyncEnabled)
        {
            [[TDSync getInstance] initBackgroundSync];
        }
        else if (settings.rmdSyncEnabled)
        {
            [[EKReminderSync getInstance] initBackgroundSync];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_warningText message:_syncOffWarningText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
            
            [alertView show];
            [alertView release];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_warningText message:_syncOffWarningText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
        
        [alertView show];
        [alertView release];
    }
}

#pragma mark Notification
- (void)miniMonthResize:(NSNotification *)notification
{
    [UIView beginAnimations:@"mmresize_animation" context:NULL];
    [UIView setAnimationDuration:0.2];
    
    FocusView *focusView = [self getFocusView];
    MiniMonthView *mmView = [self getMiniMonth];
    
    if (focusView != nil && !focusView.hidden && mmView != nil)
    {
        [focusView refreshData];
        
        CGRect frm = focusView.frame;
        
        frm.origin.y = mmView.frame.origin.y + mmView.bounds.size.height + 10;
        
        focusView.frame = frm;
    }
    
    CalendarViewController *ctrler = [self getCalendarViewController];
    [ctrler refreshFrame];
    
    [UIView commitAnimations];
}

- (void)calendarDayReady:(NSNotification *)notification
{
    FocusView *focusView = [self getFocusView];
    
    if (focusView !=nil && !focusView.hidden)
    {
        [focusView refreshData];
        
        CalendarViewController *ctrler = [self getCalendarViewController];
        [ctrler refreshFrame];
    }
}

- (void)taskChanged:(NSNotification *)notification
{
    _autoPushPending = YES;
}

- (void)eventChanged:(NSNotification *)notification
{
    _autoPushPending = YES;
}

- (void)noteChanged:(NSNotification *)notification
{
    _autoPushPending = YES;
}

- (void)ekSyncComplete:(NSNotification *)notification
{
    [self deselect];
    
    TaskManager *tm = [TaskManager getInstance];
    Settings *settings = [Settings getInstance];
    EKSync *ekSync = [EKSync getInstance];
    
    if (ekSync.resultCode != 0)
    {
        return;
    }
    
    int mode = [[notification.userInfo objectForKey:@"SyncMode"] intValue];
    
    //printf("EK Sync complete - mode: %s\n", (mode == SYNC_AUTO_1WAY?"auto 1 way":"2 way"));
    
    if (mode == SYNC_AUTO_1WAY)
    {
        [tm refreshSyncID4AllItems];
        
        CalendarViewController *ctrler = [self getCalendarViewController];
        
        [ctrler.calendarLayoutController refreshSyncID4AllItems];
        
        //if (settings.tdSyncEnabled && settings.tdAutoSyncEnabled)
        if (settings.tdSyncEnabled && settings.autoPushEnabled)
        {
            if (settings.tdLastSyncTime == nil) //first sync
            {
                [[TDSync getInstance] initBackgroundSync];
            }
            else
            {
                [[TDSync getInstance] initBackground1WaySync];
            }
        }
        
        return;
    }
    
    if (mode == SYNC_MANUAL_2WAY_BACK)
    {
        [self resetAllData];
        
        return;
    }
    
    if (settings.tdSyncEnabled)
    {
        if (mode == SYNC_AUTO_2WAY)
        {
            if (settings.autoSyncEnabled)
            {
                [[TDSync getInstance] initBackgroundAuto2WaySync];
            }
            else
            {
                [self resetAllData];
            }
        }
        else if (mode == SYNC_MANUAL_2WAY)
        {
            [[TDSync getInstance] initBackgroundSync];
        }
        else
        {
            [self resetAllData];
        }
    }
    else if (settings.rmdSyncEnabled)
    {
        if (mode == SYNC_AUTO_2WAY)
        {
            if (settings.autoSyncEnabled)
            {
                [[EKReminderSync getInstance] initBackgroundAuto2WaySync];
            }
            else
            {
                [self resetAllData];
            }
        }
        else if (mode == SYNC_MANUAL_2WAY)
        {
            [[EKReminderSync getInstance] initBackgroundSync];
        }
        else
        {
            [self resetAllData];
        }
    }
    else
    {
        [self resetAllData];
    }
    
}

- (void)ekReminderSyncComplete:(NSNotification *)notification
{
    //printf("Toodledo Sync complete\n");
    [self deselect];
    
    Settings *settings = [Settings getInstance];
    TaskManager *tm = [TaskManager getInstance];
    
    int mode = [[notification.userInfo objectForKey:@"SyncMode"] intValue];
    
    if (mode != SYNC_AUTO_1WAY)
    {
        if (settings.ekSyncEnabled)
        {
            [[EKSync getInstance] initBackgroundSyncBack];
        }
        else
        {
            [self resetAllData];
        }
    }
    else
    {
        [tm refreshSyncID4AllItems];
        
        CalendarViewController *ctrler = [self getCalendarViewController];
        
        [ctrler.calendarLayoutController refreshSyncID4AllItems];
        
        return;
    }
}

- (void)tdSyncComplete:(NSNotification *)notification
{
    //printf("Toodledo Sync complete\n");
    [self deselect];
    
    Settings *settings = [Settings getInstance];
    TaskManager *tm = [TaskManager getInstance];
    
    int mode = [[notification.userInfo objectForKey:@"SyncMode"] intValue];
    
    if (mode != SYNC_AUTO_1WAY)
    {
        if (settings.ekSyncEnabled)
        {
            [[EKSync getInstance] initBackgroundSyncBack];
        }
        else
        {
            [self resetAllData];
        }
    }
    else
    {
        [tm refreshSyncID4AllItems];
        
        CalendarViewController *ctrler = [self getCalendarViewController];
        
        [ctrler.calendarLayoutController refreshSyncID4AllItems];
        
        return;
    }
}

- (void)sdwSyncComplete:(NSNotification *)notification
{
    [self deselect];
    
    TaskManager *tm = [TaskManager getInstance];
    
    int mode = [[notification.userInfo objectForKey:@"SyncMode"] intValue];
    
    //printf("SDW Sync complete - mode: %s\n", (mode == SYNC_AUTO_1WAY?"auto 1 way":"2 way"));
    
    if (mode == SYNC_MANUAL_1WAY_mSD2SD)
    {
        [self resetAllData];
        
        return;
    }
    
    if (mode == SYNC_AUTO_1WAY || mode == SYNC_MANUAL_1WAY_SD2mSD)
    {
        [tm refreshSyncID4AllItems];
        
        CalendarViewController *ctrler = [self getCalendarViewController];
        
        [ctrler.calendarLayoutController refreshSyncID4AllItems];
        
        [self refreshData]; //reload sync IDs in other views such as ADE Pane/Notes/Categories so that delete item will not clean it from DB
    }
    else
    {
        [self resetAllData];
    }
}

#pragma mark Alert Handle

- (void)reloadAlerts:(NSNotification *)notification
{
    //NSInteger taskId = [[notification.userInfo objectForKey:@"TaskId"] intValue];
    
    //[self reloadAlert4Task:taskId];
    
    [self applyFilter];
}

- (void) reloadAlert4Task:(NSInteger)taskId
{
    TaskManager *tm = [TaskManager getInstance];
    
    [tm reloadAlert4Task:taskId];
    
    PageAbstractViewController *ctrlers[4] = {
        [self getCalendarViewController],
        [self getSmartListViewController],
        [self getNoteViewController],
        [self getCategoryViewController]
    };
    
    for (int i=0; i<4; i++)
    {
        PageAbstractViewController *ctrler = ctrlers[i];
        
        [ctrler reloadAlert4Task:taskId];
    }
    
    FocusView *focusView = [self getFocusView];
    
    if (focusView != nil)
    {
        [focusView reloadAlert4Task:taskId];
    }
}

@end
