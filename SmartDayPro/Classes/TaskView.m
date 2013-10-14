//
//  TaskView.m
//  SmartCal
//
//  Created by Trung Nguyen on 5/20/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "TaskView.h"

#import "Common.h"
#import "Settings.h"
#import "Colors.h"
#import "Task.h"

#import "ProjectManager.h"
#import "DBManager.h"
#import "ImageManager.h"

#import "SimpleCoreTextView.h"

#import "SmartListViewController.h"
#import "CalendarViewController.h"

#import "AbstractSDViewController.h"
#import "PlannerViewController.h"
#import "PlannerBottomDayCal.h"
#import "iPadViewController.h"
#import "SmartDayViewController.h"

extern SmartListViewController *_smartListViewCtrler;
extern CalendarViewController *_sc2ViewCtrler;

extern AbstractSDViewController *_abstractViewCtrler;
extern PlannerViewController *_plannerViewCtrler;

extern iPadViewController *_iPadViewCtrler;
extern SmartDayViewController *_sdViewCtrler;

@implementation TaskView

@synthesize checkEnable;
@synthesize starEnable;
@synthesize transparent;
@synthesize listStyle;
@synthesize focusStyle;
@synthesize showListBorder;
@synthesize showSeparator;
@synthesize showDue;
@synthesize showFlag;
@synthesize showDuration;

@synthesize task;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        
        self.checkEnable = YES;
        
        checkView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TASK_HEIGHT, TASK_HEIGHT)];
        
        [self addSubview:checkView];
        [checkView release];
        
        checkImageView = [[UIImageView alloc] initWithFrame:CGRectMake((checkView.bounds.size.width - 20)/2, (checkView.bounds.size.height - 20)/2, 20, 20)];
        [checkView addSubview:checkImageView];
        [checkImageView release];
        
        checkButton = [Common createButton:@""
                                buttonType:UIButtonTypeCustom
                                     frame:checkView.bounds//CGRectMake(0, 0, TASK_HEIGHT, frame.size.height)
                                titleColor:[UIColor whiteColor]
                                    target:self
                                  selector:@selector(check:)
                          normalStateImage:nil
                        selectedStateImage:nil];
        checkButton.backgroundColor=[UIColor clearColor];
        [checkView addSubview:checkButton];
        
        [self refreshCheckImage];
		
        starView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width - 40, 0, 40, frame.size.height)];
        //starView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 40, frame.size.height)];
        starView.userInteractionEnabled = NO;
        starView.backgroundColor = [UIColor clearColor];
        
        [self addSubview:starView];
        [starView release];
        
        //starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(starView.bounds.size.width - 20 -2, (starView.bounds.size.height-20)/2-2, 20, 20)];
        
        //starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 8, 20, 20)];
        starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (frame.size.height-20)/2, 20, 20)];
        
        [starView addSubview:starImageView];
        [starImageView release];
        
        starButton=[Common createButton:@""
                                       buttonType:UIButtonTypeCustom
                              //frame:CGRectMake(frame.size.width - 40, 0, 40, frame.size.height)
                                            frame:starView.bounds
                                       titleColor:[UIColor whiteColor]
                                           target:self
                                         selector:@selector(star:)
                                 normalStateImage:nil
                                selectedStateImage:nil];
        starButton.backgroundColor=[UIColor clearColor];
        [starView addSubview:starButton];

        [self refreshStarImage];
        
        self.multiSelectionEnable = NO;
        
        self.transparent = NO;
        
        self.listStyle = NO;
        self.focusStyle = NO;
        self.showListBorder = NO;
        self.showSeparator = YES;
        
        self.showDue = NO;
        self.showFlag = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(appBusy:)
													 name:@"AppBusyNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(appNoBusy:)
													 name:@"AppNoBusyNotification" object:nil];
    }
    return self;	
}

- (void) changeFrame:(CGRect)frame
{
    [super changeFrame:frame];
    
    starView.frame = CGRectMake(frame.size.width - 40, 0, 40, frame.size.height);
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
     
    self.task = nil;
    
    [super dealloc];
}

/*
- (void) setListStyle:(BOOL)style
{
    listStyle = style;
    
    if (listStyle)
    {
        self.layer.cornerRadius = 6;
        [self setClipsToBounds:YES];
        //self.backgroundColor = [UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1];
        self.backgroundColor = [Colors snow3];
    }
}
*/

#pragma mark Support

-(void)refreshStarImage
{
	if (!self.starEnable)
	{
		starImageView.image = nil;
	}
	else
	{	
		//Task *task = (Task *)self.tag;
		
		starImageView.image = [[ImageManager getInstance] getImageWithName:(task.status == TASK_STATUS_PINNED? @"star.png":@"unstar.png")];
	}
    
    starView.userInteractionEnabled = self.starEnable;
}

-(void)refreshCheckImage_old
{
    //Task *task = (Task *)self.tag;
    
    if (self.multiSelectionEnable)
    {
        checkImageView.image = [[ImageManager getInstance] getImageWithName:checkButton.selected?@"multiOn.png":@"multiOff.png"];
    }
    else
    {
        checkButton.selected = [task isDone];
        checkImageView.image = (checkButton.selected?[[ImageManager getInstance] getImageWithName:@"markdone.png"]:nil);        
    }
    
    checkView.userInteractionEnabled = self.checkEnable;
}

-(void)refreshCheckImage
{
    if (!self.checkEnable)
    {
        checkImageView.image = nil;
        checkView.userInteractionEnabled = NO;
        return;
    }
    
    if (self.listStyle) {
        checkImageView.image = [[ImageManager getInstance] getImageWithName:checkButton.selected?@"multiOn.png":@"multiOff.png"];
        checkView.userInteractionEnabled = YES;
    } else {
        //checkButton.selected = [task isDone];
        checkImageView.image = (checkButton.selected?[[ImageManager getInstance] getImageWithName:@"markdone.png"]:nil);
        checkView.userInteractionEnabled = NO;
    }
}

- (void) refresh
{
    [self refreshStarImage];
    [self refreshCheckImage];
    
    [self setNeedsDisplay];
}

- (void) multiSelect:(BOOL)enabled
{    
    /*[super multiSelect:enabled];
    
    if (!enabled) {
        checkButton.selected = NO;
    }*/
    
    checkButton.selected = enabled;

    [self refreshCheckImage];

}

- (void)hideCheckImage
{
    checkImageView.hidden = YES;
}

- (BOOL) isMultiSelected
{
    //return (self.multiSelectionEnable && checkButton.selected);
    return (checkButton.selected);
}

#pragma mark Actions

-(void)check_old:(id)sender
{
    if (!checkEnable)
    {
        return;
    }
    
    //[self retain];
    
    UIButton *button = (UIButton *) sender;
    
    button.selected = !button.selected;
    
	if (!self.multiSelectionEnable)
	{
        //[_abstractViewCtrler markDoneTaskInView:self];
        if (_plannerViewCtrler)
        {
            [_plannerViewCtrler markDoneTaskInView:self];
        }
        else
        {
            [_abstractViewCtrler markDoneTaskInView:self];
        }
    }
    
    [self refreshCheckImage];
    
    //[self release];
}

-(void)check:(id)sender
{
    if (!checkEnable)
    {
        return;
    }
    
    UIButton *button = (UIButton *) sender;
    button.selected = !button.selected;
    
    self.task.isMultiEdit = button.selected;
        
    [self refreshCheckImage];

    [[AbstractActionViewController getInstance] multiEdit:button.selected];
}

-(void)star:(id)sender
{
    [_abstractViewCtrler starTaskInView:self];
}

#pragma mark Drawing

