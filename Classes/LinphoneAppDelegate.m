/* LinphoneAppDelegate.m
 *
 * Copyright (C) 2009  Belledonne Comunications, Grenoble, France
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or   
 *  (at your option) any later version.                                 
 *                                                                      
 *  This program is distributed in the hope that it will be useful,     
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of      
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the       
 *  GNU General Public License for more details.                
 *                                                                      
 *  You should have received a copy of the GNU General Public License   
 *  along with this program; if not, write to the Free Software         
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */                                                                           

#import "PhoneMainView.h"
#import "linphoneAppDelegate.h"
#import "AddressBook/ABPerson.h"

#import "CoreTelephony/CTCallCenter.h"
#import "CoreTelephony/CTCall.h"

#import "ConsoleViewController.h"
#import "LinphoneCoreSettingsStore.h"

#include "LinphoneManager.h"
#include "linphonecore.h"
#import "ldapTest.h"
@implementation UILinphoneWindow

@end

@implementation LinphoneAppDelegate{
    CLLocationManager *locationManager;
}

@synthesize started;


#pragma mark - Lifecycle Functions

- (id)init {
    self = [super init];
    if(self != nil) {
        self->started = FALSE;
    }
    return self;
}

- (void)dealloc {
	[super dealloc];
}


#pragma mark - 



- (void)applicationDidEnterBackground:(UIApplication *)application{
	[LinphoneLogger logc:LinphoneLoggerLog format:"applicationDidEnterBackground"];
	if(![LinphoneManager isLcReady]) return;
	[[LinphoneManager instance] enterBackgroundMode];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[LinphoneLogger logc:LinphoneLoggerLog format:"applicationWillResignActive"];
    if(![LinphoneManager isLcReady]) return;
    LinphoneCore* lc = [LinphoneManager getLc];
    LinphoneCall* call = linphone_core_get_current_call(lc);
	
	
    if (call){
		/* save call context */
		LinphoneManager* instance = [LinphoneManager instance];
		instance->currentCallContextBeforeGoingBackground.call = call;
		instance->currentCallContextBeforeGoingBackground.cameraIsEnabled = linphone_call_camera_enabled(call);
    
		const LinphoneCallParams* params = linphone_call_get_current_params(call);
		if (linphone_call_params_video_enabled(params)) {
			linphone_call_enable_camera(call, false);
		}
	}
    
    if (![[LinphoneManager instance] resignActive]) {

    }
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[LinphoneLogger logc:LinphoneLoggerLog format:"applicationDidBecomeActive"];
    [self startApplication];
    
	[[LinphoneManager instance] becomeActive];
    
    
    LinphoneCore* lc = [LinphoneManager getLc];
    LinphoneCall* call = linphone_core_get_current_call(lc);
    
	if (call){
		LinphoneManager* instance = [LinphoneManager instance];
		if (call == instance->currentCallContextBeforeGoingBackground.call) {
			const LinphoneCallParams* params = linphone_call_get_current_params(call);
			if (linphone_call_params_video_enabled(params)) {
				linphone_call_enable_camera(
                                        call, 
                                        instance->currentCallContextBeforeGoingBackground.cameraIsEnabled);
			}
			instance->currentCallContextBeforeGoingBackground.call = 0;
		}
	}
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge];
    
	//work around until we can access lpconfig without linphonecore
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"YES", @"start_at_boot_preference",
								 @"YES", @"backgroundmode_preference",
#ifdef DEBUG
								 @"YES",@"debugenable_preference",
#else
								 @"NO",@"debugenable_preference",
#endif
                                 nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
	
    if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]
		&& [UIApplication sharedApplication].applicationState ==  UIApplicationStateBackground
        && (![[NSUserDefaults standardUserDefaults] boolForKey:@"start_at_boot_preference"] ||
            ![[NSUserDefaults standardUserDefaults] boolForKey:@"backgroundmode_preference"])) {
            // autoboot disabled, doing nothing
            return YES;
        }
    
    [self startApplication];
	NSDictionary *remoteNotif =[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotif){
		[LinphoneLogger log:LinphoneLoggerLog format:@"PushNotification from launch received."];
		[self processRemoteNotification:remoteNotif];
	}
   // test_all_ldap(NULL);
    
    return YES;
}

