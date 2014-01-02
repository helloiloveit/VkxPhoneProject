//
//  LocationInitiateTest.m
//  Vphone
//
//  Created by NinhNB on 19/10/13.
//
//

#import <XCTest/XCTest.h>
#import "ContactDetailsViewController.h"
#import <objc/runtime.h>
#import "SMMessageDelegate.h"
#import "XMPP.h"
#import "LocationRequestDelegate.h"
#import "LinphoneAppDelegate.h"

@interface LocationFunctionsTest : XCTestCase
{
    ContactDetailsViewController *viewController;
    ContactDetailsTableViewController *tableViewController;
    UITableView *tableView;
    MKMapView *mapView;
    CLLocation *receivedLocation;
    
    UIToggleButton *editButton;
    UIButton *backButton;
    UIButton *cancelButton;
    LinphoneAppDelegate *appDelegate;
    CLLocationManager *locationManager;

    XMPPStream *xmppStream;
    id <SMMessageDelegate> _messageDelegate;
    id <LocationRequestDelegate> _locationRequestDelegate;
    
}

@end

@implementation LocationFunctionsTest

- (void)setUp
{
    [super setUp];
    viewController = [[ContactDetailsViewController alloc]init];
    
    tableViewController = [[ContactDetailsTableViewController alloc] init];
    viewController.tableController = tableViewController;
    tableView = [[UITableView alloc] init];
    tableViewController.tableView = tableView;
    
    mapView = [[MKMapView alloc] init];
    viewController.mapView = mapView;
    receivedLocation = [[CLLocation alloc] init];
    viewController.receivedLocation = receivedLocation;

    viewController.editButton = editButton;
    viewController.backButton = backButton;
    viewController.cancelButton = cancelButton;
    
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    locationManager = [[CLLocationManager alloc] init];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.

}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    viewController = nil;
    tableViewController = nil;
    mapView = nil;
    tableView = nil;
    
    editButton = nil;
    backButton = nil;
    cancelButton = nil;
    [super tearDown];
}

- (void)testViewControllerHasTableController
{
    objc_property_t tableViewControllerProperty = class_getProperty ([viewController class], "tableController");
    XCTAssertTrue(tableViewControllerProperty != NULL, @"ContactDetailsViewController needs a table controller");
}

-(void)testTableControllerHasATableView
{
    objc_property_t tableViewProperty = class_getProperty ([tableViewController class], "tableView");
    XCTAssertTrue(tableViewProperty != NULL, @"ContactDetailsTableViewController needs a table view");
}

-(void)testViewControllerHasAMapView
{
    objc_property_t mapViewProperty = class_getProperty ([viewController class], "mapView");
    XCTAssertTrue(mapViewProperty != NULL, @"ContactDetailsViewController needs a map view");
}

-(void)testViewControllerHasReceivedLocation
{
    objc_property_t locationProperty = class_getProperty ([viewController class], "receivedLocation");
    XCTAssertTrue(locationProperty != NULL, @"ContactDetailsViewController needs receivedLocation");
}

-(void)testViewControllerHasButtons
{
    objc_property_t editButtonProperty = class_getProperty ([viewController class], "editButton");
    XCTAssertTrue(editButtonProperty != NULL, @"ContactDetailsViewController needs editButton");
    
    objc_property_t backButtonProperty = class_getProperty ([viewController class], "backButton");
    XCTAssertTrue(backButtonProperty != NULL, @"ContactDetailsViewController needs backButton");
    
    objc_property_t cancelButtonProperty = class_getProperty ([viewController class], "cancelButton");
    XCTAssertTrue(cancelButtonProperty != NULL, @"ContactDetailsViewController needs cancelButton");
}

-(void)testViewControllerLoadMessageDelegateInViewDidLoad{
    [viewController viewDidLoad];
    XCTAssertEqualObjects(appDelegate._messageDelegate, viewController, @"should load message delegate");
}

-(void)testViewControllerConformsToSMMDelegate{
    XCTAssertTrue([viewController conformsToProtocol:@protocol(SMMessageDelegate)],@"needs to conform to SMMessage protocol") ;
}

-(void)testViewControllerConformsToCLLocationProtocol{
    XCTAssertTrue([viewController conformsToProtocol:@protocol(CLLocationManagerDelegate)], @"needs to conform to CLLocation protocol");
}

-(void)testTableViewControllerLoadDelegate{
    [tableViewController viewDidLoad];
   // XCTAssertEqualObjects(appDelegate._locationRequestDelegate, tableViewController, @"TableViewController should load locationRequestDelegate");
}

#pragma mark - XMPP tests

-(void)testViewControllerAttemptToConnectToXMPPServer{
    [viewController viewWillAppear:YES];
    XCTAssertTrue(appDelegate.xmppStream.isConnecting, @"Should try to connect");
}

-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    if ([[message elementForName:@"body"] stringValue] != nil)
    {
        NSString *msg = [[message elementForName:@"body"] stringValue];
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        [m setObject:msg forKey:@"msg"];
        [appDelegate._messageDelegate newMessageReceived:m];
    }
}

-(void)testReceivedAnswerFromLocationServer{
    
    NSString *messageStr = @"position|answer|1312|21.0333|105.8500|30-12-2013";

    [viewController viewDidLoad];
    
    XMPPMessage *rmsg = [[XMPPMessage alloc] initWithType:@"chat" to:[XMPPJID jidWithString:@"ninhnb@localhost"]];
    
    [rmsg addBody:messageStr];
    
    [self xmppStream:xmppStream didReceiveMessage:rmsg];

    XCTAssertEqual(viewController.receivedLocation.coordinate.latitude, 21.0333, @"Should equal input value");
    XCTAssertEqual(viewController.receivedLocation.coordinate.longitude, 105.8500,@"Should equal input value");
}

@end
