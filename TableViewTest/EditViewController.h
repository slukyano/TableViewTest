//
//  EditViewController.h
//  TableViewTest
//
//  Created by Администратор on 24.10.12.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import <UIKit/UIKit.h>

// Определяем набор режимов редактора и тип для них
typedef enum
{
    EditViewControllerModeAdd,
    EditViewControllerModeEdit
} EditViewControllerMode;

@interface EditViewController : UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil rowToEdit:(NSUInteger)row editorMode:(EditViewControllerMode)mode;

@end