- (void)startApplication {
    // Restart Linphone Core if needed
    if(![LinphoneManager isLcReady]) {
        [[LinphoneManager instance]	startLibLinphone];
    }
    if([LinphoneManager isLcReady]) {
        
        
        // Only execute one time at application start
        if(!started) {
            started = TRUE;
            [[PhoneMainView instance] startUp];
            
            // reporting GPS location
        /*     dispatch_queue_t locationQueue = dispatch_queue_create("locationQueue", NULL);
             dispatch_async(locationQueue, ^{
                while(1){
                    locationManager = [[CLLocationManager alloc] init];
                    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                    locationManager.distanceFilter = 10;
                    [locationManager startUpdatingLocation];
                    
                    if ([self.xmppStream isAuthenticated]){
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"dd.MM.YY HH:mm:ss"];
                        NSString *dateString = [dateFormatter stringFromDate:locationManager.location.timestamp];
                        
                        if (locationManager.location != nil){
                            NSString *currentLocation = [NSString stringWithFormat:@"%f|%f|%@",
                                                                locationManager.location.coordinate.latitude,
                                                                locationManager.location.coordinate.longitude,
                                                                dateString];
                            [self xmppLocationReport:currentLocation];
                        }
             
                    [NSThread sleepForTimeInterval:1800];
                    }
                    else
                        [NSThread sleepForTimeInterval:10];
                
                    [locationManager stopUpdatingLocation];
                    
                }
             });*/
            //end reporting GPS location
        }
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
	
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    [self startApplication];
    if([LinphoneManager isLcReady]) {
        if([[url scheme] isEqualToString:@"sip"]) {
            // Go to ChatRoom view
            DialerViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[DialerViewController compositeViewDescription]], DialerViewController);
            if(controller != nil) {
                [controller setAddress:[url absoluteString]];
            }
        }
    }
	return YES;
}

- (void)processRemoteNotification:(NSDictionary*)userInfo{
	NSDictionary *aps = [userInfo objectForKey:@"aps"];
    if(aps != nil) {
        NSDictionary *alert = [aps objectForKey:@"alert"];
        if(alert != nil) {
            NSString *loc_key = [alert objectForKey:@"loc-key"];
			/*if we receive a remote notification, it is because our TCP background socket was no more working.
			 As a result, break it and refresh registers in order to make sure to receive incoming INVITE or MESSAGE*/
			LinphoneCore *lc = [LinphoneManager getLc];
			linphone_core_set_network_reachable(lc, FALSE);
			linphone_core_set_network_reachable(lc, TRUE);
            if(loc_key != nil) {
                if([loc_key isEqualToString:@"IM_MSG"]) {
                    [[PhoneMainView instance] addInhibitedEvent:kLinphoneTextReceived];
                    [[PhoneMainView instance] changeCurrentView:[ChatViewController compositeViewDescription]];
                } else if([loc_key isEqualToString:@"IC_MSG"]) {
                    //it's a call
					NSString *callid=[userInfo objectForKey:@"call-id"];
                    if (callid)
						[[LinphoneManager instance] enableAutoAnswerForCallId:callid];
					else
						[LinphoneLogger log:LinphoneLoggerError format:@"PushNotification: does not have call-id yet, fix it !"];
                }
            }
        }
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	[LinphoneLogger log:LinphoneLoggerLog format:@"PushNotification: Receive %@", userInfo];
	[self processRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if([notification.userInfo objectForKey:@"callId"] != nil) {
        [[LinphoneManager instance] acceptCallForCallId:[notification.userInfo objectForKey:@"callId"]];
    } else if([notification.userInfo objectForKey:@"chat"] != nil) {
        NSString *remoteContact = (NSString*)[notification.userInfo objectForKey:@"chat"];
        // Go to ChatRoom view
        [[PhoneMainView instance] changeCurrentView:[ChatViewController compositeViewDescription]];
        ChatRoomViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[ChatRoomViewController compositeViewDescription] push:TRUE], ChatRoomViewController);
        if(controller != nil) {
            [controller setRemoteAddress:remoteContact];
        }
    } else if([notification.userInfo objectForKey:@"callLog"] != nil) {
        NSString *callLog = (NSString*)[notification.userInfo objectForKey:@"callLog"];
        // Go to HistoryDetails view
        [[PhoneMainView instance] changeCurrentView:[HistoryViewController compositeViewDescription]];
        HistoryDetailsViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[HistoryDetailsViewController compositeViewDescription] push:TRUE], HistoryDetailsViewController);
        if(controller != nil) {
            [controller setCallLogId:callLog];
        }
    }
}


#pragma mark - PushNotification Functions

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    [LinphoneLogger log:LinphoneLoggerLog format:@"PushNotification: Token %@", deviceToken];
    [[LinphoneManager instance] setPushNotificationToken:deviceToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    [LinphoneLogger log:LinphoneLoggerError format:@"PushNotification: Error %@", [error localizedDescription]];
    [[LinphoneManager instance] setPushNotificationToken:nil];
}

#pragma mark - Location Server

@synthesize xmppStream;
@synthesize _messageDelegate;
@synthesize _contactDelegate;
//@synthesize _locationRequestDelegate;
/*
-(void) setupStream {
    NSLog(@"setting up stream\n\n\n");
    xmppStream = [[XMPPStream alloc] init];
    [xmppStream setHostName:@"124.46.127.179"];
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
}*/

-(void) goOnline{
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
}

-(void) goOffline{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}

