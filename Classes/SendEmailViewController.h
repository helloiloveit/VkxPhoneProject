//
//  SendEmailViewController.h
//  Vphone
//
//  Created by NinhNB on 25/10/13.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeViewController.h"

@interface SendEmailViewController : UIViewController <UICompositeViewDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *sendTo;
@property (nonatomic, strong) NSString *mailServer;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *mailContent;
@property (nonatomic, strong) NSArray *ccMailList;

@property (strong, nonatomic) IBOutlet UITextView *contentTextField;
@property (strong, nonatomic) IBOutlet UITextField *sendToTextField;
@property (strong, nonatomic) IBOutlet UITextField *ccTextField;
@property (strong, nonatomic) IBOutlet UITextField *subjectTextField;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *sendIndicator;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;

@end
