//
//  Polljoy.m
//  PolljoySDK
//
//  Copyright (c) 2014 polljoy limited. All rights reserved.
//

#import "Polljoy.h"
#import "PolljoyCore.h"
#import "PJPollView.h"
#import "PJImageDownloader.h"

#define PJ_SDK_NAME @"Polljoy"
#define PJ_API_SANDBOX_endpoint @"https://apisandbox.polljoy.com/poll/"
#define PJ_API_PRODUCTION_endpoint @"https://api.polljoy.com/poll/"

@interface Polljoy () {
    
}

@end

static NSString *PJ_API_endpoint=PJ_API_PRODUCTION_endpoint;
static BOOL _isRegisteringSession=NO;
static BOOL _needsAutoShow=NO;

static NSObject<PolljoyDelegate> * _delegate;

static NSString *_appId;
static NSString *_userId;
static NSString *_sessionId;
static NSString *_deviceId;
static NSString *_deviceModel;
static NSString *_devicePlatform;
static NSString *_deviceOS;

static PJApp *_app;
static PJPoll *_currentPoll;

static NSString *_appVersion;
static NSUInteger _level;
static NSUInteger _session;
static NSUInteger _timeSinceInstall;
static PJUserType _userType;
static NSString *_tags;
static NSMutableArray *_polls;  // this must be in order
static NSMutableDictionary *_pollsViews;

static BOOL _autoshow;

static NSOperationQueue *_backgroundQueue;

@implementation Polljoy

+(void) startSession:(NSString *)appId
{
    [[self class] startSession:appId newSession:YES];
}

