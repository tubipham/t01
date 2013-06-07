//
//  iPadSmartDayViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 12/3/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//

#import "iPadViewController.h"

#import "Common.h"
#import "FilterData.h"

#import "ContentView.h"

#import "ImageManager.h"
#import "TaskManager.h"
#import "ProjectManager.h"
#import "MusicManager.h"

#import "CalendarViewController.h"
#import "iPadSmartDayViewController.h"
#import "PlannerViewController.h"
#import "iPadSettingViewController.h"

#import "SmartCalAppDelegate.h"

extern BOOL _isiPad;

extern SmartCalAppDelegate *_appDelegate;

extern iPadSmartDayViewController *_iPadSDViewCtrler;

iPadViewController *_iPadViewCtrler;

@interface iPadViewController ()

@end

@implementation iPadViewController

@synthesize activeViewCtrler;

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
        _iPadViewCtrler = self;
    }
    
    return self;
}

- (void) dealloc
{
    self.activeViewCtrler = nil;
    
    [super dealloc];
}

- (void) showCategory:(id) sender
{
    [_iPadSDViewCtrler showCategory];
}

- (void) showTag:(id) sender
{
    [_iPadSDViewCtrler showTag];
}

- (void) showTimer:(id) sender
{
    [_iPadSDViewCtrler showTimer];
}

- (void) deactivateSearchBar
{
    if (searchBar != nil)
    {
        [searchBar resignFirstResponder];
    }
}

- (void) showMenu:(id) sender
{
    [_iPadSDViewCtrler showMenu];
}

- (UIButton *) getTimerButton
{
    return timerButton;
}

- (void) refreshToolbar
{
    if ([self.activeViewCtrler isKindOfClass:[PlannerViewController class]])
    {
        self.navigationItem.leftBarButtonItems = nil;
        
        searchBar = nil;
        timerButton = nil;
        tagButton = nil;
        
        [[self navigationController] setNavigationBarHidden:YES animated:YES];
    }
    else if ([self.activeViewCtrler isKindOfClass:[iPadSmartDayViewController class]])
    {
        [[self navigationController] setNavigationBarHidden:NO animated:YES];
        
        UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:nil];
        
        UIBarButtonItem *fixed40Item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                     target:nil
                                                                                     action:nil];
        fixed40Item.width = 40;
        
        UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                   target:nil
                                                                                   action:nil];
        fixedItem.width = 155;
        
        UIButton *settingButton = [Common createButton:@""
                                            buttonType:UIButtonTypeCustom
                                                 frame:CGRectMake(0, 0, 40, 40)
                                            titleColor:[UIColor whiteColor]
                                                target:self
                                              selector:@selector(showMenu:)
                                      normalStateImage:@"bar_setting.png"
                                    selectedStateImage:nil];
        
        UIBarButtonItem *settingButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingButton];
        
        eyeButton = [Common createButton:@""
                                        buttonType:UIButtonTypeCustom
                                             frame:CGRectMake(0, 0, 40, 40)
                                        titleColor:[UIColor whiteColor]
                                            target:self
                                          selector:@selector(showCategory:)
                                  normalStateImage:@"bar_eye.png"
                                selectedStateImage:nil];
        
        UIBarButtonItem *eyeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:eyeButton];
        
        tagButton = [Common createButton:@""
                                        buttonType:UIButtonTypeCustom
                                             frame:CGRectMake(0, 0, 40, 40)
                                        titleColor:[UIColor whiteColor]
                                            target:self
                                          selector:@selector(showTag:)
                                  normalStateImage:@"bar_tag.png"
                                selectedStateImage:nil];
        
        UIBarButtonItem *tagButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tagButton];
        
        timerButton = [Common createButton:@""
                                buttonType:UIButtonTypeCustom
                                     frame:CGRectMake(0, 0, 40, 40)
                                titleColor:[UIColor whiteColor]
                                    target:self
                                  selector:@selector(showTimer:)
                          normalStateImage:@"bar_timer.png"
                        selectedStateImage:nil];
        
        UIBarButtonItem *timerButtonItem = [[UIBarButtonItem alloc] initWithCustomView:timerButton];
        
        searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
        searchBar.placeholder = _seekOrCreate;
        searchBar.translucent = YES;
        searchBar.delegate = self;
        
        UIBarButtonItem *searchBarItem = [[UIBarButtonItem alloc] initWithCustomView:searchBar];
        [searchBar release];
        
        NSArray *items = [NSArray arrayWithObjects:settingButtonItem, fixed40Item, eyeButtonItem, fixed40Item, tagButtonItem, fixedItem, timerButtonItem, flexItem, searchBarItem,nil];
        //NSArray *items = [NSArray arrayWithObjects:settingButtonItem, fixed40Item, eyeButtonItem, fixed40Item, tagButtonItem, flexItem, searchBarItem,nil];
        
        [flexItem release];
        [fixedItem release];
        [fixed40Item release];
        [timerButtonItem release];
        [settingButtonItem release];
        [eyeButtonItem release];
        [tagButtonItem release];
        [searchBarItem release];
        
        self.navigationItem.leftBarButtonItems = items;
    }
}

