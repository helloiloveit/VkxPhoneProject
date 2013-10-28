//
//  SendEmailViewController.h
//  Vphone
//
//  Created by NinhNB on 25/10/13.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeViewController.h"

@interface SendEmailViewController : UIViewController <UICompositeViewDelegate>

@property (nonatomic, retain) NSString *account;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *sendTo;
@property (nonatomic, retain) NSString *mailServer;
@property (nonatomic, retain) NSString *subject;
@property (nonatomic, retain) NSString *mailContent;
@property (nonatomic, retain) NSArray *ccMailList;

@property (retain, nonatomic) IBOutlet UITextView *contentTextField;
@property (retain, nonatomic) IBOutlet UITextField *sendToTextField;
@property (retain, nonatomic) IBOutlet UITextField *ccTextField;
@property (retain, nonatomic) IBOutlet UITextField *subjectTextField;

@end
