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
    IBOutlet UIImageView *virtualAmountImageView;
    IBOutlet UIView *mcView;
    IBOutlet UIButton *mcBtn1;
    IBOutlet UIButton *mcBtn2;
    IBOutlet UIButton *mcBtn3;
    IBOutlet UIButton *mcBtn4;
    
    IBOutlet UIView *textView;
    IBOutlet UITextView *responseTextView;
    IBOutlet UIButton *textBtn;
    
    IBOutlet UIButton *closeBtn;
    
    IBOutlet UIButton *collectBtn;
    
    NSArray *mcButtons;
    
    PJPoll *myPoll;
    
    CGAffineTransform rotationTransform;
    
    BOOL userIsResponded;
    UIImage *defaultImage;
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
    
    self=[self initWithFrame:CGRectMake(0,0,0,0)]; // TODO: check orientation
    if(self) {
        [self setupView];
        
        myPoll=poll;
        mcButtons = [NSArray arrayWithObjects:mcBtn1, mcBtn2, mcBtn3, mcBtn4, nil];
        
        // setup appearance
        self.backgroundColor = [UIColor clearColor];
        
        pollView.backgroundColor = poll.backgroundColor;
        pollView.layer.borderColor = [poll.borderColor CGColor];
        pollView.layer.borderWidth=4.;
        pollView.layer.cornerRadius=4.;
        
        [questionLabel setTextColor:poll.fontColor];
        
        [mcBtn1 setBackgroundColor:poll.buttonColor];
        [mcBtn1 setTitleColor:poll.fontColor forState:UIControlStateNormal];
        mcBtn1.hidden=YES;
        [mcBtn2 setBackgroundColor:poll.buttonColor];
        [mcBtn2 setTitleColor:poll.fontColor forState:UIControlStateNormal];
        mcBtn2.hidden=YES;
        [mcBtn3 setBackgroundColor:poll.buttonColor];
        [mcBtn3 setTitleColor:poll.fontColor forState:UIControlStateNormal];
        mcBtn3.hidden=YES;
        [mcBtn4 setBackgroundColor:poll.buttonColor];
        [mcBtn4 setTitleColor:poll.fontColor forState:UIControlStateNormal];
        mcBtn4.hidden=YES;
        
        [textBtn setBackgroundColor:poll.buttonColor];
        [textBtn setTitleColor:poll.fontColor forState:UIControlStateNormal];
        
        [collectBtn setBackgroundColor:poll.buttonColor];
        [collectBtn setTitleColor:poll.fontColor forState:UIControlStateNormal];
        
        closeBtn.hidden=poll.mandatory;
        UIImage *closeIcon=[UIImage imageWithContentsOfFile:[[PolljoyCore frameworkBundle] pathForResource:@"btnCancel" ofType:@"png"]];
        UIImage *maskedIcon=[closeIcon maskWithColor:poll.fontColor];
        [closeBtn setImage:maskedIcon forState:UIControlStateNormal];
    
        UIImage *bagIcon=[UIImage imageWithContentsOfFile:[[PolljoyCore frameworkBundle] pathForResource:@"moneyBag" ofType:@"png"]];
        UIImage *maskedBagIcon=[bagIcon maskWithColor:poll.fontColor];
        [virtualAmountImageView setImage:maskedBagIcon];
        
        // setp poll message
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
        
        //setup image
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

-(void) setupView
{
    self.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    pollView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 360)];
    pollView.backgroundColor=[UIColor clearColor];
    pollView.layer.masksToBounds=YES;
    
    // default image
    defaultImageView=[[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 112, 112)];
    defaultImageView.backgroundColor=[UIColor clearColor];
    [pollView addSubview:defaultImageView];
    
    closeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setFrame:CGRectMake(196, 0, 44, 44)];
    [closeBtn addTarget:self action:@selector(userSkipped:) forControlEvents:UIControlEventTouchUpInside];
    [pollView addSubview:closeBtn];
    
    virtualAmountImageView=[[UIImageView alloc] initWithFrame:CGRectMake(320, 20, 256, 256)];
    virtualAmountImageView.backgroundColor=[UIColor clearColor];
    [pollView addSubview:virtualAmountImageView];
    
    virtualAmountRewardLabel=[[UILabel alloc] initWithFrame:CGRectMake(132, 46, 98, 67)];
    [virtualAmountRewardLabel setBackgroundColor:[UIColor clearColor]];
    [virtualAmountRewardLabel setText:NSLocalizedString(@"Reward:", @"Reward:")];
    [virtualAmountRewardLabel setFont:[UIFont boldSystemFontOfSize:30]];
    [virtualAmountRewardLabel setMinimumScaleFactor:0.5];
    [virtualAmountRewardLabel setTextAlignment:NSTextAlignmentCenter];
    [pollView addSubview:virtualAmountRewardLabel];
    
    virtualAmount=[[UILabel alloc] initWithFrame:CGRectMake(132, 46, 98, 67)];
    [virtualAmount setBackgroundColor:[UIColor clearColor]];
    [virtualAmount setFont:[UIFont boldSystemFontOfSize:30]];
    [virtualAmount setMinimumScaleFactor:0.5];
    [virtualAmount setTextAlignment:NSTextAlignmentCenter];
    [pollView addSubview:virtualAmount];
    
    questionLabel=[[UILabel alloc] initWithFrame:CGRectMake(12,132,218, 64)];
    [questionLabel setBackgroundColor:[UIColor clearColor]];
    [questionLabel setFont:[UIFont systemFontOfSize:24]];
    [questionLabel setMinimumScaleFactor:0.5];
    [questionLabel setNumberOfLines:0];   // bug in iOS6, multiple line with word wrapping doesn't work with AdjustsFontSizeToFitWidth
    [questionLabel setAdjustsFontSizeToFitWidth:YES];
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
    
    collectBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [collectBtn setTitle:@"Collect" forState:UIControlStateNormal];
    [collectBtn addTarget:self action:@selector(userConfirmed:) forControlEvents:UIControlEventTouchUpInside];
    [collectBtn setFrame:CGRectMake(11, 300, 218, 30)];
    collectBtn.hidden=YES;
    [pollView addSubview:collectBtn];


    
    [self addSubview:pollView];
}
-(void) setDefaultImage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [defaultImageView setImage:[PolljoyCore defaultImage]];
        myPoll.isReadyToShow=YES;
        [self.delegate PJPollViewIsReadyToShow:self poll:myPoll];
    });

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)startImageDownload:(PJPoll *)poll
{
    NSString *urlString=nil;
    if ((poll.pollImageUrl!=nil) && (![poll.pollImageUrl isEqual:[NSNull null]])) {
        urlString=poll.pollImageUrl;
    }
    else if ((poll.appImageUrl!=nil) && (![poll.appImageUrl isEqual:[NSNull null]])) {
        urlString=poll.appImageUrl;
    }
    
    if (urlString!=nil) {
        PJImageDownloader *imageDownloader = [[PJImageDownloader alloc] init];
        [imageDownloader setUrlString:urlString];
        [imageDownloader setCompletionHandler:^(UIImage * image) {
            if (image!=nil) {
                // download success
                [defaultImageView setImage:image];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    myPoll.isReadyToShow=YES;
                    [self.delegate PJPollViewIsReadyToShow:self poll:myPoll];
                });
            }
            else {
                //download fail, use default image and return ready
                [self setDefaultImage];
                
            }
        }];
        
        [imageDownloader startDownload];
    }
    else {
        [self setDefaultImage];
    }
}

