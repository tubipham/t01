//
//  GuruViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 10/16/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "GuruViewController.h"

#import "Common.h"
#import "Settings.h"

#import "SDWSync.h"

#import "ContentView.h"
#import "ContentScrollView.h"
#import "GuideWebView.h"

#import "GuideWebView.h"

#import "iPadViewController.h"
#import "SmartDayViewController.h"

extern iPadViewController *_iPadViewCtrler;
extern SmartDayViewController *_sdViewCtrler;

#define PAGE_NUM 5

@interface GuruViewController ()

@end

@implementation GuruViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark Actions

//- (void)checkValidity:(id)sender
- (void) go2Page5:(id)sender
{
    CGPoint contentOffset = CGPointMake(4*scrollView.bounds.size.width, 0);
    
    [scrollView setContentOffset:contentOffset animated:YES];
}

- (void)signin:(id)sender
{
    [emailTextField resignFirstResponder];
    [pwdTextField resignFirstResponder];
    
    NSString *sdwEmail = emailTextField.text;
    NSString *sdwPassword = pwdTextField.text;
    
    NSInteger errorCode = [SDWSync checkUserValidity:sdwEmail password:sdwPassword];
    
    //self.setting.sdwVerified = (errorCode == 0);
    
    NSString *msg = (errorCode == -1004?_wifiConnectionOffText:(errorCode == 0?_sdwAccountValidText:_sdwAccountInvalidText));
    
    if (errorCode == 0)
    {
        Settings *settings = [Settings getInstance];
        
        settings.sdwEmail = sdwEmail;
        settings.sdwPassword = sdwPassword;
        settings.sdwVerified = YES;
        settings.sdwSyncEnabled = YES;
        
        settings.syncEnabled = YES;
        
        [settings saveSettingDict];
        [settings saveMSDAccount];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorCode == -1004? _checkValidityText:(errorCode == 0?_verifiedTitleText:_invalidAccountText) message:msg delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)signup:(id)sender
{
    BOOL emailValid = [Common validateEmail:emailTextField.text];
    
    if (emailValid)
    {
        NSString *errorMsg = [[SDWSync getInstance] createNewAccount:emailTextField.text passWord:pwdTextField.text];
        
        NSString *msg = (errorMsg == nil?_sdwSignupSuccessText:[NSString stringWithFormat:@"%@ %@", _sdwSignupFailedText, errorMsg]);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_signupText message:msg delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_signupText message:_emailInvalidText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
        [alert show];
        [alert release];
        
    }
}

- (void) startSmartDay:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    Settings *settings = [Settings getInstance];
    
    [settings enableGuruHint:NO];
}

