//
//  PolljoyCore.h
//  PolljoySDK
//
//  Copyright (c) 2014 polljoy limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PolljoyCore : NSObject
+ (NSBundle *)frameworkBundle;
+ (NSString *)getPlatformString;
+ (NSString *)getDeviceModel;
+ (NSString*)getDeviceId;
+ (NSUInteger)getSession;
+ (NSUInteger)getCurrentSession;
+ (NSUInteger)getTimeSinceInstall;
+ (UIColor *)colorFromHexString:(NSString *)hexString;
+ (UIImage *) defaultImage;
@end


@interface UIImage (colorMask)

-(UIImage *) maskWithColor:(UIColor *)color;

@end