//
//  MiniMonthView.m
//  SmartCal
//
//  Created by MacBook Pro on 3/21/11.
//  Copyright 2011 LCL. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MiniMonthView.h"

#import "Common.h"
#import "Settings.h"
#import "TaskManager.h"
#import "MonthlyCalendarView.h"
#import "MiniMonthHeaderView.h"
#import "MiniMonthWeekHeaderView.h"
#import "ImageManager.h"

#import "BusyController.h"

#import "SmartDayViewController.h"
#import "CalendarViewController.h"

#import "AbstractSDViewController.h"

extern AbstractSDViewController *_abstractViewCtrler;

//extern BOOL _isiPad;

@implementation MiniMonthView

@synthesize calView;
@synthesize headerView;
@synthesize weekHeaderView;

/*
- (void) resizeView:(BOOL) check2HideHeader
{
	//CGRect frm = self.frame;
    CGRect frm = self.bounds;
	
	//frm.size.height -= knobAreaView.frame.size.height + headerView.frame.size.height;
    frm.size.height -= 30 + headerView.frame.size.height;
    
	frm.origin.y = headerView.frame.size.height;
	
	calView.frame = frm;
	
	frm = CGRectOffset(frm, 0, frm.size.height);
	
	if (frm.size.height == 0 && check2HideHeader) //hide header
	{
		frm.origin.y = 0;
	}
	
	frm.size.height = tinyBarView.frame.size.height;
	
	tinyBarView.frame = frm;
	
	if (frm.origin.y == 0)
	{
		frm.size.height += 10;
        
        frm.origin.y = self.frame.origin.y;
		
        self.frame = frm; //hide header and show only tiny bar
	}
	
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MiniMonthResizeNotification" object:self];
}
*/
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
	
    if (self) {
        // Initialization code.
		
		self.backgroundColor = [UIColor clearColor];
		
		headerView = [[MiniMonthHeaderView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, MINI_MONTH_HEADER_HEIGHT)];
		[self addSubview:headerView];
		[headerView release];
        
        weekHeaderView = [[MiniMonthWeekHeaderView alloc] initWithFrame:_isiPad?CGRectMake(0, MINI_MONTH_HEADER_HEIGHT, MINI_MONTH_WEEK_HEADER_WIDTH, frame.size.height-MINI_MONTH_HEADER_HEIGHT):CGRectZero];
        [self addSubview:weekHeaderView];
        [weekHeaderView release];
		
		calView = [[MonthlyCalendarView alloc] initWithFrame:CGRectMake(weekHeaderView.bounds.size.width, headerView.frame.size.height, frame.size.width-weekHeaderView.bounds.size.width, frame.size.height-headerView.frame.size.height)];
				
		[self addSubview:calView];
		[calView release];
		
        [calView changeWeekPlanner:7 weeks:1];
        
        //self.layer.borderWidth = 1;
        //self.layer.borderColor = [[UIColor grayColor] CGColor];
        //self.layer.borderColor = [[UIColor colorWithRed:192.0/255 green:192.0/255 blue:192.0/255 alpha:1] CGColor];
        
        [headerView changeMWMode:0];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [super dealloc];
}

- (void)changeFrame:(CGRect) frame
{
    [UIView beginAnimations:@"resize_animation" context:NULL];
    [UIView setAnimationDuration:0.3];
        
    self.frame = frame;
    
    weekHeaderView.frame = _isiPad?CGRectMake(0, MINI_MONTH_HEADER_HEIGHT, MINI_MONTH_WEEK_HEADER_WIDTH, frame.size.height-MINI_MONTH_HEADER_HEIGHT):CGRectZero;
    [weekHeaderView setNeedsDisplay];
    
    CGRect frm = self.bounds;
    
    frm.origin.x += weekHeaderView.bounds.size.width;
    frm.origin.y = headerView.bounds.size.height;
    frm.size.width -= weekHeaderView.bounds.size.width;
    frm.size.height -= headerView.bounds.size.height;

    calView.frame = frm;
    
    [UIView commitAnimations];    
}

- (void) moveToPoint:(CGPoint) point
{
	CGPoint p = [self convertPoint:point toView:calView];

	if (CGRectContainsPoint(calView.bounds, p))
	{
		////printf("contain point - %f, frm y: %f, frm h: %f\n", p.y, calView.frame.origin.y, calView.frame.size.height);
		[calView highlightCellAtPoint:p];
	}
	else 
	{
		[calView unhighlight];
	}

}

- (void) finishMove
{
	[calView unhighlight];
}

/*
- (void) scrollDay
{
	NSDate *today = [[[TaskManager getInstance] today] copy];
	
	[calView scrollDay:today];
	
	[today release];
}
*/

- (void) changeSkin
{
	[calView changeSkin];
}


- (void) refresh
{
	[calView refresh];
}


- (void) initCalendar:(NSDate *)date
{
    [_abstractViewCtrler deselect];
    
    [headerView setNeedsDisplay];
    
    TaskManager *tm = [TaskManager getInstance];
    
    NSInteger mode = [headerView getMWMode];
    
    NSDate *dt = (mode==1?date:[Common getFirstMonthDate:date]);


    [self updateWeeks:dt];
    
    [self.calView initCalendar:dt];
    
    [self.calView highlightCellOnDate:tm.today];
}

- (void) highlight:(NSDate *)date
{
    //use for scrolling in Calendar view
    if (![self.calView checkDateInCalendar:date])
    {
        NSInteger mode = [headerView getMWMode];
        
        NSDate *dt = (mode==1?date:[Common getFirstMonthDate:date]);
        
        [self updateWeeks:dt];
        [self.calView initCalendar:dt];
        
    }
    
    [self.calView highlightCellOnDate:date];
    [headerView setNeedsDisplay];
    
}

