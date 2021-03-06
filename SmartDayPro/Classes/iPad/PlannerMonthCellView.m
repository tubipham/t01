//
//  PlannerMonthCellView.m
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 3/15/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "PlannerMonthCellView.h"
#import "Common.h"
#import "PlannerMonthView.h"

@implementation PlannerMonthCellView

@synthesize day;
@synthesize month;
@synthesize year;

@synthesize hasDTask;
@synthesize hasSTask;
@synthesize isToday;
@synthesize isFirstDayInWeek;
@synthesize weekNumberInMonth;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
		
		//dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, 40, 20)];
        dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 20, 0, 40, 20)];
		dayLabel.font = [UIFont systemFontOfSize:14];
		dayLabel.backgroundColor = [UIColor clearColor];
		
		[self addSubview:dayLabel];
        
        // init status
        //self.isWeekend = NO;
		//gray = NO;
		isToday = NO;
		//isDot = NO;
		
		hasDTask = NO;
		hasSTask = NO;
        isExpand = NO;
        isFirstDayInWeek = NO;
        gray = NO;
		
		//freeRatio = 0;
        
        self.skinStyle = 1;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // set background color
    UIColor *color;
    CGRect backgroundFrm = rect;
    if (isExpand) {
        UIImage *img = [UIImage imageNamed:@"month_cell_shadow_bg.png"];
        backgroundFrm.size.height = img.size.height;
        color = [UIColor colorWithPatternImage: img];
    } else {
        UIImage *img = [UIImage imageNamed:@"month_cell_bg.png"];
        backgroundFrm.size.height = img.size.height;
        color = [UIColor colorWithPatternImage: img];
    }
    
    [color setFill];
    //CGRect backgroundFrm = rect;
    //backgroundFrm.size.height = 27;
    CGContextFillRect(ctx, backgroundFrm);
    
	UIColor *darkColor = [UIColor grayColor];
	UIColor *lightColor = [UIColor whiteColor];
	UIColor *dotColor = [UIColor whiteColor];
	
	//if ([[Settings getInstance] skinStyle] == 0)
    if (self.skinStyle == 0)
	{
		//darkColor = [UIColor grayColor];
        darkColor = [UIColor lightGrayColor];
		lightColor = [UIColor whiteColor];
		dotColor = [UIColor blackColor];
	}
	else
	{
		darkColor = [UIColor darkGrayColor];
		lightColor = [UIColor lightGrayColor];
		dotColor = [UIColor whiteColor];
	}
	
	[darkColor set];
	
	CGContextSetLineWidth(ctx, 1);
	CGContextStrokeRect(ctx, self.bounds);
	
	[lightColor set];
	
	CGContextSetLineWidth(ctx, 0.5);
	
	CGContextMoveToPoint(ctx,  self.bounds.origin.x,  self.bounds.origin.y + 0.5);
	CGContextAddLineToPoint( ctx,  self.bounds.origin.x + self.bounds.size.width, self.bounds.origin.y + 0.5);
	CGContextStrokePath(ctx);
	
	CGContextMoveToPoint(ctx, self.bounds.origin.x + self.bounds.size.width - 0.5, self.bounds.origin.y);
	CGContextAddLineToPoint( ctx, self.bounds.origin.x + self.bounds.size.width - 0.5, self.bounds.origin.y + self.bounds.size.height);
	CGContextStrokePath(ctx);
	
	if (self.isToday)
	{
		CGContextSetLineWidth(ctx, 2);
		
		[[UIColor colorWithRed:(CGFloat)90/255 green:(CGFloat)111/255 blue:(CGFloat)140/255 alpha:1] set];
		
		CGContextStrokeRect(ctx, CGRectMake(self.bounds.origin.x + 1, self.bounds.origin.y + 1, self.bounds.size.width - 2, self.bounds.size.height - 2));
	}
    
	CGRect dotFrm = CGRectMake(self.bounds.origin.x + self.bounds.size.width - 40, self.bounds.origin.y + 2 + 5, 5, 5);
	
	if (self.hasSTask)
	{
		[[UIColor greenColor] setFill];
		
		CGContextFillEllipseInRect(ctx, dotFrm);
		
		dotFrm = CGRectOffset(dotFrm, -10, 0);
	}
	
	if (self.hasDTask)
	{
		[[UIColor redColor] setFill];
		
		CGContextFillEllipseInRect(ctx, dotFrm);
	}
}