+(void) startSession:appId newSession:(BOOL) newSession
{
    
    if (appId == nil) {
        NSLog(@"[%@ %@] missing appId:%@", _PJ_CLASS, _PJ_METHOD,appId);
        return;
    }
    
    _sessionId = nil;
    _deviceId = [PolljoyCore getDeviceId];
    _deviceModel = [PolljoyCore getDeviceModel];
    _devicePlatform = @"ios";
    _deviceOS = [[UIDevice currentDevice] systemVersion];
    //_userId = userId;
    _appId = appId;
    _appVersion = @"0";
    _level = 0;
    _userType = PJNonPayUser;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _session = newSession?[PolljoyCore getSession]:[PolljoyCore getCurrentSession];
        _timeSinceInstall = [PolljoyCore getTimeSinceInstall];

    });
    
    // POST data to register session
    NSString *endPoint = [PJ_API_endpoint stringByAppendingString:@"registerSession.json"];
    
    //-- Make URL request with server
    NSURL *url = [NSURL URLWithString:[endPoint stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    // create queue
    _backgroundQueue=[[NSOperationQueue alloc] init];
    
    //-- Get request and response though URL
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    //create the body
    NSMutableData *postBody = [NSMutableData data];
    NSString *dataString=[NSString stringWithFormat:@"appId=%@&deviceId=%@",_appId,_deviceId];
    [postBody appendData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
    
    //post
    [request setHTTPBody:postBody];
    
    _isRegisteringSession=YES;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:_backgroundQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if (!connectionError) {
                                   NSMutableDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                                   
                                   NSNumber *status=[responseObject objectForKey:@"status"];
                                   NSDictionary *appDict=[responseObject objectForKey:@"app"];
                                   
                                   if ([status integerValue]==0) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           _sessionId=[appDict objectForKey:@"sessionId"];
                                           
                                           // set app data
                                           PJApp *app=[[PJApp alloc] init];
                                           app.appId=[appDict objectForKey:@"id"];
                                           app.appName=[appDict objectForKey:@"appName"];
                                           app.defaultImageUrl=[appDict objectForKey:@"defaultImageUrl"];
                                           app.maximumPollPerSession=[[appDict objectForKey:@"maxPollsPerSession"] integerValue];
                                           app.maximumPollPerDay=[[appDict objectForKey:@"maxPollsPerDay"] integerValue];
                                           app.maximumPollInARow=[[appDict objectForKey:@"maxPollsInARow"] integerValue];
                                           app.backgroundColor=[PolljoyCore colorFromHexString:[appDict objectForKey:@"backgroundColor"]];
                                           app.borderColor=[PolljoyCore colorFromHexString:[appDict objectForKey:@"borderColor"]];
                                           app.buttonColor=[PolljoyCore colorFromHexString:[appDict objectForKey:@"buttonColor"]];
                                           app.fontColor=[PolljoyCore colorFromHexString:[appDict objectForKey:@"fontColor"]];
                                           app.backgroundAlpha=[[appDict objectForKey:@"backgroundAlpha"] integerValue];
                                           app.backgroundCornerRadius=[[appDict objectForKey:@"backgroundCornerRadius"] integerValue];
                                           app.borderWidth=[[appDict objectForKey:@"borderWidth"] integerValue];
                                           app.borderImageUrl_16x9_L=[appDict objectForKey:@"borderImageUrl_16x9_L"];
                                           app.borderImageUrl_16x9_P=[appDict objectForKey:@"borderImageUrl_16x9_P"];
                                           app.borderImageUrl_3x2_L=[appDict objectForKey:@"borderImageUrl_3x2_L"];
                                           app.borderImageUrl_3x2_P=[appDict objectForKey:@"borderImageUrl_3x2_P"];
                                           app.borderImageUrl_4x3_L=[appDict objectForKey:@"borderImageUrl_4x3_L"];
                                           app.borderImageUrl_4x3_P=[appDict objectForKey:@"borderImageUrl_4x3_P"];
                                           app.buttonFontColor=[PolljoyCore colorFromHexString:[appDict objectForKey:@"buttonFontColor"]];
                                           app.buttonImageUrl_16x9_L=[appDict objectForKey:@"buttonImageUrl_16x9_L"];
                                           app.buttonImageUrl_16x9_P=[appDict objectForKey:@"buttonImageUrl_16x9_P"];
                                           app.buttonImageUrl_3x2_L=[appDict objectForKey:@"buttonImageUrl_3x2_L"];
                                           app.buttonImageUrl_3x2_P=[appDict objectForKey:@"buttonImageUrl_3x2_P"];
                                           app.buttonImageUrl_4x3_L=[appDict objectForKey:@"buttonImageUrl_4x3_L"];
                                           app.buttonImageUrl_4x3_P=[appDict objectForKey:@"buttonImageUrl_4x3_P"];
                                           app.buttonShadow=[[appDict objectForKey:@"buttonShadow"] boolValue];
                                           app.closeButtonImageUrl=[appDict objectForKey:@"closeButtonImageUrl"];
                                           app.closeButtonLocation=[[appDict objectForKey:@"closeButtonLocation"] integerValue];
                                           app.closeButtonOffsetX=[[appDict objectForKey:@"closeButtonOffsetX"] integerValue];
                                           app.closeButtonOffsetY=[[appDict objectForKey:@"closeButtonOffsetY"] integerValue];
                                           app.deviceId=[appDict objectForKey:@"deviceId"];
                                           app.fontName=[appDict objectForKey:@"fontName"];
                                           app.overlayAlpha=[[appDict objectForKey:@"overlayAlpha"] integerValue];
                                           app.rewardImageUrl=[appDict objectForKey:@"rewardImageUrl"];
                                           app.userId=[appDict objectForKey:@"userId"];
                                           app.imageCornerRadius = [[appDict objectForKey:@"imageCornerRadius"] integerValue];
                                                                    
                                           _app = app;
                                           
                                           _userId = [appDict objectForKey:@"userId"];
                                           
                                           [[self class] downloadAppImage:_app.defaultImageUrl];
                                           
                                           util_Log(@"[%@ %@] _sessionId: %@", _PJ_CLASS, _PJ_METHOD, _sessionId);
                                           util_Log(@"[%@ %@] _deviceId: %@", _PJ_CLASS, _PJ_METHOD, _deviceId);
                                           util_Log(@"[%@ %@] _deviceModel: %@", _PJ_CLASS, _PJ_METHOD, _deviceModel);
                                           util_Log(@"[%@ %@] _deviceOS: %@", _PJ_CLASS, _PJ_METHOD, _deviceOS);
                                           util_Log(@"[%@ %@] _devicePlatform: %@", _PJ_CLASS, _PJ_METHOD, _devicePlatform);
                                           util_Log(@"[%@ %@] _session: %lu", _PJ_CLASS, _PJ_METHOD, (unsigned long)_session);
                                           util_Log(@"[%@ %@] _timeSinceInstall: %lu", _PJ_CLASS, _PJ_METHOD, (unsigned long)_timeSinceInstall);
                                           util_Log(@"[%@ %@] App: %@", _PJ_CLASS, _PJ_METHOD, _app.appName);
                                       });
                                   }
                                   else {
                                       NSLog(@"%@: startSession Error - Status: %@ appId: %@", PJ_SDK_NAME, status, _appId);
                                   }
                               }
                               else {
                                   NSLog(@"%@: startSession Error: %@ appId:%@", PJ_SDK_NAME, [connectionError localizedDescription], _appId);
                               }
                               
                               _isRegisteringSession=NO;
                           }];
}

+(void) getPoll
{
    _needsAutoShow=YES;
    [[self class] getPollWithDelegate:nil];
}

+(void) getPollWithDelegate:(NSObject<PolljoyDelegate> *) delegate
{
    [[self class] getPollWithDelegate:delegate
                           appVersion:nil
                                level:0
                              session:0
                     timeSinceInstall:0
                             userType:PJNonPayUser];
}

+(void) getPollWithDelegate:(NSObject<PolljoyDelegate> *) delegate
                 appVersion:(NSString *) version
                      level:(NSUInteger) level
                   userType:(PJUserType) userType
{
    [[self class] getPollWithDelegate:delegate
                           appVersion:version
                                level:level
                              session:0
                     timeSinceInstall:0
                             userType:userType];
}

+(void) schedulePollRequest
{
    dispatch_async(dispatch_get_main_queue(), ^{
    [[self class] getPollWithDelegate:_delegate
                           appVersion:_appVersion
                                level:_level
                              session:_session
                     timeSinceInstall:_timeSinceInstall
                             userType:_userType
                                 tags:_tags];
    });

}