- (void) drawText:(CGRect)rect context:(CGContextRef) ctx
{
	//Task *task = (Task *)self.tag;
    UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    //UIFont *infoFont = [UIFont fontWithName:@"Verdana-Italic" size:11];
    // UI improvement - dont use Italic
    UIFont *infoFont = [UIFont fontWithName:@"Verdana" size:11];
    
    CGSize oneCharSize = [@"a" sizeWithFont:font];
    NSInteger lineMaxChars = floor(rect.size.width/oneCharSize.width);
    
    //BOOL isList = self.listStyle || self.focusStyle;
    
    NSTextAlignment alignment = NSTextAlignmentLeft;
    
    //UIColor *embossedColor = isList?[UIColor clearColor]:[UIColor colorWithRed:94.0/255 green:120.0/255 blue:112.0/255 alpha:1];
    
    UIColor *embossedColor = [UIColor clearColor];
    
    //UIColor *textColor = (isList?[UIColor blackColor]:[UIColor whiteColor]);
    UIColor *textColor = [[ProjectManager getInstance] getProjectColor0:task.project];
    
    NSString *infoStr = [task.location stringByTrimmingCharactersInSet:
    [NSCharacterSet whitespaceCharacterSet]];
    
    if ([task isNote])
    {
        //NSString *name = [task.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        infoStr = [task.note stringByReplacingOccurrencesOfString:task.name withString:@""];
        
        ////printf("text after replace: %s, note:%s, name:%s\n", [infoStr UTF8String], [task.note UTF8String], [task.name UTF8String]);
        
        infoStr = [[infoStr componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"%C%C",0x2705,0x274E]]] componentsJoinedByString:@""];
        
        infoStr = [infoStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        CGRect textRec = rect;
        
        // margin
        CGFloat margin = 4;
        //textRec.size.height -= 2*margin;
        
        textRec.size.height = oneCharSize.height;
        
        if (task.name.length <= lineMaxChars && [infoStr isEqualToString:@""])
        {
            //1 line name only without note content -> align center
            textRec.origin.y += (rect.size.height - oneCharSize.height)/2;
        }
        else
        {
            textRec.origin.y += margin;
        }
        
        CGRect embossedRec = CGRectOffset(textRec, 0, -1);
        
        [embossedColor set];
        [task.name drawInRect:embossedRec withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:alignment];
        
        [textColor set];
        [task.name drawInRect:textRec withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:alignment];
        
        if (![infoStr isEqualToString:@""])
        {
            /*
            textRec = rect;
            textRec.origin.y += oneCharSize.height;
            textRec.size.height -= oneCharSize.height;
            */
            
            textRec.origin.y += textRec.size.height;
            textRec.size.height = rect.size.height - textRec.origin.y - margin;
            
            embossedRec = CGRectOffset(textRec, 0, -1);
            
            [embossedColor set];
            [infoStr drawInRect:embossedRec withFont:infoFont lineBreakMode:NSLineBreakByTruncatingTail alignment:alignment];
            
            [textColor set];
            [infoStr drawInRect:textRec withFont:infoFont lineBreakMode:NSLineBreakByTruncatingTail alignment:alignment];
        }
    }
    else
    {
        /*NSString *repeat = [task getRepeatTypeString];
        if (![repeat isEqualToString:_noneText]) {
            if (![infoStr isEqualToString:@""]) {
                infoStr = [infoStr stringByAppendingString:@", "];
            }
            infoStr = [infoStr stringByAppendingFormat:@" %@ %@", _repeatText, repeat];
        }
        
        if (self.showDuration && [task isTask]) {
            if (![infoStr isEqualToString:@""]) {
                infoStr = [infoStr stringByAppendingString:@", "];
            }
            
            NSString *duration = [Common getDurationString:self.task.duration];
            infoStr = [infoStr stringByAppendingString: duration];
        }
        
        if (self.showDue && [task isTask]) {
            if (![infoStr isEqualToString:@""]) {
                infoStr = [infoStr stringByAppendingString:@", "];
            }
            
            NSString *due = [self.task getDueString];
            infoStr = [infoStr stringByAppendingString: due];
        }
        
        NSString *firstLine = infoStr;
        NSString *secondLine = nil;

        CGRect textRec = rect;
        textRec.origin = CGPointZero;
        
        //NSString *name = [task isShared]?[NSString stringWithFormat:@"☛ %@", task.name]:task.name;
        NSString *name = task.name;
        
        SimpleCoreTextView *textView = [[SimpleCoreTextView alloc] initWithFrame:textRec];
        textView.text = name;
        textView.font = font;
        
        CGRect caretRect = [textView caretRectForIndex:name.length-1];
        
        [textView release];
        
        CGPoint endPosition = CGPointMake(rect.origin.x + caretRect.origin.x + 20, rect.origin.y + rect.size.height - caretRect.origin.y - caretRect.size.height - 2);
                
        if ((endPosition.y <= rect.size.height - 12) && ![infoStr isEqualToString:@""] ) //draw location
        {            
            oneCharSize = [@"a" sizeWithFont:infoFont];
            NSInteger lineMaxChars = floor((rect.size.width - endPosition.x)/oneCharSize.width);

            if (infoStr.length > lineMaxChars)
            {
                int idx = lineMaxChars;
                
                firstLine = [infoStr substringToIndex:idx];
                
                NSRange range = [firstLine rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet] options:NSBackwardsSearch];
                
                if (range.location != NSNotFound)
                {
                    idx = range.location;
                    
                    firstLine = [infoStr substringToIndex:idx];
                }
                
                range.location = idx;
                range.length = infoStr.length - idx;
                
                secondLine = [infoStr substringWithRange:range];
            }
        }

        textRec = rect;

        if (name.length <= lineMaxChars && secondLine == nil)
        {
            //1 line text and info -> align vertical center
            
            if (isList || [task isTask])
            {
                textRec.origin.y += (rect.size.height - oneCharSize.height)/2 - 2;
            }
            
            textRec.size.height = oneCharSize.height;
            
            endPosition.y = textRec.origin.y;
        }
        
        CGRect embossedRec = CGRectOffset(textRec, 0, -1);
        
        [embossedColor set];
        [name drawInRect:embossedRec withFont:font lineBreakMode:NSLineBreakByTruncatingTail alignment:alignment];
        
        [textColor set];
        [name drawInRect:textRec withFont:font lineBreakMode:NSLineBreakByTruncatingTail alignment:alignment];
        
        textRec.origin.x = endPosition.x;
        textRec.origin.y = endPosition.y;
        textRec.size = oneCharSize;
        textRec.size.width = rect.size.width - textRec.origin.x;
        
        embossedRec = CGRectOffset(textRec, 0, -1);
        
        [embossedColor set];
        [firstLine drawInRect:embossedRec withFont:infoFont lineBreakMode:NSLineBreakByWordWrapping alignment:alignment];
        
        [textColor set];
        [firstLine drawInRect:textRec withFont:infoFont lineBreakMode:NSLineBreakByWordWrapping alignment:alignment];
        
        if (secondLine != nil)
        {
            textRec = rect;
            textRec.origin.y = endPosition.y + oneCharSize.height;
            textRec.size.height -= textRec.origin.y;
            
            if (textRec.size.height >= oneCharSize.height)
            {
                CGRect embossedRec = CGRectOffset(textRec, 0, -1);
                
                [embossedColor set];
                [secondLine drawInRect:embossedRec withFont:infoFont lineBreakMode:NSLineBreakByWordWrapping alignment:alignment];
                
                [textColor set];
                [secondLine drawInRect:textRec withFont:infoFont lineBreakMode:NSLineBreakByWordWrapping alignment:alignment];
            }
        }*/
        
        NSString *repeat = [task getRepeatTypeString];
        if (![repeat isEqualToString:_noneText]) {
            if (![infoStr isEqualToString:@""]) {
                infoStr = [infoStr stringByAppendingString:@", "];
            }
            infoStr = [infoStr stringByAppendingFormat:@" %@ %@", _repeatText, repeat];
        }
        
        if ([task isTask]) {
            if (![infoStr isEqualToString:@""]) {
                infoStr = [infoStr stringByAppendingString:@", "];
            }
            
            NSString *duration = [Common getDurationString:self.task.duration];
            infoStr = [infoStr stringByAppendingString: duration];
        }
        
        if ([task isDTask]) {
            if (![infoStr isEqualToString:@""]) {
                infoStr = [infoStr stringByAppendingString:@", "];
            }
            
            NSString *due = [self.task getDueString];
            infoStr = [infoStr stringByAppendingString: due];
        }
        
        CGRect textRec = rect;
        /*textRec.size.height = oneCharSize.height * 2;
        
        if ([infoStr isEqualToString:@""]) {
            if (task.name.length <= lineMaxChars)
            {
                textRec.origin.y += (rect.size.height - oneCharSize.height)/2;
                textRec.size.height = oneCharSize.height;
            } else if (task.name.length <= 2*lineMaxChars) {
                textRec.origin.y += (rect.size.height - 2*oneCharSize.height)/2;
                textRec.size.height = 2*oneCharSize.height;
            } else {
                textRec.origin.y += (rect.size.height - 3*oneCharSize.height)/2;
                textRec.size.height = 3*oneCharSize.height;
            }
        } else {
            if (task.name.length <= lineMaxChars)
            {
                textRec.origin.y += (rect.size.height - 2*oneCharSize.height)/2;
                textRec.size.height = oneCharSize.height;
            } else {
                textRec.origin.y += (rect.size.height - 3*oneCharSize.height)/2;
                textRec.size.height = 2*oneCharSize.height;
            }
        }
        textRec.origin.y = textRec.origin.y < 0 || !self.listStyle ? 0 : textRec.origin.y;*/
        
        // margin
        CGFloat margin = 4;
        textRec.size.height -= 2*margin;
        textRec.origin.y += margin;
        
        // calculate height of text
        NSInteger lineNumber = floor(task.name.length / lineMaxChars + 1.0);
        CGFloat nameHeight = lineNumber * oneCharSize.height;
        if (nameHeight > textRec.size.height) {
            nameHeight = textRec.size.height;
            nameHeight = nameHeight - fmod(nameHeight, oneCharSize.height);
        }
        
        if (![infoStr isEqualToString:@""] && lineNumber > 2 && nameHeight >= 3*oneCharSize.height) {
            nameHeight -= oneCharSize.height;
        }
        textRec.size.height = nameHeight;
        
        CGFloat inforLine = [infoStr isEqualToString:@""] ? 0 : oneCharSize.height;
        if (self.listStyle) {
            textRec.origin.y = (rect.size.height - nameHeight - inforLine)/2;
        } else if (self.focusStyle){
            textRec.size.height = oneCharSize.height;
            textRec.origin.y = (rect.size.height - textRec.size.height)/2;
            infoStr = @"";
        }
        
        CGRect embossedRec = CGRectOffset(textRec, 0, -1);
        
        [embossedColor set];
        [task.name drawInRect:embossedRec withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:alignment];
        
        [textColor set];
        [task.name drawInRect:textRec withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:alignment];
        
        if (![infoStr isEqualToString:@""] && rect.size.height - textRec.origin.y - textRec.size.height >= oneCharSize.height)
        {
            //infoStr = [@"- " stringByAppendingString:infoStr];
            
            textRec.origin.y += textRec.size.height;
            textRec.size.height = oneCharSize.height;
            
            embossedRec = CGRectOffset(textRec, 0, -1);
            
            [embossedColor set];
            [UIColor redColor];
            [infoStr drawInRect:embossedRec withFont:infoFont lineBreakMode:NSLineBreakByTruncatingTail alignment:alignment];
            
            [textColor set];
            [infoStr drawInRect:textRec withFont:infoFont lineBreakMode:NSLineBreakByTruncatingTail alignment:alignment];
        }
    }
}

- (void)drawHashmark_old:(CGRect)rect context:(CGContextRef) ctx
{
    //Task *task = (Task *) self.tag;
    
	CGFloat f = task.duration/60;
    
    NSInteger imgIdx = 0;
	
    if (f == 0)
    {
        imgIdx = 0;
    }
	else if (f < 60)
	{
		imgIdx = 1;
	}
	else if (f < 180)
	{
		imgIdx = 2;
	}
	else
	{
		imgIdx = 3;
	}
    
    NSString *imgNames[4] = {@"hashmash_0.png", @"hashmash_1.png", @"hashmash_2.png", @"hashmash_3.png"};
    
    UIImage *img = [UIImage imageNamed:imgNames[imgIdx]];
    
    [img drawInRect:rect];
}

- (CGSize)drawHashmark:(CGRect)rect context:(CGContextRef) ctx
{
    NSString *durationString = [Common getDurationString:self.task.duration];
    
    UIFont *infoFont = [UIFont fontWithName:@"Helvetica" size:12];
    
    // calculate size
    CGSize sz = [durationString sizeWithFont:infoFont];
    rect.origin.x += rect.size.width - sz.width;
    rect.origin.y += (rect.size.height - sz.height)/2;
    rect.size = sz;
    
    [[UIColor blackColor] setFill];
    [durationString drawInRect:rect withFont:infoFont];
    return sz;
}

- (void) drawHours:(CGRect)rect context:(CGContextRef) ctx
{
	//Task *task = (Task *) self.tag;
	
	NSString *taskHours = [NSString stringWithFormat:@"%.1f", (CGFloat)task.duration/3600];
	
	CGRect rec = rect;
	
	rec.origin.x += SPACE_PAD;
	rec.origin.y += 2;
	rec.size.height = rect.size.height/2;
	
	UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:12];		
	
	UIColor *embossedColor = [UIColor colorWithRed:94.0/255 green:120.0/255 blue:112.0/255 alpha:1];
	
	CGRect embossedRec = CGRectOffset(rec, 0, -1);
	
	[embossedColor set];
	
	[taskHours drawInRect:embossedRec withFont:font lineBreakMode:NSLineBreakByTruncatingMiddle alignment:NSTextAlignmentCenter];
	
	[[UIColor whiteColor] set];
	
	if (isSelected)
	{
		[[UIColor yellowColor] set];
	}
	
	[taskHours drawInRect:rec withFont:font lineBreakMode:NSLineBreakByTruncatingMiddle alignment:NSTextAlignmentCenter];
	
	rec.origin.y = rect.size.height - rec.size.height + 2;
	
	embossedRec = CGRectOffset(rec, 0, -1);
	
	[embossedColor set];
	
	[_hoursText drawInRect:embossedRec withFont:font lineBreakMode:NSLineBreakByTruncatingMiddle alignment:NSTextAlignmentCenter];
	
	[[UIColor whiteColor] set];
	
	if (isSelected)
	{
		[[UIColor yellowColor] set];
	}
	
	[_hoursText drawInRect:rec withFont:font lineBreakMode:NSLineBreakByTruncatingMiddle alignment:NSTextAlignmentCenter];
	
}

- (void) drawTimeOnly:(CGRect)rect context:(CGContextRef) ctx
{	
	//Task *task = (Task *) self.tag;
    
    NSString *timeStr = 
        ([task isEvent]?[NSString stringWithFormat:@"%@ - %@", [Common getShortTimeString:task.startTime], [Common getShortTimeString:task.endTime]]:[Common getShortTimeString:task.startTime]);
    
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:12];
    
    CGSize sz = [@"A" sizeWithFont:font];
    
    CGFloat dy = (rect.size.height - sz.height)/2;
    
    CGRect frm = CGRectMake(rect.origin.x, dy, rect.size.width, sz.height);
    
    UIColor *color = (self.listStyle || self.focusStyle)?[UIColor blackColor]:[Colors snow2];
    
    [color set];
    
    [timeStr drawInRect:frm withFont:font lineBreakMode:NSLineBreakByTruncatingMiddle alignment:NSTextAlignmentCenter];
}

