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
#import "CellData.h"
#import "DataBaseManagerSingleton.h"

@interface TableViewDataSingleton ()

+ (NSString *) dataFilePath:(BOOL)forSave;
- (void) saveDataToXML;
- (BOOL) loadDataFromXML;
- (BOOL) loadDataFromDB;

@end

@implementation TableViewDataSingleton

@synthesize dataArray;

// Указатель на экземпляр класса
static TableViewDataSingleton *_instance;

// Возвращаем указатель на экземпляр класса; если не создан - инициализируем и загружаем данные из XML; в случае ошибки парсинга - заполняем значениями по умолчанию
+ (TableViewDataSingleton *) instance {
    @synchronized(self)
    {
        if (_instance == nil)
        {
            _instance = [[TableViewDataSingleton alloc] init];
            
            if (![_instance loadData])
            {
                NSDate *date = [NSDate date];
                UIImage* image = [UIImage imageNamed:@"defaultImage.png"];
                CellData *cell = [[CellData alloc] initWithTitle:@"defaultcell" withDate:date withImage:image withDataBaseIndex:0];
                _instance.dataArray = [NSMutableArray array];
                [_instance addObject:cell];
                [cell release];
            }
        }
    }
    
    return _instance;
}

// Задаем путь файла
+ (NSString *)dataFilePath:(BOOL)forSave {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentsPath = [documentsDirectory
                               stringByAppendingPathComponent:@"userdata.xml"];
    if (forSave || [[NSFileManager defaultManager] fileExistsAtPath:documentsPath])
        return documentsPath;
    else
        return [[NSBundle mainBundle] pathForResource:@"userdata" ofType:@"xml"];
    
}

// TODO?: перенести в CellData или куда-то еще, тут не к месту. И для XML отдельный класс создать (?)
+ (NSString *) stringFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *string = [dateFormatter stringFromDate:date];
    [dateFormatter release];
    return string;
}

+ (NSDate *) dateFromString:(NSString *)string {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:string];
    [dateFormatter release];
    
    return date;
}

// Дублируем необходимые методы класса NSMutableArray и сохраняем изменения в базе данных или XML
- (NSUInteger) count {
    return [dataArray count];
}

- (id) objectAtIndex:(NSUInteger)index {
    return [dataArray objectAtIndex:index];
}

// Изменяем данные, вызываем методы DataBaseManager или сохраняем в XML; индексы для методов DataBaseManager - индексы базы
// TODO: по возмжности сделать что-нибудь, мне не нравится. Особенно индексы.

- (void) addObject:(id)anObject {
    [dataArray addObject:anObject];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *loader = [defaults stringForKey:@"loader_preference"];
    
    if ([loader isEqualToString:@"SQLite"]) {
        [[DataBaseManagerSingleton instance] addCell:anObject];
        NSLog(@"Add: DB");
    }
    else {
        [self saveData];
    }
}

- (void) removeObjectAtIndex:(NSUInteger)index {
    NSUInteger currentDataBaseIndex = [[dataArray objectAtIndex:index] dataBaseIndex];
    [dataArray removeObjectAtIndex:index];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *loader = [defaults stringForKey:@"loader_preference"];
    
    if ([loader isEqualToString:@"SQLite"]) {
        [[DataBaseManagerSingleton instance] removeCellAtIndex:currentDataBaseIndex];
        NSLog(@"Remove: DB");
    }
    else {
        [self saveData];
    }
}

- (void) exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2 {
    CellData *cell1 = [self objectAtIndex:idx1];
    CellData *cell2 = [self objectAtIndex:idx2];
    
    NSUInteger currentDataBaseIndex1 = [cell1 dataBaseIndex];
    NSUInteger currentDataBaseIndex2 = [cell2 dataBaseIndex];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *loader = [defaults stringForKey:@"loader_preference"];
    
    if ([loader isEqualToString:@"SQLite"]) {
        [[DataBaseManagerSingleton instance] replaceCellAtIndex:currentDataBaseIndex1 withCell:cell2];
        [[DataBaseManagerSingleton instance] replaceCellAtIndex:currentDataBaseIndex2 withCell:cell1];
        NSLog(@"Exchange: DB");
        
        [dataArray exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
    }
    else {
        [dataArray exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
        
        [self saveData];
    }
}

- (void) replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    NSUInteger currentDataBaseIndex = [[self objectAtIndex:index] dataBaseIndex];
    
    [dataArray replaceObjectAtIndex:index withObject:anObject];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *loader = [defaults stringForKey:@"loader_preference"];
    
    if ([loader isEqualToString:@"SQLite"]) {
        [[DataBaseManagerSingleton instance] replaceCellAtIndex:currentDataBaseIndex withCell:anObject];
        NSLog(@"Replace: DB");
    }
    else {
        [self saveData];
    }
}

// Загружаем в зависимости от настроек
-(BOOL)loadData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *loader = [defaults stringForKey:@"loader_preference"];

    if ([loader isEqualToString:@"SQLite"]) {
        NSLog(@"DB");
        return [self loadDataFromDB];
    }
    else if ([loader isEqualToString:@"GDataXML"])
        return [self loadGDataFromXML];
    else if ([loader isEqualToString:@"NSXML"])
            return [self loadDataFromXML];
    
    NSLog(@"Loading error: no loader");
    return NO;
}