+(void) getPollWithDelegate:(NSObject<PolljoyDelegate> *) delegate
                 appVersion:(NSString *) version
                      level:(NSUInteger) level
                    session:(NSUInteger) session
           timeSinceInstall:(NSUInteger) timeSinceInstall
                   userType:(PJUserType) userType
{
    [[self class] getPollWithDelegate:delegate
                           appVersion:version
                                level:level
                              session:session
                     timeSinceInstall:timeSinceInstall
                             userType:userType
                                 tags:nil];

}

+(void) getPollWithDelegate:(NSObject<PolljoyDelegate> *) delegate
                 appVersion:(NSString *) version
                      level:(NSUInteger) level
                    session:(NSUInteger) session
           timeSinceInstall:(NSUInteger) timeSinceInstall
                   userType:(PJUserType) userType
                       tags:(NSString*) tags
{
    
    if (_sessionId==nil) {
        
        _appVersion=version;
        _level=level;
        _session=session;
        _timeSinceInstall=timeSinceInstall;
        _userType=userType;
        _delegate=delegate;
        _tags=tags;
        
        // check if _isRegitseringSession. if yes, delay the request by 1 sec
        if (_isRegisteringSession) {
            util_Log(@"[%@ %@] _isRegisteringSession, delay poll request for 1 sec", _PJ_CLASS, _PJ_METHOD);
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:[self class] selector:@selector(schedulePollRequest) userInfo:nil repeats:NO];
        }
        else if (_appId!=nil) {
             util_Log(@"[%@ %@] user already set appId. startSession onbehalf. delay poll request for 2 sec", _PJ_CLASS, _PJ_METHOD);
            // user has set appId and userId, try to register for them and delay the request by 2 second
            [[self class] startSession:_appId newSession:NO];
            [NSTimer scheduledTimerWithTimeInterval:2.0 target:[self class] selector:@selector(schedulePollRequest) userInfo:nil repeats:NO];
        }
        else {
            NSLog(@"%@: Error - Session Not Registered", PJ_SDK_NAME);
            if ([delegate respondsToSelector:@selector(PJPollNotAvailable:)]) {
                [delegate PJPollNotAvailable:PJNoPollFound];
            }
        }
        
        return;
    }
    
    _delegate=delegate;
    _polls = [NSMutableArray array];
    _pollsViews = [NSMutableDictionary dictionary];
    
    NSString *endPoint = [PJ_API_endpoint stringByAppendingString:@"smartget.json"];

    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:_sessionId,@"sessionId",
                                       _deviceId,@"deviceId",
                                       _deviceModel,@"deviceModel",
                                       _devicePlatform,@"platform",
                                       _deviceOS,@"osVersion",
                                       nil];
    
    if (version!=nil) [parameters setObject:version forKey:@"appVersion"];
    else if (_appVersion!=nil) [parameters setObject:_appVersion forKey:@"appVersion"];
    
    if (level>0) [parameters setObject:[NSNumber numberWithInteger:level] forKey:@"level"];
    else if (_level>0) [parameters setObject:[NSNumber numberWithInteger:_level] forKey:@"level"];
    
    if (session>0) [parameters setObject:[NSNumber numberWithInteger:session] forKey:@"sessionCount"];
    else if (_session>0) [parameters setObject:[NSNumber numberWithInteger:_session] forKey:@"sessionCount"];
    
    if (timeSinceInstall>0) [parameters setObject:[NSNumber numberWithInteger:timeSinceInstall] forKey:@"timeSinceInstall"];
    else if (_timeSinceInstall>0) [parameters setObject:[NSNumber numberWithInteger:_timeSinceInstall] forKey:@"timeSinceInstall"];
    
    if (userType==PJPayUser) [parameters setObject:@"Pay" forKey:@"userType"];
    else [parameters setObject:@"Non-Pay" forKey:@"userType"];
    
    if (tags!=nil) [parameters setObject:tags forKey:@"tags"];
    
    //-- Make URL request with server
    NSURL *url = [NSURL URLWithString:[endPoint stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    // create queue
    _backgroundQueue=[[NSOperationQueue alloc] init];
    
    //-- Get request and response though URL
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    //create the body
    NSMutableData *postBody = [NSMutableData data];
    NSString *dataString=@"";
    
    // format the query string for POST body
    for (NSString *key in [parameters allKeys]){
        dataString=[dataString stringByAppendingFormat:@"%@=%@&",key,[parameters objectForKey:key]];
    }
        
    [postBody appendData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
    
    //post
    [request setHTTPBody:postBody];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:_backgroundQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if (!connectionError) {
                                   NSError *error;
                                   NSMutableDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                                   
                                   NSNumber *status=[responseObject objectForKey:@"status"];
                                   //NSNumber *count=[responseObject objectForKey:@"count"];
                                   NSString *message=[responseObject objectForKey:@"message"];
                                   NSArray *pollsArray=[responseObject objectForKey:@"polls"];

                                   if ([status integerValue]==0) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           
                                           NSInteger count=0;
                                           _polls = [NSMutableArray array];
                                           _pollsViews = [NSMutableDictionary dictionary];
                                           for ( NSDictionary *pollRequest in pollsArray) {
                                               NSDictionary *request=[pollRequest objectForKey:@"PollRequest"];
                                               
                                               PJPoll *poll=[[PJPoll alloc] init];
                                               poll.appId=[request objectForKey:@"appId"];
                                               poll.pollId=[[request objectForKey:@"pollId"] integerValue];
                                               poll.desiredResponses=[[request objectForKey:@"desiredResponses"] integerValue];
                                               poll.totalResponses=[[request objectForKey:@"totalResponses"] integerValue];
                                               poll.active=[[request objectForKey:@"active"] boolValue];
                                               poll.pollText=[request objectForKey:@"pollText"];
                                               poll.type=[request objectForKey:@"type"];
                                               poll.priority=[request objectForKey:@"priority"];
                                               poll.choice=[request objectForKey:@"choice"];
                                               poll.randomOrder=[[request objectForKey:@"randomOrder"] boolValue];
                                               poll.mandatory=[[request objectForKey:@"mandatory"] boolValue];
                                               poll.virtualAmount=[request objectForKey:@"virtualAmount"]!=[NSNull null]?[[request objectForKey:@"virtualAmount"] integerValue]:0;
                                               poll.userType=[request objectForKey:@"userType"];
                                               poll.pollPlatform=[request objectForKey:@"pollPlatform"];
                                               poll.versionStart=[request objectForKey:@"versionStart"];
                                               poll.versionEnd=[request objectForKey:@"versionEnd"];
                                               poll.levelStart=[request objectForKey:@"levelStart"] !=[NSNull null]?[[request objectForKey:@"levelStart"] integerValue]:0;
                                               poll.levelEnd=[request objectForKey:@"levelEnd"]!=[NSNull null]?[[request objectForKey:@"levelEnd"] integerValue]:0;
                                               poll.sessionStart=[request objectForKey:@"sessionStart"]!=[NSNull null]?[[request objectForKey:@"sessionStart"] integerValue]:0;
                                               poll.sessionEnd=[request objectForKey:@"sessionEnd"]!=[NSNull null]?[[request objectForKey:@"sessionEnd"] integerValue]:0;
                                               poll.timeSinceInstallStart=[request objectForKey:@"timeSinceInstallStart"]!=[NSNull null]?[[request objectForKey:@"timeSinceInstallStart"] integerValue]:0;
                                               poll.timeSinceInstallEnd=[request objectForKey:@"timeSinceInstallEnd"]!=[NSNull null]?[[request objectForKey:@"timeSinceInstallEnd"] integerValue]:0;
                                               poll.customMessage=[request objectForKey:@"customMessage"];
                                               poll.pollImageUrl=[request objectForKey:@"pollImageUrl"];
                                               poll.userId=[[request objectForKey:@"userId"] integerValue];
                                               poll.appImageUrl=[request objectForKey:@"appImageUrl"];
                                               poll.backgroundColor=[PolljoyCore colorFromHexString:[request objectForKey:@"backgroundColor"]];
                                               poll.borderColor=[PolljoyCore colorFromHexString:[request objectForKey:@"borderColor"]];
                                               poll.fontColor=[PolljoyCore colorFromHexString:[request objectForKey:@"fontColor"]];
                                               poll.buttonColor=[PolljoyCore colorFromHexString:[request objectForKey:@"buttonColor"]];
                                               poll.maximumPollPerSession=[[request objectForKey:@"maxPollPerSession"] integerValue];
                                               poll.maximumPollPerDay=[[request objectForKey:@"maxPollPerDay"] integerValue];
                                               poll.maximumPollInARow=[[request objectForKey:@"maxPollInARow"] integerValue];
                                               poll.sessionId=[request objectForKey:@"sessionId"];
                                               poll.platform=[request objectForKey:@"platform"];
                                               poll.osVersion=[request objectForKey:@"osVersion"];
                                               poll.deviceId=[request objectForKey:@"deviceId"];
                                               poll.pollToken=[[request objectForKey:@"pollToken"] integerValue];
                                               poll.response=[request objectForKey:@"response"];
                                               poll.isReadyToShow=NO;
                                               poll.choices=[request objectForKey:@"choices"];
                                               poll.tags=[request objectForKey:@"tags"];
                                               poll.appUsageTime=[[request objectForKey:@"appUsageTime"] integerValue];
                                               poll.choiceUrl=[request objectForKey:@"choiceUrl"];
                                               poll.collectButtonText=[request objectForKey:@"collectButtonText"];
                                               poll.imageCornerRadius=[[request objectForKey:@"imageCornerRadius"] integerValue];
                                               poll.level=[[request objectForKey:@"level"] integerValue];
                                               poll.pollRewardImageUrl=[request objectForKey:@"pollRewardImageUrl"];
                                               poll.prerequisiteType=[request objectForKey:@"prerequisiteType"];
                                               poll.prerequisiteAnswer=[request objectForKey:@"prerequisiteAnswer"];
                                               poll.prerequisitePoll=(([request objectForKey:@"prerequisitePoll"] != nil) && (![[request objectForKey:@"prerequisitePoll"] isEqual:[NSNull null]]))?[[request objectForKey:@"prerequisitePoll"] integerValue ]:-1;
                                               poll.sendDate=[request objectForKey:@"sendDate"];
                                               poll.session=[[request objectForKey:@"session"] integerValue];
                                               poll.submitButtonText=[request objectForKey:@"submitButtonText"];
                                               poll.thankyouButtonText=[request objectForKey:@"thankyouButtonText"];
                                               poll.virtualCurrency=[request objectForKey:@"virtualCurrency"];
                                               
                                               // update _app from first record
                                               if (count == 0) {
                                                   NSDictionary *appDict=[request objectForKey:@"app"];
                                                   
                                                   _app.appId=[appDict objectForKey:@"id"];
                                                   _app.appName=[appDict objectForKey:@"appName"];
                                                   _app.defaultImageUrl=[appDict objectForKey:@"defaultImageUrl"];
                                                   _app.maximumPollPerSession=[[appDict objectForKey:@"maxPollsPerSession"] integerValue];
                                                   _app.maximumPollPerDay=[[appDict objectForKey:@"maxPollsPerDay"] integerValue];
                                                   _app.maximumPollInARow=[[appDict objectForKey:@"maxPollsInARow"] integerValue];
                                                   _app.backgroundColor=[PolljoyCore colorFromHexString:[appDict objectForKey:@"backgroundColor"]];
                                                   _app.borderColor=[PolljoyCore colorFromHexString:[appDict objectForKey:@"borderColor"]];
                                                   _app.buttonColor=[PolljoyCore colorFromHexString:[appDict objectForKey:@"buttonColor"]];
                                                   _app.fontColor=[PolljoyCore colorFromHexString:[appDict objectForKey:@"fontColor"]];
                                                   _app.backgroundAlpha=[[appDict objectForKey:@"backgroundAlpha"] integerValue];
                                                   _app.backgroundCornerRadius=[[appDict objectForKey:@"backgroundCornerRadius"] integerValue];
                                                   _app.borderWidth=[[appDict objectForKey:@"borderWidth"] integerValue];
                                                   _app.borderImageUrl_16x9_L=[appDict objectForKey:@"borderImageUrl_16x9_L"];
                                                   _app.borderImageUrl_16x9_P=[appDict objectForKey:@"borderImageUrl_16x9_P"];
                                                   _app.borderImageUrl_3x2_L=[appDict objectForKey:@"borderImageUrl_3x2_L"];
                                                   _app.borderImageUrl_3x2_P=[appDict objectForKey:@"borderImageUrl_3x2_P"];
                                                   _app.borderImageUrl_4x3_L=[appDict objectForKey:@"borderImageUrl_4x3_L"];
                                                   _app.borderImageUrl_4x3_P=[appDict objectForKey:@"borderImageUrl_4x3_P"];
                                                   _app.buttonFontColor=[PolljoyCore colorFromHexString:[appDict objectForKey:@"buttonFontColor"]];
                                                   _app.buttonImageUrl_16x9_L=[appDict objectForKey:@"buttonImageUrl_16x9_L"];
                                                   _app.buttonImageUrl_16x9_P=[appDict objectForKey:@"buttonImageUrl_16x9_P"];
                                                   _app.buttonImageUrl_3x2_L=[appDict objectForKey:@"buttonImageUrl_3x2_L"];
                                                   _app.buttonImageUrl_3x2_P=[appDict objectForKey:@"buttonImageUrl_3x2_P"];
                                                   _app.buttonImageUrl_4x3_L=[appDict objectForKey:@"buttonImageUrl_4x3_L"];
                                                   _app.buttonImageUrl_4x3_P=[appDict objectForKey:@"buttonImageUrl_4x3_P"];
                                                   _app.buttonShadow=[[appDict objectForKey:@"buttonShadow"] boolValue];
                                                   _app.closeButtonImageUrl=[appDict objectForKey:@"closeButtonImageUrl"];
                                                   _app.closeButtonLocation=[[appDict objectForKey:@"closeButtonLocation"] integerValue];
                                                   _app.closeButtonOffsetX=[[appDict objectForKey:@"closeButtonOffsetX"] integerValue];
                                                   _app.closeButtonOffsetY=[[appDict objectForKey:@"closeButtonOffsetY"] integerValue];
                                                   _app.deviceId=[appDict objectForKey:@"deviceId"];
                                                   _app.fontName=[appDict objectForKey:@"fontName"];
                                                   _app.overlayAlpha=[[appDict objectForKey:@"overlayAlpha"] integerValue];
                                                   _app.rewardImageUrl=[appDict objectForKey:@"rewardImageUrl"];
                                                   _app.userId=[appDict objectForKey:@"userId"];
                                                   _app.imageCornerRadius=[[appDict objectForKey:@"imageCornerRadius"] integerValue];
                                               }
                                               poll.app =_app;
                                               
                                               // create the view
                                               PJPollView *pollView=[[PJPollView alloc] initWithPoll:poll];
                                               pollView.delegate=(id) self;
                                               [_pollsViews setObject:pollView forKey:[NSNumber numberWithInteger:poll.pollToken]];
                                               [_polls addObject:poll];
                                            
                                               count++;
                                           }
                                       });
                                   }
                                   else {
                                       NSLog(@"%@: Error - Status: %@ (%@)", PJ_SDK_NAME, status,message);
                                       if ([delegate respondsToSelector:@selector(PJPollNotAvailable:)]) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [delegate PJPollNotAvailable:(PJResponseStatus)[status integerValue]];
                                           });
                                       }
                                   }
                               }
                               else {
                                   NSLog(@"%@: Error: %@", PJ_SDK_NAME, [connectionError localizedDescription]);
                               }
                           }];
}

