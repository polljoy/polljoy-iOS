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
@property (nonatomic,assign) NSInteger backgroundAlpha;
@property (nonatomic,assign) NSInteger backgroundCornerRadius;
@property (nonatomic,assign) NSInteger borderWidth;
@property (nonatomic,strong) NSString *borderImageUrl_16x9_L;
@property (nonatomic,strong) NSString *borderImageUrl_16x9_P;
@property (nonatomic,strong) NSString *borderImageUrl_3x2_L;
@property (nonatomic,strong) NSString *borderImageUrl_3x2_P;
@property (nonatomic,strong) NSString *borderImageUrl_4x3_L;
@property (nonatomic,strong) NSString *borderImageUrl_4x3_P;
@property (nonatomic,strong) UIColor *buttonFontColor;
@property (nonatomic,strong) NSString *buttonImageUrl_16x9_L;
@property (nonatomic,strong) NSString *buttonImageUrl_16x9_P;
@property (nonatomic,strong) NSString *buttonImageUrl_3x2_L;
@property (nonatomic,strong) NSString *buttonImageUrl_3x2_P;
@property (nonatomic,strong) NSString *buttonImageUrl_4x3_L;
@property (nonatomic,strong) NSString *buttonImageUrl_4x3_P;
@property (nonatomic,assign) BOOL buttonShadow;
@property (nonatomic,strong) NSString *closeButtonImageUrl;
@property (nonatomic,assign) NSInteger closeButtonLocation;
@property (nonatomic,assign) NSInteger closeButtonOffsetX;
@property (nonatomic,assign) NSInteger closeButtonOffsetY;
@property (nonatomic,assign) BOOL closeButtonEasyClose;
@property (nonatomic,strong) NSString *deviceId;
@property (nonatomic,strong) NSString *fontName;
@property (nonatomic,assign) NSInteger overlayAlpha;
@property (nonatomic,strong) NSString *rewardImageUrl;
@property (nonatomic,strong) NSString *userId;
@property (nonatomic,assign) NSInteger imageCornerRadius;
@property (nonatomic,strong) NSString *customSoundUrl;
@property (nonatomic,strong) NSString *customTapSoundUrl;
@end