- (void)layoutSubviews
{    
    if (!self.superview) return;
    
    [self endEditing:YES];
    
    self.frame = self.superview.bounds;

    // layout all subview for device orientation
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

    if (IS_IPHONE) {
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            [self layoutLandscapePhone];
        }
        else {
            [self layoutPortraitPhone];
        }
    }
    else {
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            [self layoutLandscapePad];
        }
        else {
            [self layoutPortraitPad];
        }
    }
    
    pollView.center=self.center;
}

-(void)layoutPortraitPad{
    pollView.frame=CGRectMake(0, 0, 586, 768);
    
    defaultImageView.frame=CGRectMake(20, 20, 256, 256);
    
    closeBtn.frame=CGRectMake(532, 10, 44, 44);
    
    questionLabel.frame=CGRectMake(20, 314,546, 152);
    [questionLabel setFont:[UIFont boldSystemFontOfSize:32.0]];
    
    virtualAmountImageView.frame=CGRectMake(320, 20, 256, 256);
    virtualAmountImageView.hidden=YES;
    virtualAmountRewardLabel.frame=CGRectMake(320, 73, 256, 58);
    [virtualAmountRewardLabel setFont:[UIFont boldSystemFontOfSize:60.0]];
    [virtualAmountRewardLabel setMinimumScaleFactor:0.5];
    virtualAmount.frame=CGRectMake(345, 139, 188, 97);
    [virtualAmount setFont:[UIFont boldSystemFontOfSize:60.0]];
    
    collectBtn.frame=CGRectMake(31, 704, 525, 44);
    [collectBtn.titleLabel setFont:[UIFont systemFontOfSize:24]];
    
    mcView.frame=CGRectMake(20, 500, 546, 264);
    mcBtn1.frame=CGRectMake(10, 20, 525, 44);
    [mcBtn1.titleLabel setFont:[UIFont systemFontOfSize:24]];
    mcBtn2.frame=CGRectMake(10, 81, 525, 44);
    [mcBtn2.titleLabel setFont:[UIFont systemFontOfSize:24]];
    mcBtn3.frame=CGRectMake(10, 139, 525, 44);
    [mcBtn3.titleLabel setFont:[UIFont systemFontOfSize:24]];
    mcBtn4.frame=CGRectMake(10, 200, 525, 44);
    [mcBtn4.titleLabel setFont:[UIFont systemFontOfSize:24]];
    
    textView.frame=CGRectMake(20, 500, 546, 248);
    responseTextView.frame=CGRectMake(10, 20, 525, 171);
    [responseTextView setFont:[UIFont systemFontOfSize:24]];
    textBtn.frame=CGRectMake(10, 203, 525, 44);
    [textBtn.titleLabel setFont:[UIFont systemFontOfSize:24]];
}

