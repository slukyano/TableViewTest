//
//  EditViewController.m
//  TableViewTest
//
//  Created by Администратор on 24.10.12.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import "EditViewController.h"
#import "TableViewController.h"
#import "TableViewDataSingleton.h"

@interface EditViewController ()
{
        UITextField *editField;
        NSUInteger rowCurrentCell;
        EditViewControllerMode editorMode;
}
@end

@implementation EditViewController

// Инициализация - номер строки, режим
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil rowToEdit:(NSUInteger)row editorMode:(EditViewControllerMode)mode
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
        rowCurrentCell = row;
        editorMode = mode;
    }
    
    return self;
}

// Помещаем в текстовое поле значение текущей ячейки и устанавливаем заголовок
- (void)viewDidLoad
{
    [super viewDidLoad];
    editField.text = [[TableViewDataSingleton instance] objectAtIndex:rowCurrentCell];
    
    switch (editorMode) {
        case EditViewControllerModeAdd:
            self.title = @"Add Cell";
            break;
        case EditViewControllerModeEdit:
            self.title = @"Edit Cell";
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Освобождаем ресурсы
- (void)dealloc
{
    [editField release];
    
    [super dealloc];
}

//Сохраняем результаты редактирования при закрытии данного View
- (void) viewDidDisappear:(BOOL)animated {
    if (![editField.text isEqualToString:@""])
        [[TableViewDataSingleton instance] replaceObjectAtIndex:rowCurrentCell withObject:editField.text];
    else
        [[TableViewDataSingleton instance] removeObjectAtIndex:rowCurrentCell];
}

@end
