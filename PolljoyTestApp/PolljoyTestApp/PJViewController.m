//
//  PJViewController.m
//  PolljoyTestApp
//
//  Copyright (c) 2014 polljoy limited. All rights reserved.
//

#import "PJViewController.h"

@interface PJViewController () {
    IBOutlet UITextField *userId;
    IBOutlet UITextField *appId;
    IBOutlet UITextView *log;
    IBOutlet UITextField *appVersion;
    IBOutlet UISegmentedControl *userType;
    IBOutlet UITextField *level;
    IBOutlet UITextField *session;
    IBOutlet UITextField *timeSinceInstall;
    IBOutlet UILabel *sessionId;
    IBOutlet UIButton *showBtn;
}

@end

@implementation PJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    sessionId.text=[Polljoy sessionId];
    
    // schedule a timer to check for session state if you want to monitor it
    //[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateSession) userInfo:nil repeats:NO];
    
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTouch:)];
    [self.view addGestureRecognizer:gesture];
    
    // set this if you want poll to show automatically when ready
    // [Polljoy setAutoShow:YES];
    
    // you should request for poll at somehwhere you need
    [self requestPoll:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) renewSession
{
    NSString *_appId=appId.text;
    
    [Polljoy startSession:_appId];
    
    [self requestPoll:nil];
    
    //[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSession) userInfo:nil repeats:NO];
}

-(IBAction)requestPoll:(id)sender
{
    appId.text = [Polljoy appId];
    
    NSString *_appVersion = [appVersion.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    _appVersion=([_appVersion length]>0?_appVersion:@"0");
    NSUInteger _level=[level.text integerValue];
    NSUInteger _sessionCount=[session.text integerValue];
    NSUInteger _timeSinceInstall=[timeSinceInstall.text integerValue];
    PJUserType _userType=(PJUserType)[userType selectedSegmentIndex];
    
//    [Polljoy getPoll];  // no delegate call, will autoshow by default

    [Polljoy getPollWithDelegate:self
                      appVersion:_appVersion
                           level:_level
                         session:_sessionCount
                      timeSinceInstall:_timeSinceInstall
                        userType:_userType];

}

-(IBAction)showPoll:(id)sender {
    [Polljoy showPoll];
}

-(void)viewTouch:(UITapGestureRecognizer *) gesturer{

    [self.view endEditing:YES];
    
}

-(void) updateSession
{
    NSLog(@"Update session");
    
    if ([Polljoy sessionId]==nil) {
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSession) userInfo:nil repeats:NO];
    }
    else{
        [self updateSessionLog];
    }
    

}

-(void) updateSessionLog
{
    sessionId.text=[Polljoy sessionId];
    userId.text = [Polljoy userId];
    appId.text = [Polljoy appId];
    session.text = [NSString stringWithFormat:@"%lu",(unsigned long)[Polljoy session]];
    timeSinceInstall.text = [NSString stringWithFormat:@"%lu",(unsigned long)[Polljoy timeSinceInstall]];
    
    // request for poll as you want
    // this sample already request poll in viewDidLoad.
    // [self requestPoll:nil];
    
    // append log
    log.text = [log.text stringByAppendingFormat:@"Device Id: %@\n",[Polljoy deviceId]];
    log.text = [log.text stringByAppendingFormat:@"App Name: %@\n",[Polljoy app].appName];
    log.text = [log.text stringByAppendingFormat:@"defaultImageUrl: %@\n",[Polljoy app].defaultImageUrl];
    log.text = [log.text stringByAppendingFormat:@"maximumPollPerSession: %lu\n",(unsigned long)[Polljoy app].maximumPollPerSession];
    log.text = [log.text stringByAppendingFormat:@"maximumPollPerDay: %lu\n",(unsigned long)[Polljoy app].maximumPollPerDay];
    log.text = [log.text stringByAppendingFormat:@"maximumPollInARow: %lu\n",(unsigned long)[Polljoy app].maximumPollInARow];
    log.text = [log.text stringByAppendingFormat:@"backgroundColor: %@\n",[Polljoy app].backgroundColor];
    log.text = [log.text stringByAppendingFormat:@"borderColor: %@\n",[Polljoy app].borderColor];
    log.text = [log.text stringByAppendingFormat:@"buttonColor: %@\n",[Polljoy app].buttonColor];
    log.text = [log.text stringByAppendingFormat:@"fontColor: %@\n",[Polljoy app].fontColor];

    [self scrollLogToBottom];
}

