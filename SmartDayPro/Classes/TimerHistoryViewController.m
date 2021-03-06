//
//  TimerHistoryViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 3/4/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <MessageUI/MFMailComposeViewController.h>

#import "TimerHistoryViewController.h"

#import "Common.h"
#import "Task.h"
#import "TaskProgress.h"

#import "DBManager.h"
#import "ProjectManager.h"

#import "ContentView.h"

//extern BOOL _isiPad;

#import "iPadViewController.h"
#import "SmartDayViewController.h"

extern iPadViewController *_iPadViewCtrler;
extern SmartDayViewController *_sdViewCtrler;

@implementation TimerHistoryViewController

@synthesize task;
@synthesize progressList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) init
{
    if (self = [super init])
    {
        self.preferredContentSize = CGSizeMake(320,416);
    }
    
    return self;
}

- (void) dealloc
{
    self.progressList = nil;
    
    [super dealloc];
}

- (void) report:(id) sender
{
    ProjectManager *pm = [ProjectManager getInstance];
    
    //NSString *mailBody = [NSString stringWithFormat:@"Hi,\n This is a report of task '%@' from SmartDay. You can view it in any spreadsheet.", self.task.name];
    
    NSString *mailBody = [NSString stringWithFormat:_reportEmailHeader, self.task.name];

    NSString *csvContent = @"Project, Task Name, Duration, Start Date, Due Date, Completed Date, Timer Duration, Segment No, From Time, To Time, Sub Total \n";
    
    TaskProgress *progress = [self.progressList objectAtIndex:0];
    NSInteger duration = [Common timeIntervalNoDST:progress.endTime sinceDate:progress.startTime];
    
    csvContent = [csvContent stringByAppendingString:[NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%d,%@,%@,%@\n",
                                                     [pm getProjectNameByKey:self.task.project],
                                                      self.task.name,
                                                      [Common getDurationString:self.task.duration],
                                                      self.task.startTime == nil? @"None":[Common getFullDateString:self.task.startTime],
                                                      self.task.deadline == nil? @"None":[Common getFullDateString:self.task.deadline],
                                                      self.task.completionTime == nil? @"None":[Common getFullDateString:self.task.completionTime],
                                                      [Common getTimerDurationString:actualDuration],
                                                      1,
                                                      [Common getFullDateTimeString2:progress.startTime],
                                                      [Common getFullDateTimeString2:progress.endTime],
                                                      [Common getTimerDurationString:duration]
                                                      ]];
    
    for (int i=1; i<self.progressList.count; i++)
    {
        TaskProgress *progress = [self.progressList objectAtIndex:i];
        NSInteger duration = [Common timeIntervalNoDST:progress.endTime sinceDate:progress.startTime];
        
        csvContent = [csvContent stringByAppendingString:[NSString stringWithFormat:@",,,,,,,%d,%@,%@,%@\n",
                                                          i+1,
                                                          [Common getFullDateTimeString2:progress.startTime],
                                                          [Common getFullDateTimeString2:progress.endTime],
                                                          [Common getTimerDurationString:duration]
                                                          ]];
        
    }

	MFMailComposeViewController *picker = [[[MFMailComposeViewController alloc] init] autorelease];
	if (picker) {
		picker.mailComposeDelegate=self;
		//[picker setSubject:@"SmartDay Report"];
        [picker setSubject:_reportEmailSubject];
		
		[picker setToRecipients:nil];
		[picker setCcRecipients:nil];
		[picker setBccRecipients:nil];
		
		if(csvContent)
        {
			NSData *myData = [csvContent dataUsingEncoding:NSUTF8StringEncoding];
			[picker addAttachmentData:myData mimeType:@"text/csv" fileName:@"SmartDay_Report.csv"];
		}
		
		// Fill out the email body text
		if(mailBody)
        {
			[picker setMessageBody:mailBody isHTML:YES];
		}
        
        UIViewController *ctrler = (_isiPad?_iPadViewCtrler:_sdViewCtrler);
        
		[ctrler presentModalViewController:picker animated:NO];
	}
}

#pragma mark View

