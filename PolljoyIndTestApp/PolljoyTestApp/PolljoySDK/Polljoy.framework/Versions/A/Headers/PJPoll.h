//
//  PJPoll.h
//  PolljoySDK
//
//  Copyright (c) 2014 polljoy limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PJApp.h"

enum {
    PJPollDefaultImageReady      = 1 << 0,
    PJPollRewardImageReady       = 1 << 1,
    PJPollCloseButtonImageReady  = 1 << 2,
    PJPollBorderLImageReady      = 1 << 3,
    PJPollBorderPImageReady      = 1 << 4,
    PJPollButtonLImageReady      = 1 << 5,
    PJPollButtonPImageReady      = 1 << 6,
    PJPollAllImageReady          = 127
};
typedef NSUInteger PJPollImageStatus;

@interface PJPoll : NSObject

@property (nonatomic,strong) NSString *appId;
@property (nonatomic,assign) NSInteger pollId;
@property (nonatomic,assign) NSInteger desiredResponses;
@property (nonatomic,assign) BOOL active;
@property (nonatomic,assign) NSInteger totalResponses;
@property (nonatomic,strong) NSString *pollText;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSString *priority;
@property (nonatomic,strong) NSString *choice;   // depricated since 1.4.3, use 'choices'
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
@property (nonatomic,strong) NSArray *choices;
@property (nonatomic,strong) NSString *tags;
@property (nonatomic,assign) NSInteger appUsageTime;
@property (nonatomic,strong) NSDictionary *choiceUrl;
@property (nonatomic,strong) NSDictionary *choiceImageUrl;
@property (nonatomic,strong) NSString *collectButtonText;
@property (nonatomic,assign) NSInteger imageCornerRadius;
@property (nonatomic,assign) NSInteger level;
@property (nonatomic,strong) NSString *pollRewardImageUrl;
@property (nonatomic,strong) NSString *prerequisiteType;
@property (nonatomic,strong) NSString *prerequisiteAnswer;
@property (nonatomic,assign) NSInteger prerequisitePoll;
@property (nonatomic,strong) NSDate *sendDate;
@property (nonatomic,assign) NSInteger session;
@property (nonatomic,strong) NSString *submitButtonText;
@property (nonatomic,strong) NSString *thankyouButtonText;
@property (nonatomic,strong) NSString *virtualCurrency;
@property (nonatomic,strong) PJApp *app;
@property (nonatomic,assign) PJPollImageStatus imagesStatus;
@property (nonatomic,assign) NSInteger imagePollStatus;
@property (nonatomic,strong) NSDictionary *childPolls;
@property (nonatomic,assign) NSInteger searchDepth;
@property (nonatomic,strong) NSString *virtualRewardAnswer;
@property (nonatomic,strong) NSString *collectMsgText;
@property (nonatomic,strong) NSString *thankyouMsgText;

-(PJPoll *) initWithRequest: (NSDictionary *) request;

@end
