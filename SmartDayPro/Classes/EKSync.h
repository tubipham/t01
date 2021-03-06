//
//  EKSync.h
//  SmartCal
//
//  Created by Trung Nguyen on 7/7/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <EventKit/EventKit.h>
#import <Foundation/Foundation.h>

@class EKEventStore;

@interface EKSync : NSObject {
	NSMutableDictionary *scEKMappingDict;
	NSMutableDictionary *ekSCMappingDict;
	
	EKEventStore *eventStore;
	
	BOOL noMapping;
	
	NSInteger syncMode;
    
    BOOL syncInProgress;
    //NSCondition *syncCond;
    
    NSMutableArray *createList;
    
    EKSource *ekSourceLocal;
    EKSource *ekSourceiCloud;
}

@property (nonatomic, retain) 	NSMutableDictionary *scEKMappingDict;
@property (nonatomic, retain) 	NSMutableDictionary *ekSCMappingDict;

//@property (nonatomic, retain) NSMutableArray *sdOriginatedList;
//@property (nonatomic, retain) NSMutableArray *iCalOriginatedList;

@property (nonatomic, retain) NSMutableArray *dupCategoryList;

@property (nonatomic, retain) 	EKEventStore *eventStore;

@property NSInteger syncMode;
@property NSInteger resultCode; //0:OK, -1:cancel of Cal name duplication, -2:cancel of choosing sync source

-(void)initBackgroundSync;
-(void)initBackgroundSyncBack;
-(void)initBackgroundAuto1WaySync;
-(void)initBackgroundAuto2WaySync;

- (BOOL) syncProjects;

+(BOOL) checkEKAccessEnabled;

+(id)getInstance;
+(void)free;

@end