- (IBAction)changePage:(id)sender {
    CGFloat x = pageControl.currentPage * scrollView.frame.size.width;
    [scrollView setContentOffset:CGPointMake(x, 0) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
}


#pragma mark View

- (UIScrollView *) createLoginPage:(CGRect)frm
{
    Settings *settings = [Settings getInstance];
    
    UIScrollView *pageView = [[[UIScrollView alloc] initWithFrame:frm] autorelease];
    pageView.backgroundColor = [UIColor clearColor];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:pageView.bounds];
    
    imgView.image = [UIImage imageNamed:_isiPad?@"slider_5.jpg":(IS_IPHONE_5?@"slider_5_iphone5.jpg":@"slider_5_iphone4.jpg")];
    
    [pageView addSubview:imgView];
    [imgView release];
    
    CGFloat titleY = (_isiPad?280:(IS_IPHONE_5?130:120));
    CGFloat titleX = (_isiPad?280:90);
    
    GuideWebView *webView = [[GuideWebView alloc] initWithFrame:CGRectMake(titleX, titleY, 240, 50)];
    webView.backgroundColor = [UIColor clearColor];
    
    webView.safariEnabled = YES;
    
    NSString *link = @"http://www.leftcoastlogic.com/smartday/online/";
    
    NSString *url = _isiPad?[NSString stringWithFormat:@"<a style='font-size:28px;font-family:Helvetica;color:#007AFF;text-decoration:none' href='%@'>%@</a>", link, _SmartDayOnline]:[NSString stringWithFormat:@"<a style='font-size:20px;font-family:Helvetica;color:#007AFF;text-decoration:none' href='%@'>%@</a>", link, _SmartDayOnline];
    
    [webView loadHTMLContent:url];
    
    [pageView addSubview:webView];
    
    [webView release];
    
    
    CGFloat marginY = (_isiPad?340:(IS_IPHONE_5?150:140));
    CGFloat marginX = (_isiPad?180:40);
    CGFloat width = _isiPad?400:240;
    CGFloat pad = _isiPad?70:50;
    
    /*
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(marginX, marginY+10, width, 100)];
    
    hintLabel.backgroundColor = [UIColor clearColor];
    hintLabel.text =_SmartDayOnlineRegistration;
    hintLabel.numberOfLines = 0;
    hintLabel.font = [UIFont systemFontOfSize:_isiPad?16:13];
    hintLabel.textColor = [UIColor grayColor];
    
    [pageView addSubview:hintLabel];
    [hintLabel release];
    */
	
    //CGFloat y = marginY+ (_isiPad || IS_IPHONE_5?120:100);
    
    CGFloat y = marginY + (_isiPad || IS_IPHONE_5?60:50);
	
	emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(marginX, y, width, 35)];
    emailTextField.backgroundColor = [UIColor whiteColor];
	emailTextField.text = settings.sdwEmail;
	emailTextField.delegate = self;
	//emailTextField.borderStyle = UITextBorderStyleLine;
	emailTextField.keyboardType=UIKeyboardTypeDefault;
	emailTextField.returnKeyType = UIReturnKeyDone;
	emailTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
	emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    emailTextField.placeholder = _emailText;
	
	[pageView addSubview:emailTextField];
	[emailTextField release];
	
    y += pad;
    
	pwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(marginX, y, width, 35)];
    pwdTextField.backgroundColor = [UIColor whiteColor];
	pwdTextField.text = settings.sdwPassword;
	pwdTextField.secureTextEntry = YES;
	pwdTextField.delegate = self;
	//pwdTextField.borderStyle = UITextBorderStyleRoundedRect;
	pwdTextField.keyboardType=UIKeyboardTypeDefault;
	pwdTextField.returnKeyType = UIReturnKeyDone;
	pwdTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
    pwdTextField.placeholder = _passwordText;
	
	[pageView addSubview:pwdTextField];
	[pwdTextField release];
	
    /*
	UIButton *checkButton=[Common createButton:_checkValidityText
                                    buttonType:UIButtonTypeRoundedRect
                                         frame:CGRectMake(marginX, marginY+150, 160, 25)
                                    titleColor:nil
                                        target:self
                                      selector:@selector(checkValidity:)
                              normalStateImage:nil
                            selectedStateImage:nil];
	[checkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    checkButton.titleLabel.font=[UIFont boldSystemFontOfSize:16];
	
	[pageView addSubview:checkButton];*/
    
    y += pad;
    
	UIButton *signupButton=[Common createButton:_signupText
                                     buttonType:UIButtonTypeRoundedRect
                                          //frame:CGRectMake(marginX + (width - 100)/2, y, 100, 25)
                                        frame:CGRectMake(marginX, y, 60, 25)
                                     titleColor:[Colors blueButton]
                                         target:self 
                                       selector:@selector(signup:) 
                               normalStateImage:nil
                             selectedStateImage:nil];
    signupButton.titleLabel.font=[UIFont systemFontOfSize:16];
    signupButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    
	[pageView addSubview:signupButton];
    
	UIButton *signinButton=[Common createButton:_signinText
                                     buttonType:UIButtonTypeRoundedRect
                                          frame:CGRectMake(marginX + width - 60, y, 60, 25)
                                     titleColor:[Colors blueButton]
                                         target:self
                                       selector:@selector(signin:)
                               normalStateImage:nil
                             selectedStateImage:nil];
    
    signinButton.titleLabel.font=[UIFont systemFontOfSize:16];
    signinButton.titleLabel.textAlignment = NSTextAlignmentRight;
    
	[pageView addSubview:signinButton];
    
    return pageView;
    
}

