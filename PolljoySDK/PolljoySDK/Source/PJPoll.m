//
//  PJPoll.m
//  PolljoySDK
//
//  Copyright (c) 2014 polljoy limited. All rights reserved.
//

#import "PJPoll.h"

@implementation PJPoll
-(PJPoll *) initWithRequest: (NSDictionary *) request
{
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
    poll.choiceImageUrl=[request objectForKey:@"choiceImageUrl"];
    poll.imagePollStatus = 0;
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
    poll.searchDepth=[[request objectForKey:@"searchDepth"] integerValue];
    
    return poll;
}
@end
