//
//  ProjectInputViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 7/11/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "ProjectInputViewController.h"

#import "Common.h"
#import "Project.h"
#import "Task.h"

#import "ProjectManager.h"

#import "DetailViewController.h"
#import "NoteDetailViewController.h"

extern DetailViewController *_detailViewCtrler;
extern NoteDetailViewController *_noteDetailViewCtrler;

@interface ProjectInputViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation ProjectInputViewController

@synthesize projectList;
@synthesize listTableView;
@synthesize doneItem;
@synthesize task;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc
{
    self.projectList = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //self.view.backgroundColor = [UIColor colorWithRed:209.0/255 green:212.0/255 blue:217.0/255 alpha:1];
    self.view.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    
    self.doneItem.title = _doneText;
    
    self.listTableView.delegate = self;
    self.listTableView.dataSource = self;
    self.listTableView.backgroundColor = [UIColor clearColor];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.projectList = [[ProjectManager getInstance] getVisibleProjectList];
    [self.listTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.projectList = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender
{
    if (_detailViewCtrler != nil)
    {
        [_detailViewCtrler refreshProject];
        [_detailViewCtrler closeInputView];
    }
    else if (_noteDetailViewCtrler != nil)
    {
        [_noteDetailViewCtrler refreshProject];
        [_noteDetailViewCtrler closeInputView];        
    }
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return projectList.count;
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
    
    // Set up the cell...
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	Project *prj = [projectList objectAtIndex:indexPath.row];
	
	cell.textLabel.text = prj.name;
	cell.textLabel.textColor = [Common getColorByID:prj.colorId colorIndex:0];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    cell.backgroundColor = [UIColor clearColor];
	
	if (prj.primaryKey == self.task.project)
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		selectedIndex = indexPath.row;
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (selectedIndex >= 0)
	{
		NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
		
		[[tableView cellForRowAtIndexPath:oldIndexPath] setAccessoryType:UITableViewCellAccessoryNone];
	}
	
	[[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
	
	selectedIndex = indexPath.row;
	
	Project *prj = [projectList objectAtIndex:selectedIndex];
	
	self.task.project = prj.primaryKey;
}

@end
