//
//  PJPoll.h
//  PolljoySDK
//
//  Copyright (c) 2014 polljoy limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PJPoll : NSObject

@property (nonatomic,strong) NSString *appId;
@property (nonatomic,assign) NSInteger pollId;
@property (nonatomic,assign) NSInteger desiredResponses;
@property (nonatomic,assign) BOOL active;
@property (nonatomic,assign) NSInteger totalResponses;
@property (nonatomic,strong) NSString *pollText;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSString *priority;
@property (nonatomic,strong) NSString *choice;
@property (nonatomic,assign) BOOL randomOrder;
@property (nonatomic,assign) BOOL mandatory;
@property (nonatomic,assign) NSInteger virtualAmount;
@property (nonatomic,strong) NSString *userType;
@property (nonatomic,strong) NSString *pollPlatform;
@property (nonatomic,assign) NSString *versionStart;
@property (nonatomic,assign) NSString *versionEnd;
@property (nonatomic,assign) NSInteger levelStart;
@property (nonatomic,assign) NSInteger levelEnd;
@property (nonatomic,assign) NSInteger sessionStart;
@property (nonatomic,assign) NSInteger sessionEnd;
@property (nonatomic,assign) NSInteger timeSinceInstallStart;
@property (nonatomic,assign) NSInteger timeSinceInstallEnd;
@property (nonatomic,strong) NSString *customMessage;
@property (nonatomic,strong) NSString *pollImageUrl;
@property (nonatomic,assign) NSInteger userId;
@property (nonatomic,strong) NSString *appImageUrl;
@property (nonatomic,strong) UIColor *backgroundColor;
@property (nonatomic,strong) UIColor *borderColor;
@property (nonatomic,strong) UIColor *buttonColor;
@property (nonatomic,strong) UIColor *fontColor;
@property (nonatomic,assign) NSUInteger maximumPollPerSession;
@property (nonatomic,assign) NSUInteger maximumPollPerDay;
@property (nonatomic,assign) NSUInteger maximumPollInARow;
@property (nonatomic,strong) NSString *sessionId;
@property (nonatomic,strong) NSString *platform;
@property (nonatomic,strong) NSString *osVersion;
@property (nonatomic,strong) NSString *deviceId;
@property (nonatomic,assign) NSInteger pollToken;
@property (nonatomic,strong) NSString *response;
@property (nonatomic,assign) BOOL isReadyToShow;

@end