+(void) responsePoll:(NSUInteger) pollToken
            response:(NSString *) response
{
    NSString *endPoint = [PJ_API_endpoint stringByAppendingFormat:@"response/%lu.json", (unsigned long)pollToken];

    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       _sessionId,@"sessionId",
                                       _deviceId,@"deviceId",
                                       response,@"response",
                                       nil];
    //-- Make URL request with server
    NSURL *url = [NSURL URLWithString:[endPoint stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    // create queue
    _backgroundQueue=[[NSOperationQueue alloc] init];
    
    //-- Get request and response though URL
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    //create the body
    NSMutableData *postBody = [NSMutableData data];
    NSString *dataString=@"";
    
    // format the query string for POST body
    for (NSString *key in [parameters allKeys]){
        dataString=[dataString stringByAppendingFormat:@"%@=%@&",key,[parameters objectForKey:key]];
    }
    
    [postBody appendData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
    
    //post
    [request setHTTPBody:postBody];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:_backgroundQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if (!connectionError) {
                                   NSMutableDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                                   
                                   NSNumber *status=[responseObject objectForKey:@"status"];
                                   NSString *message=[responseObject objectForKey:@"message"];
                                   NSString *virtualAmount=[responseObject objectForKey:@"virtualAmount"];
                                   NSString *response=[responseObject objectForKey:@"response"];
                                   
                                   if ([status integerValue]==0) {
                                       util_Log(@"[%@ %@] status: %@ message: %@", _PJ_CLASS, _PJ_METHOD, status, message);
                                       util_Log(@"[%@ %@] response: %@", _PJ_CLASS, _PJ_METHOD, response);
                                       util_Log(@"[%@ %@] virtualAmount: %@", _PJ_CLASS, _PJ_METHOD, virtualAmount);
                                   }
                                   else {
                                       NSLog(@"%@: Error - Status: %@ (%@)", PJ_SDK_NAME, status,message);
                                   }

                               }
                               else {
                                   NSLog(@"%@: Error: %@", PJ_SDK_NAME, [connectionError localizedDescription]);
                               }
                           }];
}

