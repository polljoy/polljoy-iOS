//
//  PolljoyCore.m
//  PolljoySDK
//
//  Copyright (c) 2014 polljoy limited. All rights reserved.
//

#import "PolljoyCore.h"
#import <UIKit/UIKit.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <CommonCrypto/CommonDigest.h>

#define PJ_SDK @"com.polljoy.archiveDict"

@implementation PolljoyCore

// Load the framework bundle.
+ (NSBundle *)frameworkBundle {
    static NSBundle* frameworkBundle = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSString* mainBundlePath = [[NSBundle mainBundle] resourcePath];
        NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"Polljoy.bundle"];
        frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    });
    return frameworkBundle;
}

+ (NSUInteger)getSession
{
    NSString *dataArchiveKey=[NSString stringWithFormat:@"%@.%@",PJ_SDK,@"session"];
    NSUInteger session=0;
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *sessionCount=[standardUserDefaults objectForKey:dataArchiveKey];
    
    if (sessionCount != nil) {
        session=[sessionCount integerValue] + 1 ;
    }
    else {
        session=1;
    }
    
    [standardUserDefaults setObject:[NSNumber numberWithInteger:session] forKey:dataArchiveKey];
    [standardUserDefaults synchronize];
    
    return session;
}

+ (NSUInteger)getCurrentSession
{
    NSString *dataArchiveKey=[NSString stringWithFormat:@"%@.%@",PJ_SDK,@"session"];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *sessionCount=[standardUserDefaults objectForKey:dataArchiveKey];
    
    if (sessionCount != nil) {
        return [sessionCount integerValue] ;
    }
    else {
        return [[self class] getSession];
    }
}

+ (NSUInteger)getTimeSinceInstall
{
    NSString *dataArchiveKey=[NSString stringWithFormat:@"%@.%@",PJ_SDK,@"dateInstalled"];
    NSUInteger timeSinceInstall=0;
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *dateInstalled=[standardUserDefaults objectForKey:dataArchiveKey];
    
    if (dateInstalled == nil) {
        dateInstalled=[NSDate date];
        [standardUserDefaults setObject:dateInstalled forKey:dataArchiveKey];
        [standardUserDefaults synchronize];
    }
    else {
        timeSinceInstall=[[self class] daysFromDate:dateInstalled toDate:[NSDate date]];
    }

    return timeSinceInstall;
    
}

+ (NSInteger)daysFromDate:(NSDate *)fromDate  toDate:(NSDate*) toDate{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger startDay=[calendar ordinalityOfUnit:NSDayCalendarUnit
                                           inUnit:NSEraCalendarUnit
                                          forDate:fromDate];
    NSInteger endDay=[calendar ordinalityOfUnit:NSDayCalendarUnit
                                         inUnit:NSEraCalendarUnit
                                        forDate:toDate];

    return (endDay-startDay);
}
+ (NSString*)getDeviceId
{
    // On iOS 6+, return identifierForVendor
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= (float) 6.0) {
        NSString *identifierForVendor = [[self class] getVendorID:0];
        if (identifierForVendor != nil && ![identifierForVendor isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
            return identifierForVendor;
        }
    }
    
    // Otherwise generate random ID
    NSString *randomId = [[self class] generateRandomId];
    return randomId;
}

+ (NSString*)getVendorID:(int) timesCalled
{
    NSString *identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    if (identifier == nil && timesCalled < 5) {
        // Try again every 5 seconds
        [NSThread sleepForTimeInterval:5.0];
        return [[self class] getVendorID:timesCalled + 1];
    } else {
        return identifier;
    }
}

+ (NSString*)generateRandomId
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
#if __has_feature(objc_arc)
    NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
#else
    NSString *uuidStr = (NSString *) CFUUIDCreateString(kCFAllocatorDefault, uuid);
#endif
    CFRelease(uuid);
    // Add "R" at the end of the ID to distinguish it from advertiserId
    return [uuidStr stringByAppendingString:@"R"];
}

// Taken from http://stackoverflow.com/a/3950748/340520
+ (NSString *)getPlatformString
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

+ (NSString *)getDeviceModel{
    NSString *platform = [self getPlatformString];
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad mini 2G (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad mini 2G (Cellular)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:0]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (UIImage *) defaultImage
{
    return [UIImage imageWithContentsOfFile:[[[self class] frameworkBundle] pathForResource:@"polljoy" ofType:@"png"]];
}

@end

@implementation UIImage (colorMask)

-(UIImage *) maskWithColor:(UIColor *)color
{
    CGImageRef maskImage = self.CGImage;
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    CGRect bounds = CGRectMake(0,0,width,height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    CGContextClipToMask(bitmapContext, bounds, maskImage);
    CGContextSetFillColorWithColor(bitmapContext, color.CGColor);
    CGContextFillRect(bitmapContext, bounds);
    
    CGImageRef cImage = CGBitmapContextCreateImage(bitmapContext);
    UIImage *coloredImage = [UIImage imageWithCGImage:cImage];
    
    CGContextRelease(bitmapContext);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(cImage);
    
    return coloredImage;
}

@end

// hashes
static inline NSString *PJNSStringCCHashFunction(unsigned char *(function)(const void *data, CC_LONG len, unsigned char *md), CC_LONG digestLength, NSString *string)
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[digestLength];
    
    function(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:digestLength * 2];
    
    for (int i = 0; i < digestLength; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

@implementation NSString (PJHashes)

- (NSString *)md5
{
    return PJNSStringCCHashFunction(CC_MD5, CC_MD5_DIGEST_LENGTH, self);
}

- (NSString *)sha1
{
    return PJNSStringCCHashFunction(CC_SHA1, CC_SHA1_DIGEST_LENGTH, self);
}

- (NSString *)sha224
{
    return PJNSStringCCHashFunction(CC_SHA224, CC_SHA224_DIGEST_LENGTH, self);
}

- (NSString *)sha256
{
    return PJNSStringCCHashFunction(CC_SHA256, CC_SHA256_DIGEST_LENGTH, self);
}

- (NSString *)sha384
{
    return PJNSStringCCHashFunction(CC_SHA384, CC_SHA384_DIGEST_LENGTH, self);
}
- (NSString *)sha512
{
    return PJNSStringCCHashFunction(CC_SHA512, CC_SHA512_DIGEST_LENGTH, self);
}

@end