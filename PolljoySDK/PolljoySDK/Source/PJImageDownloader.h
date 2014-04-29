//
//  PJImageDownloader.h
//  PolljoySDK
//
//  Copyright (c) 2014 polljoy limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PJImageDownloader : NSObject

@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, copy) void (^completionHandler)(UIImage *image);

- (void)startDownload;
- (void)cancelDownload;

@end