+(void) checkPollStatus
{
    if ([_polls count]==0) return;
    BOOL pollsAreReady=YES;
    for (PJPoll *poll in _polls) {
        if (!poll.isReadyToShow) {
            pollsAreReady=NO;
        }
    }
    
    if (pollsAreReady) {
        util_Log(@"[%@ %@] Polls are ready.", _PJ_CLASS, _PJ_METHOD);
        if ([_delegate respondsToSelector:@selector(PJPollIsReady:)]) {
            [_delegate PJPollIsReady:_polls];
        }
        
        if ((_autoshow) || (_needsAutoShow)) {
            _needsAutoShow=NO;
            [Polljoy showPoll];
        }
    }
    else {
        util_Log(@"[%@ %@] Polls are not ready.", _PJ_CLASS, _PJ_METHOD);
    }
}

+(void) downloadAppImage:(NSString*) urlString
{    
    // cache the default image and let it handle by iOS
    if ((_app.defaultImageUrl !=nil) && (![_app.defaultImageUrl isEqual:[NSNull null]])){
        PJImageDownloader *imageDownloader = [[PJImageDownloader alloc] init];
        [imageDownloader setUrlString:_app.defaultImageUrl];
        [imageDownloader setCompletionHandler:^(UIImage * image) {
            // do nothing, just let iOS cache the image
             util_Log(@"[%@ %@] defaultImageUrl completed: %@", _PJ_CLASS, _PJ_METHOD, urlString);
        }];
        
        [imageDownloader startDownload];

    }
    
    // cache reward image
    if ((_app.rewardImageUrl !=nil) && (![_app.rewardImageUrl isEqual:[NSNull null]])){
        PJImageDownloader *imageDownloader = [[PJImageDownloader alloc] init];
        [imageDownloader setUrlString:_app.rewardImageUrl];
        [imageDownloader setCompletionHandler:^(UIImage * image) {
            // do nothing, just let iOS cache the image
            util_Log(@"[%@ %@] rewardImageUrl completed: %@", _PJ_CLASS, _PJ_METHOD, _app.closeButtonImageUrl);
        }];
        
        [imageDownloader startDownload];
        
    }
    
    // cache close button image
    if ((_app.closeButtonImageUrl != nil) && (![_app.closeButtonImageUrl isEqual:[NSNull null]])){
        PJImageDownloader *imageDownloader = [[PJImageDownloader alloc] init];
        [imageDownloader setUrlString:_app.closeButtonImageUrl];
        [imageDownloader setCompletionHandler:^(UIImage * image) {
            // do nothing, just let iOS cache the image
            util_Log(@"[%@ %@] closeButtonImageUrl completed: %@", _PJ_CLASS, _PJ_METHOD, _app.closeButtonImageUrl);
        }];
        
        [imageDownloader startDownload];
        
    }
    
    // cache border and button image
    NSString *borderImageL = nil;
    NSString *borderImageP = nil;
    NSString *buttonImageL = nil;
    NSString *buttonImageP = nil;
    
    if (IS_IPHONE) {
        if (IS_HEIGHT_GTE_568) {
            // 16:9
            borderImageL = [_app.borderImageUrl_16x9_L length] > 0 ? _app.borderImageUrl_16x9_L : nil;
            borderImageP = [_app.borderImageUrl_16x9_P length] > 0 ? _app.borderImageUrl_16x9_P : nil;
            buttonImageL = [_app.buttonImageUrl_16x9_L length] > 0 ? _app.buttonImageUrl_16x9_L : nil;
            buttonImageP = [_app.buttonImageUrl_16x9_P length] > 0 ? _app.buttonImageUrl_16x9_P : nil;
        }
        else {
            // 3:2
            borderImageL = [_app.borderImageUrl_3x2_L length] > 0 ? _app.borderImageUrl_3x2_L : nil;
            borderImageP = [_app.borderImageUrl_3x2_P length] > 0 ? _app.borderImageUrl_3x2_P : nil;
            buttonImageL = [_app.buttonImageUrl_3x2_L length] > 0 ? _app.buttonImageUrl_3x2_L : nil;
            buttonImageP = [_app.buttonImageUrl_3x2_P length] > 0 ? _app.buttonImageUrl_3x2_P : nil;
        }
    }
    else {
        // 4:3, iPad
        borderImageL = [_app.borderImageUrl_4x3_L length] > 0 ? _app.borderImageUrl_4x3_L : nil;
        borderImageP = [_app.borderImageUrl_4x3_P length] > 0 ? _app.borderImageUrl_4x3_P : nil;
        buttonImageL = [_app.buttonImageUrl_4x3_L length] > 0 ? _app.buttonImageUrl_4x3_L : nil;
        buttonImageP = [_app.buttonImageUrl_4x3_P length] > 0 ? _app.buttonImageUrl_4x3_P : nil;
    }
    
    // cache images
    if ((borderImageL != nil) && (![borderImageL isEqual:[NSNull null]])){
        PJImageDownloader *imageDownloader0 = [[PJImageDownloader alloc] init];
        [imageDownloader0 setUrlString:borderImageL];
        [imageDownloader0 setCompletionHandler:^(UIImage * image) {
            // do nothing, just let iOS cache the image
            util_Log(@"[%@ %@] borderImageL completed: %@", _PJ_CLASS, _PJ_METHOD, borderImageL);
        }];
        
        [imageDownloader0 startDownload];
        
    }
    
    if ((borderImageP != nil) && (![borderImageP isEqual:[NSNull null]])){
        PJImageDownloader *imageDownloader1 = [[PJImageDownloader alloc] init];
        [imageDownloader1 setUrlString:borderImageP];
        [imageDownloader1 setCompletionHandler:^(UIImage * image) {
            // do nothing, just let iOS cache the image
            util_Log(@"[%@ %@] borderImageP completed: %@", _PJ_CLASS, _PJ_METHOD, borderImageP);
        }];
        
        [imageDownloader1 startDownload];
        
    }

    if ((buttonImageL != nil) && (![buttonImageL isEqual:[NSNull null]])){
        PJImageDownloader *imageDownloader2 = [[PJImageDownloader alloc] init];
        [imageDownloader2 setUrlString:buttonImageL];
        [imageDownloader2 setCompletionHandler:^(UIImage * image) {
            // do nothing, just let iOS cache the image
            util_Log(@"[%@ %@] buttonImageL completed: %@", _PJ_CLASS, _PJ_METHOD, buttonImageL);
        }];
        
        [imageDownloader2 startDownload];
        
    }
    
    if ((buttonImageP != nil) && (![buttonImageP isEqual:[NSNull null]])){
        PJImageDownloader *imageDownloader3 = [[PJImageDownloader alloc] init];
        [imageDownloader3 setUrlString:buttonImageP];
        [imageDownloader3 setCompletionHandler:^(UIImage * image) {
            // do nothing, just let iOS cache the image
            util_Log(@"[%@ %@] buttonImageP completed: %@", _PJ_CLASS, _PJ_METHOD, buttonImageP);
        }];
        
        [imageDownloader3 startDownload];
        
    }
}

