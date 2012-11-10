//
//  EditViewController.h
//  TableViewTest
//
//  Created by Администратор on 24.10.12.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopoverDateViewController.h"
//#import "PopoverImageViewController.h"
// Определяем набор режимов редактора и тип для них
typedef enum
{
    EditViewControllerModeAdd,
    EditViewControllerModeEdit
} EditViewControllerMode;

@interface EditViewController : UIViewController <DataPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    PopoverDateViewController *_datePicker;
    UIPopoverController *_datePickerPopover;
    UIImagePickerController *_imagePicker;
    UIPopoverController *_imagePickerPopover;
}
@property (nonatomic, retain) PopoverDateViewController *datePicker;
@property (nonatomic, retain) UIPopoverController *datePickerPopover;
@property (nonatomic, retain) UIImagePickerController *imagePicker;
@property (nonatomic, retain) UIPopoverController *imagePickerPopover;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil rowToEdit:(NSUInteger)row editorMode:(EditViewControllerMode)mode;

- (IBAction)DateButtonTapped:(id)sender;
- (IBAction)ImageButtonTapped:(id)sender;
@end
