//
//  RestoreViewController.m
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 6/26/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "RestoreViewController.h"
#import "Common.h"
#import "SmartCalAppDelegate.h"

extern BOOL _isiPad;

@interface RestoreViewController ()

@end

@implementation RestoreViewController

- (id)init
{
    if (self) {
        self.contentSizeForViewInPopover = CGSizeMake(320,416);
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *backupPath = [documentsDirectory stringByAppendingPathComponent:@"Backup"];
        NSError * error = nil;
        
        backupDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:backupPath error:&error];
    }
    return self;
}

- (void)loadView
{
    //CGRect frm = CGRectMake(0, 0, 320, 416);
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    if (_isiPad)
    {
        frm.size.width = 2*frm.size.width/3;
    }
    else
    {
        frm.size.width = 320;
    }
    
    UIView *contentView = [[UIView alloc] initWithFrame:frm];
    contentView.backgroundColor = [UIColor darkGrayColor];
    
    self.view = contentView;
    [contentView release];
    
    // list file table
    listFileTableView = [[UITableView alloc] initWithFrame:contentView.bounds style:UITableViewStyleGrouped];
	listFileTableView.delegate = self;
	listFileTableView.dataSource = self;
	[contentView addSubview:listFileTableView];
	[listFileTableView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [super dealloc];
    backupDirectoryContents = nil;
}

#pragma mark - Actions
- (void)restoreDBFromLocalFile: (NSString *) filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dBPath = [documentsDirectory stringByAppendingPathComponent:@"SmartCalDB.sql"];
    NSError * error = nil;
    
    if ([fileManager fileExistsAtPath:dBPath] == YES) {
        [fileManager removeItemAtPath:dBPath error:&error];
    }
    [fileManager copyItemAtPath:filePath toPath:dBPath error:&error];
    
    exit(0);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return backupDirectoryContents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	else
	{
		for(UIView *view in cell.contentView.subviews)
		{
            [view removeFromSuperview];
		}
	}
    
    // Set up the cell...
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryNone;
    NSString *fileName = [backupDirectoryContents objectAtIndex:indexPath.row];
	cell.textLabel.text = fileName;
	cell.textLabel.backgroundColor = [UIColor clearColor];
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *backupPath = [documentsDirectory stringByAppendingPathComponent:@"Backup"];
    NSError * error = nil;
    
    backupDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:backupPath error:&error];
    
    NSString *fileName = [backupDirectoryContents objectAtIndex:indexPath.row];
    NSString *filePath = [backupPath stringByAppendingPathComponent:fileName];
    [self restoreDBFromLocalFile:filePath];
}

@end