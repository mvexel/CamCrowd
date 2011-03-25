//
//  RootViewController.m
//  CamCrowd
//
//  Created by Martijn van Exel on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "WildcardGestureRecognizer.h"
#import "GTMOAuthAuthentication.h"
#import "GTMOAuthViewControllerTouch.h"

static NSString * const kOSMAppServiceName = @"OSM";

@interface RootViewController()
- (void)signInToOSM;
- (GTMOAuthAuthentication *)osmAuth;
- (void)setAuthentication:(GTMOAuthAuthentication *)auth;
- (void)getUserInfo;
@end

@implementation RootViewController

@synthesize mapView;

- (void)awakeFromNib {

    GTMOAuthAuthentication *auth = [self osmAuth];
    if (auth) {
        BOOL didAuth = [GTMOAuthViewControllerTouch authorizeFromKeychainForName:@"My App: Custom Service"
                                                                  authentication:auth];
        // if the auth object contains an access token, didAuth is now true
        BOOL isSignedIn = [auth canAuthorize]; // returns NO if auth cannot authorize requests
        NSLog(@"did auth: %i / is signed in: %i",didAuth,isSignedIn);
        
        if(!didAuth) {
            [self signInToOSM];
        }
        else
        {
            [self setAuthentication:auth];
            [self getUserInfo];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"CamCrowd";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(addDing:)];
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager startUpdatingLocation];

    WildcardGestureRecognizer * tapInterceptor = [[WildcardGestureRecognizer alloc] init];
    tapInterceptor.touchesBeganCallback = ^(NSSet * touches, UIEvent * event) {
        
    };
    [mapView addGestureRecognizer:tapInterceptor];
    
    [self.navigationController setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark -

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [mapView setRegion:MKCoordinateRegionMakeWithDistance(newLocation.coordinate, newLocation.horizontalAccuracy * 2, newLocation.horizontalAccuracy * 2)];
    [locationManager stopUpdatingLocation];
}

#pragma mark -

-(void)addDing:(id)sender {
    NSLog(@"adding ding");
}

#pragma mark -

- (void)signInToOSM {
    
    NSURL *requestURL = [NSURL URLWithString:@"http://www.openstreetmap.org/oauth/request_token"];
    NSURL *accessURL = [NSURL URLWithString:@"http://www.openstreetmap.org/oauth/access_token"];
    NSURL *authorizeURL = [NSURL URLWithString:@"http://www.openstreetmap.org/oauth/authorize"];
    NSString *scope = @"http://example.com/scope";
    
    GTMOAuthAuthentication *auth = [self osmAuth];
    
    // set the callback URL to which the site should redirect, and for which
    // the OAuth controller should look to determine when sign-in has
    // finished or been canceled
    //
    // This URL does not need to be for an actual web page
    [auth setCallback:@"http://www.example.com/OAuthCallback"];
    
    // Display the autentication view
    GTMOAuthViewControllerTouch *viewController;
    viewController = [[[GTMOAuthViewControllerTouch alloc] initWithScope:scope
                                                                language:nil
                                                         requestTokenURL:requestURL
                                                       authorizeTokenURL:authorizeURL
                                                          accessTokenURL:accessURL
                                                          authentication:auth
                                                          appServiceName:@"My App: Custom Service"
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)] autorelease];
    
    [[self navigationController] pushViewController:viewController
                                           animated:YES];
}


- (GTMOAuthAuthentication *)osmAuth {
    NSString *myConsumerKey = @"BYgJMXj1RImF3hfdXjr0w";
    NSString *myConsumerSecret = @"A8Rm7bkIo13lXO5EaUbQ6oAWziCKcPJGF35s79wclPw";
    
    GTMOAuthAuthentication *auth;
    auth = [[[GTMOAuthAuthentication alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1
                                                        consumerKey:myConsumerKey
                                                         privateKey:myConsumerSecret] autorelease];
    
    // setting the service name lets us inspect the auth object later to know
    // what service it is for
    auth.serviceProvider = @"OpenStreetMap";
    
    return auth;
}

- (void)viewController:(GTMOAuthViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuthAuthentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        // Authentication failed
        NSLog(@"Authentication failed");
    } else {
        NSLog(@"Authentication succeeded");
        [self setAuthentication:auth];
        [self getUserInfo];
    }
}

- (void)setAuthentication:(GTMOAuthAuthentication *)auth {
    [mAuth autorelease];
    mAuth = [auth retain];
}

#pragma mark -

- (void)getUserInfo {
    NSURL *userInfoUrl = [NSURL URLWithString:@"http://api.openstreetmap.org/api/0.6/user/details"];
    NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:userInfoUrl];
    [mAuth authorizeRequest:req];
    NSURLConnection *conn = [NSURLConnection connectionWithRequest:req delegate:self];
    if (conn) {
        receivedData = [[NSMutableData data] retain];
    } else {
        NSLog(@"user details could not be retrieved: connection failed");
    }
}

#pragma mark -

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [receivedData release];
    
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
    NSLog(@"%@",[[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding]);
    xmlParser = [[NSXMLParser alloc] initWithData:receivedData];
    [xmlParser setDelegate:self];
    [xmlParser parse];
    [receivedData release];
}

#pragma mark -

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    if ( [elementName isEqualToString:@"user"]) {
        NSString *thisUser = [attributeDict valueForKey:@"display_name"];
        if (thisUser) {
            userName = thisUser;
            NSLog(@"userName: %@",userName);
            UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"you are signed in as %@",userName] delegate:self cancelButtonTitle:@"That's me!" destructiveButtonTitle:@"Sign out" otherButtonTitles:nil];
            [as showInView:self.view];
        }
    }
}

#pragma mark -

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"dismissed with index %i",buttonIndex);
    switch (buttonIndex) {
        case 0:
            // sign out
            [GTMOAuthViewControllerTouch removeParamsFromKeychainForName:kOSMAppServiceName];
            [self signInToOSM];
            break;
        case 1:
            // OK, do nothing
        default:
            break;
    }
}


@end