- (void) initPages
{
    NSString *pages[PAGE_NUM-1] = {
        _isiPad?@"slider_1_768":(IS_IPHONE_5?@"slider_1_iphone5":@"slider_1_iphone4"),
        _isiPad?@"slider_2_768":(IS_IPHONE_5?@"slider_2_iphone5":@"slider_2_iphone4"),
        _isiPad?@"slider_3_768":(IS_IPHONE_5?@"slider_3_iphone5":@"slider_3_iphone4"),
        _isiPad?@"slider_4_768":(IS_IPHONE_5?@"slider_4_iphone5":@"slider_4_iphone4")};
    
    for (int i=0; i<PAGE_NUM; i++)
    {
        CGRect frm = contentView.bounds;
        frm.origin.x = i*frm.size.width;
        
        if (i==PAGE_NUM-1)
        {
            //login page
            
            UIView *pageView = [self createLoginPage:frm];
            
            [scrollView addSubview:pageView];
        }
        else
        {
            GuideWebView *pageView = [[GuideWebView alloc] initWithFrame:frm];
            pageView.backgroundColor = [UIColor clearColor];
            pageView.userInteractionEnabled = NO;
            
            NSString *page = pages[i];
            
            [pageView loadHTMLFile:page extension:@"html"];
            
            [scrollView addSubview:pageView];
            
            [pageView release];
            
        }
    }
}

- (void) loadView
{
    CGSize sz = [Common getScreenSize];
    
    sz.height += 44;
    
    CGRect frm = CGRectZero;
    frm.origin.y = 20;
    
    frm.size = sz;
    
    contentView = [[ContentView alloc] initWithFrame:frm];
    
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    
    self.view = contentView;
    
    [contentView release];
    
    scrollView = [[ContentScrollView alloc] initWithFrame:frm];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * PAGE_NUM, scrollView.frame.size.height);
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    
    [contentView addSubview:scrollView];
    
    [scrollView release];
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, contentView.bounds.size.height-70, contentView.bounds.size.width, 20)];
    pageControl.numberOfPages = scrollView.contentSize.width/scrollView.frame.size.width;
    [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    
    [contentView addSubview:pageControl];
    [pageControl release];
    
    UIButton *startButton = [Common createButton:_startText
                                       buttonType:UIButtonTypeCustom
                                           frame:CGRectMake(10 + (_isiPad?100:0), contentView.bounds.size.height-40, 80, 40)
                                       titleColor:[UIColor whiteColor]
                                           target:self
                                         selector:@selector(startSmartDay:)
                                 normalStateImage:nil
                               selectedStateImage:nil];
    
    startButton.titleLabel.font = [UIFont systemFontOfSize:18];
    
    startButton.layer.cornerRadius = 10;
    startButton.layer.borderWidth = 1;
    startButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    [contentView addSubview:startButton];
    
    UIButton *sdOnlineButton = [Common createButton:_SmartDayOnline
                                      buttonType:UIButtonTypeCustom
                                           frame:CGRectMake(contentView.bounds.size.width-170-(_isiPad?100:0), contentView.bounds.size.height-40, 160, 40)
                                      titleColor:[UIColor whiteColor]
                                          target:self
                                        selector:@selector(go2Page5:)
                                normalStateImage:nil
                              selectedStateImage:nil];
    
    sdOnlineButton.titleLabel.font = [UIFont systemFontOfSize:18];
    
    sdOnlineButton.layer.cornerRadius = 10;
    sdOnlineButton.layer.borderWidth = 1;
    sdOnlineButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    [contentView addSubview:sdOnlineButton];
    
    
    [self initPages];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewWillDisappear:(BOOL)animated
{
    if (_iPadViewCtrler != nil)
    {
        [_iPadViewCtrler changeOrientation:_iPadViewCtrler.interfaceOrientation];
    }
    else if (_sdViewCtrler != nil)
    {
        [_sdViewCtrler changeOrientation:_sdViewCtrler.interfaceOrientation];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark TextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	/*if (![emailTextField.text isEqualToString:@""] && ![pwdTextField.text isEqualToString:@""])
	{
        [emailTextField resignFirstResponder];
        [pwdTextField resignFirstResponder];
	}
	else if([textField isEqual:emailTextField])
	{
		[emailTextField resignFirstResponder];
		[pwdTextField becomeFirstResponder];
	}
	else if([textField isEqual:pwdTextField])
	{
		[pwdTextField resignFirstResponder];
		[emailTextField becomeFirstResponder];
	}*/
    
    [emailTextField resignFirstResponder];
    [pwdTextField resignFirstResponder];
    
    if (!_isiPad && !IS_IPHONE_5)
    {
        UIScrollView *superView = (UIScrollView *)textField.superview;
        
        superView.contentOffset = CGPointMake(0, 0);
    }
    
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (!_isiPad && !IS_IPHONE_5)
    {
        UIScrollView *superView = (UIScrollView *)textField.superview;
        
        superView.contentOffset = CGPointMake(0, 90);
    }
}

@end