-(void) scrollLogToBottom
{
    if ((log.contentSize.height - log.bounds.size.height) >0) {
        CGPoint bottomOffset = CGPointMake(0, log.contentSize.height - log.bounds.size.height);
        [log setContentOffset:bottomOffset animated:YES];
    }
}

-(void) textViewDidBeginEditing:(UITextView *)textView {
    [self scrollLogToBottom];
}

// TODO: implement the below optional delegates to handle response for Polljoy
//
//       if you have virtual currency, must implement below delegate to handle
//          -(void) PJPollDidResponded:(PJPoll*) poll
#pragma mark - PolljoyDelegate
-(void) PJPollNotAvailable:(PJResponseStatus) status
{
    log.text = [log.text stringByAppendingFormat:@"PJPollNotAvailable: status: %u\n",status];
    
    [self scrollLogToBottom];
}

-(void) PJPollIsReady:(NSArray *) polls
{
    // pause your app and save any status if needed
    
    // update session log
    [self updateSessionLog];
    
    log.text = [log.text stringByAppendingFormat:@"PJPollIsReady: %@\n",polls];

    showBtn.enabled=YES;
    
    // trigger to show the poll when you are ready
    //[Polljoy showPoll];
    
    [self scrollLogToBottom];
}

-(void) PJPollWillShow:(PJPoll*) poll
{
    // update your UI if needed to prepare for poll presentation
    log.text = [log.text stringByAppendingFormat:@"PJPollWillShow %@\n",poll];
    
    [self scrollLogToBottom];
}

-(void) PJPollDidShow:(PJPoll*) poll
{
    // did anything you need when poll did show,
    // you may not need to do anything on this
    log.text = [log.text stringByAppendingFormat:@"PJPollDidShow %@\n",poll];
    
    [self scrollLogToBottom];
}

-(void) PJPollWillDismiss:(PJPoll*) poll
{
    // prepare you UI to resume game if need
    log.text = [log.text stringByAppendingFormat:@"PJPollWillDismiss %@\n",poll];
    
    [self scrollLogToBottom];
}

-(void) PJPollDidDismiss:(PJPoll*) poll
{
    // prepare you UI to resume game if need
    log.text = [log.text stringByAppendingFormat:@"PJPollDidDismiss %@\n",poll];
    
    [self scrollLogToBottom];
}


-(void) PJPollDidResponded:(PJPoll*) poll
{
    // user response to the poll
    // check if any vrtual money is received and update your app status
    //
    // poll.virtualAmount
    log.text = [log.text stringByAppendingFormat:@"PJPollDidResponded %@\n",poll];
    if (poll.virtualAmount >0) {
        log.text = [log.text stringByAppendingFormat:@"Virtual Amount: %ld\n",(long)poll.virtualAmount];
    }
    
    if ([[Polljoy polls] count] >0) {
        showBtn.enabled=YES;
    }
    else {
        showBtn.enabled=NO;
    }
    
    [self scrollLogToBottom];
}

-(void) PJPollDidSkipped:(PJPoll*) poll
{
    // user skipped to respose to the poll
    // no virtual money will be allocated
    
    log.text = [log.text stringByAppendingFormat:@"PJPollDidSkipped %@\n",poll];
    
    if ([[Polljoy polls] count] >0) {
        showBtn.enabled=YES;
    }
    else {
        showBtn.enabled=NO;
    }
    
    [self scrollLogToBottom];
}


@end
