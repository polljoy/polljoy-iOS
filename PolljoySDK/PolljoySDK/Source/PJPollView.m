//
//  PJPollView.m
//  PolljoySDK
//
//  Copyright (c) 2014 polljoy limited. All rights reserved.
//



#import "PJPollView.h"
#import "PolljoyCore.h"
#import "PJImageDownloader.h"
#import "Polljoy.h"

@interface PJPollView () {
    IBOutlet UIView *pollView;
    
    IBOutlet UIImageView *defaultImageView;
    IBOutlet UILabel *questionLabel;
    IBOutlet UILabel *virtualAmount;
    IBOutlet UILabel *virtualAmountRewardLabel;
    IBOutlet UIImageView *rewardImageView;
    IBOutlet UIView *mcView;
    IBOutlet UIButton *mcBtn1;
    IBOutlet UIButton *mcBtn2;
    IBOutlet UIButton *mcBtn3;
    IBOutlet UIButton *mcBtn4;
    
    IBOutlet UIView *textView;
    IBOutlet UITextView *responseTextView;
    IBOutlet UIButton *textBtn;
    
    IBOutlet UIButton *closeBtn;
    
    IBOutlet UIView *collectView;
    IBOutlet UIImageView *collectRewardImageView;
    IBOutlet UILabel *collectTextLabel;
    IBOutlet UIButton *collectBtn;
    
    IBOutlet UIView *overlayView;
    IBOutlet UIView *backgroundView;
    IBOutlet UIImageView *borderImageView;
    
    
    NSArray *mcButtons;
    
    PJPoll *myPoll;
    
    CGAffineTransform rotationTransform;
    
    BOOL userIsResponded;
    UIImage *defaultImage;
    
    UIImage *borderImageLandscape;
    UIImage *borderImagePortrait;
    UIImage *buttonImageLandscape;
    UIImage *buttonImagePortrait;
    
    NSString *borderImageL;
    NSString *borderImageP;
    NSString *buttonImageL;
    NSString *buttonImageP;
}

@end


@implementation PJPollView
@synthesize delegate;
- (void) dealloc
{
    [self unregisterFromNotifications];
    [self unregisterFromKeyboardNotifications];
    
}
- (void) awakeFromNib
{
    [super awakeFromNib];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype) initWithPoll: (PJPoll*) poll
{
    util_Log(@"[%@ %@] poll: %@", _PJ_CLASS, _PJ_METHOD, poll);
    
    self=[self initWithFrame:CGRectMake(0,0,0,0)];
    if(self) {
        [self setupView];
        
        myPoll=poll;
        mcButtons = [NSArray arrayWithObjects:mcBtn1, mcBtn2, mcBtn3, mcBtn4, nil];
        
        // setup appearance
        self.backgroundColor = [UIColor clearColor];
        
        overlayView.alpha = (CGFloat) ((100.f - poll.app.overlayAlpha) / 100.f) ;
        
        backgroundView.backgroundColor = poll.app.backgroundColor;
        backgroundView.layer.borderColor = [poll.app.borderColor CGColor];
        backgroundView.layer.borderWidth=poll.app.borderWidth;
        backgroundView.layer.cornerRadius=poll.app.backgroundCornerRadius;
        backgroundView.alpha = (CGFloat) (poll.app.backgroundAlpha / 100.f);
        
        borderImageView.alpha = (CGFloat) (poll.app.backgroundAlpha / 100.f);
        
        pollView.backgroundColor = [UIColor clearColor];
        pollView.layer.cornerRadius = poll.app.backgroundCornerRadius;
        
        for (UIButton *button in [NSArray arrayWithObjects:mcBtn1,mcBtn2,mcBtn3,mcBtn4,textBtn,collectBtn,nil ] ) {
            [self setButtonStyle:button];
            button.hidden=YES;
        }
        textBtn.hidden = NO;
        collectBtn.hidden = NO;
        
        closeBtn.hidden=poll.mandatory;
        UIImage *closeIcon=[UIImage imageWithContentsOfFile:[[PolljoyCore frameworkBundle] pathForResource:@"closeButton" ofType:@"png"]];
        UIImage *maskedIcon=[closeIcon maskWithColor:poll.app.fontColor];
        [closeBtn setImage:maskedIcon forState:UIControlStateNormal];
    
        // TODO: no need to mask the color
        UIImage *rewardImage=[UIImage imageWithContentsOfFile:[[PolljoyCore frameworkBundle] pathForResource:@"rewardImage" ofType:@"png"]];
        [rewardImageView setImage:rewardImage];
        
        // setp poll message
        [questionLabel setTextColor:poll.app.fontColor];
        questionLabel.text = poll.pollText;
        
        if ([poll.type isEqualToString:@"M"]) {
            NSArray *choices=poll.choices;
            NSInteger offset=[mcButtons count] - [choices count];
            
            for (int i=0;i<[choices count];i++) {
                UIButton *btn=[mcButtons objectAtIndex:i+offset];
                btn.hidden=NO;
                [btn setTitle:[choices objectAtIndex:i] forState:UIControlStateNormal];
            }
            mcView.hidden=NO;
            textView.hidden=YES;
        }
        else if ([poll.type isEqualToString:@"T"]) {
            [textBtn setTitle:poll.submitButtonText forState:UIControlStateNormal];
            mcView.hidden=YES;
            textView.hidden=NO;
        }
        else {
            mcView.hidden=YES;
            textView.hidden=YES;
        }
        
        if (poll.virtualAmount > 0) {
            virtualAmount.text=[NSString stringWithFormat:@"%ld",(long)poll.virtualAmount];
            virtualAmount.hidden=NO;
            [virtualAmount setTextColor:poll.fontColor];
            virtualAmountRewardLabel.hidden=NO;
            [virtualAmountRewardLabel setTextColor:poll.fontColor];
        }
        else {
            virtualAmount.hidden=YES;
            virtualAmountRewardLabel.hidden=YES;
        }
        
        collectView.hidden=YES;
        collectTextLabel.text=[NSString stringWithFormat:@"%ld",(long)poll.virtualAmount];
        [collectTextLabel setTextColor:poll.fontColor];
        [collectRewardImageView setImage:rewardImageView.image];
        
        //setup image
        poll.imagesStatus = 0;
        [self startImageDownload:poll];
        
        if ([poll.type isEqualToString:@"T"]) {
            UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTouch:)];
            [self addGestureRecognizer:gesture];
        }
        
        [self registerForNotifications];
        
        userIsResponded = NO;
        
    }
    
    return self;
}