- (void) drawDateTime:(CGRect)rect context:(CGContextRef) ctx
{	
	//Task *task = (Task *) self.tag;
    
    NSString *dateStr1 = [Common getFullDateString:task.startTime];
    NSString *dateStr2 = [task isADE]? 
        [Common getFullDateString:task.endTime]:
        ([task isEvent]?[NSString stringWithFormat:@"%@ - %@", [Common getShortTimeString:task.startTime], [Common getShortTimeString:task.endTime]]:[Common getShortTimeString:task.startTime]);
    
    
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:12];
    
    CGSize sz = [@"A" sizeWithFont:font];
    
    CGFloat dy = (rect.size.height - 2*sz.height)/3;
    
    CGRect frm = CGRectMake(rect.origin.x, dy, rect.size.width, sz.height);
    
    UIColor *color = (self.listStyle || self.focusStyle)?[UIColor blackColor]:[Colors snow2];
    
    [color set];

    [dateStr1 drawInRect:frm withFont:font lineBreakMode:NSLineBreakByTruncatingMiddle alignment:NSTextAlignmentRight];

    frm.origin.y += dy + sz.height;
    
    [dateStr2 drawInRect:frm withFont:font lineBreakMode:NSLineBreakByTruncatingMiddle alignment:NSTextAlignmentRight];
        
}

- (void) drawTime:(CGRect)rect context:(CGContextRef) ctx
{	
	//Task *task = (Task *) self.tag;
	
	NSString *startStr = [Common getFullDateString:task.startTime];
	NSString *endStr = [Common getFullDateString:task.endTime];
	
	CGRect rec = rect;
	
	rec.origin.x += SPACE_PAD;
	rec.origin.y += 2;
	rec.size.height = rect.size.height/2;
	
	UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:12];		
	
	UIColor *embossedColor = self.listStyle?[UIColor clearColor]:[UIColor colorWithRed:94.0/255 green:120.0/255 blue:112.0/255 alpha:1];
    UIColor *textColor = self.listStyle?[UIColor blackColor]:[UIColor whiteColor];
    
    if (isSelected)
    {
        textColor = [UIColor yellowColor];
    }
	
	CGRect embossedRec = CGRectOffset(rec, 0, -1);
	
	[embossedColor set];
	
	[startStr drawInRect:embossedRec withFont:font lineBreakMode:NSLineBreakByTruncatingMiddle alignment:NSTextAlignmentCenter];
	
    [textColor set];    
    
	[startStr drawInRect:rec withFont:font lineBreakMode:NSLineBreakByTruncatingMiddle alignment:NSTextAlignmentCenter];
	
	rec.origin.y = rect.size.height - rec.size.height + 2;
	
	embossedRec = CGRectOffset(rec, 0, -1);
	
	[embossedColor set];
	
	[endStr drawInRect:embossedRec withFont:font lineBreakMode:NSLineBreakByTruncatingMiddle alignment:NSTextAlignmentCenter];

	[textColor set];
	
	[endStr drawInRect:rec withFont:font lineBreakMode:NSLineBreakByTruncatingMiddle alignment:NSTextAlignmentCenter];
	
}

