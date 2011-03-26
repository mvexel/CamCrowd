//
//  AddCameraFirstViewController.m
//  CamCrowd
//
//  Created by Martijn van Exel on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddCameraFirstViewController.h"

@interface AddCameraFirstViewController()
-(void)cancelAdd:(id)sender;
-(void)addDone:(id)sender;
@end

@implementation AddCameraFirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAdd:)];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(addDone:)];
    [[self navigationItem] setLeftBarButtonItem:cancelItem];
    [[self navigationItem] setRightBarButtonItem:doneItem];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -

-(void)cancelAdd:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)addDone:(id)sender {
    NSLog(@"done,save");
}


@end