-(void) setButtonStyle: (UIButton *) button {
    [button setTitleColor:myPoll.app.buttonFontColor forState:UIControlStateNormal];
    [button.titleLabel setNumberOfLines:2];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [button.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    button.backgroundColor = myPoll.app.buttonColor;
    button.layer.cornerRadius = myPoll.app.backgroundCornerRadius;
    [button.titleLabel setFont:[UIFont systemFontOfSize:(IS_IPHONE?17:24)]];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    UIImage *buttonImage = (UIInterfaceOrientationIsLandscape(orientation)) ? buttonImageLandscape : buttonImagePortrait;
    
    if (buttonImage != nil) {
        [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [button.imageView setContentMode:UIViewContentModeScaleAspectFill];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 0;
        button.backgroundColor = [UIColor clearColor];
    }
    else {
        if (myPoll.app.buttonShadow) {
            button.layer.masksToBounds = NO;
            button.layer.shadowColor = [UIColor darkGrayColor].CGColor;
            button.layer.shadowOpacity = 0.8;
            button.layer.shadowRadius = mcBtn1.layer.cornerRadius;
            button.layer.shadowOffset = CGSizeMake(12.0f, 12.0f);
        }
        else {
            button.layer.masksToBounds = YES;
        }
    }
}

-(void) setBorderImage {
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    UIImage *borderImage = (UIInterfaceOrientationIsLandscape(orientation)) ? borderImageLandscape : borderImagePortrait;

    if (borderImage != nil) {
        [borderImageView setImage:borderImage];
    }
}

-(void) setupView
{
    self.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    overlayView =[[UIView alloc] initWithFrame:self.frame];
    overlayView.backgroundColor=[UIColor blackColor];
    [self addSubview:overlayView];
    
    backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 360)];
    backgroundView.backgroundColor = [UIColor clearColor];
    backgroundView.layer.masksToBounds=YES;
    [self addSubview:backgroundView];
    
    borderImageView = [[UIImageView alloc] initWithFrame:overlayView.frame];
    borderImageView.backgroundColor=[UIColor clearColor];
    [borderImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self addSubview:borderImageView];
    
    pollView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 360)];
    pollView.backgroundColor=[UIColor clearColor];
    pollView.layer.masksToBounds=YES;
    
    // default image
    defaultImageView=[[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 112, 112)];
    defaultImageView.backgroundColor=[UIColor clearColor];
    [defaultImageView setContentMode:UIViewContentModeScaleAspectFit];
    [pollView addSubview:defaultImageView];
    
    closeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setFrame:CGRectMake(196, 0, 44, 44)];
    [closeBtn addTarget:self action:@selector(userSkipped:) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.layer.borderWidth=20;
    closeBtn.layer.borderColor=[[UIColor clearColor] CGColor];
    [closeBtn setContentEdgeInsets:UIEdgeInsetsMake(closeBtn.layer.borderWidth, closeBtn.layer.borderWidth, closeBtn.layer.borderWidth, closeBtn.layer.borderWidth)]; // adjust for easy touch
    [pollView addSubview:closeBtn];
    
    rewardImageView=[[UIImageView alloc] initWithFrame:CGRectMake(320, 20, 256, 256)];
    rewardImageView.backgroundColor=[UIColor clearColor];
    [rewardImageView setContentMode:UIViewContentModeScaleAspectFit];
    [pollView addSubview:rewardImageView];
    
    virtualAmountRewardLabel=[[UILabel alloc] initWithFrame:CGRectMake(132, 46, 98, 67)];
    [virtualAmountRewardLabel setBackgroundColor:[UIColor clearColor]];
    [virtualAmountRewardLabel setText:NSLocalizedString(@"Earn", @"Earn")];
    [virtualAmountRewardLabel setFont:[UIFont boldSystemFontOfSize:30]];
    //[virtualAmountRewardLabel setMinimumScaleFactor:0.5];
    [virtualAmountRewardLabel setTextAlignment:NSTextAlignmentLeft];
    [pollView addSubview:virtualAmountRewardLabel];
    
    virtualAmount=[[UILabel alloc] initWithFrame:CGRectMake(132, 46, 98, 67)];
    [virtualAmount setBackgroundColor:[UIColor clearColor]];
    [virtualAmount setFont:[UIFont boldSystemFontOfSize:30]];
    //[virtualAmount setMinimumScaleFactor:0.5];
    [virtualAmount setTextAlignment:NSTextAlignmentLeft];
    [pollView addSubview:virtualAmount];
    
    questionLabel=[[UILabel alloc] initWithFrame:CGRectMake(12,132,218, 64)];
    [questionLabel setBackgroundColor:[UIColor clearColor]];
    [questionLabel setFont:[UIFont systemFontOfSize:24]];
    //[questionLabel setMinimumScaleFactor:0.5];
    [questionLabel setNumberOfLines:3];   // bug in iOS6, multiple line with word wrapping doesn't work with AdjustsFontSizeToFitWidth
    //[questionLabel setAdjustsFontSizeToFitWidth:YES];
    [questionLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [questionLabel setTextAlignment:NSTextAlignmentCenter];
    [pollView addSubview:questionLabel];
    
    // Multiple Choice View
    mcView=[[UIView alloc] initWithFrame:CGRectMake(0, 195, 240, 165)];
    mcView.backgroundColor=[UIColor clearColor];
    
    mcBtn1=[UIButton buttonWithType:UIButtonTypeCustom];
    [mcBtn1 setFrame:CGRectMake(11, 8, 218, 30)];
    [mcBtn1.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [mcBtn1 addTarget:self action:@selector(userReponded:) forControlEvents:UIControlEventTouchUpInside];
    [mcView addSubview:mcBtn1];
    mcBtn2=[UIButton buttonWithType:UIButtonTypeCustom];
    [mcBtn2.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [mcBtn2 addTarget:self action:@selector(userReponded:) forControlEvents:UIControlEventTouchUpInside];
    [mcBtn2 setFrame:CGRectMake(11, 46, 218, 30)];
    [mcView addSubview:mcBtn2];
    mcBtn3=[UIButton buttonWithType:UIButtonTypeCustom];
    [mcBtn3.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [mcBtn3 addTarget:self action:@selector(userReponded:) forControlEvents:UIControlEventTouchUpInside];
    [mcBtn3 setFrame:CGRectMake(11, 84, 218, 30)];
    [mcView addSubview:mcBtn3];
    mcBtn4=[UIButton buttonWithType:UIButtonTypeCustom];
    [mcBtn4.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [mcBtn4 addTarget:self action:@selector(userReponded:) forControlEvents:UIControlEventTouchUpInside];
    [mcBtn4 setFrame:CGRectMake(11, 122, 218, 30)];
    [mcView addSubview:mcBtn4];
    
    [pollView addSubview:mcView];
    
    // text input view
    textView=[[UIView alloc] initWithFrame:CGRectMake(0, 195, 240, 165)];
    textView.backgroundColor=[UIColor clearColor];
    
    responseTextView=[[UITextView alloc] initWithFrame:CGRectMake(11, 8, 218, 106)];
    responseTextView.layer.borderColor=[[UIColor blackColor] CGColor];
    responseTextView.layer.borderWidth=1.0;
    [textView addSubview:responseTextView];
    
    textBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [textBtn addTarget:self action:@selector(userReponded:) forControlEvents:UIControlEventTouchUpInside];
    [textBtn setFrame:CGRectMake(11, 122, 218, 30)];
    [textBtn setTitle:NSLocalizedString(@"Submit", @"Submit") forState:UIControlStateNormal];
    [textView addSubview:textBtn];
    
    [pollView addSubview:textView];
    
    collectView=[[UIView alloc] initWithFrame:CGRectMake(0, 195, 240, 165)];
    collectView.backgroundColor=[UIColor clearColor];
    collectBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [collectBtn setTitle:@"Collect" forState:UIControlStateNormal];
    [collectBtn addTarget:self action:@selector(userConfirmed:) forControlEvents:UIControlEventTouchUpInside];
    [collectBtn setFrame:CGRectMake(11, 300, 218, 30)];
    collectBtn.hidden=YES;
    collectRewardImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    collectRewardImageView.backgroundColor=[UIColor clearColor];
    collectTextLabel=[[UILabel alloc] initWithFrame:CGRectMake(132, 46, 98, 67)];
    [collectTextLabel setBackgroundColor:[UIColor clearColor]];
    [collectTextLabel setFont:[UIFont boldSystemFontOfSize:30]];
    //[collectTextLabel setMinimumScaleFactor:0.5];
    [collectTextLabel setTextAlignment:NSTextAlignmentLeft];
    [collectView addSubview:collectTextLabel];
    [collectView addSubview:collectRewardImageView];
    [collectView addSubview:collectBtn];
    [pollView addSubview:collectView];

    [self addSubview:pollView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)checkImageStatus{
    if (!myPoll.isReadyToShow) {
        
        if (PJPollAllImageReady == myPoll.imagesStatus) {
            myPoll.isReadyToShow=YES;
            [self.delegate PJPollViewIsReadyToShow:self poll:myPoll];
        }
    }
}

- (void)startImageDownload:(PJPoll *)poll
{
    // cache default image
    NSString *urlString=nil;
    if ((poll.pollImageUrl!=nil) && (![poll.pollImageUrl isEqual:[NSNull null]])) {
        urlString=poll.pollImageUrl;
    }
    else if ((poll.appImageUrl!=nil) && (![poll.appImageUrl isEqual:[NSNull null]])) {
        urlString=poll.app.defaultImageUrl;
    }
    
    if (urlString!=nil) {
        PJImageDownloader *imageDownloader = [[PJImageDownloader alloc] init];
        [imageDownloader setUrlString:urlString];
        [imageDownloader setCompletionHandler:^(UIImage * image) {
            if (image!=nil) {
                // download success
                dispatch_async(dispatch_get_main_queue(), ^{
                    [defaultImageView setImage:image];
                    myPoll.imagesStatus |= PJPollDefaultImageReady;
                    [self checkImageStatus];
                });
            }
            else {
                //download fail, use default image and return ready
                dispatch_async(dispatch_get_main_queue(), ^{
                    [defaultImageView setImage:[PolljoyCore defaultImage]];
                    myPoll.imagesStatus |= PJPollDefaultImageReady;
                    [self checkImageStatus];
                });
            }
        }];
        
        [imageDownloader startDownload];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [defaultImageView setImage:[PolljoyCore defaultImage]];
            myPoll.imagesStatus |= PJPollDefaultImageReady;
            [self checkImageStatus];
        });
    }
    
    // cache reward image
    NSString *rewardUrlString=nil;
    if ((poll.pollRewardImageUrl!=nil) && (![poll.pollRewardImageUrl isEqual:[NSNull null]]) && ([poll.pollRewardImageUrl length] > 0)) {
        rewardUrlString=poll.pollRewardImageUrl;
    }
    else if ((poll.app.rewardImageUrl!=nil) && (![poll.app.rewardImageUrl isEqual:[NSNull null]]) && ([poll.app.rewardImageUrl length] > 0)) {
        rewardUrlString=poll.app.rewardImageUrl;
    }
    
    if (rewardUrlString!=nil) {
        PJImageDownloader *imageDownloader = [[PJImageDownloader alloc] init];
        [imageDownloader setUrlString:rewardUrlString];
        [imageDownloader setCompletionHandler:^(UIImage * image) {
            if (image!=nil) {
                // download success
                dispatch_async(dispatch_get_main_queue(), ^{
                    [rewardImageView setImage:image];
                    myPoll.imagesStatus |= PJPollRewardImageReady;
                    [self checkImageStatus];
                });
            }
            else {
                //download fail, use default image and return ready
                dispatch_async(dispatch_get_main_queue(), ^{
                    myPoll.imagesStatus |= PJPollRewardImageReady;
                    [self checkImageStatus];
                });
            }
            util_Log(@"[%@ %@] completed: %@", _PJ_CLASS, _PJ_METHOD, rewardUrlString);
        }];
        
        [imageDownloader startDownload];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            myPoll.imagesStatus |= PJPollRewardImageReady;
            [self checkImageStatus];
        });
    }

    // cache close button image
    if ((myPoll.app.closeButtonImageUrl != nil) && (![myPoll.app.closeButtonImageUrl isEqual:[NSNull null]]) && ([myPoll.app.closeButtonImageUrl length] >0)){
        PJImageDownloader *imageDownloader = [[PJImageDownloader alloc] init];
        [imageDownloader setUrlString:myPoll.app.closeButtonImageUrl];
        [imageDownloader setCompletionHandler:^(UIImage * image) {
            if (image!=nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [closeBtn setImage:image forState:UIControlStateNormal];
                    myPoll.imagesStatus |= PJPollCloseButtonImageReady;
                    [self checkImageStatus];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    myPoll.imagesStatus |= PJPollCloseButtonImageReady;
                    [self checkImageStatus];
                });
            }
            util_Log(@"[%@ %@] completed: %@", _PJ_CLASS, _PJ_METHOD, myPoll.app.closeButtonImageUrl);
        }];
        
        [imageDownloader startDownload];
        
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            myPoll.imagesStatus |= PJPollCloseButtonImageReady;
            [self checkImageStatus];
        });
    }
    
    // cache border and button image
    borderImageL = nil;
    borderImageP = nil;
    buttonImageL = nil;
    buttonImageP = nil;
    
    if (IS_IPHONE) {
        if (IS_HEIGHT_GTE_568) {
            // 16:9
            borderImageL = [myPoll.app.borderImageUrl_16x9_L length] > 0 ? myPoll.app.borderImageUrl_16x9_L : nil;
            borderImageP = [myPoll.app.borderImageUrl_16x9_P length] > 0 ? myPoll.app.borderImageUrl_16x9_P : nil;
            buttonImageL = [myPoll.app.buttonImageUrl_16x9_L length] > 0 ? myPoll.app.buttonImageUrl_16x9_L : nil;
            buttonImageP = [myPoll.app.buttonImageUrl_16x9_P length] > 0 ? myPoll.app.buttonImageUrl_16x9_P : nil;
        }
        else {
            // 3:2
            borderImageL = [myPoll.app.borderImageUrl_3x2_L length] > 0 ? myPoll.app.borderImageUrl_3x2_L : nil;
            borderImageP = [myPoll.app.borderImageUrl_3x2_P length] > 0 ? myPoll.app.borderImageUrl_3x2_P : nil;
            buttonImageL = [myPoll.app.buttonImageUrl_3x2_L length] > 0 ? myPoll.app.buttonImageUrl_3x2_L : nil;
            buttonImageP = [myPoll.app.buttonImageUrl_3x2_P length] > 0 ? myPoll.app.buttonImageUrl_3x2_P : nil;
        }
    }
    else {
        // 4:3, iPad
        borderImageL = [myPoll.app.borderImageUrl_4x3_L length] > 0 ? myPoll.app.borderImageUrl_4x3_L : nil;
        borderImageP = [myPoll.app.borderImageUrl_4x3_P length] > 0 ? myPoll.app.borderImageUrl_4x3_P : nil;
        buttonImageL = [myPoll.app.buttonImageUrl_4x3_L length] > 0 ? myPoll.app.buttonImageUrl_4x3_L : nil;
        buttonImageP = [myPoll.app.buttonImageUrl_4x3_P length] > 0 ? myPoll.app.buttonImageUrl_4x3_P : nil;
    }
    
    // border image landscape
    if ((borderImageL != nil) && (![borderImageL isEqual:[NSNull null]])){
        PJImageDownloader *imageDownloader0 = [[PJImageDownloader alloc] init];
        [imageDownloader0 setUrlString:borderImageL];
        [imageDownloader0 setCompletionHandler:^(UIImage * image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                borderImageLandscape = image;
                myPoll.imagesStatus |= PJPollBorderLImageReady;
                [self checkImageStatus];
            });

            util_Log(@"[%@ %@] borderImageL completed: %@", _PJ_CLASS, _PJ_METHOD, borderImageL);
        }];
        
        [imageDownloader0 startDownload];
        
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            borderImageLandscape = nil;
            myPoll.imagesStatus |= PJPollBorderLImageReady;
            [self checkImageStatus];
        });
    }
    
    // border image portrait
    if ((borderImageP != nil) && (![borderImageP isEqual:[NSNull null]])){
        PJImageDownloader *imageDownloader1 = [[PJImageDownloader alloc] init];
        [imageDownloader1 setUrlString:borderImageP];
        [imageDownloader1 setCompletionHandler:^(UIImage * image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                borderImagePortrait = image;
                myPoll.imagesStatus |= PJPollBorderPImageReady;
                [self checkImageStatus];
            });
            util_Log(@"[%@ %@] borderImageP completed: %@", _PJ_CLASS, _PJ_METHOD, borderImageP);
        }];
        
        [imageDownloader1 startDownload];
        
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            borderImagePortrait = nil;
            myPoll.imagesStatus |= PJPollBorderPImageReady;
            [self checkImageStatus];
        });
    }
    
    // button image landscape
    if ((buttonImageL != nil) && (![buttonImageL isEqual:[NSNull null]])){
        PJImageDownloader *imageDownloader2 = [[PJImageDownloader alloc] init];
        [imageDownloader2 setUrlString:buttonImageL];
        [imageDownloader2 setCompletionHandler:^(UIImage * image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                buttonImageLandscape = image;
                myPoll.imagesStatus |= PJPollButtonLImageReady;
                [self checkImageStatus];
            });
            util_Log(@"[%@ %@] buttonImageL completed: %@", _PJ_CLASS, _PJ_METHOD, buttonImageL);
        }];
        
        [imageDownloader2 startDownload];
        
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            buttonImageLandscape = nil;
            myPoll.imagesStatus |= PJPollButtonLImageReady;
            [self checkImageStatus];
        });
    }

    // button image portrait
    if ((buttonImageP != nil) && (![buttonImageP isEqual:[NSNull null]])){
        PJImageDownloader *imageDownloader3 = [[PJImageDownloader alloc] init];
        [imageDownloader3 setUrlString:buttonImageP];
        [imageDownloader3 setCompletionHandler:^(UIImage * image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                buttonImagePortrait = image;
                myPoll.imagesStatus |= PJPollButtonPImageReady;
                [self checkImageStatus];
            });
            util_Log(@"[%@ %@] buttonImageP completed: %@", _PJ_CLASS, _PJ_METHOD, buttonImageP);
        }];
        
        [imageDownloader3 startDownload];
        
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            buttonImagePortrait = nil;
            myPoll.imagesStatus |= PJPollButtonPImageReady;
            [self checkImageStatus];
        });
    }
}