- (void) drawDue_old:(CGRect)rect context:(CGContextRef) ctx
{	
	//Task *task = (Task *) self.tag;
	
	if ([self.task isDTask])
	{
		//NSTimeInterval diff = [Common timeIntervalNoDST:task.deadline sinceDate:[Common clearTimeForDate:[NSDate date]]];
        
        NSTimeInterval diff = [self.task.deadline timeIntervalSinceDate:[Common clearTimeForDate:[NSDate date]]];
		
		NSInteger dueDays = floor(diff/24/3600);
		
		UIColor *dueColor = [Colors seaGreen];
		
		if (dueDays < 0)
		{
			dueColor = [Colors red];
		}
		else if (dueDays == 0)
		{
			dueColor = [Colors darkOrange];  
		}
        
        if ([task checkMustDo])
        {
            CGRect rec = rect;
            
            rec.origin.x += 1;
            rec.origin.y += 1;
            rec.size.width -= 2;
            rec.size.height -= 2;
            
            CGContextMoveToPoint(ctx, rec.origin.x + rec.size.width/2, rec.origin.y);
            CGContextAddLineToPoint(ctx, rec.origin.x, rec.origin.y + rec.size.height);
            CGContextAddLineToPoint(ctx, rec.origin.x + rec.size.width, rec.origin.y + rec.size.height);
            
            CGContextClosePath(ctx);
            
            [dueColor setFill];
            CGContextFillPath(ctx);

            CGContextMoveToPoint(ctx, rec.origin.x + rec.size.width/2, rec.origin.y);
            CGContextAddLineToPoint(ctx, rec.origin.x, rec.origin.y + rec.size.height);
            CGContextAddLineToPoint(ctx, rec.origin.x + rec.size.width, rec.origin.y + rec.size.height);
            
            CGContextClosePath(ctx);
            
            CGContextSetLineWidth(ctx, 1);
            [[UIColor yellowColor] set];
            CGContextStrokePath(ctx);
            
            rect = CGRectOffset(rect, 0, 6);
        }
        else 
        {
            CGRect rec = rect;
            
            rec.origin.x += 2;
            rec.origin.y += 2;
            rec.size.width -= 4;
            rec.size.height -= 4;
            
            [dueColor setFill];
            
            CGContextFillEllipseInRect(ctx, rec);
            
            rec.origin.x -= 1;
            rec.origin.y -= 1;
            rec.size.width += 2;
            rec.size.height += 2;
            
            [[UIColor whiteColor] set];
            CGContextSetLineWidth(ctx, 2);
            CGContextStrokeEllipseInRect(ctx, rec);
            
            rec.origin.x -= 1;
            rec.origin.y -= 1;
            rec.size.width += 2;
            rec.size.height += 2;
            
            [[UIColor grayColor] set];
            
            CGContextSetLineWidth(ctx, 1);
            CGContextStrokeEllipseInRect(ctx, rec); 
            
            rect = CGRectOffset(rect, 0, 3);
        }
			
		NSString *s = [NSString stringWithFormat:@"%d",dueDays];
		UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
		
		if (dueDays < 0)
		{
			s = @"!";
		}
		else if (dueDays > 99)
		{
			s = @"*";
		}
		
		[[UIColor whiteColor] set];
		[s drawInRect:rect withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
		
	}
}

- (CGSize) drawDue:(CGRect)rect context:(CGContextRef) ctx
{
    if ([self.task isDTask]) {
        NSDate *today = [NSDate date];
        
        //NSComparisonResult result = [today compare:self.task.deadline];
        NSComparisonResult result = [Common compareDateNoTime:self.task.deadline withDate:today];
        
        NSString *dueString = @"";
        if (result == NSOrderedAscending) {
            dueString = _overDueText;
        } else if (result == NSOrderedSame) {
            
            dueString = [_dueText stringByAppendingFormat:@" %@", _todayText];
        } else {
            NSTimeInterval diff = [self.task.deadline timeIntervalSinceDate:[Common clearTimeForDate:today]];
            NSInteger dueDays = floor(diff/24/3600);
            
            dueString = [NSString stringWithFormat:@"%@ %d %@", _dueInTex, dueDays, _daysText];
        }
    
        UIFont *infoFont = [UIFont fontWithName:@"Helvetica" size:12];
        
        // calculate size
        CGSize sz = [dueString sizeWithFont:infoFont];
        rect.origin.x += rect.size.width - sz.width;
        rect.origin.y += (rect.size.height - sz.height)/2;
        rect.size = sz;
        
        [[UIColor blackColor] setFill];
        [dueString drawInRect:rect withFont:infoFont];
        return sz;
    }
    return CGSizeZero;
}

- (void) drawPin:(CGRect)rect context:(CGContextRef) ctx
{	
	//Task *task = (Task *) self.tag;
	
	if ((self.task.type == TYPE_TASK || self.task.type == TYPE_SHOPPING_ITEM) && self.task.status == TASK_STATUS_PINNED)
	{
		//UIImage *pinImage = [UIImage imageNamed:@"pin.png"];
		
		UIImage *pinImage = [[ImageManager getInstance] getImageWithName:@"pin.png"];
		
		[pinImage drawInRect:rect];
	}
}

- (void) drawAlert:(CGRect)rect context:(CGContextRef) ctx
{	
	//Task *task = (Task *) self.tag;
	
	if (self.task.alerts != nil && self.task.alerts.count > 0)
	{
		//UIImage *alertImage = [UIImage imageNamed:@"alert.png"];
		
		UIImage *alertImage = [[ImageManager getInstance] getImageWithName:@"alert.png"];
		
		[alertImage drawInRect:rect];
	}
}

- (void) drawFlag:(CGRect)rect context:(CGContextRef) ctx
{	
    UIImage *flagImage = [[ImageManager getInstance] getImageWithName:@"flag.png"];
    
    [flagImage drawInRect:rect];
}

- (void) drawLink:(CGRect)rect context:(CGContextRef) ctx
{	
    UIImage *linkImage = [[ImageManager getInstance] getImageWithName:(self.listStyle || self.focusStyle)?@"links.png":@"links_white.png"];
    
    [linkImage drawInRect:rect];
}

- (void) drawHand:(CGRect)rect context:(CGContextRef) ctx
{
    UIImage *flagImage = [[ImageManager getInstance] getImageWithName:@"assign.png"];
    
    [flagImage drawInRect:rect];
}

- (void) drawFocusStyle_old:(CGRect)rect ctx:(CGContextRef)ctx
{
    ProjectManager *pm = [ProjectManager getInstance];
    
    BOOL hasAlert = (self.task.original != nil && ![self.task isREException]?self.task.original.alerts.count > 0:self.task.alerts.count > 0);
	BOOL hasDue = [self.task isDTask];
    BOOL hasFlag = [self.task isTask] && (self.task.isTop || (self.task.original != nil && self.task.original.isTop));
    BOOL hasHashMark = NO;
    BOOL hasTime = NO;
    BOOL hasLink = (self.task.original != nil && ![self.task isREException]? self.task.original.links.count > 0: self.task.links.count > 0);
    BOOL hasHand = [self.task isShared];
    
    //printf("task %s link count: %d\n", [task.name UTF8String], task.links.count);
    
    UIColor *dimProjectColor = [pm getProjectColor1:self.task.project];
    
    if (isSelected)
    {
        CGRect frm = rect;
        
        frm.origin.x += 1;
        frm.size.width -= 2;
        frm.size.height -= 2;
        
        //[[[UIColor magentaColor] colorWithAlphaComponent:0.2] setFill];
        UIColor *highlightColor = [UIColor colorWithRed:149.0/255 green:185.0/255 blue:239.0/255 alpha:1];
        
        [highlightColor setFill];
        
        CGContextFillRect(ctx, frm);
    }
    
    if (self.multiSelectionEnable)
    {
        rect = CGRectOffset(rect, 30, 0);
        rect.size.width -= 30;
    }
    
    if (self.task.type == TYPE_ADE)
    {
        /*CGRect frm = CGRectOffset(rect, SPACE_PAD, 0);
        
        frm.size.height -= 2;
        frm.size.width -= 2*SPACE_PAD;
        */
        
        rect = CGRectOffset(rect, SPACE_PAD, 0);
        rect.size.width -= 2*SPACE_PAD;
        
        CGRect frm = rect;
        frm.size.height -= 2;
        
        [[dimProjectColor colorWithAlphaComponent:0.4] setFill];
        fillRoundedRect(ctx, frm, 5, 5);
    }
    
    if (self.showListBorder)
    {
        [[UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1] setFill];
        
        CGContextFillRect(ctx, rect);
        
        [[UIColor grayColor] setStroke];
        
        CGContextStrokeRect(ctx, rect);
    }

    if (self.showSeparator)
    {
        UIColor *separatorColor = [UIColor colorWithRed:195.0/255 green:195.0/255 blue:195.0/255 alpha:1];
        [separatorColor setStroke];
        
        CGContextMoveToPoint(ctx, rect.origin.x, rect.origin.y + rect.size.height);
        CGContextAddLineToPoint( ctx, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
        CGContextStrokePath(ctx);
    }
    
	if (rect.size.width <= 120) //no need to draw these in WeekPlanner
	{
		hasAlert = NO;
		hasFlag = NO;
		hasHashMark = NO;
        hasDue = NO;
        hasTime = NO;
        hasLink = NO;
	}
    
    UIImage *img = nil;
    
    if ([self.task isEvent] && ![self.task isADE])
    {
        img = [pm getEventIcon:self.task.project];
    }
    else if ([self.task isTask])
    {
        img = [pm getTaskIcon:self.task.project];
    }
    else if ([self.task isNote])
    {
        img = [pm getNoteIcon:self.task.project];
    }
    
    ////printf("icon w=%f, h=%f\n", img.size.width, img.size.height);
    
    CGRect frm = CGRectZero;
    frm.size = img.size;
    frm.origin.y = (rect.size.height-frm.size.height)/2;
    frm.origin.x = rect.origin.x + SPACE_PAD;
    
    [img drawInRect:frm];
    
    if (self.multiSelectionEnable && [self.task isDone])
    {
        img = [[ImageManager getInstance] getImageWithName:@"checkmark.png"];
        
        [img drawInRect:frm];
    }
    
    rect.origin.x += frm.size.width + 2*SPACE_PAD;
    rect.size.width -= frm.size.width + 2*SPACE_PAD;
    
    if (self.starEnable)
    {
        rect.size.width -= 20;
    }
    
    if (([task isEvent] || [task isNote]) && hasTime)
    {
        frm = CGRectMake(0, 0, [task isNote] || [task isADE]?70:90, rect.size.height);
        
        frm.origin.x = rect.origin.x + rect.size.width - frm.size.width - SPACE_PAD;
        frm.origin.y = (rect.size.height-frm.size.height)/2;
        
        [self drawDateTime:frm context:ctx];
        
        rect.size.width -= frm.size.width + SPACE_PAD;
    }
    else if ([task isRT])
	{
		frm.size.width = HASHMARK_WIDTH/2;
		frm.size.height = HASHMARK_HEIGHT;
        
        frm.origin.x = rect.origin.x + rect.size.width - HASHMARK_WIDTH - SPACE_PAD;
        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
        
        if (hasHashMark)
        {
            [self drawHashmark:frm context:ctx];
            
            rect.size.width -= HASHMARK_WIDTH + SPACE_PAD;
		}
        else
        {
            rect.size.width -= HASHMARK_WIDTH/2 + SPACE_PAD;
        }
        
		frm = CGRectOffset(frm, HASHMARK_WIDTH/2 + SPACE_PAD/2, 0);
		frm.size.height /= 2;
		
		UIImage *image = [[ImageManager getInstance] getImageWithName:@"repeat_black.png"];
        
		[image drawInRect:frm];
	}
	else if ([task isTask] && hasHashMark)
	{
		frm.size.width = HASHMARK_WIDTH;
		frm.size.height = HASHMARK_HEIGHT;
        
        frm.origin.x = rect.origin.x + rect.size.width - HASHMARK_WIDTH - SPACE_PAD;
        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
		
		[self drawHashmark:frm context:ctx];
        
        rect.size.width -= HASHMARK_WIDTH + SPACE_PAD;
	}
    
	if (hasDue)
	{
		frm.size.width = DUE_SIZE;
		frm.size.height = DUE_SIZE;
        
        frm.origin.x = rect.origin.x + rect.size.width - DUE_SIZE - SPACE_PAD/2;
        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
        
		[self drawDue:frm context:ctx];
        
        rect.size.width -= DUE_SIZE + SPACE_PAD/2;
	}
    
	if (hasAlert)
	{
		frm.size.width = ALERT_SIZE;
		frm.size.height = ALERT_SIZE;
        
        frm.origin.x = rect.origin.x + rect.size.width - ALERT_SIZE;
        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
        
        UIImage *alertImage = [[ImageManager getInstance] getImageWithName:@"alert_black.png"];
        
        [alertImage drawInRect:frm];
        
        rect.size.width -= DUE_SIZE;
	}
    
    if (hasLink)
    {
        //printf("task %s has link\n", [task.name UTF8String]);
		frm.size.width = LINK_SIZE;
		frm.size.height = LINK_SIZE;
        
		frm.origin.x = rect.origin.x + rect.size.width - LINK_SIZE - SPACE_PAD;
		frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
		
		[self drawLink:frm context:ctx];
        
        rect.size.width -= LINK_SIZE + SPACE_PAD;
    }
    else
    {
        //printf("task %s has no link\n", [task.name UTF8String]);
    }
    
    if ([task isRE])
    {
		frm.size.width = REPEAT_SIZE;
		frm.size.height = REPEAT_SIZE;
        
		frm.origin.x = rect.origin.x + rect.size.width - REPEAT_SIZE;
		frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
		
		UIImage *image = [[ImageManager getInstance] getImageWithName:@"repeat_black.png"];
        
        [image drawInRect:frm];
        
        rect.size.width -= REPEAT_SIZE;
    }
    
	if (hasFlag)
	{
		frm.size.width = FLAG_SIZE;
		frm.size.height = FLAG_SIZE;
        
		frm.origin.x = rect.origin.x + SPACE_PAD/2;
		frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
		
		[self drawFlag:frm context:ctx];
		
        rect.origin.x += FLAG_SIZE + SPACE_PAD/2;
        rect.size.width -= FLAG_SIZE + SPACE_PAD/2;
	}
    
	if (hasHand)
	{
		frm.size.width = HAND_SIZE;
		frm.size.height = HAND_SIZE;
        
		frm.origin.x = rect.origin.x + SPACE_PAD/2;
		frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
		
		[self drawHand:frm context:ctx];
		
        rect.origin.x += HAND_SIZE + SPACE_PAD/2;
        rect.size.width -= HAND_SIZE + SPACE_PAD/2;
	}
    
    [self drawText:rect context:ctx];
}

- (void) drawFocusStyle:(CGRect)rect ctx:(CGContextRef)ctx
{
    ProjectManager *pm = [ProjectManager getInstance];
    
    //BOOL hasAlert = (self.task.original != nil && ![self.task isREException]?self.task.original.alerts.count > 0:self.task.alerts.count > 0);
	BOOL hasDue = [self.task isDTask];
    //BOOL hasFlag = [self.task isTask] && (self.task.isTop || (self.task.original != nil && self.task.original.isTop));
    //BOOL hasHashMark = NO;
    BOOL hasTime = NO;
    //BOOL hasLink = (self.task.original != nil && ![self.task isREException]? self.task.original.links.count > 0: self.task.links.count > 0);
    BOOL hasHand = [self.task isShared];
    
    //printf("task %s link count: %d\n", [task.name UTF8String], task.links.count);
    
    UIColor *dimProjectColor = [pm getProjectColor1:self.task.project];
    
    if (isSelected)
    {
        CGRect frm = rect;
        
        frm.origin.x += 1;
        frm.size.width -= 2;
        frm.size.height -= 2;
        
        //[[[UIColor magentaColor] colorWithAlphaComponent:0.2] setFill];
        UIColor *highlightColor = [UIColor colorWithRed:149.0/255 green:185.0/255 blue:239.0/255 alpha:1];
        
        [highlightColor setFill];
        
        CGContextFillRect(ctx, frm);
    }
    
    /*if (self.multiSelectionEnable)
    {
        rect = CGRectOffset(rect, 30, 0);
        rect.size.width -= 30;
    }*/
    
    if (self.task.type == TYPE_ADE)
    {
        /*CGRect frm = CGRectOffset(rect, SPACE_PAD, 0);
         
         frm.size.height -= 2;
         frm.size.width -= 2*SPACE_PAD;
         */
        
        rect = CGRectOffset(rect, SPACE_PAD, 0);
        rect.size.width -= 2*SPACE_PAD;
        
        CGRect frm = rect;
        frm.size.height -= 2;
        
        [[dimProjectColor colorWithAlphaComponent:0.4] setFill];
        fillRoundedRect(ctx, frm, 5, 5);
    }
    
    if (self.showListBorder)
    {
        [[UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1] setFill];
        
        CGContextFillRect(ctx, rect);
        
        [[UIColor grayColor] setStroke];
        
        CGContextStrokeRect(ctx, rect);
    }
    
    if (self.showSeparator)
    {
        UIColor *separatorColor = [UIColor colorWithRed:195.0/255 green:195.0/255 blue:195.0/255 alpha:1];
        [separatorColor setStroke];
        
        CGContextMoveToPoint(ctx, rect.origin.x, rect.origin.y + rect.size.height);
        CGContextAddLineToPoint( ctx, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
        CGContextStrokePath(ctx);
    }
    
	if (rect.size.width <= 120) //no need to draw these in WeekPlanner
	{
		//hasAlert = NO;
		//hasFlag = NO;
		//hasHashMark = NO;
        hasDue = NO;
        hasTime = NO;
        //hasLink = NO;
	}
    
    UIImage *img = nil;
    
    if ([self.task isEvent] && ![self.task isADE])
    {
        //img = [pm getEventIcon:self.task.project];
        /*img = [task isManual] ? [[ImageManager getInstance] getImageWithName:@"atask_lines.png"] : [[ImageManager getInstance] getImageWithName:@"event.png"];*/
        img = [task isManual]?[pm getAnchoredIcon:self.task.project]:[pm getEventIcon:self.task.project];
    }
    else if ([self.task isTask])
    {
        img = [pm getTaskIcon:self.task.project];
    }
    else if ([self.task isNote])
    {
        img = [pm getNoteIcon:self.task.project];
    }
    
    ////printf("icon w=%f, h=%f\n", img.size.width, img.size.height);
    
    CGRect frm = CGRectZero;
    //frm.size = img.size;
    frm.size = CGSizeMake(13, 13);
    frm.origin.y = (rect.size.height-frm.size.height)/2;
    frm.origin.x = rect.origin.x + SPACE_PAD;
    
    [img drawInRect:frm];
    
    //if (self.multiSelectionEnable && [self.task isDone])
    if ([self.task isDone])
    {
        img = [[ImageManager getInstance] getImageWithName:@"checkmark.png"];
        
        [img drawInRect:frm];
    }
    
    rect.origin.x += frm.size.width + 2*SPACE_PAD;
    rect.size.width -= frm.size.width + 2*SPACE_PAD;
    
    if (self.starEnable)
    {
        rect.size.width -= 20;
    }
    
    if (([task isEvent] || [task isNote]) && hasTime)
    {
        frm = CGRectMake(0, 0, [task isNote] || [task isADE]?70:90, rect.size.height);
        
        frm.origin.x = rect.origin.x + rect.size.width - frm.size.width - SPACE_PAD;
        frm.origin.y = (rect.size.height-frm.size.height)/2;
        
        [self drawDateTime:frm context:ctx];
        
        rect.size.width -= frm.size.width + SPACE_PAD;
    }
    else if ([task isRT])
	{
		frm.size.width = HASHMARK_WIDTH/2;
		frm.size.height = HASHMARK_HEIGHT;
        
        frm.origin.x = rect.origin.x + rect.size.width - HASHMARK_WIDTH - SPACE_PAD;
        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
        
        /*if (hasHashMark)
        {
            [self drawHashmark:frm context:ctx];
            
            rect.size.width -= HASHMARK_WIDTH + SPACE_PAD;
		}
        else
        {
            rect.size.width -= HASHMARK_WIDTH/2 + SPACE_PAD;
        }*/
        
		frm = CGRectOffset(frm, HASHMARK_WIDTH/2 + SPACE_PAD/2, 0);
		frm.size.height /= 2;
		
		UIImage *image = [[ImageManager getInstance] getImageWithName:@"repeat_black.png"];
        
		[image drawInRect:frm];
        
        rect.size.width -= frm.size.width + SPACE_PAD;
	}
	/*else if ([task isTask] && hasHashMark)
	{
		frm.size.width = HASHMARK_WIDTH;
		frm.size.height = HASHMARK_HEIGHT;
        
        frm.origin.x = rect.origin.x + rect.size.width - HASHMARK_WIDTH - SPACE_PAD;
        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
		
		[self drawHashmark:frm context:ctx];
     
        rect.size.width -= HASHMARK_WIDTH + SPACE_PAD;
	}*/
    
	if (hasDue && showDue)
	{
		frm.size.width = DUE_SIZE;
		frm.size.height = DUE_SIZE;
        
        frm.origin.x = rect.origin.x + rect.size.width - DUE_SIZE - SPACE_PAD/2;
        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
        
		CGSize sz = [self drawDue:frm context:ctx];
        
        //rect.size.width -= DUE_SIZE + SPACE_PAD/2;
        rect.size.width -= sz.width + SPACE_PAD/2;
	}
    
	/*if (hasAlert)
	{
		frm.size.width = ALERT_SIZE;
		frm.size.height = ALERT_SIZE;
        
        frm.origin.x = rect.origin.x + rect.size.width - ALERT_SIZE;
        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
        
        UIImage *alertImage = [[ImageManager getInstance] getImageWithName:@"alert_black.png"];
        
        [alertImage drawInRect:frm];
        
        rect.size.width -= DUE_SIZE;
	}
    
    if (hasLink)
    {
        //printf("task %s has link\n", [task.name UTF8String]);
		frm.size.width = LINK_SIZE;
		frm.size.height = LINK_SIZE;
        
		frm.origin.x = rect.origin.x + rect.size.width - LINK_SIZE - SPACE_PAD;
		frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
		
		[self drawLink:frm context:ctx];
        
        rect.size.width -= LINK_SIZE + SPACE_PAD;
    }
    else
    {
        //printf("task %s has no link\n", [task.name UTF8String]);
    }*/
    
    if ([task isRE])
    {
		frm.size.width = REPEAT_SIZE;
		frm.size.height = REPEAT_SIZE;
        
		frm.origin.x = rect.origin.x + rect.size.width - REPEAT_SIZE;
		frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
		
		UIImage *image = [[ImageManager getInstance] getImageWithName:@"repeat_black.png"];
        
        [image drawInRect:frm];
        
        rect.size.width -= REPEAT_SIZE;
    }
    
	/*if (hasFlag)
	{
		frm.size.width = FLAG_SIZE;
		frm.size.height = FLAG_SIZE;
        
		frm.origin.x = rect.origin.x + SPACE_PAD/2;
		frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
		
		[self drawFlag:frm context:ctx];
		
        rect.origin.x += FLAG_SIZE + SPACE_PAD/2;
        rect.size.width -= FLAG_SIZE + SPACE_PAD/2;
	}*/
    
	if (hasHand)
	{
		frm.size.width = HAND_SIZE;
		frm.size.height = HAND_SIZE;
        
		frm.origin.x = rect.origin.x + SPACE_PAD/2;
		frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
		
		[self drawHand:frm context:ctx];
		
        rect.origin.x += HAND_SIZE + SPACE_PAD/2;
        rect.size.width -= HAND_SIZE + SPACE_PAD/2;
	}
    
    [self drawText:rect context:ctx];
}

    
- (void) drawListStyle_old:(CGRect)rect ctx:(CGContextRef)ctx
{
    ProjectManager *pm = [ProjectManager getInstance];
    
    //Task *task = (Task *) self.tag;
    BOOL hasAlert = (task.original != nil && ![task isREException]?task.original.alerts.count > 0:task.alerts.count > 0);
	BOOL hasDue = [task isDTask];
    BOOL hasFlag = [task isTask] && (task.isTop || (task.original != nil && task.original.isTop));
    BOOL hasHashMark = YES;
    BOOL hasTime = YES;
    BOOL hasLink = (task.original != nil && ![task isREException]? task.original.links.count > 0: task.links.count > 0);
    BOOL hasHand = [task isShared];
    
    //printf("task %s link count: %d\n", [task.name UTF8String], task.links.count);
    
    UIColor *dimProjectColor = [pm getProjectColor1:task.project];
    
    if (isSelected)
    {
        CGRect frm = rect;
        
        frm.origin.x += 1;
        frm.size.width -= 2;
        frm.size.height -= 2;
        
        //[[[UIColor magentaColor] colorWithAlphaComponent:0.2] setFill];
        UIColor *highlightColor = [UIColor colorWithRed:149.0/255 green:185.0/255 blue:239.0/255 alpha:1];
        
        [highlightColor setFill];
        
        CGContextFillRect(ctx, frm);
    }
    
    if (self.multiSelectionEnable)
    {
        rect = CGRectOffset(rect, 30, 0);
        rect.size.width -= 30;
    }
    
    if (task.type == TYPE_ADE)
    {
        /*
        CGRect frm = CGRectOffset(rect, SPACE_PAD, 0);

        frm.size.height -= 2;
        frm.size.width -= 2*SPACE_PAD;
        */
        
        rect = CGRectOffset(rect, SPACE_PAD, 0);
        rect.size.width -= 2*SPACE_PAD;
        
        CGRect frm = rect;
        frm.size.height -= 2;
        
        [[dimProjectColor colorWithAlphaComponent:0.4] setFill];
        fillRoundedRect(ctx, frm, 5, 5);
    }
    
    if (self.showListBorder)
    {
        //[[UIColor colorWithRed:113.0/255 green:116.0/255 blue:123.0/255 alpha:1] setFill];
        [[UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1] setFill];
        
        CGContextFillRect(ctx, rect);
        
        [[UIColor grayColor] setStroke];
        
        CGContextStrokeRect(ctx, rect);
    }
    
    /*if ([task isManual]) {
        // draw dash border
        //CGRect dashRect = CGRectInset(rect, 1, 1);
        CGFloat dashPattern[]= {4.0, 3};
        CGContextSetLineDash(ctx, 0.0, dashPattern, 2);
        strokeRoundedRect(ctx, rect, 5, 5);
    }*/

    /*
    UIColor *separatorColor = [UIColor colorWithRed:243.0/255 green:243.0/255 blue:243.0/255 alpha:1];
    [separatorColor setStroke];
    
    CGContextMoveToPoint(ctx, rect.origin.x, rect.origin.y + rect.size.height);
    CGContextAddLineToPoint( ctx, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    CGContextStrokePath(ctx);
    */
    
    if (self.showSeparator)
    {
        UIColor *separatorColor = [UIColor colorWithRed:195.0/255 green:195.0/255 blue:195.0/255 alpha:1];
        [separatorColor setStroke];
        
        CGContextMoveToPoint(ctx, rect.origin.x, rect.origin.y + rect.size.height);
        CGContextAddLineToPoint( ctx, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
        CGContextStrokePath(ctx);
    }
    
	if (rect.size.width <= 120) //no need to draw these in WeekPlanner
	{
		hasAlert = NO;
		hasFlag = NO;
		hasHashMark = NO;
        hasDue = NO;
        hasTime = NO;
        hasLink = NO;
	}    
    
    UIImage *img = nil;
    
    if ([task isEvent] && ![task isManual])
    {
        img = [pm getEventIcon:task.project];
    }
    else if ([task isEvent] && [task isManual])
    {
        img = [pm getAnchoredIcon:task.project];
    }
    else if ([task isTask])
    {
        img = [pm getTaskIcon:task.project];
    }
    else if ([task isNote])
    {
        img = [pm getNoteIcon:task.project];
    }
    
    ////printf("icon w=%f, h=%f\n", img.size.width, img.size.height);
    
    CGRect frm = CGRectZero;
    frm.size = img.size;
    frm.origin.y = (rect.size.height-frm.size.height)/2;
    //frm.origin.y = SPACE_PAD;
    frm.origin.x = rect.origin.x + SPACE_PAD;
    
    [img drawInRect:frm];
    
    if (self.multiSelectionEnable && [task isDone])
    {
        img = [[ImageManager getInstance] getImageWithName:@"checkmark.png"];
        
        [img drawInRect:frm];
    }

    rect.origin.x += frm.size.width + 2*SPACE_PAD;
    rect.size.width -= frm.size.width + 2*SPACE_PAD;
    
    if (self.starEnable)
    {
        rect.size.width -= 20;
    }

    if (([task isEvent] || [task isNote]) && hasTime)
    {
        frm = CGRectMake(0, 0, [task isNote] || [task isADE]?70:90, rect.size.height);
        
        frm.origin.x = rect.origin.x + rect.size.width - frm.size.width - SPACE_PAD;
        frm.origin.y = (rect.size.height-frm.size.height)/2;
        
        [self drawDateTime:frm context:ctx];
        
        rect.size.width -= frm.size.width + SPACE_PAD;        
    }
    else if ([task isRT])
	{
		frm.size.width = HASHMARK_WIDTH/2;
		frm.size.height = HASHMARK_HEIGHT;
        
        frm.origin.x = rect.origin.x + rect.size.width - HASHMARK_WIDTH - SPACE_PAD;
        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;

        if (hasHashMark)
        {
            [self drawHashmark:frm context:ctx];
            
            rect.size.width -= HASHMARK_WIDTH + SPACE_PAD;
		}
        else 
        {
            rect.size.width -= HASHMARK_WIDTH/2 + SPACE_PAD;
        }
        
		frm = CGRectOffset(frm, HASHMARK_WIDTH/2 + SPACE_PAD/2, 0);
		frm.size.height /= 2;
		
		UIImage *image = [[ImageManager getInstance] getImageWithName:@"repeat_black.png"];
        
		[image drawInRect:frm];
	}
	else if ([task isTask] && hasHashMark)
	{
		frm.size.width = HASHMARK_WIDTH;
		frm.size.height = HASHMARK_HEIGHT;
        
        frm.origin.x = rect.origin.x + rect.size.width - HASHMARK_WIDTH - SPACE_PAD;
        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;        
		
		[self drawHashmark:frm context:ctx];
        
        rect.size.width -= HASHMARK_WIDTH + SPACE_PAD;
	}    
    
	if (hasDue)
	{
		frm.size.width = DUE_SIZE;
		frm.size.height = DUE_SIZE;
        
        frm.origin.x = rect.origin.x + rect.size.width - DUE_SIZE - SPACE_PAD/2;
        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;                
				
		[self drawDue:frm context:ctx];
        
        rect.size.width -= DUE_SIZE + SPACE_PAD/2;
	} 
    
	if (hasAlert)
	{
		frm.size.width = ALERT_SIZE;
		frm.size.height = ALERT_SIZE;
        
        frm.origin.x = rect.origin.x + rect.size.width - ALERT_SIZE;
        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;                
        
		//[self drawAlert:frm context:ctx];	
        UIImage *alertImage = [[ImageManager getInstance] getImageWithName:@"alert_black.png"];
        
        [alertImage drawInRect:frm];
        
        rect.size.width -= DUE_SIZE;
	}
    
    if (hasLink)
    {
        //printf("task %s has link\n", [task.name UTF8String]);
		frm.size.width = LINK_SIZE;
		frm.size.height = LINK_SIZE;
        
		frm.origin.x = rect.origin.x + rect.size.width - LINK_SIZE - SPACE_PAD;
		frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
		
		[self drawLink:frm context:ctx];
        
        rect.size.width -= LINK_SIZE + SPACE_PAD;
    }
    else 
    {
        //printf("task %s has no link\n", [task.name UTF8String]);
    }
    
    if ([task isRE])
    {
		frm.size.width = REPEAT_SIZE;
		frm.size.height = REPEAT_SIZE;
        
		frm.origin.x = rect.origin.x + rect.size.width - REPEAT_SIZE;
		frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
		
		UIImage *image = [[ImageManager getInstance] getImageWithName:@"repeat_black.png"];
        
        [image drawInRect:frm];
        
        rect.size.width -= REPEAT_SIZE;        
    }
    
	if (hasFlag)
	{
		frm.size.width = FLAG_SIZE;
		frm.size.height = FLAG_SIZE;
        
		frm.origin.x = rect.origin.x + SPACE_PAD/2;
		frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
		
		[self drawFlag:frm context:ctx];
		
        rect.origin.x += FLAG_SIZE + SPACE_PAD/2;
        rect.size.width -= FLAG_SIZE + SPACE_PAD/2;
	}
    
	if (hasHand)
	{
		frm.size.width = HAND_SIZE;
		frm.size.height = HAND_SIZE;
        
		frm.origin.x = rect.origin.x + SPACE_PAD/2;
		frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
		
		[self drawHand:frm context:ctx];
		
        rect.origin.x += HAND_SIZE + SPACE_PAD/2;
        rect.size.width -= HAND_SIZE + SPACE_PAD/2;
	}
    
    [self drawText:rect context:ctx];
}

- (void) drawListStyle:(CGRect)rect ctx:(CGContextRef)ctx
{
    ProjectManager *pm = [ProjectManager getInstance];
    
    //Task *task = (Task *) self.tag;
    //BOOL hasAlert = (task.original != nil && ![task isREException]?task.original.alerts.count > 0:task.alerts.count > 0);
    BOOL hasAlert = NO;
	BOOL hasDue = [task isDTask];
    BOOL hasFlag = [task isTask] && (task.isTop || (task.original != nil && task.original.isTop));
    //BOOL hasHashMark = YES;
    BOOL hasHashMark = NO;
    BOOL hasTime = YES;
    BOOL hasLink = (task.original != nil && ![task isREException]? task.original.links.count > 0: task.links.count > 0);
    BOOL hasHand = [task isShared];
    
    //printf("task %s link count: %d\n", [task.name UTF8String], task.links.count);
    
    UIColor *dimProjectColor = [pm getProjectColor1:task.project];
    
    [[dimProjectColor colorWithAlphaComponent:0.4] setFill];
    CGContextFillRect(ctx, rect);
    
    if (isSelected)
    {
        CGRect frm = rect;
        
        frm.origin.x += 1;
        frm.size.width -= 2;
        frm.size.height -= 2;
        
        //[[[UIColor magentaColor] colorWithAlphaComponent:0.2] setFill];
        UIColor *highlightColor = [UIColor colorWithRed:149.0/255 green:185.0/255 blue:239.0/255 alpha:1];
        
        [highlightColor setFill];
        
        CGContextFillRect(ctx, frm);
    }
    
    //if (self.multiSelectionEnable)
    if (self.checkEnable)
    {
        rect = CGRectOffset(rect, TASK_HEIGHT, 0);
        rect.size.width -= TASK_HEIGHT;
        checkImageView.image = [[ImageManager getInstance] getImageWithName:checkButton.selected?@"multiOn.png":@"multiOff.png"];
        //checkView.userInteractionEnabled = NO;
    }
    
//    if (task.type == TYPE_ADE)
//    {
//        /*
//         CGRect frm = CGRectOffset(rect, SPACE_PAD, 0);
//         
//         frm.size.height -= 2;
//         frm.size.width -= 2*SPACE_PAD;
//         */
//        
//        rect = CGRectOffset(rect, SPACE_PAD, 0);
//        rect.size.width -= 2*SPACE_PAD;
//        
//        CGRect frm = rect;
//        frm.size.height -= 2;
//        
//        [[dimProjectColor colorWithAlphaComponent:0.4] setFill];
//        fillRoundedRect(ctx, frm, 5, 5);
//    }
    
    if (self.showListBorder)
    {
        //[[UIColor colorWithRed:113.0/255 green:116.0/255 blue:123.0/255 alpha:1] setFill];
        [[UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1] setFill];
        
        CGContextFillRect(ctx, rect);
        
        [[UIColor grayColor] setStroke];
        
        CGContextStrokeRect(ctx, rect);
    }
    
    if (self.showSeparator)
    {
        UIColor *separatorColor = [UIColor colorWithRed:195.0/255 green:195.0/255 blue:195.0/255 alpha:1];
        [separatorColor setStroke];
        
        CGContextMoveToPoint(ctx, rect.origin.x, rect.origin.y + rect.size.height);
        CGContextAddLineToPoint( ctx, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
        CGContextStrokePath(ctx);
    }
    
	if (rect.size.width <= 120) //no need to draw these in WeekPlanner
	{
		hasAlert = NO;
		hasFlag = NO;
		hasHashMark = NO;
        hasDue = NO;
        hasTime = NO;
        hasLink = NO;
	}
    
//    UIImage *img = nil;
//    
//    if ([task isEvent] && ![task isManual])
//    {
//        img = [pm getEventIcon:task.project];
//    }
//    else if ([task isEvent] && [task isManual])
//    {
//        img = [pm getAnchoredIcon:task.project];
//    }
//    else if ([task isTask])
//    {
//        img = [pm getTaskIcon:task.project];
//    }
//    else if ([task isNote])
//    {
//        img = [pm getNoteIcon:task.project];
//    }
    
    ////printf("icon w=%f, h=%f\n", img.size.width, img.size.height);
    
    CGRect frm = CGRectZero;
//    frm.size = img.size;
//    frm.origin.y = (rect.size.height-frm.size.height)/2;
//    //frm.origin.y = SPACE_PAD;
//    frm.origin.x = rect.origin.x + SPACE_PAD;
//    
//    [img drawInRect:frm];
//    
//    if (self.multiSelectionEnable && [task isDone])
//    {
//        img = [[ImageManager getInstance] getImageWithName:@"checkmark.png"];
//        
//        [img drawInRect:frm];
//    }
    
    rect.origin.x += frm.size.width + 2*SPACE_PAD;
    rect.size.width -= frm.size.width + 2*SPACE_PAD;
    
    if (self.starEnable)
    {
        //rect.size.width -= 20;
        rect.size.width -= starView.frame.size.width;
    }
    
    if (([task isEvent] || [task isNote]) && hasTime)
    {
        frm = CGRectMake(0, 0, [task isNote] || [task isADE]?70:90, rect.size.height);
        
        frm.origin.x = rect.origin.x + rect.size.width - frm.size.width - SPACE_PAD;
        frm.origin.y = (rect.size.height-frm.size.height)/2;
        
        [self drawDateTime:frm context:ctx];
        
        rect.size.width -= frm.size.width + SPACE_PAD;
    } else {
        if (self.showDuration) {
            
            frm.size.width = HASHMARK_WIDTH;
            frm.size.height = HASHMARK_HEIGHT;

            frm.origin.x = rect.origin.x + rect.size.width - HASHMARK_WIDTH - SPACE_PAD;
            frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;

            CGSize sz = [self drawHashmark:frm context:ctx];

            rect.size.width -= sz.width + SPACE_PAD;
        }
    }
//    else if ([task isRT])
//	{
//		frm.size.width = HASHMARK_WIDTH/2;
//		frm.size.height = HASHMARK_HEIGHT;
//        
//        frm.origin.x = rect.origin.x + rect.size.width - HASHMARK_WIDTH - SPACE_PAD;
//        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
//        
//        if (hasHashMark)
//        {
//            [self drawHashmark:frm context:ctx];
//            
//            rect.size.width -= HASHMARK_WIDTH + SPACE_PAD;
//		}
//        else
//        {
//            rect.size.width -= HASHMARK_WIDTH/2 + SPACE_PAD;
//        }
//        
//		frm = CGRectOffset(frm, HASHMARK_WIDTH/2 + SPACE_PAD/2, 0);
//		frm.size.height /= 2;
//		
//		UIImage *image = [[ImageManager getInstance] getImageWithName:@"repeat_black.png"];
//        
//		[image drawInRect:frm];
//	}
//	else if ([task isTask] && hasHashMark)
//	{
//		frm.size.width = HASHMARK_WIDTH;
//		frm.size.height = HASHMARK_HEIGHT;
//        
//        frm.origin.x = rect.origin.x + rect.size.width - HASHMARK_WIDTH - SPACE_PAD;
//        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
//		
//		[self drawHashmark:frm context:ctx];
//        
//        rect.size.width -= HASHMARK_WIDTH + SPACE_PAD;
//	}
    
	/*if (self.showDue && hasDue)
	{
        
        frm = CGRectMake(0, 0, 90, rect.size.height);
        
        frm.origin.x = rect.origin.x + rect.size.width - frm.size.width - SPACE_PAD;
        frm.origin.y = (rect.size.height-frm.size.height)/2;
        
        CGSize realSize = [self drawDue:frm context:ctx];
        
        rect.size.width -= realSize.width + SPACE_PAD;
	}*/
    
	if (hasAlert)
	{
		frm.size.width = ALERT_SIZE;
		frm.size.height = ALERT_SIZE;
        
        frm.origin.x = rect.origin.x + rect.size.width - ALERT_SIZE;
        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
        
		//[self drawAlert:frm context:ctx];
        UIImage *alertImage = [[ImageManager getInstance] getImageWithName:@"alert_black.png"];
        
        [alertImage drawInRect:frm];
        
        rect.size.width -= DUE_SIZE;
	}
    
//    if (hasLink)
//    {
//        //printf("task %s has link\n", [task.name UTF8String]);
//		frm.size.width = LINK_SIZE;
//		frm.size.height = LINK_SIZE;
//        
//		frm.origin.x = rect.origin.x + rect.size.width - LINK_SIZE - SPACE_PAD;
//		frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
//		
//		[self drawLink:frm context:ctx];
//        
//        rect.size.width -= LINK_SIZE + SPACE_PAD;
//    }
//    else
//    {
//        //printf("task %s has no link\n", [task.name UTF8String]);
//    }
    
    if ([task isRE])
    {
		frm.size.width = REPEAT_SIZE;
		frm.size.height = REPEAT_SIZE;
        
		frm.origin.x = rect.origin.x + rect.size.width - REPEAT_SIZE;
		frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
		
		UIImage *image = [[ImageManager getInstance] getImageWithName:@"repeat_black.png"];
        
        [image drawInRect:frm];
        
        rect.size.width -= REPEAT_SIZE;
    }
    
	/*if (self.showFlag && hasFlag)
	{
		frm.size.width = FLAG_SIZE;
		frm.size.height = FLAG_SIZE;
        
		//frm.origin.x = rect.origin.x + SPACE_PAD/2;
		//frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
        frm.origin.x = rect.origin.x + rect.size.width - FLAG_SIZE - SPACE_PAD/2;
        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
		
		[self drawFlag:frm context:ctx];
		
        //rect.origin.x += FLAG_SIZE + SPACE_PAD/2;
        //rect.size.width -= FLAG_SIZE + SPACE_PAD/2;
        rect.size.width -= FLAG_SIZE + SPACE_PAD/2;
        
//        frm.size.width = DUE_SIZE;
//		frm.size.height = DUE_SIZE;
//        
//        frm.origin.x = rect.origin.x + rect.size.width - DUE_SIZE - SPACE_PAD/2;
//        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
//        
//		[self drawDue:frm context:ctx];
//        
//        rect.size.width -= DUE_SIZE + SPACE_PAD/2;
	}*/
    
	if (hasHand)
	{
		frm.size.width = HAND_SIZE;
		frm.size.height = HAND_SIZE;
        
		frm.origin.x = rect.origin.x + SPACE_PAD/2;
		frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
		
		[self drawHand:frm context:ctx];
		
        rect.origin.x += HAND_SIZE + SPACE_PAD/2;
        rect.size.width -= HAND_SIZE + SPACE_PAD/2;
	}
    
    [self drawText:rect context:ctx];
}

- (void) drawBoxStyle_old:(CGRect)rect ctx:(CGContextRef)ctx
{    
    //ProjectManager *pm = [ProjectManager getInstance];
    
    //Task *task = (Task *) self.tag;
    
	//BOOL hasAlert = (task.alerts != nil && task.alerts.count > 0);
    BOOL hasAlert = (task.original != nil && ![task isREException]?task.original.alerts.count > 0:task.alerts.count > 0);
	BOOL hasDue = [task isDTask];
	BOOL hasFlag = [task isTask] && (task.isTop || (task.original != nil && task.original.isTop));
    BOOL hasLink = (task.original != nil && ![task isREException]? task.original.links.count > 0: task.links.count > 0);
    BOOL hasHand = [task isShared];

    ////printf("task view: %s - has Link: %s\n", [task.name UTF8String], (hasLink?"Yes":"No"));
    	
    //BOOL hasHashMark = (task.duration != 0);
    BOOL hasHashMark = NO; //dont' draw hash marks in Calendar view
    
	if (rect.size.width <= 120) //no need to draw these in WeekPlanner
	{
		hasAlert = NO;
		hasFlag = NO;
		hasHashMark = NO;
        hasDue = NO;
        if (task.listSource != SOURCE_PLANNER_CALENDAR) {
            hasLink = NO;
        }
	} 
    
	UIColor *lightColor = [[ProjectManager getInstance] getProjectColor2:task.project];
	
	UIColor *dimColor = [[ProjectManager getInstance] getProjectColor1:task.project];
    
	const CGFloat *fstComps = CGColorGetComponents([lightColor CGColor]);	
	const CGFloat *sndComps = CGColorGetComponents([dimColor CGColor]);
	
	size_t num_locations = 3;
	CGFloat locations[3] = { 0.0, 0.4, 1.0 };
	
	CGFloat components[12] = { fstComps[0], fstComps[1], fstComps[2], 1.0,  // Start color
		sndComps[0], sndComps[1], sndComps[2], 1.0, sndComps[0], sndComps[1], sndComps[2], 1.0 };
    
    int shadowPad = 2;
    
    CGRect frm = CGRectOffset(rect, shadowPad, shadowPad);
    
    frm.size.height -= shadowPad;
    frm.size.width -= shadowPad;
    
    [[Common getShadowColor] setFill];
    
    if ([task isTask])
    {
        fillRoundedRect(ctx, frm, 5, 5);
    }
    else 
    {
        CGContextFillRect(ctx, frm);            
    }    
    
    frm = CGRectOffset(frm, -shadowPad, -shadowPad);
    
	if ([task isTask])
	{
		gradientRoundedRect(ctx, frm, 5, 5, components, locations, num_locations);
	}
	else 
	{
		gradientRect(ctx, frm, components, locations, num_locations);
        
        if (self.transparent)
        {
            UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"transparent_pattern.png"]];
            
            [color setFill];
            CGContextFillRect(ctx, frm);
        }
        
	}
    
    if (isSelected)
    {
        CGRect outlineRec = frm;
        
        outlineRec.origin.y += 1;
        outlineRec.origin.x += 1;
        
        UIColor *highlightColor = [UIColor colorWithRed:149.0/255 green:185.0/255 blue:239.0/255 alpha:1];
        
        [highlightColor setStroke];
        CGContextSetLineWidth(ctx, 2);
        
        if ([task isTask])
        {
            strokeRoundedRect(ctx, outlineRec, 5, 5);
        }
        else
        {
            CGContextStrokeRect(ctx, outlineRec);
        }            
    }
    
    rect = frm;
    
    if (self.starEnable)
    {
        rect.size.width -= 20;
    }
    
    if ([task isEvent] || [task isNote])
    {
		//UIImage *image = [[ImageManager getInstance] getImageWithName:@"event.png"];
        UIImage *image = [task isManual] ? [[ImageManager getInstance] getImageWithName:@"atask_lines.png"] : [[ImageManager getInstance] getImageWithName:@"event.png"];
        
        //v4.0
        if (task.groupKey != -1)
        {
            image = [[ImageManager getInstance] getImageWithName:@"exception.png"];
        }
		else if (task.original != nil) //Recurring Event
		{
            //v3.2
            /*
			if (task.repeatData != nil) //exception
			{
				image = [[ImageManager getInstance] getImageWithName:@"exception.png"];
			}
			else*/
			{
				image = [[ImageManager getInstance] getImageWithName:@"repeat.png"];
			}
		}
		
		frm = CGRectOffset(rect, SPACE_PAD, SPACE_PAD);
		frm.size.width = REPEAT_SIZE;
		frm.size.height = REPEAT_SIZE;
		
		[image drawInRect:frm];
        
        rect.origin.x += REPEAT_SIZE + SPACE_PAD;
        rect.size.width -= REPEAT_SIZE + SPACE_PAD;        
    }
    else if ([task isRT])
	{
		frm.size.width = HASHMARK_WIDTH/2;
		frm.size.height = HASHMARK_HEIGHT;
        
        frm.origin.x = rect.origin.x + rect.size.width - HASHMARK_WIDTH - SPACE_PAD;
        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
        
        if (hasHashMark)
        {
            [self drawHashmark:frm context:ctx];
            
            rect.size.width -= HASHMARK_WIDTH + SPACE_PAD;
		}
        else 
        {
            rect.size.width -= HASHMARK_WIDTH/2 + SPACE_PAD;
        }
        
		frm = CGRectOffset(frm, HASHMARK_WIDTH/2 + SPACE_PAD/2, 0);
		frm.size.height /= 2;
		
		UIImage *image = [[ImageManager getInstance] getImageWithName:@"repeat.png"];
        
		[image drawInRect:frm];
	}
	else if ([task isTask] && hasHashMark)
	{
		frm.size.width = HASHMARK_WIDTH;
		frm.size.height = HASHMARK_HEIGHT;
        
        frm.origin.x = rect.origin.x + rect.size.width - HASHMARK_WIDTH - SPACE_PAD;
        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;        
		
		[self drawHashmark:frm context:ctx];
        
        rect.size.width -= HASHMARK_WIDTH + SPACE_PAD;
	}    
    
	if (hasDue)
	{
		frm.size.width = DUE_SIZE;
		frm.size.height = DUE_SIZE;
        
        frm.origin.x = rect.origin.x + rect.size.width - DUE_SIZE - SPACE_PAD/2;
        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;                
        
		[self drawDue:frm context:ctx];
        
        rect.size.width -= DUE_SIZE + SPACE_PAD/2;
	} 
    
	if (hasAlert)
	{
		frm.size.width = ALERT_SIZE;
		frm.size.height = ALERT_SIZE;
        
        frm.origin.x = rect.origin.x + rect.size.width - ALERT_SIZE;
        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;                
        
		[self drawAlert:frm context:ctx];	
        
        rect.size.width -= DUE_SIZE;
	}
 
    if (hasLink)
    {
		frm.size.width = LINK_SIZE;
		frm.size.height = LINK_SIZE;
        
		frm.origin.x = rect.origin.x + rect.size.width - LINK_SIZE;
		frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
        
		[self drawLink:frm context:ctx];
		
        rect.size.width -= LINK_SIZE;
    }
    
	if (hasFlag)
	{
		frm.size.width = FLAG_SIZE;
		frm.size.height = FLAG_SIZE;
        
		frm.origin.x = rect.origin.x + SPACE_PAD/2;
		frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
		
		[self drawFlag:frm context:ctx];
		
        rect.origin.x += FLAG_SIZE + SPACE_PAD/2;
        rect.size.width -= FLAG_SIZE + SPACE_PAD/2;
	}
    
	if (hasHand)
	{
		frm.size.width = HAND_SIZE;
		frm.size.height = HAND_SIZE;
        
		frm.origin.x = rect.origin.x + SPACE_PAD/2;
		frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
		
		[self drawHand:frm context:ctx];
		
        rect.origin.x += HAND_SIZE + SPACE_PAD/2;
        rect.size.width -= HAND_SIZE + SPACE_PAD/2;
	}
    
    rect.origin.x += SPACE_PAD;
    rect.size.width -= SPACE_PAD;
    rect.origin.y += SPACE_PAD;
    rect.size.height -= SPACE_PAD;
    
    [self drawText:rect context:ctx];
}

- (void) drawBoxStyle:(CGRect)rect ctx:(CGContextRef)ctx
{
    //ProjectManager *pm = [ProjectManager getInstance];
    
    //Task *task = (Task *) self.tag;
    
	//BOOL hasAlert = (task.alerts != nil && task.alerts.count > 0);
    //BOOL hasAlert = (task.original != nil && ![task isREException]?task.original.alerts.count > 0:task.alerts.count > 0);
	//BOOL hasDue = [task isDTask];
	//BOOL hasFlag = [task isTask] && (task.isTop || (task.original != nil && task.original.isTop));
    //BOOL hasLink = (task.original != nil && ![task isREException]? task.original.links.count > 0: task.links.count > 0);
    BOOL hasHand = [task isShared];
    
    ////printf("task view: %s - has Link: %s\n", [task.name UTF8String], (hasLink?"Yes":"No"));
    
    //BOOL hasHashMark = (task.duration != 0);
    BOOL hasHashMark = NO; //dont' draw hash marks in Calendar view
    
	/*if (rect.size.width <= 120) //no need to draw these in WeekPlanner
	{
		hasAlert = NO;
		hasFlag = NO;
		hasHashMark = NO;
        hasDue = NO;
        if (task.listSource != SOURCE_PLANNER_CALENDAR) {
            hasLink = NO;
        }
	}*/
    
    /*
	UIColor *lightColor = [[ProjectManager getInstance] getProjectColor2:task.project];
	
	UIColor *dimColor = [[ProjectManager getInstance] getProjectColor1:task.project];
    
	const CGFloat *fstComps = CGColorGetComponents([lightColor CGColor]);
	const CGFloat *sndComps = CGColorGetComponents([dimColor CGColor]);
	
	size_t num_locations = 3;
	CGFloat locations[3] = { 0.0, 0.4, 1.0 };
	
	CGFloat components[12] = { fstComps[0], fstComps[1], fstComps[2], 1.0,  // Start color
		sndComps[0], sndComps[1], sndComps[2], 1.0, sndComps[0], sndComps[1], sndComps[2], 1.0 };
    
    
    int shadowPad = 2;
    
    CGRect frm = CGRectOffset(rect, shadowPad, shadowPad);
    
    frm.size.height -= shadowPad;
    frm.size.width -= shadowPad;
    
    [[Common getShadowColor] setFill];
    
    if ([task isTask])
    {
        fillRoundedRect(ctx, frm, 5, 5);
    }
    else
    {
        CGContextFillRect(ctx, frm);
    }
    
    frm = CGRectOffset(frm, -shadowPad, -shadowPad);
    */
    
    CGRect frm = rect;
    
    UIColor *prjColor = [[ProjectManager getInstance] getProjectColor0:task.project];

    self.layer.cornerRadius = ([task isTask]?6:0);
    self.layer.borderWidth = 0.25;
    self.layer.borderColor = [prjColor CGColor];
    
    //self.layer.backgroundColor = self.transparent?[[UIColor colorWithPatternImage:[UIImage imageNamed:@"transparent_pattern.png"]] CGColor]: [[prjColor colorWithAlphaComponent:0.4] CGColor];
    
    self.layer.backgroundColor = [[prjColor colorWithAlphaComponent:0.4] CGColor];
    
    if (self.transparent)
    {
        UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"transparent_pattern.png"]];
        
        [color setFill];
        CGContextFillRect(ctx, frm);
    }


    /*
    [[prjColor colorWithAlphaComponent:0.4] setFill];
    [prjColor setStroke];
    
	if ([task isTask])
	{
		//gradientRoundedRect(ctx, frm, 5, 5, components, locations, num_locations);
        fillRoundedRect(ctx, frm, 5, 5);
        strokeRoundedRect(ctx, frm, 5, 5);
	}
	else
	{
		//gradientRect(ctx, frm, components, locations, num_locations);
        CGContextFillRect(ctx, frm);
        
        if (self.transparent)
        {
            UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"transparent_pattern.png"]];
            
            [color setFill];
            CGContextFillRect(ctx, frm);
        }
        
        CGContextStrokeRect(ctx, frm);
	}
    */
    
    if (isSelected)
    {
        CGRect outlineRec = frm;
        
        outlineRec.origin.y += 1;
        outlineRec.origin.x += 1;
        
        UIColor *highlightColor = [UIColor colorWithRed:149.0/255 green:185.0/255 blue:239.0/255 alpha:1];
        
        [highlightColor setStroke];
        CGContextSetLineWidth(ctx, 2);
        
        if ([task isTask])
        {
            strokeRoundedRect(ctx, outlineRec, 5, 5);
        }
        else
        {
            CGContextStrokeRect(ctx, outlineRec);
        }
    }
    
    rect = frm;
    
    if (self.starEnable)
    {
        rect.size.width -= 20;
    }
    
    if ([task isEvent] || [task isNote])
    {
		//UIImage *image = [[ImageManager getInstance] getImageWithName:@"event.png"];
        UIImage *image = [task isManual] ? [[ImageManager getInstance] getImageWithName:@"atask_lines.png"] : [[ImageManager getInstance] getImageWithName:@"event.png"];
        
        //v4.0
//        if (task.groupKey != -1)
//        {
//            image = [[ImageManager getInstance] getImageWithName:@"exception.png"];
//        }
//		else if (task.original != nil) //Recurring Event
//		{
//            //v3.2
//            /*
//             if (task.repeatData != nil) //exception
//             {
//             image = [[ImageManager getInstance] getImageWithName:@"exception.png"];
//             }
//             else*/
//			{
//				image = [[ImageManager getInstance] getImageWithName:@"repeat.png"];
//			}
//		}
		
		frm = CGRectOffset(rect, SPACE_PAD, SPACE_PAD);
		frm.size.width = REPEAT_SIZE;
		frm.size.height = REPEAT_SIZE;
		
		[image drawInRect:frm];
        
        rect.origin.x += REPEAT_SIZE + SPACE_PAD;
        rect.size.width -= REPEAT_SIZE + SPACE_PAD;
    }
    /*else if ([task isRT])
	{
		frm.size.width = HASHMARK_WIDTH/2;
		frm.size.height = HASHMARK_HEIGHT;
        
        frm.origin.x = rect.origin.x + rect.size.width - HASHMARK_WIDTH - SPACE_PAD;
        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
        
        if (hasHashMark)
        {
            [self drawHashmark:frm context:ctx];
            
            rect.size.width -= HASHMARK_WIDTH + SPACE_PAD;
		}
        else
        {
            rect.size.width -= HASHMARK_WIDTH/2 + SPACE_PAD;
        }
        
		frm = CGRectOffset(frm, HASHMARK_WIDTH/2 + SPACE_PAD/2, 0);
		frm.size.height /= 2;
		
		UIImage *image = [[ImageManager getInstance] getImageWithName:@"repeat.png"];
        
		[image drawInRect:frm];
	}
	else if ([task isTask] && hasHashMark)
	{
		frm.size.width = HASHMARK_WIDTH;
		frm.size.height = HASHMARK_HEIGHT;
        
        frm.origin.x = rect.origin.x + rect.size.width - HASHMARK_WIDTH - SPACE_PAD;
        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
		
		[self drawHashmark:frm context:ctx];
        
        rect.size.width -= HASHMARK_WIDTH + SPACE_PAD;
	}*/
    
	/*if (hasDue)
	{
		frm.size.width = DUE_SIZE;
		frm.size.height = DUE_SIZE;
        
        frm.origin.x = rect.origin.x + rect.size.width - DUE_SIZE - SPACE_PAD/2;
        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
        
		[self drawDue:frm context:ctx];
        
        rect.size.width -= DUE_SIZE + SPACE_PAD/2;
	}
    
	if (hasAlert)
	{
		frm.size.width = ALERT_SIZE;
		frm.size.height = ALERT_SIZE;
        
        frm.origin.x = rect.origin.x + rect.size.width - ALERT_SIZE;
        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
        
		[self drawAlert:frm context:ctx];
        
        rect.size.width -= DUE_SIZE;
	}
    
    if (hasLink)
    {
		frm.size.width = LINK_SIZE;
		frm.size.height = LINK_SIZE;
        
		frm.origin.x = rect.origin.x + rect.size.width - LINK_SIZE;
		frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
        
		[self drawLink:frm context:ctx];
		
        rect.size.width -= LINK_SIZE;
    }
    
	if (hasFlag)
	{
		frm.size.width = FLAG_SIZE;
		frm.size.height = FLAG_SIZE;
        
		frm.origin.x = rect.origin.x + SPACE_PAD/2;
		frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
		
		[self drawFlag:frm context:ctx];
		
        rect.origin.x += FLAG_SIZE + SPACE_PAD/2;
        rect.size.width -= FLAG_SIZE + SPACE_PAD/2;
	}*/
    
	if (hasHand)
	{
		frm.size.width = HAND_SIZE;
		frm.size.height = HAND_SIZE;
        
		frm.origin.x = rect.origin.x + SPACE_PAD/2;
		frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
		
		[self drawHand:frm context:ctx];
		
        rect.origin.x += HAND_SIZE + SPACE_PAD/2;
        rect.size.width -= HAND_SIZE + SPACE_PAD/2;
	}
    
    rect.origin.x += SPACE_PAD;
    rect.size.width -= SPACE_PAD;
    rect.origin.y += SPACE_PAD;
    rect.size.height -= SPACE_PAD;
    
    [self drawText:rect context:ctx];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
 	CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(ctx, rect);
    
    if (self.focusStyle)
    {
        [self drawFocusStyle:rect ctx:ctx];
    }
    else if (self.listStyle)
    {
        [self drawListStyle:rect ctx:ctx];
    }
    else 
    {
        [self drawBoxStyle:rect ctx:ctx];        
    }
}

#pragma mark MovableView Interface Customization
- (void) enableActions:(BOOL)enable
{
    /*
    if (_plannerViewCtrler != nil)
    {
        [_plannerViewCtrler enableActions:enable onView:self];
    }
    else if (_abstractViewCtrler != nil)
    {
        [_abstractViewCtrler enableActions:enable onView:self];
    }*/
    
    [[AbstractActionViewController getInstance] enableActions:enable onView:self];
}

- (void) singleTouch
{
    [[AbstractActionViewController getInstance] hideDropDownMenu];
    [[[AbstractActionViewController getInstance] getActiveModule] cancelMultiEdit];

    if (_isiPad)
    {
        [[AbstractActionViewController getInstance] editItem:self.task inView:self];
    }
    else
    {
        [[AbstractActionViewController getInstance] enableActions:!self.isSelected onView:self];
    }
}

- (void) doubleTouch
{
    [[AbstractActionViewController getInstance] hideDropDownMenu];
    [[[AbstractActionViewController getInstance] getActiveModule] cancelMultiEdit];
    
	//[super doubleTouch];
	
    /*
    if (_plannerViewCtrler != nil)
    {
        [_plannerViewCtrler editItem:self.task inView:self];
    }
    else if (_abstractViewCtrler != nil)
    {
        [_abstractViewCtrler editItem:self.task inView:self];
    }*/
    
    //if (_iPadViewCtrler != nil)
    if (_isiPad)
    {
        if (self.task.listSource != SOURCE_CALENDAR && self.task.listSource != SOURCE_FOCUS)
        {
            [_iPadViewCtrler slideView:YES];
            
            MovableView *activeView = [[AbstractActionViewController getInstance] getActiveView4Item:self.task];
            
            [[AbstractActionViewController getInstance] editItem:self.task inView:activeView];
        }
    }
    else /*if (_abstractViewCtrler != nil)
    {
        [_abstractViewCtrler editItem:self.task inView:nil];
    }*/
    {
        [[AbstractActionViewController getInstance] editItem:self.task inView:self];
    }
}

- (void) touchAndHold
{
    if ([self.task isShared])
    {
        return;
    }
    
    if (self.task.listSource == SOURCE_CALENDAR) //only allow resize in Calendar View
    {
        [_abstractViewCtrler deselect];
        
        CalendarViewController *ctrler = [_abstractViewCtrler getCalendarViewController];
        
        [ctrler beginResize:self];
    } else if (self.task.listSource == SOURCE_PLANNER_CALENDAR) {
        //[_abstractViewCtrler hidePreview];
        [_plannerViewCtrler deselect];
        
        [_plannerViewCtrler.plannerBottomDayCal beginResize:self];
    }
    
}

-(BOOL) checkMovable:(NSSet *)touches
{
	return [super checkMovable:touches];
}

#pragma mark Notification

- (void)appBusy:(NSNotification *)notification
{
    //NSLog(@"app busy");
    
    self.userInteractionEnabled = NO;
}

- (void)appNoBusy:(NSNotification *)notification
{
    self.userInteractionEnabled = YES;
}

@end
