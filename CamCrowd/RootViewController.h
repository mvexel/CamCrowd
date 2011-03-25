//
//  RootViewController.h
//  CamCrowd
//
//  Created by Martijn van Exel on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class GTMOAuthAuthentication;

@interface RootViewController : UIViewController<CLLocationManagerDelegate,UINavigationControllerDelegate,NSXMLParserDelegate,UIActionSheetDelegate> {
    MKMapView *mapView;
    CLLocationManager *locationManager;
    GTMOAuthAuthentication *mAuth;
    NSMutableData *receivedData;
    NSXMLParser *xmlParser;
    NSString *userName;
}

@property (nonatomic,retain) IBOutlet MKMapView *mapView;

@end
