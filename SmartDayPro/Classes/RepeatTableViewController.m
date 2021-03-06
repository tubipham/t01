//
//  RepeatTableViewController.m
//  SmartPlan
//
//  Created by Huy Le on 12/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RepeatTableViewController.h"

#import "Common.h"
#import "Colors.h"
#import "ProjectManager.h"
#import "ImageManager.h"
#import "Project.h"
#import "Task.h"
#import "RepeatData.h"

#import "DetailViewController.h"

#import "DateInputViewController.h"
#import "iPadViewController.h"

//extern BOOL _isiPad;
extern iPadViewController *_iPadViewCtrler;

RepeatTableViewController *_repeatViewCtrler = nil;

@implementation RepeatTableViewController

@synthesize task;
@synthesize repeatData;

@synthesize inputViewCtrler;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (id)init
{
	if (self = [super init])
	{
		selectedIndex = -1;
        
        self.preferredContentSize = CGSizeMake(320,416);
	}
	
	return self;
}

- (void)dealloc {
	
	self.repeatData = nil;
    self.inputViewCtrler = nil;
	
    [super dealloc];
}

- (void) changeFrame:(CGRect)frm
{
    contentView.frame = frm;
    
    repeatTableView.frame = contentView.bounds;
    
    frm = CGRectMake(0, contentView.bounds.size.height - 300, contentView.bounds.size.width, 300);
    
    inputView.frame = frm;
}

- (void) changeOrientation:(UIInterfaceOrientation) orientation
{
    CGSize sz = [Common getScreenSize];
    sz.height += 20 + 44;
    
    CGRect frm = CGRectZero;
    
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        frm.size.height = sz.width;
        frm.size.width = sz.height;
    }
    else
    {
        frm.size = sz;
    }
    
    frm.size.height -= 20 + 2*44;
    
    frm.size.width = _isiPad?384:320;
    
    [self changeFrame:frm];
}

- (void)loadView 
{
	self.repeatData = task.repeatData;
	
	if (self.repeatData == nil)
	{
		selectedIndex = 0;
	}
	else 
	{
		selectedIndex = self.repeatData.type + 1;
		
		if (task.deadline == nil)
		{
			self.repeatData.repeatFrom = 1;
		}
        
        if (self.repeatData.type == REPEAT_WEEKLY && self.repeatData.weekOption == 0)
        {
            int day = [Common getWeekday:task.startTime];
            
            NSInteger wkOptions[7] = {ON_SUNDAY, ON_MONDAY, ON_TUESDAY, ON_WEDNESDAY, ON_THURSDAY, ON_FRIDAY, ON_SATURDAY}; 

            self.repeatData.weekOption = wkOptions[day - 1];
        }
	}

    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    //frm.size.width = 320;
    if (_isiPad)
    {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        {
            frm.size.height = frm.size.width - 20;
        }
        
        frm.size.width = 384;
    }
    else
    {
        frm.size.width = 320;
    }
	
    contentView = [[UIView alloc] initWithFrame:frm];
	//contentView.backgroundColor = [UIColor colorWithRed:209.0/255 green:212.0/255 blue:217.0/255 alpha:1];
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
	
    repeatTableView = [[UITableView alloc] initWithFrame:contentView.bounds style:UITableViewStylePlain];
    repeatTableView.backgroundColor = [UIColor clearColor];
	repeatTableView.delegate = self;
	repeatTableView.dataSource = self;
	//repeatTableView.sectionHeaderHeight=5;
    repeatTableView.backgroundColor = [UIColor clearColor];
	
	[contentView addSubview:repeatTableView];
	[repeatTableView release];
    
    inputView = [[UIView alloc] initWithFrame:CGRectMake(0, contentView.bounds.size.height - 300, contentView.bounds.size.width, 300)];
    inputView.hidden = YES;
    
    [contentView addSubview:inputView];
    [inputView release];
    
	self.view = contentView;
	[contentView release];
    
    contentView.userInteractionEnabled = ![self.task isShared];
	
	self.navigationItem.title = _repeatText;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
	[ImageManager free];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void) viewDidLoad
{
    [self changeOrientation:_iPadViewCtrler.interfaceOrientation];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _repeatViewCtrler = self;
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    _repeatViewCtrler = nil;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([activeTextField isFirstResponder])
    {
        [activeTextField resignFirstResponder];
    }
    
	self.task.repeatData = self.repeatData;
    
    if ([self.navigationController.topViewController isKindOfClass:[DetailViewController class]])
    {
        DetailViewController *ctrler = (DetailViewController *)self.navigationController.topViewController;
        
       
        [ctrler refreshUntil];
    }
    
    _repeatViewCtrler = nil;
}

- (void) showRepeatFromDueHint
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_repeatFromDueText message:_repeatFromDueHintText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
	
	alertView.tag = -10002;

	[alertView show];
	[alertView release];
}

#pragma mark RepeatData Update

