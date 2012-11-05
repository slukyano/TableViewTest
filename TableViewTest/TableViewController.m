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
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [[[TableViewDataSingleton instance] objectAtIndex:indexPath.row] title];
    return cell;

}

//Добавление ячейки
- (void) adding {
    CellData *cellData = [[CellData alloc] initWithTitle:@"" withDate:nil withImage:nil];
    [[TableViewDataSingleton instance] addObject:cellData];
    [cellData release];
    
    EditViewController *editlViewController = [[EditViewController alloc]
                                               initWithNibName:@"EditViewController" bundle:nil rowToEdit:[[TableViewDataSingleton instance] count]-1 editorMode:EditViewControllerModeAdd];
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

//Обнавляем таблицу при появлении данного View 
- (void) viewDidAppear:(BOOL)animated {
    [self.tableView reloadData];
}

@end
