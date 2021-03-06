//
//  SDWSync.h
//  SmartCal
//
//  Created by Mac book Pro on 2/7/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
	SHARED_ACCEPT = 1,
    SHARED_REJECT = 2
} TaskSharedResponse;

typedef enum
{
	SHARED_OBJECT_TASK = 1,
    SHARED_OBJECT_PROJECT = 2
} sharedObjectType;

@class SDWSection;

@class Task;

@interface SDWSync : NSObject
{
    NSInteger syncMode;
    BOOL syncAuto1WayPending;
	BOOL sync2WayPending;
    
    NSDate *lastTaskUpdateTime;
    
    BOOL needResetSection;
    NSInteger lastSyncMode;
}

@property NSInteger syncMode;

@property (nonatomic, copy) NSDate *lastTaskUpdateTime;

@property (nonatomic, retain) SDWSection *sdwSection;
@property (nonatomic, retain) NSMutableDictionary *sdwSCMappingDict;
@property (nonatomic, retain) NSMutableDictionary *scSDWMappingDict;

@property (nonatomic, retain) NSMutableArray *dupCategoryList;

@property (nonatomic, copy) NSString *errorDescription;

- (NSString *)createNewAccount:(NSString *)email passWord:(NSString *)pass;

- (void) initSyncComments;
-(void)initBackgroundSync;
-(void)initBackground1WayPush;
-(void)initBackground1WayGet;
-(void)initBackgroundAuto1WaySync;
-(void)initBackgroundAuto2WaySync;
- (void)resetSyncSection;

- (NSDictionary *) toSDWTaskDict:(Task *)task;
- (Task *) getSDWTask:(NSDictionary *) dict;

+ (BOOL) refreshDeviceUUID;
+ (NSString *) getDeviceUUID;

+ (NSInteger)checkUserValidity:(NSString*)username password:(NSString*)password;
+(id)getInstance;
+(void)free;

#pragma mark Accept / Reject
- (void)initUpdateSDWShared:(NSInteger)objectType andId:(NSInteger)sdwID withStatus:(NSInteger)status;
@end
