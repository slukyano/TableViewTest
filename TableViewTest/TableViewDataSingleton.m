//
//  TableViewDataSingleton.m
//  TableViewTest
//
//  Created by LSA on 26/10/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import "TableViewDataSingleton.h"
#import "UserDataLoader.h"

NSString * const userDataXMLPath = @"/Library/userdata.xml";

@interface TableViewDataSingleton ()

- (void) saveDataToXML;
- (BOOL) loadDataFromXML;

@end

@implementation TableViewDataSingleton

@synthesize dataArray;

// Указатель на экземпляр класса
static TableViewDataSingleton *_instance = nil;

// Возвращаем указатель на экземпляр класса; если не создан - инициализируем и загружаем данные из XML; в случае ошибки парсинга - заполняем значениями по умолчанию
+ (TableViewDataSingleton *) instance
{
    @synchronized(self) {
        if (_instance == nil) {
            _instance = [[TableViewDataSingleton alloc] init];
            
            if (![_instance loadDataFromXML]) {
                _instance.dataArray = [NSMutableArray arrayWithObjects:@"object1", @"object2", @"object3", nil];
            }
        }
    }
    
    return _instance;
}

// Дублируем необходимые методы класса NSMutableArray
+ (NSUInteger) count
{
    return [[self instance].dataArray count];
}

+ (id) objectAtIndex:(NSUInteger)index
{
    return [[self instance].dataArray objectAtIndex:index];
}

+ (void) addObject:(id)anObject
{
    [[self instance].dataArray addObject:anObject];
}

+ (void) removeObjectAtIndex:(NSUInteger)index
{
    [[self instance].dataArray removeObjectAtIndex:index];
}

+ (void) exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2
{
    [[self instance].dataArray exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
}

+ (void) replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    [[self instance].dataArray replaceObjectAtIndex:index withObject:anObject];
}

// Сохраняем данные в XML
- (void) dealloc
{
    [self saveDataToXML];
    
    [super dealloc];
}

// Генерируем XML и сохраняем в файл
- (void) saveDataToXML
{
    NSString *xmlString = @"<?xml version=\"1.0\" encoding=\"UTF8\"?>\n<table>\n";
    
    for (int i = 0; i < [_instance.dataArray count]; i++)
    {
        xmlString = [xmlString stringByAppendingFormat:@"<cell title=\"%@\" />\n", [_instance.dataArray objectAtIndex:i]];
    }
    
    xmlString = [xmlString stringByAppendingString:@"</table>"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm createFileAtPath:userDataXMLPath contents:[xmlString dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}

// Запускаем парсер и получаем данные
- (BOOL) loadDataFromXML
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSData *userDataXML = [fm contentsAtPath:userDataXMLPath];
    
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:userDataXML];
    UserDataLoader *dataLoader = [[UserDataLoader alloc] init];
    [xmlParser setDelegate:dataLoader];
    [dataLoader setDelegate:self];
    
    BOOL success = [xmlParser parse];
    
    [dataLoader release];
    
    return success;
}

// Получив сообщение от загрузчика данных, сохраняем массив
- (void) loader:(UserDataLoader *)loader didEndLoadingDataArray:(NSMutableArray *)newDataArray
{
    self.dataArray = [NSMutableArray arrayWithArray:newDataArray];
}

@end