+(void) showPoll
{
    if ([_polls count] > 0) {
        PJPoll *poll=[_polls objectAtIndex:0];
        [[self class] showPoll:poll];
    }
    else {
        // inform delegate no polls to show
        if ([_delegate respondsToSelector:@selector(PJPollNotAvailable:)]) {
            [_delegate PJPollNotAvailable:PJNoPollFound];
        }
    }
}

+(void) showPoll:(PJPoll*) poll{
    if ([_delegate respondsToSelector:@selector(PJPollWillShow:)]) {
        [_delegate PJPollWillShow:poll];
    }
    
    // make sure to run in main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        PJPollView *pollView=[_pollsViews objectForKey:[NSNumber numberWithInteger:poll.pollToken]];
        [pollView show];
    });
    
    if ([_delegate respondsToSelector:@selector(PJPollDidShow:)]) {
        [_delegate PJPollDidShow:poll];
    }
}

+(void) setUserId:(NSString *)userId
{
    _userId = userId;
}

+(void) setAppId:(NSString *)appId
{
    _appId = appId;
}

+(void) setAppVersion:(NSString *) version
{
    _appVersion = version;
}

+(void) setLevel:(NSUInteger) level
{
    _level = level;
}

+(void) setSession:(NSUInteger) session
{
    _session = session;
}

