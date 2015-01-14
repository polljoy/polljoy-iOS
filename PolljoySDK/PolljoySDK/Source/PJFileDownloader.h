//
//  PJFileDownloader.h
//  PolljoySDK
//
//  Copyright (c) 2014 polljoy limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PJFileDownloader : NSObject

@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSString *localTempFilename;
@property (nonatomic, copy) void (^completionHandler)(NSURL *fileUrl);

- (void)startDownload;
- (void)cancelDownload;

@end