- (void)setDay:(NSInteger) dayValue
{
	day = dayValue;
	
    dayLabel.text = dayValue>0?[NSString stringWithFormat:@"%d", dayValue]:@"";
}

// set dot if this day has DS Task
-(void) setDSDots:(BOOL)dTask sTask:(BOOL)sTask
{
	self.hasDTask = dTask;
	self.hasSTask = sTask;
	
	[self setNeedsDisplay];
}

- (NSDate *)getCellDate
{
	NSDate *date = [NSDate date];
	
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
	
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:date];
    
	comps.year = year;
	comps.month = month;
	comps.day = day;
	
	comps.hour = 0;
	comps.minute = 0;
	comps.second = 0;
	
	date = [gregorian dateFromComponents:comps];
	
	return date;
}

// expand cell
- (void)expandDayCell: (int) height {
    isExpand = YES;
    
    // change frame
    CGRect frm = self.frame;
    frm.size.height = self.frame.size.height + PLANNER_DAY_CELL_HEIGHT;
    frm.size.height = self.frame.size.height + height;
    self.frame = frm;
    
    // change image
    if (isFirstDayInWeek) {
        UIButton *button = (UIButton*)[self viewWithTag:BUTTON_EXPAND_TAG];
        UIImageView *imgView = (UIImageView *) [button viewWithTag:IMAGE_EXPAND_TAG];
        imgView.image = [UIImage imageNamed:@"month_expand.png"];
    }
    
    [self setNeedsDisplay];
}

- (void)collapseDayCell {
    isExpand = NO;
    
    // change height
    CGRect frm = self.frame;
    frm.size.height = PLANNER_DAY_CELL_COLLAPSE_HEIGHT;
    self.frame = frm;
    
    // change image
    if (isFirstDayInWeek) {
        UIButton *button = (UIButton*)[self viewWithTag:BUTTON_EXPAND_TAG];
        UIImageView *imgView = (UIImageView *) [button viewWithTag:IMAGE_EXPAND_TAG];
        imgView.image = [UIImage imageNamed:@"month_collapse.png"];
    }
    
    [self setNeedsDisplay];
}

- (void)disPlayExpandButton:(BOOL)value {
    self.isFirstDayInWeek = value;
    if (isFirstDayInWeek) {
        UIButton *expandButton = [Common createButton:@""
                                           buttonType:UIButtonTypeCustom
                                                frame:CGRectMake(0, 0, 25, 25)
                                           titleColor:[UIColor whiteColor]
                                               target:self
                                             selector:@selector(expand:)
                                     normalStateImage:nil
                                   selectedStateImage:nil];
        expandButton.tag = BUTTON_EXPAND_TAG;
        
        [self addSubview:expandButton];
        
        UIImageView *expandImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 20, 20)];
        expandImgView.tag = IMAGE_EXPAND_TAG;
        
        expandImgView.image = [UIImage imageNamed:@"month_collapse.png"];
        
        [expandButton addSubview:expandImgView];
        [expandImgView release];
    }
}

-(void)setGray:(BOOL) isGray
{
	gray = isGray;
	
	[self changeDayColor];
	
}

- (void) changeDayColor
{
	if (gray)
	{
		//if ([[Settings getInstance] skinStyle] == 0)
        if (self.skinStyle == 0)
		{
			dayLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
		}
		else
		{
			dayLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
		}
	}
	else
	{
		//if ([[Settings getInstance] skinStyle] == 0)
        if (self.skinStyle == 0)
		{
			dayLabel.textColor = [UIColor blackColor];
		}
		else
		{
			dayLabel.textColor = [UIColor whiteColor];
		}
	}
}
#pragma mark Actions

- (void)expand:(id) sender {
    
    PlannerMonthView *monthView = (PlannerMonthView *)self.superview;
    [monthView collapseExpand:weekNumberInMonth];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	PlannerMonthView *parent = (PlannerMonthView *)[self superview];
	[parent selectCell:self];
	
}

- (void)dealloc {
	[dayLabel release];
	
    [super dealloc];
}
@end