-(void)layoutLandscapePad{
    pollView.frame=CGRectMake(0, 0, 768, 586);
    
    defaultImageView.frame=CGRectMake(20, 20, 256, 256);
    
    closeBtn.frame=CGRectMake(714, 10, 44, 44);
    
    questionLabel.frame=CGRectMake(292, 68,456, 208);
    [questionLabel setFont:[UIFont boldSystemFontOfSize:32.0]];
    
    virtualAmountImageView.frame=CGRectMake(20, 310, 256, 256);
    virtualAmountImageView.hidden=YES;
    virtualAmountRewardLabel.frame=CGRectMake(20, 369, 256, 58);
    [virtualAmountRewardLabel setFont:[UIFont boldSystemFontOfSize:60.0]];
    [virtualAmountRewardLabel setMinimumScaleFactor:0.5];
    virtualAmount.frame=CGRectMake(46, 435, 188, 97);
    [virtualAmount setFont:[UIFont boldSystemFontOfSize:60.0]];
    
    collectBtn.frame=CGRectMake(303, 500, 435, 44);
    [collectBtn.titleLabel setFont:[UIFont systemFontOfSize:24]];
    
    mcView.frame=CGRectMake(292, 318, 456, 264);
    mcBtn1.frame=CGRectMake(10, 20, 435, 44);
    [mcBtn1.titleLabel setFont:[UIFont systemFontOfSize:24]];
    mcBtn2.frame=CGRectMake(10, 81, 435, 44);
    [mcBtn2.titleLabel setFont:[UIFont systemFontOfSize:24]];
    mcBtn3.frame=CGRectMake(10, 139, 435, 44);
    [mcBtn3.titleLabel setFont:[UIFont systemFontOfSize:24]];
    mcBtn4.frame=CGRectMake(10, 200, 435, 44);
    [mcBtn4.titleLabel setFont:[UIFont systemFontOfSize:24]];
    
    textView.frame=CGRectMake(292, 318, 456, 248);
    responseTextView.frame=CGRectMake(10, 10, 435, 180);
    [responseTextView setFont:[UIFont systemFontOfSize:24]];
    textBtn.frame=CGRectMake(10, 203, 435, 44);
    [textBtn.titleLabel setFont:[UIFont systemFontOfSize:24]];
}

