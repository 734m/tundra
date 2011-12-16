//
//  MainViewController.h
//  tundra
//
//  Created by Brent Fitzgerald on 12/15/11.
//  Copyright (c) 2011 Lumber Labs Inc. All rights reserved.
//

#import "FlipsideViewController.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;
@end