// Сохраняем в зависисмости от настроек
-(void) saveData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:@"parse_preference"])
        [self saveGDataToXML];
    else {
        [self saveDataToXML];
    }
}

// Генерируем XML и сохраняем в файл
- (void) saveDataToXML {
    NSString *xmlString = @"<?xml version=\"1.0\" encoding=\"UTF8\"?>\n<table>\n";
    
    for (int i = 0; i < [_instance.dataArray count]; i++) {
        CellData *currentCell = [_instance.dataArray objectAtIndex:i];
        
        xmlString = [xmlString stringByAppendingFormat:@"<cell title=\"%@\">\n", currentCell.title];
        
        NSString *dateString = [TableViewDataSingleton stringFromDate:currentCell.date];
        xmlString = [xmlString stringByAppendingFormat:@"<date>%@</date>\n", dateString];
        
        //NSData *imageData = UIImagePNGRepresentation(currentCell.image);
        //xmlString = [xmlString stringByAppendingFormat:@"<image>%@</image>\n", imageString];
        
        xmlString = [xmlString stringByAppendingFormat:@"</cell>"];
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
    [xmlParser release];
    
    return success;
}

// Получив сообщение от загрузчика данных, сохраняем массив
- (void) loader:(UserDataLoader *)loader didEndLoadingDataArray:(NSMutableArray *)newDataArray {
    self.dataArray = [NSMutableArray arrayWithArray:newDataArray];
}

// Загружаем из xml с помощью GData
- (BOOL)loadGDataFromXML {
    self.dataArray = [[NSMutableArray alloc] init];
    
    NSString *filePath = [TableViewDataSingleton dataFilePath:FALSE];
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    if (doc == nil) {
        [xmlData release];
        return NO;
    }
    
    NSArray *cells = [doc.rootElement elementsForName:@"cell"];
    for (GDataXMLElement *cell in cells) {
        NSString *title = [[cell attributeForName:@"title"]  stringValue];
        
        NSString *dateString = [[[cell elementsForName:@"date"] objectAtIndex:0] stringValue];
        NSDate *date = [TableViewDataSingleton dateFromString:dateString];
        // !!! Работа с изображением
        UIImage* image = [UIImage imageNamed:@"defaultImage.png"];
        CellData *cellData = [[CellData alloc] initWithTitle:title withDate:date withImage:image];
        [self.dataArray addObject:cellData];
        [cellData release];
    }
    
    [doc release];
    [xmlData release];
    
    return YES;
}

// Сохраняем в xml с помощью GData
- (void)saveGDataToXML {
    
    //задаем структуру  xml
    GDataXMLElement * tableElement = [GDataXMLNode elementWithName:@"table"];
    
    for(int i=0; i<self.dataArray.count; i++) {
        CellData *currentCell = [self.dataArray objectAtIndex:i];
        
        NSString *dateString = [TableViewDataSingleton stringFromDate:currentCell.date];
        
        GDataXMLElement *cellElement = [GDataXMLNode elementWithName:@"cell"];
        GDataXMLNode *titleElement = [GDataXMLNode attributeWithName:@"title" stringValue:currentCell.title];
        GDataXMLElement *dateElement = [GDataXMLNode elementWithName:@"date" stringValue:dateString];
        
        // !!! Работа с изображением
        
        [cellElement addAttribute:titleElement];
        [cellElement addChild:dateElement];
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

// Загружаем массив из базы данных
- (BOOL) loadDataFromDB {
    NSMutableArray *dataBaseDataArray = [[DataBaseManagerSingleton instance] dataArrayFromDB];
    
    if (dataBaseDataArray != nil) {
        self.dataArray = [NSMutableArray arrayWithArray:dataBaseDataArray];
        return YES;
    }
    else
        return NO;
}

@end
