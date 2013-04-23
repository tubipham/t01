//
//  YearView.h
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 4/22/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YearView : UIView {
    NSDate *date;
}
@property (nonatomic, retain) NSDate *date;

- (void)initCalendar;
@end