-(void)layoutPortraitPhone{
    pollView.frame=CGRectMake(0, 0, 280, 360);
    
    defaultImageView.frame=CGRectMake(12, 12, 112, 112);
    
    closeBtn.frame=CGRectMake(245, 5, 30, 30);
    
    questionLabel.frame=CGRectMake(12, 132,258, 64);
    [questionLabel setFont:[UIFont boldSystemFontOfSize:24.0]];
    
    virtualAmountImageView.frame=CGRectMake(158, 12, 112, 112);
    virtualAmountImageView.hidden=YES;
    virtualAmountRewardLabel.frame=CGRectMake(158, 31, 112, 44);
    [virtualAmountRewardLabel setFont:[UIFont boldSystemFontOfSize:28.0]];
    [virtualAmountRewardLabel setMinimumScaleFactor:0.5];
    virtualAmount.frame=CGRectMake(176, 69, 69, 44);
    [virtualAmount setFont:[UIFont boldSystemFontOfSize:32.0]];
    
    collectBtn.frame=CGRectMake(11, 300, 259, 30);
    [collectBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
    
    mcView.frame=CGRectMake(0, 195, 280, 165);
    mcBtn1.frame=CGRectMake(10, 8, 258, 30);
    [mcBtn1.titleLabel setFont:[UIFont systemFontOfSize:17]];
    mcBtn2.frame=CGRectMake(10, 46, 258, 30);
    [mcBtn2.titleLabel setFont:[UIFont systemFontOfSize:17]];
    mcBtn3.frame=CGRectMake(10, 84, 258, 30);
    [mcBtn3.titleLabel setFont:[UIFont systemFontOfSize:17]];
    mcBtn4.frame=CGRectMake(10, 122, 258, 30);
    [mcBtn4.titleLabel setFont:[UIFont systemFontOfSize:17]];
    
    textView.frame=CGRectMake(0, 195, 280, 165);
    responseTextView.frame=CGRectMake(10, 8, 258, 106);
    [responseTextView setFont:[UIFont systemFontOfSize:17]];
    textBtn.frame=CGRectMake(10, 122, 258, 30);
    [textBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
}

-(void)layoutLandscapePhone{
    pollView.frame=CGRectMake(0, 0, 360, 280);
    
    defaultImageView.frame=CGRectMake(12, 12, 112, 112);
    
    closeBtn.frame=CGRectMake(325, 5, 30, 30);
    
    questionLabel.frame=CGRectMake(136, 32,214, 72);
    [questionLabel setFont:[UIFont boldSystemFontOfSize:24.0]];
    
    virtualAmountImageView.frame=CGRectMake(12, 157, 112, 112);
    virtualAmountImageView.hidden=YES;
    virtualAmountRewardLabel.frame=CGRectMake(12, 162, 112, 44);
    [virtualAmountRewardLabel setFont:[UIFont boldSystemFontOfSize:28.0]];
    [virtualAmountRewardLabel setMinimumScaleFactor:0.5];
    virtualAmount.frame=CGRectMake(30, 214, 69, 44);
    [virtualAmount setFont:[UIFont boldSystemFontOfSize:32.0]];
    
    collectBtn.frame=CGRectMake(139, 230, 214, 30);
    [collectBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
    
    mcView.frame=CGRectMake(132, 115, 228, 165);
    mcBtn1.frame=CGRectMake(7, 8, 214, 30);
    [mcBtn1.titleLabel setFont:[UIFont systemFontOfSize:17]];
    mcBtn2.frame=CGRectMake(7, 46, 214, 30);
    [mcBtn2.titleLabel setFont:[UIFont systemFontOfSize:17]];
    mcBtn3.frame=CGRectMake(7, 84, 214, 30);
    [mcBtn3.titleLabel setFont:[UIFont systemFontOfSize:17]];
    mcBtn4.frame=CGRectMake(7, 122, 214, 30);
    [mcBtn4.titleLabel setFont:[UIFont systemFontOfSize:17]];
    
    textView.frame=CGRectMake(132, 115, 228, 165);
    responseTextView.frame=CGRectMake(7, 8, 214, 106);
    [responseTextView setFont:[UIFont systemFontOfSize:17]];
    textBtn.frame=CGRectMake(7, 122, 214, 30);
    [textBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
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
        virtualAmountImageView.hidden=NO;
        virtualAmount.hidden=NO;
    }
    else {
        virtualAmountImageView.hidden=YES;
        virtualAmount.hidden=YES;
    }
    
    [mainWindow.rootViewController.view addSubview:self];
    self.frame=self.superview.bounds;
    self.center=self.superview.center;
    pollView.center=self.center;
    [mainWindow.rootViewController.view endEditing:YES];
    
    [self setNeedsDisplay];

}

-(void) showActionAfterResponse
{
    questionLabel.text=myPoll.customMessage;
    
    if (myPoll.virtualAmount>0) {
        collectBtn.hidden=NO;
        closeBtn.hidden=YES;
    }
    else {
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
    
    [self.delegate PJPollViewDidAnswered:self poll:myPoll];
}

-(IBAction)userSkipped:(id)sender {
    
    [self endEditing:YES];
    
    if (userIsResponded) {
        [self userConfirmed:sender];
    }
    else {
        [self.delegate PJPollViewDidSkipped:self poll:myPoll];
    }
}

-(void)userConfirmed:(id)sender {
    [self endEditing:YES];
    [self.delegate PJPollViewCloseAfterReponse:self poll:myPoll];
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
        center.y=center.y - keyboardFrame.size.width + textBtn.frame.size.height;
    }
    else {
        center.y=center.y - keyboardFrame.size.height + textBtn.frame.size.height;
    }
    
    [UIView animateWithDuration:[animationDuration floatValue] animations:^{
        pollView.center=center;
    }];
}

-(void) keyboardWillHide:(NSNotification *)notification
{
    
    NSNumber *animationDuration=[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    [UIView animateWithDuration:[animationDuration floatValue] animations:^{
        pollView.center=self.center;
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
		[self setTransformForCurrentOrientation:YES];//
	} else {
        [self setNeedsDisplay];
	}
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