- (void) finishInitCalendar
{
    NSInteger weeks = self.calView.nWeeks;
	
//    CGRect frm = CGRectMake(_isiPad?10:0, _isiPad?10:0, self.frame.size.width, (_isiPad?48:40)*weeks + MINI_MONTH_HEADER_HEIGHT + (_isiPad?0:6));
    
    CGRect frm = CGRectMake(_isiPad?10:0, _isiPad?10:0, self.frame.size.width, (_isiPad?48:40)*weeks + MINI_MONTH_HEADER_HEIGHT);
    
    [self changeFrame:frm];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MiniMonthResizeNotification" object:nil];
 }

- (void) jumpToDate:(NSDate *)date
{
    [_abstractViewCtrler jumpToDate:date];
    [headerView setNeedsDisplay];
}

- (void) switchView:(NSInteger)mode
{
    TaskManager *tm = [TaskManager getInstance];
    
    NSDate *dt = (tm.today==nil?[NSDate date]:tm.today);
    
    NSDate *calDate = (mode == 1?dt:[Common getFirstMonthDate:dt]);
    
    [self initCalendar:calDate];
    
}

- (void) shiftTime:(NSInteger)mode
{
    //mode 0: go previous - 1: go next
    NSDate *dt = [self.calView getFirstDate];
    
    NSInteger mwMode = [headerView getMWMode];
    
    if (mwMode == 0)
    {
        dt = [Common getFirstMonthDate:[Common dateByAddNumDay:7 toDate:dt]];
    }

    dt = (mwMode == 0? [Common dateByAddNumMonth:(mode == 0?-1:1) toDate:dt]:[Common dateByAddNumDay:(mode == 0?-7:7) toDate:dt]);
    
    [self initCalendar:dt]; //must init calendar first then jump
    
    [self jumpToDate:dt];
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.4];
    [animation setType:kCATransitionPush];
    [animation setSubtype:(mode==0?kCATransitionFromLeft:kCATransitionFromRight)];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    self.calView.superview.layer.masksToBounds = YES;
    
    [[self.calView layer] addAnimation:animation forKey:@"slideTransition"];
}

- (void) updateWeeks:(NSDate *)date
{
    Settings *settings = [Settings getInstance];
    
    NSInteger mode = [headerView getMWMode];
    
    NSDate *calDate = (mode == 1?date:[Common getFirstMonthDate:date]);
    
    NSDate *lastWeekDate = [Common getLastWeekDate:calDate mondayAsWeekStart:settings.isMondayAsWeekStart];
    
    NSInteger weeks = (mode==1?1:[Common getWeeksInMonth:lastWeekDate mondayAsWeekStart:settings.isMondayAsWeekStart]);
    
    [self.calView changeWeekPlanner:7 weeks:weeks];
}

#pragma mark Actions

- (void) goPrevious:(id) sender
{
    Settings *settings = [Settings getInstance];
    
    NSInteger wkPlannerRows = settings.weekPlannerRows;

    NSDate *dt = [calView getFirstDate];
    
    dt = [Common dateByAddNumDay:-7*wkPlannerRows toDate:dt];
    
    [self jumpToDate:dt];
    
    [calView initCalendar:dt];
}

- (void) goNext:(id) sender
{
    //printf("go next\n");
    
    Settings *settings = [Settings getInstance];
    
    NSInteger wkPlannerRows = settings.weekPlannerRows;
    
    NSDate *dt = [calView getFirstDate];
    
    dt = [Common dateByAddNumDay:7*wkPlannerRows toDate:dt];
    
    [self jumpToDate:dt];
    
    [calView initCalendar:dt];    
}

/*
#pragma mark Touch 
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject] locationInView:self];
    
    CGRect r = CGRectMake(self.bounds.size.width/2-20, self.bounds.size.height-40, 40, 40);
	
    touchedPoint = CGPointZero;
    
    if (CGRectContainsPoint(r, p))
	{
        touchedPoint = [[touches anyObject] locationInView:tinyBarView];
	}
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touchedPoint.x != 0 && touchedPoint.y != 0)
	{
		UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:tinyBarView];
		
		CGFloat dy = location.y - touchedPoint.y;
		
		CGRect frm = self.frame;
		
		frm.size.height += dy;
		
        if (frm.size.height <= (5*40 + 30 + headerView.frame.size.height) && frm.size.height >= (30 + headerView.frame.size.height))
		{
			self.frame = frm;
			
			[self resizeView:NO];
		}
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touchedPoint.x != 0 && touchedPoint.y != 0)
	{
		CGRect frm = calView.frame;
		
		int div = frm.size.height/40;
		int mod = (int)frm.size.height%40;
		
		int nRows = (mod > 20?div+1:div);
        
        Settings *settings = [Settings getInstance];
        
        NSInteger wkPlannerRows = settings.weekPlannerRows;
		
		[settings saveWeekPlannerRows:nRows];
		
		frm.size.height = nRows*40;
		
        frm.size.height += headerView.frame.size.height + 30;

        frm.origin.y = self.frame.origin.y;
		
		self.frame = frm;
		
		[self resizeView:YES];
        
        if (nRows != wkPlannerRows)
        {
            [self refresh];
        }        
	}
    else
    {
        CGPoint p = [[touches anyObject] locationInView:self];
        
        CGRect r = CGRectMake(0, self.bounds.size.height-40, 40, 40); 
        
        if (CGRectContainsPoint(r, p))
        {
            [self goPrevious:nil];
        }
        else 
        {
            r = CGRectMake(self.bounds.size.width-40, self.bounds.size.height-40, 40, 40);
            
            if (CGRectContainsPoint(r, p))
            {
                [self goNext:nil];
            }            
        }
    }
}
*/

@end
