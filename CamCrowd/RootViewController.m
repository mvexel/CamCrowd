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

static NSString *const kOSMAppServiceName = @"OAuth Sample: OSM";
static NSString *const kOSMServiceName = @"OpenStreetMap";

@interface RootViewController()
- (void)viewController:(GTMOAuthViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuthAuthentication *)auth
                 error:(NSError *)error;
- (void)incrementNetworkActivity:(NSNotification *)notify;
- (void)decrementNetworkActivity:(NSNotification *)notify;
- (void)signInNetworkLostOrFound:(NSNotification *)notify;
- (GTMOAuthAuthentication *)authForOSM;
@end

@implementation RootViewController

@synthesize mapView;

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
    
    if (![self isSignedIn]) {
        // sign in
        [self signInToOSM];
    } else {
        // sign out
        [self signOut];
    }
    [self updateUI];

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
}

#pragma mark -

-(void)addDing:(id)sender {
    NSLog(@"adding ding");
}

#pragma mark -

- (BOOL)isSignedIn {
    BOOL isSignedIn = [mAuth canAuthorize];
    return isSignedIn;
}

- (void)signOut {    
    [GTMOAuthViewControllerTouch removeParamsFromKeychainForName:kOSMAppServiceName];
    [self setAuthentication:nil];
    
    [self updateUI];
}

- (GTMOAuthAuthentication *)authForOSM {
    NSString *myConsumerKey = @"BYgJMXj1RImF3hfdXjr0w";
    NSString *myConsumerSecret = @"A8Rm7bkIo13lXO5EaUbQ6oAWziCKcPJGF35s79wclPw";
    
    if ([myConsumerKey length] == 0 || [myConsumerSecret length] == 0) {
        return nil;
    }
    
    GTMOAuthAuthentication *auth;
    auth = [[[GTMOAuthAuthentication alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1
                                                        consumerKey:myConsumerKey
                                                         privateKey:myConsumerSecret] autorelease];
    
    // setting the service name lets us inspect the auth object later to know
    // what service it is for
    [auth setServiceProvider:kOSMServiceName];
    
    return auth;
}

- (void)signInToOSM {
    
    [self signOut];
    
    NSURL *requestURL = [NSURL URLWithString:@"http://www.openstreetmap.org/oauth/request_token"];
    NSURL *accessURL = [NSURL URLWithString:@"http://www.openstreetmap.org/oauth/access_token"];
    NSURL *authorizeURL = [NSURL URLWithString:@"http://www.openstreetmap.org/oauth/authorize"];
    NSString *scope = @"http://api.openstreempap.org/";
    
    GTMOAuthAuthentication *auth = [self authForOSM];
    if (auth == nil) {
        // perhaps display something friendlier in the UI?
        NSAssert(NO, @"A valid consumer key and consumer secret are required for signing in to OSM");
    }
    
    // set the callback URL to which the site should redirect, and for which
    // the OAuth controller should look to determine when sign-in has
    // finished or been canceled
    //
    // This URL does not need to be for an actual web page; it will not be
    // loaded
    [auth setCallback:@"http://www.example.com/OAuthCallback"];
    
    NSString *keychainAppServiceName = nil;
    keychainAppServiceName = kOSMServiceName;
    
    // Display the autentication view.
    GTMOAuthViewControllerTouch *viewController;
    viewController = [[[GTMOAuthViewControllerTouch alloc] initWithScope:scope
                                                                language:nil
                                                         requestTokenURL:requestURL
                                                       authorizeTokenURL:authorizeURL
                                                          accessTokenURL:accessURL
                                                          authentication:auth
                                                          appServiceName:keychainAppServiceName
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)] autorelease];
    
    // We can set a URL for deleting the cookies after sign-in so the next time
    // the user signs in, the browser does not assume the user is already signed
    // in
    [viewController setBrowserCookiesURL:[NSURL URLWithString:@"http://api.openstreetmap.org/"]];
    
    // You can set the title of the navigationItem of the controller here, if you want.
    //    navigationController = [[UINavigationController alloc] initWithRootViewController:self];
    //    [navigationController pushViewController:viewController animated:YES];
    [[self navigationController] pushViewController:viewController animated:YES];
    //    [self pushViewController:viewController animated:YES];
}

- (void)setAuthentication:(GTMOAuthAuthentication *)auth {
    [mAuth autorelease];
    mAuth = [auth retain];    
}

- (void)updateUI {
    // update the text showing the signed-in state and the button title
    // A real program would use NSLocalizedString() for strings shown to the user.
    if ([self isSignedIn]) {
    } else {
        // signed out
    }
}


#pragma mark -

- (void)viewController:(GTMOAuthViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuthAuthentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        // Authentication failed (perhaps the user denied access, or closed the
        // window before granting access)
        NSLog(@"Authentication error: %@", error);
        NSData *responseData = [[error userInfo] objectForKey:@"data"]; // kGTMHTTPFetcherStatusDataKey
        if ([responseData length] > 0) {
            // show the body of the server's authentication failure response
            NSString *str = [[[NSString alloc] initWithData:responseData
                                                   encoding:NSUTF8StringEncoding] autorelease];
            NSLog(@"%@", str);
        }
        
        [self setAuthentication:nil];
    } else {
        // Authentication succeeded
        //
        // At this point, we either use the authentication object to explicitly
        // authorize requests, like
        //
        //   [auth authorizeRequest:myNSURLMutableRequest]
        //
        // or store the authentication object into a GTM service object like
        //
        //   [[self contactService] setAuthorizer:auth];
        
        // save the authentication object
        [self setAuthentication:auth];
        
    }
    
    [self updateUI];
}

#pragma mark -

- (void)incrementNetworkActivity:(NSNotification *)notify {
    ++mNetworkActivityCounter;
    if (1 == mNetworkActivityCounter) {
        UIApplication *app = [UIApplication sharedApplication];
        [app setNetworkActivityIndicatorVisible:YES];
    }
}

- (void)decrementNetworkActivity:(NSNotification *)notify {
    --mNetworkActivityCounter;
    if (0 == mNetworkActivityCounter) {
        UIApplication *app = [UIApplication sharedApplication];
        [app setNetworkActivityIndicatorVisible:NO];
    }
}

- (void)signInNetworkLostOrFound:(NSNotification *)notify {
    if ([[notify name] isEqual:kGTMOAuthNetworkLost]) {
        // network connection was lost; alert the user, or dismiss
        // the sign-in view with
        //   [[[notify object] delegate] cancelSigningIn];
    } else {
        // network connection was found again
    }
}

@end