- (void)changeType
{
	//doneBarView.hidden = YES;
	
	if (selectedIndex == 0)
	{
		self.repeatData = nil;
	}
	else 
	{
		if (self.repeatData == nil)
		{
			//self.repeatData = [[[RepeatData alloc] init] autorelease];
			RepeatData *original = [[RepeatData alloc] init]; 
			self.repeatData = original;
			[original release];
		}
		
		self.repeatData.type = selectedIndex - 1;
		
		[self.repeatData reset];
		
		if (self.task.deadline == nil)
		{
			self.repeatData.repeatFrom = 1;
		}
		
        if (selectedIndex == 2) //weekly
        {
            if (self.task.startTime != nil)
            {
                NSInteger wkOptions[7] = {ON_SUNDAY, ON_MONDAY, ON_TUESDAY, ON_WEDNESDAY, ON_THURSDAY, ON_FRIDAY, ON_SATURDAY}; 
                int idx = [Common getWeekday:self.task.startTime] - 1;
                
                self.repeatData.weekOption = wkOptions[idx];                
            }
        }
	}
	
	[repeatTableView reloadData];
}

- (void) changeInterval:(NSInteger) interval
{	
	if (self.repeatData != nil)
	{
		self.repeatData.interval = interval;
		
		if (self.task.type == TYPE_TASK && interval > 1)
		{
			if (self.repeatData.type == REPEAT_WEEKLY)
			{
				self.repeatData.weekOption = 0;
				
				UITableViewCell *cell = [repeatTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
				
				for (int i=0; i<7; i++)
				{
					UIButton *optionButton = (UIButton *)[cell.contentView viewWithTag:10205 + i];
					optionButton.selected = NO;
				}
			}
			else if (self.repeatData.type == REPEAT_MONTHLY)
			{
				//self.repeatData.monthOption = -1;
				
				UITableViewCell *cell = [repeatTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
				
                /*
				for (int i=0; i<2; i++)
				{
					UIButton *optionButton = (UIButton *)[cell.contentView viewWithTag:10305 + i];
					optionButton.selected = NO;
				}
                */
                
                UIButton *option1Button = (UIButton *)[cell.contentView viewWithTag:10305];
                UIButton *option2Button = (UIButton *)[cell.contentView viewWithTag:10306];
                
                if (self.repeatData.monthOption == BY_DAY_OF_MONTH)
                {
                    option1Button.selected = YES;
                    monthOptionButton = option1Button;
                }
                else if (self.repeatData.monthOption == BY_DAY_OF_WEEK)
                {
                    option2Button.selected = YES;
                    monthOptionButton = option2Button;
                }
			}
		}		
	}
}

- (void) changeOption:(NSInteger) option
{
	if (self.repeatData != nil)
	{
		if (self.repeatData.type == REPEAT_WEEKLY)
		{
			if (self.repeatData.weekOption & option)
			{
				self.repeatData.weekOption &= ~option;
			}
			else 
			{
				self.repeatData.weekOption |= option;
			}
		}
		else if (self.repeatData.type == REPEAT_MONTHLY)
		{
			self.repeatData.monthOption = option;
		}
		
        /*
		if (self.task.type == TYPE_TASK)
		{
			if (self.repeatData.type == REPEAT_WEEKLY && self.repeatData.weekOption != 0)
			{
				self.repeatData.interval = 1;
				
				UITableViewCell *cell = [repeatTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
				UITextField *everyTextField = (UITextField *)[cell.contentView viewWithTag:10203];
				everyTextField.text = [NSString stringWithFormat:@"%d", self.repeatData.interval];
			}
			else if (self.repeatData.type == REPEAT_MONTHLY && self.repeatData.monthOption != -1)
			{
				self.repeatData.interval = 1;
				
				UITableViewCell *cell = [repeatTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
				UITextField *everyTextField = (UITextField *)[cell.contentView viewWithTag:10303];
				everyTextField.text = [NSString stringWithFormat:@"%d", self.repeatData.interval];
				
			}
		}*/
	}
}

- (void) changeCount:(NSInteger) count
{	
	if (self.repeatData != nil)
	{
		self.repeatData.count = count;
		
		[self.repeatData calculateUntilByCount:self.task.endTime];
	}
}

- (void) changeUntil:(NSDate *) until
{
    NSDate *dt = [Common copyTimeFromDate:self.task.endTime toDate:until];
    
    //until = [Common dateByAddNumSecond:-1 toDate:dt];
    until = dt;
    
	if (self.repeatData != nil)
	{
        if ([Common compareDate:until withDate:self.task.startTime] == NSOrderedAscending)
        {
            //don't allow until before start
            
            //until = [Common dateByAddNumSecond:-1 toDate:[Common getEndDate:self.task.startTime]];
            until = [Common getEndDate:self.task.startTime];
        }
        
		self.repeatData.until = until;
        
        //untilPicker.date = until;
        
        /*
        [repeatTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];*/
        
        [Common reloadRowOfTable:repeatTableView row:0 section:1];
	}
}

- (void) selectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int oldSelectedIndex = selectedIndex;
	
	if (selectedIndex >= 0)
	{
		NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
		
		[[repeatTableView cellForRowAtIndexPath:oldIndexPath] setAccessoryType:UITableViewCellAccessoryNone];
	}
	
	[[repeatTableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
	
	selectedIndex = indexPath.row;
	
	if (oldSelectedIndex != selectedIndex)
	{
		[self changeType];
	}
}

#pragma mark Actions
-(void)save:(id)sender
{
    if ([activeTextField isFirstResponder])
    {
        [activeTextField resignFirstResponder];
    }
    
	self.task.repeatData = self.repeatData;
	
	[self.navigationController popViewControllerAnimated:YES];	
}

/*
-(void)done:(id)sender
{
	doneBarView.hidden = YES;
	untilPicker.hidden = YES;

	repeatTableView.frame = CGRectMake(0, 0, 320, 410);
	
	if (activeTextField != nil)
	{
		[activeTextField resignFirstResponder];
		
		activeTextField = nil;
	}
	
}
*/

-(void)changeWeekOption:(id)sender
{
	UIButton *option = (UIButton *) sender;
	
	option.selected = !option.selected;
	
	[self selectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
	
	NSInteger wkOptions[7] = {ON_SUNDAY, ON_MONDAY, ON_TUESDAY, ON_WEDNESDAY, ON_THURSDAY, ON_FRIDAY, ON_SATURDAY}; 
	
	[self changeOption:wkOptions[option.tag - 10205]];
}

-(void)changeMonthOption:(id)sender
{
	UIButton *option = (UIButton *) sender;
	
	if (monthOptionButton != nil)
	{
		monthOptionButton.selected = NO;
	}
	
	monthOptionButton = option;
	monthOptionButton.selected = YES;
	
	[self selectRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
	
	NSInteger mthOptions[2] = {BY_DAY_OF_MONTH, BY_DAY_OF_WEEK}; 
	[self changeOption:mthOptions[option.tag - 10305]];
}

-(void)repeatForever:(id)sender
{
	//[self changeUntil:nil];
	
	self.repeatData.until = nil;
    
	untilValueLabel.text = _foreverText;
}

-(void)repeatUntil:(id)sender
{
    /*
    if (!_isiPad)
    {
        repeatTableView.frame = CGRectMake(0, 0, 320, 160);
	
        [repeatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
	doneBarView.hidden = NO;
	untilPicker.hidden = NO;

	untilPicker.date = (self.repeatData != nil && self.repeatData.until != nil?self.repeatData.until:[NSDate date]);
    */
    
    DateInputViewController *ctrler = [[DateInputViewController alloc] initWithNibName:@"DateInputViewController" bundle:nil];
    ctrler.task = self.task;
    ctrler.dateEdit = TASK_EDIT_UNTIL;
    
    [self showInputView:ctrler];
    
    [ctrler release];
}

-(void)untilChanged:(id)sender
{
	UIDatePicker *picker = (UIDatePicker *)sender;
	
	[self changeUntil:picker.date];
	
	untilValueLabel.text = [Common getFullDateString3:picker.date];
}

#pragma mark Input Views
-(void) showInputView:(UIViewController *)ctrler
{
    self.inputViewCtrler = ctrler;
    
    ctrler.view.frame = inputView.bounds;
    
    [inputView addSubview:ctrler.view];
    
    inputView.hidden = NO;
    
    [contentView bringSubviewToFront:inputView];
    
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	[animation setType:kCATransitionMoveIn];
	[animation setSubtype:kCATransitionFromTop];
	
	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:kTransitionDuration];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[inputView.layer addAnimation:animation forKey:kInfoViewAnimationKey];
}

- (void) closeInputView
{
    if (self.inputViewCtrler != nil)
    {
        [self.inputViewCtrler.view removeFromSuperview];
        
        inputView.hidden = YES;
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        
        [animation setType:kCATransitionReveal];
        [animation setSubtype:kCATransitionFromBottom];
        
        // Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
        [animation setDuration:kTransitionDuration];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        [inputView.layer addAnimation:animation forKey:kInfoViewAnimationKey];
        
        self.inputViewCtrler = nil;
    }
}

#pragma mark Cell Creation
- (void) createNoneCell:(UITableViewCell *) cell
{
	UILabel *noneLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, 80, 25)];
	noneLabel.tag = 10001;
	noneLabel.text=_noneText;
	noneLabel.backgroundColor=[UIColor clearColor];
	noneLabel.font=[UIFont systemFontOfSize:16];
	noneLabel.textColor=[UIColor grayColor];
	
	[cell.contentView addSubview:noneLabel];
	[noneLabel release];
}

- (void) createDailyCell:(UITableViewCell *) cell
{
    CGFloat xMargin = repeatTableView.bounds.size.width - 3*60 - 30;
    
	UILabel *dailyLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, 80, 25)];
	dailyLabel.tag = 10101;
	dailyLabel.text=_dailyText;
	dailyLabel.backgroundColor=[UIColor clearColor];
	dailyLabel.font=[UIFont systemFontOfSize:16];
	dailyLabel.textColor=[UIColor grayColor];
	
	[cell.contentView addSubview:dailyLabel];
	[dailyLabel release];
	
	//UILabel *everyLabel=[[UILabel alloc] initWithFrame:CGRectMake(100, 5, 60, 25)];
    UILabel *everyLabel=[[UILabel alloc] initWithFrame:CGRectMake(xMargin, 5, 60, 25)];
	everyLabel.tag = 10102;
	everyLabel.text=_everyText;
	everyLabel.backgroundColor=[UIColor clearColor];
	everyLabel.font=[UIFont systemFontOfSize:15];
	everyLabel.textColor=[Colors darkSteelBlue];
	
	[cell.contentView addSubview:everyLabel];
	[everyLabel release];
	
	//UITextField *everyTextField=[[UITextField alloc] initWithFrame:CGRectMake(150, 5, 60, 25)];
    UITextField *everyTextField=[[UITextField alloc] initWithFrame:CGRectMake(xMargin + 50, 5, 60, 25)];
	everyTextField.tag = 10103;
	everyTextField.borderStyle = UITextBorderStyleRoundedRect;
	everyTextField.text=(selectedIndex == 1? [NSString stringWithFormat:@"%d", self.repeatData.interval] : @"1");
	everyTextField.textAlignment = NSTextAlignmentCenter;
	everyTextField.backgroundColor=[UIColor clearColor];
	everyTextField.font=[UIFont systemFontOfSize:15];
	everyTextField.textColor=[Colors darkSteelBlue];
	everyTextField.keyboardType=UIKeyboardTypeNumberPad;
	everyTextField.returnKeyType = UIReturnKeyDone;
	everyTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
	everyTextField.delegate=self;
	
	[cell.contentView addSubview:everyTextField];
	[everyTextField release];
	
	//UILabel *unitLabel=[[UILabel alloc] initWithFrame:CGRectMake(220, 5, 60, 25)];
    UILabel *unitLabel=[[UILabel alloc] initWithFrame:CGRectMake(xMargin + 120, 5, 60, 25)];
	unitLabel.tag = 10104;
	unitLabel.text=_dayUnitText;
	unitLabel.backgroundColor=[UIColor clearColor];
	unitLabel.font=[UIFont systemFontOfSize:15];
	unitLabel.textColor=[Colors darkSteelBlue];
	
	[cell.contentView addSubview:unitLabel];
	[unitLabel release];
}

