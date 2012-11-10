//
//  TableViewController.m
//  TableViewTest
//
//  Created by Администратор on 24.10.12.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import "TableViewController.h"
#import "EditViewController.h"
#import "TableViewDataSingleton.h"
#import "CellData.h"
#import "TableCell.h"

@implementation TableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

//Добавляем кнопки редактирования таблицы и добаления ячейки
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Table";
    
    UIBarButtonItem *edit =[[[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                             target:self
                             action:@selector(editing)] autorelease];
    self.navigationItem.leftBarButtonItem = edit;
    
    UIBarButtonItem *add =[[[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                             target:self
                             action:@selector(adding)] autorelease];
    self.navigationItem.rightBarButtonItem = add;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// Количество секций в таблице
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//Количество ячеек в таблице
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[TableViewDataSingleton instance] count];
}

//Заполняем таблицу
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"Cell";
    TableCell *cell = (TableCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        UIViewController *tempVC = [[UIViewController alloc] initWithNibName:@"TableCell" bundle:nil];
        cell=(TableCell *)tempVC.view;
        [tempVC release];
    }
    cell.TextLabel.text = [[[TableViewDataSingleton instance] objectAtIndex:indexPath.row] title];
    cell.DateLabel.text = [TableViewDataSingleton stringFromDate:[[[TableViewDataSingleton instance] objectAtIndex:indexPath.row] date]];
    cell.ImageView.image = [[[TableViewDataSingleton instance] objectAtIndex:indexPath.row] image];
    return cell;

}

//Добавление ячейки
- (void) adding {    
    EditViewController *editlViewController = [[EditViewController alloc]
                                               initWithNibName:@"EditViewController" bundle:nil rowToEdit:[[TableViewDataSingleton instance] count] editorMode:EditViewControllerModeAdd];
    [self.navigationController pushViewController:editlViewController animated:YES];
    [editlViewController release];

}

//Ячейки можно перемещать
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//Переключение режимов редактирования таблицы
- (void)editing {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}

//Редактирование таблицы (удаление ячеек)
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[TableViewDataSingleton instance] removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }
}

//Перемещение ячеек
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[TableViewDataSingleton  instance] exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
}

//При выборе ячейки переходим к ее редактированию
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditViewController *editlViewController = [[EditViewController alloc]
                                                   initWithNibName:@"EditViewController" bundle:nil rowToEdit:indexPath.row editorMode:EditViewControllerModeEdit];
    [self.navigationController pushViewController:editlViewController animated:YES];
    [editlViewController release];
}

//Освобождаем ресурсы
- (void)dealloc
{
    [super dealloc];
}

//Обновляем таблицу при появлении данного View 
- (void) viewDidAppear:(BOOL)animated {
    [self.tableView reloadData];
}

// Ограничиваем перенос ячейки до одной строки, иначе порядок в массиве сбивается
- (NSIndexPath *) tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    NSIndexPath *newDestinationIndexPath;
    if (proposedDestinationIndexPath.row > sourceIndexPath.row)
        newDestinationIndexPath = [NSIndexPath indexPathForRow:(sourceIndexPath.row + 1)
                                                     inSection:sourceIndexPath.section];
    else if (proposedDestinationIndexPath.row < sourceIndexPath.row)
        newDestinationIndexPath = [NSIndexPath indexPathForRow:(sourceIndexPath.row - 1)
                                                     inSection:sourceIndexPath.section];
    else
        newDestinationIndexPath = sourceIndexPath;
    
    return newDestinationIndexPath;
}

@end
