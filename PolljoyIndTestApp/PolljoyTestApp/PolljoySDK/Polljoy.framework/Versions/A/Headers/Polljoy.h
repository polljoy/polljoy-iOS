//
//  Polljoy.h
//  PolljoySDK
//
//  Copyright (c) 2014 polljoy limited. All rights reserved.
//

/**
 
 2014/04/14, Antony Man
    Version 1.0

 2014/04/15, Antony Man - fix a bug in background thread when there is only one poll without default image setup
    Version 1.1

 2014/04/16, Antony Man - add session monitor when requesting poll
    Version 1.2
 
 2014/04/17, Antony Man - change API end point to SSL, fix display problem in long question and long answer
    Version 1.3
 
 2014/04/21, Antony Man - update API spec
    Version 1.4
 
 2014/04/24, Antony Man - bug fix in pollId value
    Version 1.4.1
 
 2014/04/24, Antony Man - bug fix
    Version 1.4.2
 
 2014/05/05, Antony Man - added: PJPoll.choices to support ',' in multiple choices answers, added: tags as optional selection criteria
    Version 1.4.3
 
 2014/05/06, Antony Man - bug fix in rescheduling poll request (schedulePollRequest) in setting tags
    Version 1.4.4
 
 2014/05/08, Antony Man - add more controls to present poll UI
    Version 1.4.5
 
 2014/06/09, Antony Man - new poll UI with custom settings
 Version 1.5
 
 2014/06/12, Antony Man - UI update
 Version 1.5.1
 
 2014/06/16, Antony Man - Fixed reward image location in portrait mode
 Version 1.5.2
 
 2014/06/17, Antony Man - Not showing default image when there is no poll image
 Version 1.5.3
 
 2014/06/14, Antony Man - UI improvement
 Version 1.5.4
 
 2014/08/20, Antony Man - Supports Image poll, use REST API Vesion 2
 Version 2.0
 
 2014/11/07 Antony Man - bug fix
 Version 2.0.1
 
 2014/12/24 Antony Man - support getting prerequisite polls at the same queue
 Version 2.1
 
 2015/01/07 Antony Man - UI improvement (show temp msg instead of Thankyou or Collect reward screen), support custom sound when reward user
 Version 2.2
 
 2015/02/28 Antony Man - fixed and get the correct aspect ratio for iPhone 6/iPhone 6+ 
 Version 2.2.2.1
 
 2015/05/04 - use REST API Version 3
 Version 3.0
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "PJPoll.h"
#import "PJApp.h"

typedef enum {
    PJSuccess=0,
    PJSessionRegistrationFail=1,
    PJSessionMauLimitReached=2,
    PJNoPollFound=100,
    PNSessionQuotaReached=102,
    PJDailyQuotaReached=103,
    PJUserQuotaReached=104,
    PJInvalidRequest=110,
    PJInvalidResponse=301,
    PJUnknownError=302,
    PJAlreadyResponded=303,
    PJInvalidPollToken=310,
    PJUserAccountProblem=999
} PJResponseStatus;

typedef enum {
    PJPayUser,
    PJNonPayUser
} PJUserType;

typedef enum {
    PJRewardThankyouMessageStyleMessage,
    PJRewardThankyouMessageStylePopup
} PJRewardThankyouMessageStyle;

@protocol PolljoyDelegate <NSObject>
@optional
-(void) PJPollNotAvailable:(PJResponseStatus) status;
-(void) PJPollIsReady:(NSArray *) polls;
-(void) PJPollWillShow:(PJPoll*) poll;
-(void) PJPollDidShow:(PJPoll*) poll;
-(void) PJPollWillDismiss:(PJPoll*) poll;
-(void) PJPollDidDismiss:(PJPoll*) poll;
-(void) PJPollDidResponded:(PJPoll*) poll;
-(void) PJPollDidSkipped:(PJPoll*) poll;
@end

@interface Polljoy : NSObject
+(void) startSession:(NSString *)appId;
+(void) startSession:(NSString *)appId deviceId:(NSString *) deviceId;

+(void) getPoll;

+(void) getPollWithDelegate:(NSObject<PolljoyDelegate> *) delegate;

+(void) getPollWithDelegate:(NSObject<PolljoyDelegate> *) delegate
                     appVersion:(NSString *) version
                          level:(NSUInteger) level
                       userType:(PJUserType) userType;


+(void) getPollWithDelegate:(NSObject<PolljoyDelegate> *) delegate
                     appVersion:(NSString *) version
                          level:(NSUInteger) level
                        session:(NSUInteger) session
               timeSinceInstall:(NSUInteger) timeSinceInstall
                       userType:(PJUserType) userType;

+(void) getPollWithDelegate:(NSObject<PolljoyDelegate> *) delegate
                 appVersion:(NSString *) version
                      level:(NSUInteger) level
                    session:(NSUInteger) session
           timeSinceInstall:(NSUInteger) timeSinceInstall
                   userType:(PJUserType) userType
                       tags:(NSString*) tags;

+(void) showPoll;

+(void) responsePoll:(NSUInteger) pollToken
            response:(NSString *) response;

+(void) setUserId:(NSString *) userId;
+(void) setAppId:(NSString *) appId;
+(void) setAppVersion:(NSString *) version;
+(void) setLevel:(NSUInteger) level;
+(void) setSession:(NSUInteger) session;
+(void) setTimeSinceInstall:(NSUInteger) timeSinceInstall;
+(void) setUserType:(PJUserType) userType;
+(void) setDelegate:(NSObject<PolljoyDelegate> *) delegate;
+(void) setAutoShow:(BOOL) autoshow;
+(void) setSandboxMode:(BOOL) sandbox;
+(void) setTags:(NSString*) tags;
+(void) setMessageShowDuration: (CGFloat) seconds;
+(void) setRewardThankyouMessageStyle: (PJRewardThankyouMessageStyle) style;

+(PJApp *) app;
+(NSArray *) polls;
+(NSDictionary *) pollsViews;
+(PJPoll *) currentPoll;
+(NSString *) userId;
+(NSString *) appId;
+(NSString *) deviceId;
+(NSString *) sessionId;
+(NSString *) version;
+(NSUInteger) level;
+(NSUInteger) session;
+(NSUInteger) timeSinceInstall;
+(PJUserType) userType;
+(NSString *) tags;
+(NSString *) SDKVersion;
+(SystemSoundID) soundID;
+(SystemSoundID) tapSoundID;
+(CGFloat) messageShowDuration;
+(PJRewardThankyouMessageStyle) rewardThankyouMessageStyle;

@end