- (void) createWeeklyCell:(UITableViewCell *) cell
{
    CGFloat xMargin = repeatTableView.bounds.size.width - 3*60 - 30;
    
	UILabel *weeklyLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, 80, 25)];
	weeklyLabel.tag = 10201;
	weeklyLabel.text=_weeklyText;
	weeklyLabel.backgroundColor=[UIColor clearColor];
	weeklyLabel.font=[UIFont systemFontOfSize:16];
	weeklyLabel.textColor=[UIColor grayColor];
	
	[cell.contentView addSubview:weeklyLabel];
	[weeklyLabel release];
	
	//UILabel *everyLabel=[[UILabel alloc] initWithFrame:CGRectMake(100, 5, 60, 25)];
    UILabel *everyLabel=[[UILabel alloc] initWithFrame:CGRectMake(xMargin, 5, 60, 25)];
	everyLabel.tag = 10202;
	everyLabel.text=_everyText;
	everyLabel.backgroundColor=[UIColor clearColor];
	everyLabel.font=[UIFont systemFontOfSize:15];
	everyLabel.textColor=[Colors darkSteelBlue];
	
	[cell.contentView addSubview:everyLabel];
	[everyLabel release];
	
	//UITextField *everyTextField=[[UITextField alloc] initWithFrame:CGRectMake(150, 5, 60, 25)];
	UITextField *everyTextField=[[UITextField alloc] initWithFrame:CGRectMake(xMargin + 50, 5, 60, 25)];
	everyTextField.tag = 10203;
	everyTextField.borderStyle = UITextBorderStyleRoundedRect;
	everyTextField.text=(selectedIndex == 2? [NSString stringWithFormat:@"%d", self.repeatData.interval]:@"1");
	everyTextField.textAlignment = NSTextAlignmentCenter;
	everyTextField.backgroundColor=[UIColor clearColor];
	everyTextField.font=[UIFont systemFontOfSize:15];
	everyTextField.textColor=[Colors darkSteelBlue];
	everyTextField.keyboardType=UIKeyboardTypeNumberPad;
	everyTextField.returnKeyType = UIReturnKeyDone;
	everyTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
	everyTextField.delegate=self;
	
	[cell.contentView addSubview:everyTextField];
	[everyTextField release];
	
	//UILabel *unitLabel=[[UILabel alloc] initWithFrame:CGRectMake(220, 5, 60, 25)];
    UILabel *unitLabel=[[UILabel alloc] initWithFrame:CGRectMake(xMargin + 120, 5, 60, 25)];
	unitLabel.tag = 10204;
	unitLabel.text=_weekUnitText;
	unitLabel.backgroundColor=[UIColor clearColor];
	unitLabel.font=[UIFont systemFontOfSize:15];
	unitLabel.textColor=[Colors darkSteelBlue];
	
	[cell.contentView addSubview:unitLabel];
	[unitLabel release];
	
	//NSString *weekDays[7] = {@"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat"};
    NSString *weekDays[7] = {_sunText, _monText, _tueText, _wedText, _thuText, _friText, _satText};
    
	NSInteger mask[7] = {ON_SUNDAY, ON_MONDAY,ON_TUESDAY, ON_WEDNESDAY, ON_THURSDAY, ON_FRIDAY, ON_SATURDAY};
    
    int w = (repeatTableView.bounds.size.width - 30)/4;
	
	for (int i=0; i<7; i++)
	{
        int div = i/4;
        int mod = i%4;
        
		UIButton *wkDayButton = [Common createButton:nil 
										  buttonType:UIButtonTypeCustom
                                               //frame:CGRectMake(10 + mod*w, 35 + div*30, 20, 20)
                                               frame:CGRectMake(10 + mod*w, 35 + div*30, 20, 20)
										  titleColor:[UIColor whiteColor]
											  target:self 
											selector:@selector(changeWeekOption:) 
									normalStateImage:@"CheckOff20.png"
								  selectedStateImage:@"CheckOn20.png"];
		wkDayButton.tag = 10205 + i;
		
		if (selectedIndex == 2 && (self.repeatData.weekOption & mask[i]))
		{
			wkDayButton.selected = YES;
		}
		
		[cell.contentView addSubview:wkDayButton];
		
//        UILabel *unitLabel=[[UILabel alloc] initWithFrame:CGRectMake(10 + mod*w + 20, 35 + div*30, 40, 20)];
        UILabel *unitLabel=[[UILabel alloc] initWithFrame:CGRectMake(10 + mod*w + 20 + 5, 35 + div*30, 40, 20)];
		unitLabel.tag = 10212 + i;
		unitLabel.text=weekDays[i];
		unitLabel.backgroundColor=[UIColor clearColor];
		unitLabel.font=[UIFont systemFontOfSize:15];
		unitLabel.textColor=[Colors darkSteelBlue];
		
		[cell.contentView addSubview:unitLabel];
		[unitLabel release];					
	}	
}