- (void)layoutSubviews
{    
    if (!self.superview) return;
    
    [self endEditing:YES];
    
    self.frame = self.superview.bounds;

    // layout all subview for device orientation
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [self layoutLandscape];
    }
    else {
        [self layoutPortrait];
    }
    
    overlayView.frame=self.frame;
    borderImageView.frame=overlayView.frame;
    pollView.center=self.center;
    backgroundView.frame=pollView.frame;
    backgroundView.frame = CGRectInset(backgroundView.frame, -myPoll.app.borderWidth, -myPoll.app.borderWidth); // adjust for outter border
}

-(void) layoutPortrait{
    CGFloat baseScale;
    CGFloat widthScale;
    CGFloat heightScale;
    CGFloat fontSize;
    CGFloat rewardFontSize;
    
    [self setBorderImage];
    
    if (IS_IPHONE) {
        if (IS_HEIGHT_GTE_568) {
            // 16:9
            baseScale = 1136.f / 1600.f;
            widthScale = 0.75f;
            heightScale = 0.78125f;
            fontSize=IS_IPHONE?15:24;
            rewardFontSize=IS_IPHONE?12:14;
        }
        else {
            // 3:2
            baseScale = 960.f / 1400.f;  // 1400 is base height reference
            widthScale = 0.75f;
            heightScale = 0.7292f;
            fontSize=IS_IPHONE?15:24;
            rewardFontSize=IS_IPHONE?12:14;
        }
    }
    else {
        // 4:3
        baseScale = 1024.f / 1500.f;  // 1500 is base height reference
        widthScale = 0.729f;
        heightScale = 0.7324f;
        fontSize=IS_IPHONE?15:30;
        rewardFontSize=IS_IPHONE?12:24;
    }
    
    CGSize baseSize = self.bounds.size;
    CGSize innerSize = CGSizeMake(baseSize.width * widthScale, baseSize.height * heightScale);
    
    // default image
    CGFloat spacer1 = innerSize.height * 0.0469;
    CGSize pollImageSize = CGSizeMake(innerSize.height * 0.2188, innerSize.height * 0.2188);
    
    // close button
    CGFloat spacer4 = innerSize.height * 0.01875;
    CGSize closeButtonSize = CGSizeMake(innerSize.height * 0.0375 , innerSize.height * 0.0375);
    
    // reward
    CGSize rewardImageSize = CGSizeMake(innerSize.height * 0.0313 , innerSize.height * 0.0313);
    CGSize rewardTextSize = CGSizeMake(innerSize.height * 0.0625 , 14);
    
    // poll question
    CGSize pollTextSize = CGSizeMake(innerSize.width * 0.8889, innerSize.height * (0.0234+0.1375+0.0234));
    
    // button
    CGFloat spacer3 = innerSize.height * 0.0313;
    CGSize buttonSize = CGSizeMake(innerSize.width * 0.8889, innerSize.height * 0.1063);
    CGSize buttonShadowSize = CGSizeMake(innerSize.height * 0.0106, innerSize.height * 0.0106);
    
    // spacerx
    CGFloat spacerX = innerSize.width * ((1 - 0.8889) / 2);
    
    // resize and layout poll view
    pollView.frame = CGRectMake(0, 0, innerSize.width, innerSize.height);

    defaultImageView.frame = CGRectMake((innerSize.width - pollImageSize.width)/2, spacer1, pollImageSize.width, pollImageSize.height);
    
    if (myPoll.app.closeButtonLocation == 0) {
        // top left
        closeBtn.frame = CGRectMake(spacer4 + (baseScale * myPoll.app.closeButtonOffsetX/2), spacer4 + (baseScale *myPoll.app.closeButtonOffsetY/2), closeButtonSize.width, closeButtonSize.height);
        
        // reward image
        rewardImageView.frame=CGRectMake(5+defaultImageView.frame.origin.x + defaultImageView.frame.size.width, defaultImageView.frame.origin.y+defaultImageView.frame.size.height/2, rewardImageSize.width, rewardImageSize.height);
        [virtualAmountRewardLabel sizeToFit];
    }
    else {
        // top right
        closeBtn.frame = CGRectMake(innerSize.width - (spacer4 + closeButtonSize.width + (baseScale * myPoll.app.closeButtonOffsetX/2)), spacer4 + (baseScale * myPoll.app.closeButtonOffsetY/2), closeButtonSize.width, closeButtonSize.height);
        
        // reward image
        rewardImageView.frame=CGRectMake(5, defaultImageView.frame.origin.y+defaultImageView.frame.size.height/2, rewardImageSize.width, rewardImageSize.height);

    }
    // adjust frame to have bigger button for easy touch
    closeBtn.frame = CGRectInset(closeBtn.frame, -closeBtn.layer.borderWidth, -closeBtn.layer.borderWidth);
    
    // reward text
    virtualAmount.frame=CGRectMake(5 + rewardImageView.frame.origin.x + rewardImageView.frame.size.width, rewardImageView.frame.origin.y, rewardTextSize.width, rewardTextSize.height);
    [virtualAmount setFont:[UIFont systemFontOfSize:rewardFontSize]];
    [virtualAmount sizeToFit];
    [virtualAmountRewardLabel setFont:[UIFont systemFontOfSize:rewardFontSize]];
    //[virtualAmountRewardLabel setMinimumScaleFactor:0.5];
    virtualAmountRewardLabel.frame=virtualAmount.frame;
    virtualAmountRewardLabel.frame=CGRectMake(virtualAmountRewardLabel.frame.origin.x, virtualAmount.frame.origin.y-virtualAmountRewardLabel.frame.size.height, defaultImageView.frame.size.width, virtualAmountRewardLabel.frame.size.height);
    [virtualAmountRewardLabel sizeToFit];
    // adjust X
    CGFloat x0 = (defaultImageView.frame.origin.x- (rewardImageView.frame.size.width + 5 + MAX(virtualAmount.frame.size.width,virtualAmountRewardLabel.frame.size.width)))/2;
    x0 += (myPoll.app.closeButtonLocation == 0) ? defaultImageView.frame.size.width: 0;
    rewardImageView.frame=CGRectOffset(rewardImageView.frame, x0, 0);
    virtualAmount.frame=CGRectOffset(virtualAmount.frame, x0, 0);
    virtualAmountRewardLabel.frame=CGRectOffset(virtualAmountRewardLabel.frame, x0, 0);
    
    // poll question
    questionLabel.frame = CGRectMake(spacerX, defaultImageView.frame.origin.y + defaultImageView.frame.size.height, pollTextSize.width, pollTextSize.height );
    [questionLabel setFont:[UIFont systemFontOfSize:fontSize]];
    
    // mc choice
    mcView.frame = CGRectMake(0, questionLabel.frame.origin.y + questionLabel.frame.size.height, innerSize.width, 4 *( (buttonSize.height + spacer3)));
    for (UIButton *button in [NSArray arrayWithObjects:mcBtn1,mcBtn2,mcBtn3,mcBtn4,nil ] ) {
        [self setButtonStyle:button];
        
        button.layer.shadowOffset = buttonShadowSize;
        [button.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
    }
    mcBtn1.frame=CGRectMake(spacerX, 0, buttonSize.width, buttonSize.height);
    mcBtn2.frame=CGRectMake(spacerX, spacer3 + buttonSize.height, buttonSize.width, buttonSize.height);
    mcBtn3.frame=CGRectMake(spacerX, 2 * (spacer3 + buttonSize.height), buttonSize.width, buttonSize.height);
    mcBtn4.frame=CGRectMake(spacerX, 3 * (spacer3 + buttonSize.height), buttonSize.width, buttonSize.height);
    
    // text view
    textView.frame=mcView.frame;
    responseTextView.frame=CGRectMake(spacerX, 0, buttonSize.width, (3 * buttonSize.height) + (2 * spacer3));
    [responseTextView setFont:[UIFont systemFontOfSize:fontSize]];
    [self setButtonStyle:textBtn];
    textBtn.layer.shadowOffset = buttonShadowSize;
    [textBtn.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
    textBtn.frame=CGRectMake(spacerX, responseTextView.frame.origin.y + responseTextView.frame.size.height + spacer3, buttonSize.width, buttonSize.height);

    // collect button
    collectView.frame=mcView.frame;
    [collectRewardImageView setImage:rewardImageView.image];
    [collectTextLabel setFont:[UIFont systemFontOfSize:fontSize]];
    [collectTextLabel sizeToFit];
    CGPoint center=responseTextView.center;
    CGFloat y=center.y - collectRewardImageView.frame.size.height/2;
    CGFloat x=(collectView.frame.size.width - (collectRewardImageView.frame.size.width + 5 + collectTextLabel.frame.size.width))/2;
    collectRewardImageView.frame=CGRectMake(x, y, collectTextLabel.frame.size.height, collectTextLabel.frame.size.height);
    collectTextLabel.frame=CGRectMake(collectRewardImageView.frame.origin.x+collectRewardImageView.frame.size.width+5, y, collectTextLabel.frame.size.width, collectTextLabel.frame.size.height);
    [collectTextLabel setFont:[UIFont systemFontOfSize:fontSize]];
    [self setButtonStyle:collectBtn];
    collectBtn.layer.shadowOffset = buttonShadowSize;
    [collectBtn.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
    collectBtn.frame=CGRectMake(spacerX, responseTextView.frame.origin.y + responseTextView.frame.size.height + spacer3, buttonSize.width, buttonSize.height);

}

-(void) layoutLandscape{
    CGFloat baseScale;
    CGFloat widthScale;
    CGFloat heightScale;
    CGFloat fontSize;
    CGFloat rewardFontSize;
    
    [self setBorderImage];
    
    if (IS_IPHONE) {
        if (IS_HEIGHT_GTE_568) {
            // 16:9
            baseScale = 1136.f / 1600.f;  // 1600 is base height reference
            widthScale = 0.78125f;
            heightScale = 0.75f;
            fontSize=IS_IPHONE?15:30;
            rewardFontSize=IS_IPHONE?12:24;
        }
        else {
            // 3:2
            baseScale = 960.f / 1400.f;  // 1400 is base height reference
            widthScale = 0.8125f;
            heightScale = 0.625f;
            fontSize=IS_IPHONE?15:30;
            rewardFontSize=IS_IPHONE?12:24;
        }
    }
    else {
        // 4:3
        baseScale = 1024.f / 1500.f;  // 1500 is base height reference
        widthScale = 0.7325;
        heightScale = 0.7292f;
        fontSize=IS_IPHONE?15:30;
        rewardFontSize=IS_IPHONE?12:24;
    }
    
    CGSize baseSize = self.bounds.size;
    CGSize innerSize = CGSizeMake(baseSize.width * widthScale, baseSize.height * heightScale);
    
    // default image
    CGFloat spacer1 = innerSize.width * 0.03125;
    CGSize pollImageSize = CGSizeMake(innerSize.width * 0.2188, innerSize.width * 0.2188);
    
    // close button
    CGFloat spacer4 = innerSize.width * 0.03125;
    CGSize closeButtonSize = CGSizeMake(innerSize.width * 0.03125, innerSize.width * 0.03125);
    
    // reward
    CGSize rewardImageSize = CGSizeMake(innerSize.width * 0.0365 , innerSize.width * 0.0365);
    CGSize rewardTextSize = CGSizeMake(innerSize.width * 0.0625 , 14);
    
    // poll question
    //CGFloat spacer2 = innerSize.height * 0.03125;
    CGSize pollTextSize = CGSizeMake(innerSize.width * 0.6250, innerSize.height * 0.24675);
    
    // button
    CGFloat spacer3 = innerSize.height * 0.0644;
    CGSize buttonSize = CGSizeMake(innerSize.width * 0.6250, innerSize.height * 0.10);
    CGSize buttonShadowSize = CGSizeMake(innerSize.width * 0.0106, innerSize.width * 0.0106);
    
    // spacerx
    CGFloat spacerX = 0;
    
    // resize and layout poll view
    pollView.frame = CGRectMake(0, 0, innerSize.width, innerSize.height);
    
    if (myPoll.app.closeButtonLocation == 0) {
        defaultImageView.frame = CGRectMake(innerSize.width - (pollImageSize.width + spacer1), spacer1, pollImageSize.width, pollImageSize.height);
    
        // top left
        closeBtn.frame = CGRectMake(spacer4 + (baseScale * myPoll.app.closeButtonOffsetX/2), spacer4 + (baseScale * myPoll.app.closeButtonOffsetY/2), closeButtonSize.width, closeButtonSize.height);
        closeBtn.frame = CGRectInset(closeBtn.frame, -closeBtn.layer.borderWidth, -closeBtn.layer.borderWidth);
        
        // poll question
        questionLabel.frame = CGRectMake(spacer4 + closeButtonSize.width + spacer4, spacer4, pollTextSize.width, innerSize.height - (4 * (buttonSize.height + spacer3)) - (2 * spacer4));
        [questionLabel setFont:[UIFont systemFontOfSize:fontSize]];
        
        // mc choice
        mcView.frame = CGRectMake(questionLabel.frame.origin.x, innerSize.height - 4 * (buttonSize.height + spacer3), pollTextSize.width, 4 *( (buttonSize.height + spacer3)));
        for (UIButton *button in [NSArray arrayWithObjects:mcBtn1,mcBtn2,mcBtn3,mcBtn4,nil ] ) {
            [self setButtonStyle:button];
            
            button.layer.shadowOffset = buttonShadowSize;
            [button.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
        }
        mcBtn1.frame=CGRectMake(spacerX, 0, buttonSize.width, buttonSize.height);
        mcBtn2.frame=CGRectMake(spacerX, spacer3 + buttonSize.height, buttonSize.width, buttonSize.height);
        mcBtn3.frame=CGRectMake(spacerX, 2 * (spacer3 + buttonSize.height), buttonSize.width, buttonSize.height);
        mcBtn4.frame=CGRectMake(spacerX, 3 * (spacer3 + buttonSize.height), buttonSize.width, buttonSize.height);
        
        // text view
        textView.frame=mcView.frame;
        responseTextView.frame=CGRectMake(spacerX, 0, buttonSize.width, (3 * buttonSize.height) + (2 * spacer3));
        [responseTextView setFont:[UIFont systemFontOfSize:fontSize]];
        [self setButtonStyle:textBtn];
        textBtn.layer.shadowOffset = buttonShadowSize;
        [textBtn.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
        textBtn.frame=CGRectMake(spacerX, responseTextView.frame.origin.y + spacer3, buttonSize.width, buttonSize.height);
        
        // collect button
        collectView.frame=mcView.frame;
        [collectRewardImageView setImage:rewardImageView.image];
        [collectTextLabel setFont:[UIFont systemFontOfSize:fontSize]];
        [collectTextLabel sizeToFit];
        CGPoint center=responseTextView.center;
        CGFloat y=center.y - collectRewardImageView.frame.size.height/2;
        CGFloat x=(collectView.frame.size.width - (collectRewardImageView.frame.size.width + 5 + collectTextLabel.frame.size.width))/2;
        collectRewardImageView.frame=CGRectMake(x, y, collectTextLabel.frame.size.height, collectTextLabel.frame.size.height);
        collectTextLabel.frame=CGRectMake(collectRewardImageView.frame.origin.x+collectRewardImageView.frame.size.width+5, y, collectTextLabel.frame.size.width, collectTextLabel.frame.size.height);
        [collectTextLabel setFont:[UIFont systemFontOfSize:fontSize]];
        [self setButtonStyle:collectBtn];
        collectBtn.layer.shadowOffset = buttonShadowSize;
        [collectBtn.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
        collectBtn.frame=CGRectMake(spacerX, responseTextView.frame.origin.y + spacer3, buttonSize.width, buttonSize.height);

        // reward image and text
        rewardImageView.frame=CGRectMake(defaultImageView.frame.origin.x, (pollView.frame.size.height - defaultImageView.frame.origin.y - defaultImageView.frame.size.height)/2 + defaultImageView.frame.size.height, rewardImageSize.width, rewardImageSize.height);
        virtualAmount.frame=CGRectMake(5+rewardImageView.frame.origin.x + rewardImageView.frame.size.width, rewardImageView.frame.origin.y, rewardTextSize.width, rewardTextSize.height);
        [virtualAmount setFont:[UIFont systemFontOfSize:rewardFontSize]];
        [virtualAmount sizeToFit];
        [virtualAmountRewardLabel setFont:[UIFont systemFontOfSize:rewardFontSize]];
        //[virtualAmountRewardLabel setMinimumScaleFactor:0.5];
        virtualAmountRewardLabel.frame=virtualAmount.frame;
        virtualAmountRewardLabel.frame=CGRectMake(virtualAmountRewardLabel.frame.origin.x, virtualAmountRewardLabel.frame.origin.y-virtualAmountRewardLabel.frame.size.height, pollImageSize.width, virtualAmountRewardLabel.frame.size.height);
        [virtualAmountRewardLabel sizeToFit];
        
        // adjust x offset to center
        CGFloat totalWidth=MAX(virtualAmount.frame.size.width, virtualAmountRewardLabel.frame.size.width)+ 5 + rewardImageView.frame.size.width;
        CGFloat deltaX=(pollImageSize.width - totalWidth)/2;
        rewardImageView.frame = CGRectOffset(rewardImageView.frame, deltaX, 0);
        virtualAmount.frame = CGRectOffset(virtualAmount.frame, deltaX, 0);
        virtualAmountRewardLabel.frame = CGRectOffset(virtualAmountRewardLabel.frame, deltaX, 0);
     }
    else {
        // top right
        defaultImageView.frame = CGRectMake(spacer1, spacer1, pollImageSize.width, pollImageSize.height);
        
        // top left
        closeBtn.frame = CGRectMake(innerSize.width - (closeButtonSize.width + spacer4 + (baseScale * myPoll.app.closeButtonOffsetX/2)), spacer4 + (baseScale * myPoll.app.closeButtonOffsetY/2), closeButtonSize.width, closeButtonSize.height);
        closeBtn.frame = CGRectInset(closeBtn.frame, -closeBtn.layer.borderWidth, -closeBtn.layer.borderWidth);
        
        
        // poll question
        questionLabel.frame = CGRectMake(defaultImageView.frame.origin.x + defaultImageView.frame.size.width + spacer4, spacer4, pollTextSize.width, innerSize.height - (4 * (buttonSize.height + spacer3)) - (2 * spacer4));
        [questionLabel setFont:[UIFont systemFontOfSize:fontSize]];
        
        // mc choice
        mcView.frame = CGRectMake(questionLabel.frame.origin.x, questionLabel.frame.origin.y + questionLabel.frame.size.height + spacer4, pollTextSize.width, 4 *( (buttonSize.height + spacer3)));
        for (UIButton *button in [NSArray arrayWithObjects:mcBtn1,mcBtn2,mcBtn3,mcBtn4,nil ] ) {
            [self setButtonStyle:button];
            
            button.layer.shadowOffset = buttonShadowSize;
            [button.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
        }
        mcBtn1.frame=CGRectMake(spacerX, 0, buttonSize.width, buttonSize.height);
        mcBtn2.frame=CGRectMake(spacerX, spacer3 + buttonSize.height, buttonSize.width, buttonSize.height);
        mcBtn3.frame=CGRectMake(spacerX, 2 * (spacer3 + buttonSize.height), buttonSize.width, buttonSize.height);
        mcBtn4.frame=CGRectMake(spacerX, 3 * (spacer3 + buttonSize.height), buttonSize.width, buttonSize.height);
        
        // text view
        textView.frame=mcView.frame;
        responseTextView.frame=CGRectMake(spacerX, 0, buttonSize.width, (3 * buttonSize.height) + (2 * spacer3));
        [responseTextView setFont:[UIFont systemFontOfSize:fontSize]];
        [self setButtonStyle:textBtn];
        textBtn.layer.shadowOffset = buttonShadowSize;
        [textBtn.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
        textBtn.frame=CGRectMake(spacerX, responseTextView.frame.origin.y +  responseTextView.frame.size.height + spacer3, buttonSize.width, buttonSize.height);
        
        // collect button
        collectView.frame=mcView.frame;
        [collectRewardImageView setImage:rewardImageView.image];
        [collectTextLabel setFont:[UIFont systemFontOfSize:fontSize]];
        [collectTextLabel sizeToFit];
        CGPoint center=responseTextView.center;
        CGFloat y=center.y - collectRewardImageView.frame.size.height/2;
        CGFloat x=(collectView.frame.size.width - (collectRewardImageView.frame.size.width + 5 + collectTextLabel.frame.size.width))/2;
        collectRewardImageView.frame=CGRectMake(x, y, collectTextLabel.frame.size.height, collectTextLabel.frame.size.height);
        collectTextLabel.frame=CGRectMake(collectRewardImageView.frame.origin.x+collectRewardImageView.frame.size.width+5, y, collectTextLabel.frame.size.width, collectTextLabel.frame.size.height);
        [collectTextLabel setFont:[UIFont systemFontOfSize:fontSize]];
        [self setButtonStyle:collectBtn];
        collectBtn.layer.shadowOffset = buttonShadowSize;
        [collectBtn.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
        collectBtn.frame=CGRectMake(spacerX, responseTextView.frame.origin.y +  responseTextView.frame.size.height +  spacer3, buttonSize.width, buttonSize.height);
        
        // reward image and text
        rewardImageView.frame=CGRectMake(defaultImageView.frame.origin.x, (pollView.frame.size.height - defaultImageView.frame.origin.y - defaultImageView.frame.size.height)/2 + defaultImageView.frame.size.height, rewardImageSize.width, rewardImageSize.height);
        virtualAmount.frame=CGRectMake(5+rewardImageView.frame.origin.x + rewardImageView.frame.size.width, rewardImageView.frame.origin.y, rewardTextSize.width, rewardTextSize.height);
        [virtualAmount setFont:[UIFont systemFontOfSize:rewardFontSize]];
        [virtualAmount sizeToFit];
        [virtualAmountRewardLabel setFont:[UIFont systemFontOfSize:rewardFontSize]];
        //[virtualAmountRewardLabel setMinimumScaleFactor:0.5];
        virtualAmountRewardLabel.frame=virtualAmount.frame;
        virtualAmountRewardLabel.frame=CGRectMake(virtualAmountRewardLabel.frame.origin.x, virtualAmountRewardLabel.frame.origin.y-virtualAmountRewardLabel.frame.size.height, pollImageSize.width, virtualAmountRewardLabel.frame.size.height);
        [virtualAmountRewardLabel sizeToFit];
        
        // adjust x offset to center
        CGFloat totalWidth=MAX(virtualAmount.frame.size.width, virtualAmountRewardLabel.frame.size.width)+ 5 + rewardImageView.frame.size.width;
        CGFloat deltaX=(pollImageSize.width - totalWidth)/2;
        rewardImageView.frame = CGRectOffset(rewardImageView.frame, deltaX, 0);
        virtualAmount.frame = CGRectOffset(virtualAmount.frame, deltaX, 0);
        virtualAmountRewardLabel.frame = CGRectOffset(virtualAmountRewardLabel.frame, deltaX, 0);
    }

}

- (void)didMoveToSuperview {
	// We need to take care of rotation ourselfs if added to a window
	if ([self.superview isKindOfClass:[UIWindow class]]) {
		[self setTransformForCurrentOrientation:NO];
	}
    
    if ([myPoll.type isEqualToString:@"T"]) {
        [self registerForKeybaordNotifications];
    }
}

#pragma mark - view show/hide
-(void) show
{
    
    UIWindow* mainWindow = [[UIApplication sharedApplication] keyWindow];

    self.frame=mainWindow.bounds;
    
    if (myPoll.virtualAmount>0) {
        rewardImageView.hidden=NO;
        virtualAmountRewardLabel.hidden=NO;
        virtualAmount.hidden=NO;
    }
    else {
        rewardImageView.hidden=YES;
        virtualAmountRewardLabel.hidden=YES;
        virtualAmount.hidden=YES;
    }
    
    collectView.hidden=YES;
    
    UIView *rootView=[self topViewController].view ;
    [rootView addSubview:self];
    self.frame=self.superview.bounds;
    self.center=self.superview.center;
    overlayView.frame=self.bounds;
    borderImageView.frame=self.bounds;
    pollView.center=self.center;
    backgroundView.center=pollView.center;
    [rootView endEditing:YES];
    
    [self setNeedsDisplay];

}

-(void) showActionAfterResponse
{
    questionLabel.text=myPoll.customMessage;
    
    if (myPoll.virtualAmount>0) {
        [collectBtn setTitle:myPoll.collectButtonText forState:UIControlStateNormal];
        [collectRewardImageView setImage:rewardImageView.image];
        collectView.hidden=NO;
        collectBtn.hidden=NO;
        closeBtn.hidden=YES;
        rewardImageView.hidden=YES;
        virtualAmount.hidden=YES;
        virtualAmountRewardLabel.hidden=YES;
    }
    else {
        [collectBtn setTitle:myPoll.thankyouButtonText forState:UIControlStateNormal];
        collectView.hidden=YES;
        collectBtn.hidden=YES;
        closeBtn.hidden=NO;
    }
}

-(void) hide
{
    [self unregisterFromKeyboardNotifications];
    [self unregisterFromNotifications];
    
    [self removeFromSuperview];
}

-(void) viewTouch:(UITapGestureRecognizer*) gesture
{
    [self endEditing:YES];
}

#pragma mark - response handling
-(IBAction)userReponded:(id)sender {

    [self endEditing:YES];
    
    UIButton *button=(UIButton*) sender;
    if (button==textBtn) {
        myPoll.response=[responseTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        // ignore all blank reply
        if ([myPoll.response length]==0) {
            [responseTextView becomeFirstResponder];
            return;
        }
        else {
            myPoll.response=responseTextView.text;
        }
    }
    else {
        myPoll.response=[button titleForState:UIControlStateNormal];
    }
    
    userIsResponded=YES;
    
    closeBtn.hidden=NO;
    mcView.hidden=YES;
    textView.hidden=YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate PJPollViewDidAnswered:self poll:myPoll];
    });
}

-(IBAction)userSkipped:(id)sender {
    
    [self endEditing:YES];
    
    if (userIsResponded) {
        [self userConfirmed:sender];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate PJPollViewDidSkipped:self poll:myPoll];
        });
    }
}

-(void)userConfirmed:(id)sender {
    [self endEditing:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate PJPollViewCloseAfterReponse:self poll:myPoll];
     });
}

#pragma mark - Notifications
- (void)registerForKeybaordNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterFromKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    NSNumber *animationDuration=[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    CGPoint center=self.center;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        center.y=center.y - keyboardFrame.size.width + textBtn.frame.size.height + 10;
    }
    else {
        center.y=center.y - keyboardFrame.size.height + textBtn.frame.size.height;
    }
    
    [UIView animateWithDuration:[animationDuration floatValue] animations:^{
        backgroundView.center=center;
        pollView.center=center;
        borderImageView.center=center;
    }];
}

-(void) keyboardWillHide:(NSNotification *)notification
{
    
    NSNumber *animationDuration=[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    [UIView animateWithDuration:[animationDuration floatValue] animations:^{
        backgroundView.center=self.center;
        pollView.center=self.center;
        borderImageView.center=self.center;
    }];
}

- (void)registerForNotifications {
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(deviceOrientationDidChange:)
			   name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)unregisterFromNotifications {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
	UIView *superview = self.superview;
	if (!superview) {
		return;
	} else if ([superview isKindOfClass:[UIWindow class]]) {
		[self setTransformForCurrentOrientation:YES];
	} else {
        [self setNeedsDisplay];
	}
}

- (UIViewController *)topViewController{
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

// NOT USED
- (void)setTransformForCurrentOrientation:(BOOL)animated {
	// Stay in sync with the superview
	if (self.superview) {
		self.bounds = self.superview.bounds;
		[self setNeedsDisplay];
	}
	
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	CGFloat radians = 0;
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		if (orientation == UIInterfaceOrientationLandscapeLeft) { radians = -(CGFloat)M_PI_2; }
		else { radians = (CGFloat)M_PI_2; }
		// Window coordinates differ!
		self.bounds = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
	} else {
		if (orientation == UIInterfaceOrientationPortraitUpsideDown) { radians = (CGFloat)M_PI; }
		else { radians = 0; }
	}
	rotationTransform = CGAffineTransformMakeRotation(radians);
	
	if (animated) {
		[UIView beginAnimations:nil context:nil];
	}
	[self setTransform:rotationTransform];
	if (animated) {
		[UIView commitAnimations];
	}
}
@end