-(BOOL) connect:(NSString *) data{
   // setupStream
    NSString *jabberID = [[NSUserDefaults standardUserDefaults] stringForKey:@"userID"];
    NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"userPassword"];
    
    NSString *server = [[data componentsSeparatedByString:@"|"] objectAtIndex:2];
    
    myPassword = [[data componentsSeparatedByString:@"|"] objectAtIndex:1];
    jabberID = [[[data componentsSeparatedByString:@"|"] objectAtIndex:0] stringByAppendingString:[@"@" stringByAppendingString:@"124.46.127.179"]];
  /*
    server = @"localhost";
    jabberID = @"ninhnb2@localhost";
    myPassword = @"admin";
    */
    
    InfoLog(@"XMPP server = %@", server);
    InfoLog(@"XMPP account = %@", jabberID);
    InfoLog(@"XMPP passw = %@", myPassword);
    xmppStream = [[XMPPStream alloc] init];
    [xmppStream setHostName:server];
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    if (![xmppStream isDisconnected]){
        return YES;
    }
    if (jabberID ==nil || myPassword == nil){
        return NO;
    }
    
    [xmppStream setMyJID:[XMPPJID jidWithString:jabberID]];
    password = [myPassword copy];
    NSError *error = nil;
    
   [xmppStream connectWithTimeout:20 error:&error];
   /* if (data == nil) {
        isRequest = YES;
    }else {
        locationData = data;
    }*/
    return YES;
}

-(void) disconnect{
    [self goOffline];
    [xmppStream disconnect];
    NSLog(@"XMPPStream disconnected");
}


-(void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSError *error = nil;
    [[self xmppStream] authenticateWithPassword:password error:&error];
}

-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    [self goOnline];
    NSLog(@"Stream authenticated");
    
    /*//old location
     
    if (isRequest){
        [_locationRequestDelegate locationRequest];
        isRequest = NO;
    }
    else{
      
        // NSString *userID = [self.userManipulatedData[@"userID"] lastObject];
         NSString *messageStr = [@"position|send|" stringByAppendingString:locationData];
        
        XMPPMessage *msg = [[XMPPMessage alloc] initWithType:@"chat" to:[XMPPJID jidWithString:@"1045@124.46.127.179"]];
        [msg addBody:messageStr];
        [self.xmppStream sendElement: msg];
      //  NSLog(@"Message sent \n\n");
      //  [self disconnect];
   
    }
    //end old location
    */
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    if (error!=nil){
   //     NSLog(@"error =   %@",[error localizedDescription]);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"XMPP server"
                                                            message:[error localizedDescription]
                                                           delegate:nil cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
    }
}

-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    if ([[message elementForName:@"body"] stringValue] != nil)
    {
        if ([[[message elementForName:@"body"] stringValue] hasPrefix:@"position|"])
        {
            NSString *msg = [[message elementForName:@"body"] stringValue];
            NSString *from = [[message attributeForName:@"from"] stringValue];
            NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
            [m setObject:msg forKey:@"msg"];
            [m setObject:from forKey:@"sender"];
            [_messageDelegate newMessageReceived:m];
        }
        else if ([[[message elementForName:@"body"] stringValue] hasPrefix:@"chat|"])
        {
        }
    }
}

@synthesize _chatDelegate;

-(void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    NSString *presenceType = [presence type];
    NSString *myUsername = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];
    if (![presenceFromUser isEqualToString:myUsername]);
    {
        if ([presenceType isEqualToString:@"available"]){
            [_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, xmppStream.hostName]];
        }
        else if ([presenceType isEqualToString:@"unavailable"]){
            [_chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, xmppStream.hostName]];
        }
    }
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    [settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
}

-(void)xmppLocationReport:(NSString *) locationData {
 //   LinphoneAddress* linphoneAddress = linphone_address_new(linphone_core_get_identity([LinphoneManager getLc]));
   // NSString *server = [NSString stringWithUTF8String:linphone_address_get_domain(linphoneAddress)];
    //NSString *locationServer = [@"location@" stringByAppendingString:server];
    NSString *locationServer = @"location@124.46.127.179";
    
    LinphoneAuthInfo *ai;
    const MSList *elem=linphone_core_get_auth_info_list([LinphoneManager getLc]);
    if (elem && (ai=(LinphoneAuthInfo*)elem->data)){
        NSString *username = [NSString stringWithUTF8String:linphone_auth_info_get_username(ai)];
        locationData = [NSString stringWithFormat:@"%@|%@", username, locationData];
    }
    else
    {
        InfoLog(@"Failed sending location");
        return;
    }
    
    NSString *messageStr = [@"position|send|" stringByAppendingString:locationData];
    XMPPMessage *msg = [[XMPPMessage alloc] initWithType:@"chat" to:[XMPPJID jidWithString:locationServer]];
    [msg addBody:messageStr];
    [self.xmppStream sendElement: msg];
}
@end