+(void) setTimeSinceInstall:(NSUInteger) timeSinceInstall
{
    _timeSinceInstall = timeSinceInstall;
}

+(void) setUserType:(PJUserType) userType
{
    _userType = userType;
}

+(void) setTags:(NSString *) tags
{
    _tags = tags;
}

+(void) setDelegate:(NSObject<PolljoyDelegate> *) delegate
{
    _delegate = delegate;
}

+(void) setAutoShow:(BOOL) autoshow
{
    _autoshow=autoshow;
}

+(void) setSandboxMode:(BOOL) sandbox
{
    PJ_API_endpoint=sandbox?PJ_API_SANDBOX_endpoint:PJ_API_PRODUCTION_endpoint;
}

#pragma mark - getter methods

+(PJApp *) app
{
    return _app;
}

+(PJPoll *) currentPoll
{
    return _currentPoll;
}

+(NSString *) userId
{
    return _userId;
}

+(NSString *) appId
{
    return _appId;
}

+(NSString *) deviceId
{
    return _deviceId;
}

+(NSString *) sessionId
{
    return _sessionId;
}

+(NSString *) version
{
    return _appVersion;
}

+(NSUInteger) level
{
    return _level;
}

+(NSUInteger) session
{
    return _session;
}

+(NSUInteger) timeSinceInstall
{
    return _timeSinceInstall;
}

