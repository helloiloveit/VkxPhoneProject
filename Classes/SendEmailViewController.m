//
//  SendEmailViewController.m
//  Vphone
//
//  Created by NinhNB on 25/10/13.
//
//

#import "SendEmailViewController.h"
#import <MailCore/MailCore.h>

#import "PhoneMainView.h"

@interface SendEmailViewController ()

@end

@implementation SendEmailViewController

@synthesize account, password, sendTo, mailServer, subject;
@synthesize mailContent, ccMailList;
@synthesize sendToTextField, ccTextField, subjectTextField, contentTextField;
@synthesize sendIndicator, sendButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if(compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:@"Email"
                                                                content:@"SendEmailViewController"
                                                               stateBar:@"UIStateBar"
                                                        stateBarEnabled:true
                                                                 tabBar:@"UIMainBar"
                                                          tabBarEnabled:true
                                                             fullscreen:false
                                                          landscapeMode:[LinphoneManager runningOnIpad]
                                                           portraitMode:true];
    }
    return compositeDescription;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    account = @"vphonedev@gmail.com";
    password = @"vkx114401";
    mailServer = @"smtp.gmail.com";
    
    contentTextField.layer.borderWidth =1;
    contentTextField.layer.borderColor = [[UIColor blackColor] CGColor];
    // Do any additional setup after loading the view from its nib.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [self setSendToTextField:nil];
    [self setCcTextField:nil];
    [self setSubjectTextField:nil];
    [self setContentTextField:nil];
    [super viewDidUnload];
}

-(void)dismissKeyboard {
    [contentTextField resignFirstResponder];
    [sendToTextField resignFirstResponder];
    [ccTextField resignFirstResponder];
    [subjectTextField resignFirstResponder];
}

- (IBAction)sendEmail:(id)sender {
    sendButton.userInteractionEnabled = NO;
    sendTo = sendToTextField.text;
    subject = subjectTextField.text;
    ccMailList = [ccTextField.text componentsSeparatedByString:@";"];
    mailContent = contentTextField.text;
    
    if ( sendTo == nil || [sendTo isEqualToString:@""]){
        sendButton.userInteractionEnabled = YES;
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Address missing",nil)
														message:NSLocalizedString(@"Address field is empty. Please enter a valid email adress",nil)
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK",nil)
											  otherButtonTitles:nil];
		[error show];
        return;
    }
    
    if (mailContent == nil || [mailContent isEqualToString:@""]){
        sendButton.userInteractionEnabled = YES;
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Empty text mail",nil)
														message:NSLocalizedString(@"You're sending an empty text mail. Are you sure?",nil)
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                                              otherButtonTitles:@"OK", nil];
        [error show];
        return;
    }
    [self sendEmail:sendTo cc:ccMailList withSubject:subject content:mailContent];
}

-(void) sendEmail: (NSString *)toAccount cc:(NSArray *)ccList withSubject:(NSString *)wSubject content:(NSString *)content
{
    
   // toAccount = @"ninhnb88@gmail.com";
   // wSubject = @"test message";
   // content = @"test test test";
  
    [sendIndicator startAnimating];
    sendIndicator.hidden =NO;
    
    MCOSMTPSession *session = [[MCOSMTPSession alloc] init];
    [session setHostname:mailServer];
    [session setPort:465];
    [session setUsername:account];
    [session setPassword:password];
    [session setAuthType:MCOAuthTypeSASLPlain];
    [session setConnectionType:MCOConnectionTypeTLS];
    
    MCOMessageBuilder *builder = [[MCOMessageBuilder alloc] init];
    MCOAddress *from = [MCOAddress addressWithDisplayName:nil mailbox:account];
    MCOAddress *to = [MCOAddress addressWithDisplayName:nil mailbox:toAccount];
    
    [[builder header] setFrom:from];
    [[builder header] setTo:@[to]];
    [[builder header] setSubject:wSubject];
    
    NSMutableArray *cc = [[NSMutableArray alloc] init];
    for(NSString *ccAddress in ccList) {
        MCOAddress *newAddress = [MCOAddress addressWithMailbox:ccAddress];
        [cc addObject:newAddress];
    }
    [[builder header] setCc:cc];
    
    [builder setHTMLBody:content];
    NSData *rfc882Data = [builder data];
    
    MCOSMTPSendOperation *sendOperation = [session sendOperationWithData:rfc882Data];
    [sendOperation start:^(NSError *error){
        if (error){
            [sendIndicator stopAnimating];
            sendIndicator.hidden =YES;
            sendButton.userInteractionEnabled = YES;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            return;
        }
        else {
            [sendIndicator stopAnimating];
            sendIndicator.hidden =YES;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email" message:@"Mail sent" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        sendButton.userInteractionEnabled = YES;
    }];

}
- (IBAction)onCancelClick:(id)sender {
    ccTextField.text = nil;
    subjectTextField.text = nil;
    contentTextField.text = nil;
    [[PhoneMainView instance] changeCurrentView:[ContactsViewController compositeViewDescription]];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
   
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"Cancel"])
        {
            NSLog(@"Sending canceled");
        }
        else if([title isEqualToString:@"OK"])
        {
            [self sendEmail:sendTo cc:ccMailList withSubject:subject content:mailContent];
        }
    
}


@end