- (void) loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
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
    
    ContentView *contentView = [[ContentView alloc] initWithFrame:frm];
    //contentView.backgroundColor = [UIColor colorWithRed:209.0/255 green:212.0/255 blue:217.0/255 alpha:1];
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    self.view = contentView;
    
    [contentView release];
    
    historyTableView = [[UITableView alloc] initWithFrame:CGRectInset(contentView.bounds, 5, 5) style:UITableViewStylePlain];
    
    historyTableView.delegate = self;
    historyTableView.dataSource = self;
    historyTableView.backgroundColor = [UIColor clearColor];
    
	[contentView addSubview:historyTableView];
	[historyTableView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    DBManager *dbm = [DBManager getInstance];
    
    self.progressList = [dbm getProgressHistoryForTask:self.task.primaryKey];
    
	actualDuration = 0;
	
	for (TaskProgress *progress in self.progressList)
	{
		actualDuration += [Common timeIntervalNoDST:progress.endTime sinceDate:progress.startTime];
	}

    [historyTableView reloadData];
    
	UIButton *reportButton = [Common createButton:@""
                                    buttonType:UIButtonTypeCustom
                                         frame:CGRectMake(0, 0, 40, 40)
                                    titleColor:[UIColor whiteColor]
                                        target:self
                                      selector:@selector(report:)
                              normalStateImage:@"report.png"
                            selectedStateImage:nil];
    
    self.navigationItem.title = _timerHistoryText;
	
	UIBarButtonItem *reportButtonItem = [[UIBarButtonItem alloc] initWithCustomView:reportButton];
    
    reportButtonItem.enabled = (self.progressList.count > 0);
    
    self.navigationItem.rightBarButtonItem = reportButtonItem;
    
    [reportButtonItem release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.progressList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0)
        return 40.0f;
    
    return 0.01f;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        CGRect frm = tableView.bounds;
        frm.size.height = 40;
        
        UILabel *label = [[UILabel alloc] initWithFrame:frm];
        label.backgroundColor = [UIColor clearColor];
        label.text = [_totalDurationText stringByAppendingFormat:@": %@", [Common getDurationString:actualDuration]];;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:16];
        label.textColor = [UIColor lightGrayColor];
        
        return [label autorelease];
    }
    
    return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
	return [_totalDurationText stringByAppendingFormat:@": %@", [Common getDurationString:actualDuration]];
}
*/
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
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.backgroundColor = [UIColor clearColor];
    
    TaskProgress *progress = [self.progressList objectAtIndex:indexPath.row];
    
    NSInteger duration = [Common timeIntervalNoDST:progress.endTime sinceDate:progress.startTime];
    
    UILabel *timeValueLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, 180, 25)];
    timeValueLabel.tag = 10013;
    timeValueLabel.textAlignment=UITextAlignmentLeft;
    timeValueLabel.font = [UIFont systemFontOfSize:16];
    timeValueLabel.textColor= [UIColor grayColor];
    timeValueLabel.backgroundColor=[UIColor clearColor];
    
    timeValueLabel.text = [Common getDateTimeString:progress.startTime];
    
    [cell.contentView addSubview:timeValueLabel];
    [timeValueLabel release];
    
    UILabel *durationValueLabel=[[UILabel alloc] initWithFrame:CGRectMake(historyTableView.bounds.size.width-120, 5, 100, 25)];
    durationValueLabel.tag = 10014;
    durationValueLabel.textAlignment=UITextAlignmentRight;
    durationValueLabel.font = [UIFont systemFontOfSize:16];
    durationValueLabel.textColor = [UIColor grayColor];
    durationValueLabel.backgroundColor=[UIColor clearColor];
    
    durationValueLabel.text = [Common getTimerDurationString:duration];
    
    [cell.contentView addSubview:durationValueLabel];
    [durationValueLabel release];
    
    return cell;
}

#pragma mark Mail
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
	if(result == MFMailComposeResultSent)
    {
		UIAlertView *sentAlertView = [[UIAlertView alloc] initWithTitle:nil
															  message:_reportSuccess
															 delegate:nil
													cancelButtonTitle:_okText
													otherButtonTitles:nil];
		[sentAlertView show];
		[sentAlertView release];
	}
    else if(result == MFMailComposeResultFailed)
    {
		UIAlertView *failedAlertView=[[UIAlertView alloc] initWithTitle:nil
																message:_reportFailure
															   delegate:nil
													  cancelButtonTitle:_okText
													  otherButtonTitles:nil];
		[failedAlertView show];
		[failedAlertView release];
	}	
	
}


@end
