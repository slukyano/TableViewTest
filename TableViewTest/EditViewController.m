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
#import "CellData.h"
@interface EditViewController ()
{
        IBOutlet UITextField *editField;
        IBOutlet UILabel *dateLabel;
        IBOutlet UIImageView *imageView;
        NSUInteger rowCurrentCell;
        EditViewControllerMode editorMode;
}
@end

@implementation EditViewController

@synthesize datePicker = _datePicker;
@synthesize datePickerPopover = _datePickerPopover;
@synthesize imagePicker = _imagePicker;
@synthesize imagePickerPopover = _imagePickerPopover;

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
    //choosenDate = [[[TableViewDataSingleton instance] objectAtIndex:rowCurrentCell] date];
    
    switch (editorMode) {
        case EditViewControllerModeAdd:
            self.title = @"Add Cell";
            editField.text = @"";
            dateLabel.text = [TableViewDataSingleton stringFromDate:[NSDate date]];
            imageView.image = [UIImage imageNamed:@"defaultImage.png"];
            break;
        case EditViewControllerModeEdit:
            self.title = @"Edit Cell";
            editField.text = [[[TableViewDataSingleton instance] objectAtIndex:rowCurrentCell] title];
            dateLabel.text = [TableViewDataSingleton stringFromDate:[[[TableViewDataSingleton instance] objectAtIndex:rowCurrentCell] date]];
            imageView.image = [[[TableViewDataSingleton instance] objectAtIndex:rowCurrentCell] image];
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
    [dateLabel release];
    [imageView release];
    
    [super dealloc];
}

//Сохраняем результаты редактирования при закрытии данного View
- (void) viewDidDisappear:(BOOL)animated {
    if (![editField.text isEqualToString:@""])
    {
        CellData *cellData = [[CellData alloc] initWithTitle:editField.text
                                                    withDate:[TableViewDataSingleton dateFromString:dateLabel.text]
                                                   withImage:imageView.image];
        switch (editorMode) {
            case EditViewControllerModeAdd:
                self.title = @"Add Cell";
                [[TableViewDataSingleton instance] addObject:cellData];
                break;
            case EditViewControllerModeEdit:
                self.title = @"Edit Cell";
                [[TableViewDataSingleton instance] replaceObjectAtIndex:rowCurrentCell
                                                             withObject:cellData];
                break;
            default:
                break;
        }
        [cellData release];
    }
    else
        if (editorMode == EditViewControllerModeEdit)
            [[TableViewDataSingleton instance] removeObjectAtIndex:rowCurrentCell];
}

- (void) dateSelected:(NSDate *)newDate {
    dateLabel.text = [TableViewDataSingleton stringFromDate:newDate];
    [self.datePickerPopover dismissPopoverAnimated:YES];
}

- (IBAction) DateButtonTapped:(id)sender {
    if (_datePicker == nil) {
        PopoverDateViewController *newPopoverDateViewController = [[PopoverDateViewController alloc] initWithNibName:@"PopoverDateViewController" bundle:nil];
        self.datePicker = newPopoverDateViewController;
        [newPopoverDateViewController release];
        _datePicker.delegate = self;
        
        UIPopoverController *newUIPopoverController = [[UIPopoverController alloc] initWithContentViewController:_datePicker];
        self.datePickerPopover = newUIPopoverController;
        [newUIPopoverController release];
    }
    [self.datePickerPopover presentPopoverFromRect:((UIButton *)sender).frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

}

- (IBAction)ImageButtonTapped:(id)sender {
    if (_imagePicker == nil) {
        UIImagePickerController *newUIImagePickerController = [[UIImagePickerController alloc] init];
        self.imagePicker = newUIImagePickerController;
        [newUIImagePickerController release];
        _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _imagePicker.delegate = self;
        
        UIPopoverController *newUIPopoverController = [[UIPopoverController alloc] initWithContentViewController:_imagePicker];
        self.imagePickerPopover = newUIPopoverController;
        [newUIPopoverController release];
    }
    [self.imagePickerPopover presentPopoverFromRect:((UIButton *)sender).frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    imageView.image = image; 
    [self.imagePickerPopover dismissPopoverAnimated:YES];
    
}
@end