- (void) createMonthlyCell:(UITableViewCell *) cell
{
    CGFloat xMargin = repeatTableView.bounds.size.width - 3*60 - 30;

	UILabel *monthlyLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, 80, 25)];
	monthlyLabel.tag = 10301;
	monthlyLabel.text=_monthlyText;
	monthlyLabel.backgroundColor=[UIColor clearColor];
	monthlyLabel.font=[UIFont systemFontOfSize:16];
	monthlyLabel.textColor=[UIColor grayColor];
	
	[cell.contentView addSubview:monthlyLabel];
	[monthlyLabel release];
	
	//UILabel *everyLabel=[[UILabel alloc] initWithFrame:CGRectMake(100, 5, 60, 25)];
    UILabel *everyLabel=[[UILabel alloc] initWithFrame:CGRectMake(xMargin, 5, 60, 25)];
	everyLabel.tag = 10302;
	everyLabel.text=_everyText;
	everyLabel.backgroundColor=[UIColor clearColor];
	everyLabel.font=[UIFont systemFontOfSize:15];
	everyLabel.textColor=[Colors darkSteelBlue];
	
	[cell.contentView addSubview:everyLabel];
	[everyLabel release];
	
	//UITextField *everyTextField=[[UITextField alloc] initWithFrame:CGRectMake(150, 5, 60, 25)];
	UITextField *everyTextField=[[UITextField alloc] initWithFrame:CGRectMake(xMargin + 50, 5, 60, 25)];
	everyTextField.tag = 10303;
	everyTextField.borderStyle = UITextBorderStyleRoundedRect;
	everyTextField.text=(selectedIndex == 3? [NSString stringWithFormat:@"%d", self.repeatData.interval]:@"1");
	everyTextField.textAlignment = NSTextAlignmentCenter;
	everyTextField.backgroundColor=[UIColor clearColor];
	everyTextField.font=[UIFont systemFontOfSize:15];
	everyTextField.textColor=[Colors darkSteelBlue];
	everyTextField.keyboardType=UIKeyboardTypeNumberPad;
	everyTextField.returnKeyType = UIReturnKeyDone;
	everyTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
	everyTextField.delegate=self;
	
	[cell.contentView addSubview:everyTextField];
	[everyTextField release];
	
	//UILabel *unitLabel=[[UILabel alloc] initWithFrame:CGRectMake(220, 5, 60, 25)];
    UILabel *unitLabel=[[UILabel alloc] initWithFrame:CGRectMake(xMargin + 120, 5, 60, 25)];
	unitLabel.tag = 10304;
	unitLabel.text=_monthUnitText;
	unitLabel.backgroundColor=[UIColor clearColor];
	unitLabel.font=[UIFont systemFontOfSize:15];
	unitLabel.textColor=[Colors darkSteelBlue];
	
	[cell.contentView addSubview:unitLabel];
	[unitLabel release];
	
	NSString *options[2] = {_dayOfMonthText, _dayOfWeekText};
	NSInteger values[2] = {BY_DAY_OF_MONTH, BY_DAY_OF_WEEK};
	
	monthOptionButton = nil;
    
    CGFloat w = repeatTableView.bounds.size.width/2;
	
	for (int i=0; i<2; i++)
	{
		UIButton *optionButton = [Common createButton:nil 
										   buttonType:UIButtonTypeCustom
												//frame:CGRectMake(20 + i*140, 35, 20, 20)
                                  frame:CGRectMake(20 + i*w, 35, 20, 20)
										   titleColor:[UIColor whiteColor] 
											   target:self 
											 selector:@selector(changeMonthOption:) 
									 normalStateImage:@"PinOff20.png"
								   selectedStateImage:@"PinOn20.png"];
		optionButton.tag = 10305 + i;
		
		if (selectedIndex == 3 && self.repeatData.monthOption == values[i])
		{
			optionButton.selected = YES;
			monthOptionButton = optionButton;
		}
		
		[cell.contentView addSubview:optionButton];
		
		//UILabel *optionLabel=[[UILabel alloc] initWithFrame:CGRectMake(20 + i*140 + 25, 35, 120, 20)];
        UILabel *optionLabel=[[UILabel alloc] initWithFrame:CGRectMake(20 + i*w + 25, 35, 120, 20)];
		optionLabel.tag = 10307 + i;
		optionLabel.text=options[i];
		optionLabel.backgroundColor=[UIColor clearColor];
		optionLabel.font=[UIFont systemFontOfSize:15];
		optionLabel.textColor=[Colors darkSteelBlue];
		
		[cell.contentView addSubview:optionLabel];
		[optionLabel release];					
	}
}