+(PJUserType) userType
{
    return _userType;
}

+(NSString *) tags
{
    return _tags;
}

+(NSArray *) polls
{
    return _polls;
}

+(NSDictionary *) pollsViews
{
    return _pollsViews;
}

#pragma mark - PJPollViewDelegate
+(void) PJPollViewDidAnswered:(PJPollView*) view poll:(PJPoll*) poll
{
    NSString *response=[poll.response copy];
    NSUInteger pollToken=poll.pollToken;
    [Polljoy responsePoll:pollToken response:response];
    
    if (poll.virtualAmount>0) {
        [view showActionAfterResponse];
    }
    else {
        [_polls removeObject:poll];
        [_pollsViews removeObjectForKey:[NSNumber numberWithInteger:poll.pollToken]];
        
        if ([_polls count] > 0) {
            [view hide];
            [[self class] showPoll];
        }
        else {
            [view showActionAfterResponse];
        }
    }
    
    // check if response has associated external link
    if ([poll.type isEqualToString:@"M"]) {
        if (poll.choiceUrl != nil){
            NSDictionary *choiceUrl=[poll.choiceUrl objectForKey:response];
            NSString *iosURL = [choiceUrl objectForKey:@"ios"];
            if ([iosURL length] > 0) {
                if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:iosURL]]) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iosURL]];
                }
            }
        }
    }
}

+(void) PJPollViewDidSkipped:(PJPollView*) view poll: (PJPoll*) poll
{
    // post response as userSkipped
    NSString *response=@"";
    NSUInteger pollToken=poll.pollToken;
    [Polljoy responsePoll:pollToken response:response];
    
    if ([_delegate respondsToSelector:@selector(PJPollDidSkipped:)]) {
        [_delegate PJPollDidSkipped:poll];
    }
    
    [view hide];
    [_polls removeObject:poll];
    [_pollsViews removeObjectForKey:[NSNumber numberWithInteger:poll.pollToken]];
    
    if ([_polls count] > 0) {
        [[self class] showPoll];
    }
}


+(void) PJPollViewIsReadyToShow:(PJPollView*) view poll: (PJPoll*) poll
{
    [Polljoy checkPollStatus];
}

+(void) PJPollViewCloseAfterReponse:(PJPollView*) view poll: (PJPoll*) poll
{
    [_pollsViews removeObjectForKey:[NSNumber numberWithInteger:poll.pollToken]];
    [_polls removeObject:poll];
    
    if ([_polls count] > 0) {
        if (poll.virtualAmount>0) {
            if ([_delegate respondsToSelector:@selector(PJPollDidResponded:)]) {
                [_delegate PJPollDidResponded:poll];
            }
        }
        
        if ([_delegate respondsToSelector:@selector(PJPollWillDismiss:)]) {
            [_delegate PJPollWillDismiss:poll];
        }
        
        [view hide];

        if ([_delegate respondsToSelector:@selector(PJPollDidDismiss:)]) {
            [_delegate PJPollDidDismiss:poll];
        }
        
        [[self class] showPoll];
    }
    else {
        if ([_delegate respondsToSelector:@selector(PJPollDidResponded:)]) {
            [_delegate PJPollDidResponded:poll];
        }
        
        if ([_delegate respondsToSelector:@selector(PJPollWillDismiss:)]) {
            [_delegate PJPollWillDismiss:poll];
        }
        
        [view hide];
        
        if ([_delegate respondsToSelector:@selector(PJPollDidDismiss:)]) {
            [_delegate PJPollDidDismiss:poll];
        }
    }
}

@end


