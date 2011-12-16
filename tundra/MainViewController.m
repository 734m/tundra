//
//  MainViewController.m
//  tundra
//
//  Created by Brent Fitzgerald on 12/15/11.
//  Copyright (c) 2011 Lumber Labs Inc. All rights reserved.
//

#import "MainViewController.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>

@interface MainViewController () {
  AVCaptureSession *torchSession;
  AVCaptureDevice *device;
  CMMotionManager *motionManager;
  NSOperationQueue  *opQ;
  CMGyroHandler gyroHandler;
  
}
@property (nonatomic, retain) AVCaptureSession * torchSession;
@property (nonatomic, retain) AVCaptureDevice * device;
@property (nonatomic, retain) CMMotionManager *motionManager;
@property (nonatomic, retain) NSOperationQueue *opQ;
@property (nonatomic, retain) CMGyroHandler gyroHandler;
- (void) toggleTorch;

@end

@implementation MainViewController

@synthesize flipsidePopoverController = _flipsidePopoverController;
@synthesize torchSession;
@synthesize device;
@synthesize motionManager;
@synthesize opQ;
@synthesize gyroHandler;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (BOOL)canBecomeFirstResponder {
  return YES;
}


- (void)viewDidLoad
{
  [super viewDidLoad];
  [self becomeFirstResponder];
  self.view.backgroundColor = [UIColor blackColor];
  
  [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
  
  Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
  if (captureDeviceClass != nil) 
	{
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch] && [device hasFlash] && device.torchMode == AVCaptureTorchModeOff)
		{
			AVCaptureDeviceInput* deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error: nil];
			AVCaptureVideoDataOutput* videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
      
			AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
      
			[captureSession beginConfiguration];
			[device lockForConfiguration:nil];
      
			[captureSession addInput:deviceInput];
			[captureSession addOutput:videoDataOutput];
      
			[device unlockForConfiguration];
      
      
			[captureSession commitConfiguration];
			[captureSession startRunning];
      
			self.torchSession = captureSession;
    }
		else {
			NSLog(@"Torch not available, hasFlash: %d hasTorch: %d torchMode: %d", 
            device.hasFlash,
            device.hasTorch,
            device.torchMode
            );
		}
    
  }
	else {
		NSLog(@"Torch not available, AVCaptureDevice class not found.");
	}
  
  
  // Set up motion
  
  motionManager = [[CMMotionManager alloc] init];
  motionManager.gyroUpdateInterval = 1.0/60.0;
  if (motionManager.gyroAvailable) {
    opQ = [NSOperationQueue currentQueue];
    gyroHandler = ^ (CMGyroData *gyroData, NSError *error) {
      CMRotationRate rotate = gyroData.rotationRate;
      NSLog(@"%f, %f, %f", rotate.x, rotate.y, rotate.z);
      if(fabs(rotate.y) > 1.0) {
        [self start:self];
      } else {
        [self stop:self];
      }
      // handle rotation-rate data here......
    };
  } else {
    NSLog(@"No gyroscope on device.");
  }
  [motionManager startGyroUpdatesToQueue:opQ withHandler:gyroHandler];
  
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return NO;
}

- (void)viewDidUnload
{
  [motionManager stopGyroUpdates];

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
      return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  } else {
      return YES;
  }
}

#pragma mark - torch stuff

- (IBAction)start:(id)sender {
  self.view.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
  NSLog(@"start");
	Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
	if (captureDeviceClass != nil) {
    
		[device lockForConfiguration:nil];
    
		[device setTorchMode:AVCaptureTorchModeOn];
		[device setFlashMode:AVCaptureFlashModeOn];
    
		[device unlockForConfiguration];
    
	}	
}

- (IBAction)stop:(id)sender {
  self.view.backgroundColor = [UIColor blackColor];
  NSLog(@"stop");
	Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
	if (captureDeviceClass != nil) 
	{
		[device lockForConfiguration:nil];
    
		[device setTorchMode:AVCaptureTorchModeOff];
		[device setFlashMode:AVCaptureFlashModeOff];
    
		[device unlockForConfiguration];
  }	
}

- (void)toggleTorch {
  [device lockForConfiguration:nil];
  [device setTorchMode:AVCaptureTorchModeOn];
  [device setFlashMode:AVCaptureFlashModeOn];
  [device unlockForConfiguration];
}

#pragma mark - motion

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
  [self start:self];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
  [self stop:self];
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
  [self stop:self];
}



#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}

@end