- (void) createYearlyCell:(UITableViewCell *) cell
{
    CGFloat xMargin = repeatTableView.bounds.size.width - 3*60 - 30;

	UILabel *yearlyLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, 80, 25)];
	yearlyLabel.tag = 10401;
	yearlyLabel.text=_yearlyText;
	yearlyLabel.backgroundColor=[UIColor clearColor];
	yearlyLabel.font=[UIFont systemFontOfSize:16];
	yearlyLabel.textColor=[UIColor grayColor];
	
	[cell.contentView addSubview:yearlyLabel];
	[yearlyLabel release];
	
	//UILabel *everyLabel=[[UILabel alloc] initWithFrame:CGRectMake(100, 5, 60, 25)];
    UILabel *everyLabel=[[UILabel alloc] initWithFrame:CGRectMake(xMargin, 5, 60, 25)];
	everyLabel.tag = 10402;
	everyLabel.text=_everyText;
	everyLabel.backgroundColor=[UIColor clearColor];
	everyLabel.font=[UIFont systemFontOfSize:15];
	everyLabel.textColor=[Colors darkSteelBlue];
	
	[cell.contentView addSubview:everyLabel];
	[everyLabel release];
	
	//UITextField *everyTextField=[[UITextField alloc] initWithFrame:CGRectMake(150, 5, 60, 25)];
	UITextField *everyTextField=[[UITextField alloc] initWithFrame:CGRectMake(xMargin + 50, 5, 60, 25)];
	everyTextField.tag = 10403;
	everyTextField.borderStyle = UITextBorderStyleRoundedRect;
	everyTextField.text=(selectedIndex == 4? [NSString stringWithFormat:@"%d", self.repeatData.interval]:@"1");
	everyTextField.textAlignment = NSTextAlignmentCenter;
	everyTextField.backgroundColor=[UIColor clearColor];
	everyTextField.font=[UIFont systemFontOfSize:15];
	everyTextField.textColor=[Colors darkSteelBlue];
	everyTextField.keyboardType=UIKeyboardTypeNumberPad;
	everyTextField.returnKeyType = UIReturnKeyDone;
	everyTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
	everyTextField.delegate=self;
	
	[cell.contentView addSubview:everyTextField];
	[everyTextField release];
	
	//UILabel *unitLabel=[[UILabel alloc] initWithFrame:CGRectMake(220, 5, 60, 25)];
    UILabel *unitLabel=[[UILabel alloc] initWithFrame:CGRectMake(xMargin + 120, 5, 60, 25)];
	unitLabel.tag = 10404;
	unitLabel.text=_yearUnitText;
	unitLabel.backgroundColor=[UIColor clearColor];
	unitLabel.font=[UIFont systemFontOfSize:15];
	unitLabel.textColor=[Colors darkSteelBlue];
	
	[cell.contentView addSubview:unitLabel];
	[unitLabel release];
}

