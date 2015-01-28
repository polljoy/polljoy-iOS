//
//  PJPollView.h
//  PolljoySDK
//
//  Copyright (c) 2014 polljoy limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PJPoll.h"
#import "PJApp.h"

@class PJPollView;

@protocol PJPollViewDelegate <NSObject>
-(void) PJPollViewDidAnswered:(PJPollView*) view poll:(PJPoll*) poll;
-(void) PJPollViewDidSkipped:(PJPollView*) view poll: (PJPoll*) poll;
-(void) PJPollViewIsReadyToShow:(PJPollView*) view poll: (PJPoll*) poll;
-(void) PJPollViewCloseAfterReponse:(PJPollView*) view poll: (PJPoll*) poll;
@end

@interface PJPollView : UIView {
    
}

@property (nonatomic, strong) NSObject<PJPollViewDelegate> *delegate;

-(id) initWithPoll: (PJPoll*) poll;
-(void) show;
-(void) hide;
-(void) showActionAfterResponse;
-(void) playCollectSound;
-(void) playTapSound;
@end
