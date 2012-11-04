//
//  TableViewDataSingleton.m
//  TableViewTest
//
//  Created by LSA on 26/10/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import "TableViewDataSingleton.h"
#import "UserDataLoader.h"
#import "GDataXMLNode.h"

@interface TableViewDataSingleton ()

+ (NSString *) dataFilePath:(BOOL)forSave;
- (void) saveDataToXML;
- (BOOL) loadDataFromXML;

@end

@implementation TableViewDataSingleton

@synthesize dataArray;

// Указатель на экземпляр класса
static TableViewDataSingleton *_instance = nil;

// Возвращаем указатель на экземпляр класса; если не создан - инициализируем и загружаем данные из XML; в случае ошибки парсинга - заполняем значениями по умолчанию
+ (TableViewDataSingleton *) instance {
    @synchronized(self) {
        if (_instance == nil) {
            _instance = [[TableViewDataSingleton alloc] init];
            
            if (![_instance loadData]) {
                _instance.dataArray = [NSMutableArray arrayWithObjects:@"object1", @"object2", @"object3", nil];
            }
        }
    }
    
    return _instance;
}

// Дублируем необходимые методы класса NSMutableArray
- (NSUInteger) count {
    return [dataArray count];
}

- (id) objectAtIndex:(NSUInteger)index {
    return [dataArray objectAtIndex:index];
}

- (void) addObject:(id)anObject {
    [dataArray addObject:anObject];
    [self saveData];
}

- (void) removeObjectAtIndex:(NSUInteger)index {
    [dataArray removeObjectAtIndex:index];
    [self saveData];
}

- (void) exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2 {
    [dataArray exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
    [self saveData];
}

- (void) replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    [dataArray replaceObjectAtIndex:index withObject:anObject];
    [self saveData];
}

// Загружаем в зависимости от настроек: "parse_preference" - "YES" означает предпочтение DOM
-(BOOL)loadData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if ([defaults boolForKey:@"parse_preference"])
        return [self loadGDataFromXML];
    else {
        //NSLog(@"NSXML");
        return [self loadDataFromXML];
    }
}

// Сохраняем в зависисмости от настроек
-(void) saveData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:@"parse_preference"])
        [self saveGDataToXML];
    else {
        //NSLog(@"NSXML");
        [self saveDataToXML];
    }
}

// Генерируем XML и сохраняем в файл
- (void) saveDataToXML {
    NSString *xmlString = @"<?xml version=\"1.0\" encoding=\"UTF8\"?>\n<table>\n";
    
    for (int i = 0; i < [_instance.dataArray count]; i++)
    {
        xmlString = [xmlString stringByAppendingFormat:@"<cell title=\"%@\" />\n", [_instance.dataArray objectAtIndex:i]];
    }
    
    xmlString = [xmlString stringByAppendingString:@"</table>"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm createFileAtPath:[TableViewDataSingleton dataFilePath:YES] contents:[xmlString dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}

// Запускаем парсер и получаем данные
- (BOOL) loadDataFromXML {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSData *userDataXML = [fm contentsAtPath:[TableViewDataSingleton dataFilePath:NO]];
    
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:userDataXML];
    UserDataLoader *dataLoader = [[UserDataLoader alloc] init];
    [xmlParser setDelegate:dataLoader];
    [dataLoader setDelegate:self];
    
    BOOL success = [xmlParser parse];
    
    [dataLoader release];
    
    return success;
}

// Получив сообщение от загрузчика данных, сохраняем массив
- (void) loader:(UserDataLoader *)loader didEndLoadingDataArray:(NSMutableArray *)newDataArray {
    self.dataArray = [NSMutableArray arrayWithArray:newDataArray];
}

// Задаем путь файла
+ (NSString *)dataFilePath:(BOOL)forSave {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentsPath = [documentsDirectory
                               stringByAppendingPathComponent:@"userdata.xml"];
    if (forSave ||
        [[NSFileManager defaultManager] fileExistsAtPath:documentsPath]) {
        return documentsPath;
    } else {
        return [[NSBundle mainBundle] pathForResource:@"userdata" ofType:@"xml"];
    }
    
}

// Загружаем из xml с помощью GData
- (BOOL)loadGDataFromXML {
    self.dataArray = [[NSMutableArray alloc] init];
    NSString *filePath = [TableViewDataSingleton dataFilePath:FALSE];
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    if (doc == nil)
        return false;
    
    NSArray *cells = [doc.rootElement elementsForName:@"cell"];
    for (GDataXMLElement *cell in cells) {
            NSString *title = [[cell attributeForName:@"title"]  stringValue];
        [self.dataArray addObject:title];
    }
    [doc release];
    [xmlData release];
    
    return true;
}

// Сохраняем в xml с помощью GData
- (void)saveGDataToXML {
    
    //задаем структуру  xml
    GDataXMLElement * tableElement = [GDataXMLNode elementWithName:@"table"];
    
    for(int i=0; i<self.dataArray.count; i++) {
        
        GDataXMLElement * cellElement =
        [GDataXMLNode elementWithName:@"cell"];
        
        GDataXMLNode *titleElement = [GDataXMLNode attributeWithName:@"title" stringValue:[self.dataArray objectAtIndex:i]];
        
        [cellElement addAttribute:titleElement];
        [tableElement addChild:cellElement];
    }
    
    //непосредственно сохраняем
    GDataXMLDocument *document = [[[GDataXMLDocument alloc]
                                   initWithRootElement:tableElement] autorelease];
    NSData *xmlData = document.XMLData;
    
    NSString *filePath = [TableViewDataSingleton dataFilePath:TRUE];
    
    NSLog(@"Saving xml data to %@...", filePath);
    [xmlData writeToFile:filePath atomically:YES];
    
}

@end