- (void) refreshFilterStatus
{
    if (tagButton != nil)
    {
        TaskManager *tm = [TaskManager getInstance];
        
        [tagButton setImage:[UIImage imageNamed:@"bar_tag.png"] forState:UIControlStateNormal];
        
        if (tm.filterData != nil && ![tm.filterData.tag isEqualToString:@""])
        {
            [tagButton setImage:[UIImage imageNamed:@"bar_tag_blue.png"] forState:UIControlStateNormal];            
        }
    }

    if (eyeButton != nil)
    {
        [eyeButton setImage:[UIImage imageNamed:@"bar_eye.png"] forState:UIControlStateNormal];

        BOOL checkInvisible = [[[ProjectManager getInstance] getInvisibleProjectDict] count] > 0;
        
        if (checkInvisible)
        {
            [eyeButton setImage:[UIImage imageNamed:@"bar_eye_blue.png"] forState:UIControlStateNormal];
        }
    }
}

-(void)changeSkin
{
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        [self.navigationController.navigationBar setBackgroundImage:[[ImageManager getInstance] getImageWithName:@"top_bg.png"] forBarMetrics:UIBarMetricsDefault];
    }
}


#pragma mark View

- (void) showLandscapeView
{
    if (_iPadSDViewCtrler != nil)
    {
        [_iPadSDViewCtrler showTaskModule:NO];
    }
    
    if (self.activeViewCtrler != nil && [self.activeViewCtrler.view superview])
    {
        [self.activeViewCtrler.view removeFromSuperview];
    }
        
    PlannerViewController *ctrler = [[PlannerViewController alloc] init];
    
    self.activeViewCtrler = ctrler;
    
    [ctrler release];
    
    [contentView addSubview:self.activeViewCtrler.view];

    [ctrler refreshTaskFilterTitle];
    
    [self refreshToolbar];
}

- (void) showPortraitView
{
    if (self.activeViewCtrler != nil && [self.activeViewCtrler.view superview])
    {
        [self.activeViewCtrler.view removeFromSuperview];
    }

    self.activeViewCtrler = _iPadSDViewCtrler;
    
    [contentView addSubview:self.activeViewCtrler.view];
    
    if (_iPadSDViewCtrler != nil)
    {
        [_iPadSDViewCtrler showTaskModule:YES];
    }

    [_iPadSDViewCtrler refreshTaskFilterTitle];
    
    [self refreshToolbar];
}

- (void) loadView
{
    CGRect frm = [Common getFrame];
    
    contentView = [[ContentView alloc] initWithFrame:frm];
    
    //contentView.backgroundColor = [UIColor darkGrayColor];
    contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern_dark.png"]];
    
    self.view = contentView;
    
    [self showPortraitView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self changeSkin];
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        [self showLandscapeView];
        
        if ([self.activeViewCtrler isKindOfClass:[PlannerViewController class]])
        {
            PlannerViewController *ctrler = (PlannerViewController *) self.activeViewCtrler;
            
            [ctrler viewWillAppear:NO];
        }
    }
    else
    {
        [self showPortraitView];
    }
    
    [self refreshFilterStatus];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[_iPadSDViewCtrler getCalendarViewController] stopQuickAdd];
}

-(NSUInteger)supportedInterfaceOrientations
{
     return UIInterfaceOrientationMaskAll;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_appDelegate dismissAllAlertViews];
    
    CGSize sz = [Common getScreenSize];
    sz.height += 20 + 44;
    
    CGRect frm = CGRectZero;
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        frm.size.height = sz.width;
        frm.size.width = sz.height;
        
        [self showLandscapeView];
    }
    else
    {
        frm.size = sz;
        
        [self showPortraitView];
    }
    
    contentView.frame = frm;    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) quickCreate:(NSString *)text
{
    NSString *str = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (str.length > 2)
    {
        NSString *prefix = [str substringToIndex:2];
        
        BOOL taskPrefix = [prefix isEqualToString:@"#t"];
        BOOL eventPrefix = [prefix isEqualToString:@"#e"];
        BOOL notePrefix = [prefix isEqualToString:@"#n"];
        
        if (taskPrefix || eventPrefix || notePrefix)
        {
            str = [[str substringFromIndex:2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSInteger type = eventPrefix?TYPE_EVENT:(notePrefix?TYPE_NOTE:TYPE_TASK);
            
            [_iPadSDViewCtrler quickAddItem:str type:type];
            
            return YES;
        }
    }
    
    return NO;
}

- (void) search:(NSString *)text
{
    NSString *str = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (str.length > 1 && [str characterAtIndex:0] == '#')
    {
        NSInteger n = 1;
        
        if (str.length > 1 && ([str characterAtIndex:1] == 't' || [str characterAtIndex:1] == 'e' || [str characterAtIndex:1] == 'n'))
        {
            n = 2;
        }
        
        str = [[text substringFromIndex:n] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    [_iPadSDViewCtrler showSeekOrCreate:str];
}

#pragma mark UISearchBar delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [_iPadSDViewCtrler hideDropDownMenu];
    
	return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self search:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self search:searchBar.text];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
}

- (BOOL) searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        //printf("return \n");
        
        if ([self quickCreate:searchBar.text])
        {
            searchBar.text = @"";
            [searchBar resignFirstResponder];
            
            [_iPadSDViewCtrler showSeekOrCreate:@""];//dismiss
            
            return NO;
        }
    }
    
    return YES;
}


@end
