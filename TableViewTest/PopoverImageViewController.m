//
//  PopoverImageViewController.m
//  TableViewTest
//
//  Created by Администратор on 07.11.12.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import "PopoverImageViewController.h"

@interface PopoverImageViewController ()

@end

@implementation PopoverImageViewController
@synthesize delegate = _delegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.contentSizeForViewInPopover = CGSizeMake(400.0, 260.0);
    // Do any additional setup after loading the view from its nib.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

