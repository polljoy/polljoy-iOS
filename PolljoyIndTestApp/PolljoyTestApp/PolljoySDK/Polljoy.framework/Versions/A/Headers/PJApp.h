//
//  PJApp.h
//  PolljoySDK
//
//  Copyright (c) 2014 polljoy limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PJApp : NSObject
@property (nonatomic,strong) NSString *appId;
@property (nonatomic,strong) NSString *appName;
@property (nonatomic,strong) NSString *defaultImageUrl;
@property (nonatomic,assign) NSUInteger maximumPollPerSession;
@property (nonatomic,assign) NSUInteger maximumPollPerDay;
@property (nonatomic,assign) NSUInteger maximumPollInARow;
@property (nonatomic,strong) UIColor *backgroundColor;
@property (nonatomic,strong) UIColor *borderColor;
@property (nonatomic,strong) UIColor *buttonColor;
@property (nonatomic,strong) UIColor *fontColor;

@end
