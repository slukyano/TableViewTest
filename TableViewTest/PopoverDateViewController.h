//
//  PopoverDateViewController.h
//  TableViewTest
//
//  Created by Администратор on 05.11.12.
//  Copyright (c) 2012 Администратор. All rights reserved.
//
#import <UIKit/UIKit.h>

@protocol DataPickerDelegate
- (void)dateSelected:(NSDate *)newDate;
@end

@interface PopoverDateViewController : UIViewController {
    id<DataPickerDelegate> _delegate;
    IBOutlet UIDatePicker *datepick;
}

@property (nonatomic, assign) id<DataPickerDelegate> delegate;
- (IBAction)changeDateButton;
@end