/*
- (void) createRepeatAfterDoneCell:(UITableViewCell *) cell
{
	UILabel *radLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 25)];
	radLabel.tag = 10501;
	radLabel.text=_repeatAfterDoneText;
	radLabel.backgroundColor=[UIColor clearColor];
	radLabel.font=[UIFont boldSystemFontOfSize:16];
	radLabel.textColor=[UIColor blackColor];
	
	[cell.contentView addSubview:radLabel];
	[radLabel release];
}
*/

- (void) createUntilCell:(UITableViewCell *) cell
{
	UILabel *untilLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 30)];
	untilLabel.tag = 11001;
	untilLabel.text=_untilText;
	untilLabel.backgroundColor=[UIColor clearColor];
	untilLabel.font=[UIFont boldSystemFontOfSize:16];
	untilLabel.textColor=[UIColor blackColor];
	
	[cell.contentView addSubview:untilLabel];
	[untilLabel release];
	
	untilValueLabel=[[UILabel alloc] initWithFrame:CGRectMake(repeatTableView.bounds.size.width - 195 - 30, 0, 195, 25)];
	untilValueLabel.tag = 11002;
	untilValueLabel.textAlignment=NSTextAlignmentRight;
	untilValueLabel.textColor= [Colors darkSteelBlue];
	untilValueLabel.font=[UIFont systemFontOfSize:15];
	untilValueLabel.backgroundColor=[UIColor clearColor];
	
	untilValueLabel.text = (self.repeatData != nil && self.repeatData.until != nil?[Common getFullDateString3:self.repeatData.until]:_foreverText);
	
	[cell.contentView addSubview:untilValueLabel];
	[untilValueLabel release];
	
	UIButton *foreverButton = [Common createButton:_foreverText 
										  buttonType:UIButtonTypeCustom
                               frame:CGRectMake(20, 25, 120, 30) 
										  titleColor:[Colors blueButton]
											  target:self 
											selector:@selector(repeatForever:) 
									normalStateImage:nil
								  selectedStateImage:nil];
	foreverButton.layer.cornerRadius = 4;
    foreverButton.layer.borderColor = [[Colors blueButton] CGColor];
    foreverButton.layer.borderWidth = 1;
    
	foreverButton.tag = 11003;
    //foreverButton.tintColor = [UIColor brownColor];
		
	[cell.contentView addSubview:foreverButton];
	
    /*
	UILabel *slash1Label=[[UILabel alloc] initWithFrame:CGRectMake(73, 30, 10, 25)];
	slash1Label.tag = 11004;
	slash1Label.text=@"/";
	slash1Label.backgroundColor=[UIColor clearColor];
	slash1Label.font=[UIFont systemFontOfSize:15];
	slash1Label.textColor=[Colors darkSteelBlue];	
	[cell.contentView addSubview:slash1Label];
	[slash1Label release];	
    */
	
	UIButton *onDateButton = [Common createButton:_onDateText 
										   buttonType:UIButtonTypeCustom
                              frame:CGRectMake(repeatTableView.bounds.size.width - 120 - 20, 25, 120, 30)
										   titleColor:[Colors blueButton]
											   target:self 
											 selector:@selector(repeatUntil:) 
									 normalStateImage:nil
								   selectedStateImage:nil];
    
    onDateButton.layer.cornerRadius = 4;
    onDateButton.layer.borderColor = [[Colors blueButton] CGColor];
    onDateButton.layer.borderWidth = 1;

	onDateButton.tag = 11005;
    //onDateButton.tintColor = [UIColor brownColor];
    
	[cell.contentView addSubview:onDateButton];
	
    /*
	if (selectedIndex != 5)
	{
		UILabel *slash2Label=[[UILabel alloc] initWithFrame:CGRectMake(143, 30, 10, 25)];
		slash2Label.tag = 11006;
		slash2Label.text=@"/";
		slash2Label.backgroundColor=[UIColor clearColor];
		slash2Label.font=[UIFont systemFontOfSize:15];
		slash2Label.textColor=[Colors darkSteelBlue];	
		[cell.contentView addSubview:slash2Label];
		[slash2Label release];	
		
		
		UILabel *afterLabel=[[UILabel alloc] initWithFrame:CGRectMake(150, 30, 40, 25)];
		afterLabel.tag = 11007;
		afterLabel.text=_afterText;
		afterLabel.backgroundColor=[UIColor clearColor];
		afterLabel.font=[UIFont systemFontOfSize:15];
		afterLabel.textColor=[Colors darkSteelBlue];
		
		[cell.contentView addSubview:afterLabel];
		[afterLabel release];
		
		//UITextField *countTextField=[[UITextField alloc] initWithFrame:CGRectMake(150, 30, 60, 25)];
		UITextField *countTextField=[[UITextField alloc] initWithFrame:CGRectMake(190, 30, 60, 25)];
		countTextField.tag = 11008;
		countTextField.borderStyle = UITextBorderStyleRoundedRect;
		countTextField.text=@"1";
		countTextField.textAlignment = NSTextAlignmentCenter;
		countTextField.backgroundColor=[UIColor clearColor];
		countTextField.font=[UIFont systemFontOfSize:15];
		countTextField.textColor=[Colors darkSteelBlue];
		countTextField.keyboardType=UIKeyboardTypeNumberPad;
		countTextField.returnKeyType = UIReturnKeyDone;
		countTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
		countTextField.delegate=self;
		
		[cell.contentView addSubview:countTextField];
		[countTextField release];
		
		UILabel *countLabel=[[UILabel alloc] initWithFrame:CGRectMake(260, 30, 40, 25)];
		countLabel.tag = 11009;
		countLabel.text=_timesText;
		countLabel.backgroundColor=[UIColor clearColor];
		countLabel.font=[UIFont systemFontOfSize:15];
		countLabel.textColor=[Colors darkSteelBlue];
		
		[cell.contentView addSubview:countLabel];
		[countLabel release];
	}
    */
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
/*	if (self.task.type == TYPE_TASK)
	{
		return 2;
	}
*/
    return (selectedIndex == 0? 1:2);
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (section == 0)
	{		
		return 5;
	}
	
	if (self.task.type == TYPE_TASK && section == 1)
	{
		return 2;
	}
	
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
/*	if ((indexPath.section == 0 && (indexPath.row == 2 || indexPath.row == 3)) ||
		(self.task.type != TYPE_TASK && indexPath.section == 1 && indexPath.row == 0))
	{
		return 60;
	}
*/
    if (indexPath.section == 0 && indexPath.row == 2) //Weekly
    {
        return 90;
    }
    
    if ((indexPath.section == 0 && indexPath.row == 3) || ([self.task isEvent] && indexPath.section == 1 && indexPath.row == 0))
    {
        return 60;
    }
    
	return 40; 
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	else
	{
		for(UIView *view in cell.contentView.subviews)
		{
			if(view.tag >= 10000)
			{
				[view removeFromSuperview];
			}
		}		
	}

    // Set up the cell...
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.textLabel.text = @"";
    
    cell.backgroundColor = [UIColor clearColor];
	
	if (indexPath.section == 0)
	{
		if (indexPath.row == selectedIndex)
		{
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
 				
		switch (indexPath.row) 
		{
			case 0:
			{
				[self createNoneCell:cell];
			}	
				break;
			case 1:
			{
				[self createDailyCell:cell];
			}	
				break;
				
			case 2:
			{
				[self createWeeklyCell:cell];
			}	
				break;
			case 3:
			{
				[self createMonthlyCell:cell];
			}
				break;
			case 4:
			{
				[self createYearlyCell:cell];
			}	
				break;
		}
	}
	else if (indexPath.section == 1)	
	{
		if (self.task.type == TYPE_TASK)
		{
			switch (indexPath.row) 
			{
				case 0:
				{
					cell.textLabel.text = _repeatFromDueText;
				}
					break;
				case 1:
				{
					cell.textLabel.text = _repeatFromCompletionText;
				}
					break;
			}
			
			if (self.repeatData.repeatFrom == indexPath.row)
			{
			
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
		}
		else 
		{
			switch (indexPath.row) 
			{
				case 0:
				{
					[self createUntilCell:cell];
				}
					break;
			}			
		}
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	if (indexPath.section == 0)
	{
		[self selectRowAtIndexPath:indexPath];
	}
	else if (self.task.type == TYPE_TASK && indexPath.section == 1 && self.repeatData.repeatFrom != indexPath.row)
	{
		if (self.task.deadline == nil && indexPath.row == 0)
		{
			[self showRepeatFromDueHint];
		}
		else 
		{
			[[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.repeatData.repeatFrom inSection:1]] setAccessoryType:UITableViewCellAccessoryNone];
			
			[[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
			
			self.repeatData.repeatFrom = indexPath.row;	
		}
	}
			 
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark TextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;	
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	//repeatTableView.frame = CGRectMake(0, 0, 320, 368);
    repeatTableView.frame = contentView.bounds;
    
    if (activeTextField.tag > 11000) //repeat count
    {
        if ([activeTextField.text isEqualToString:@""])
        {
            activeTextField.text = @"1";
        }
        
        [self changeCount:[activeTextField.text intValue]];
        
        untilValueLabel.text = [Common getFullDateString3:self.repeatData.until];
    }
    else 
    {
        int row = (activeTextField.tag-10000)/100;	
        
        [self selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];	
        
        if ([activeTextField.text isEqualToString:@""] || ![self checkforNumeric:activeTextField.text] || [activeTextField.text intValue] < 1)
        {
            activeTextField.text = @"1";
        }
        
        if ([activeTextField.text intValue] > 99) {
            activeTextField.text = @"99";
        }
        
        [self changeInterval:[activeTextField.text intValue]];
    }
    
    activeTextField = nil;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	//repeatTableView.frame = CGRectMake(0, 0, 320, 160);
    
    if (!_isiPad)
    {
        CGRect frm = contentView.bounds;
        
        frm.size.height -= [Common getKeyboardHeight] + 40;
        repeatTableView.frame = frm;
        
        int section = (textField.tag > 11000? 1: 0);
        
        int row = (textField.tag-(textField.tag > 11000?11000:10000))/100;
        
        [repeatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        //doneBarView.hidden = NO;        
    }
	
	activeTextField = textField;
}

- (BOOL)checkforNumeric:(NSString*) str
{
    //NSString *strMatchstring=@"\\b([0-9%_.+\\-]+)\\b";
    NSString *strMatchstring=@"\\b([0-9]+)\\b";
    NSPredicate *textpredicate=[NSPredicate predicateWithFormat:@"SELF MATCHES %@", strMatchstring];
    
    if(![textpredicate evaluateWithObject:str])
    {
        return FALSE;
    }
    return TRUE;
}
@end

