//
//  DataBaseManagerSingleton.m
//  TableViewTest
//
//  Created by LSA on 07/11/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import <sqlite3.h>
#import <stdio.h>
#import <stdlib.h>
#import "DataBaseManagerSingleton.h"
#import "TableViewDataSingleton.h"
#import "CellData.h"

@interface DataBaseManagerSingleton ()

+ (NSString *) dataBasePath:(BOOL)forSave;
- (void) addCell:(CellData *)cell withIndex:(NSUInteger)index;

@end

@implementation DataBaseManagerSingleton

static DataBaseManagerSingleton *_instance;
// Счетчик выделенных ячеек за все время существования базы
static NSUInteger rowCounter;

static int setRowCounterCallback(void *rowCounterPointer, int numberOfColumns, char **columnText, char **columnNames);

+ (DataBaseManagerSingleton *) instance {
    if (_instance == nil)
    {
        _instance = [[DataBaseManagerSingleton alloc] init];
    }
    
    return _instance;
}

+ (NSString *) dataBasePath:(BOOL)forSave {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentsPath = [documentsDirectory stringByAppendingPathComponent:@"userdb.sqlite3"];
    if (forSave || [[NSFileManager defaultManager] fileExistsAtPath:documentsPath])
        return documentsPath;
    else
        return [[NSBundle mainBundle] pathForResource:@"userdb" ofType:@"sqlite3"];
}

- (id) init {
    self = [super init];
    
    if (self) {
        sqlite3 *db = 0;
        const char *dbPath = [[DataBaseManagerSingleton dataBasePath:YES] UTF8String];
        char *err = 0;
    
        if (sqlite3_open(dbPath, &db))
            NSLog(@"DB: open error");
        
        //const char *droptable = "DROP TABLE IF EXISTS Cells";
        /*if (sqlite3_exec(db, droptable, nil, nil, &err)) {
            printf("%s", err);
            sqlite3_free(err);
        }*/
        
        const char *createTable = "CREATE TABLE IF NOT EXISTS Cells(title, date, image, rowNumber);";
        if (sqlite3_exec(db, createTable, nil, nil, &err)) {
            NSLog(@"%s", err);
            sqlite3_free(err);
        }
        
        // Восстанавливаем счетчик созданных записей
        // TODO: exec заменить на get_table или prepare-step-finalize      
        const char *selectMaxRowNumber = "SELECT MAX(rowNumber) FROM Cells;";
        if (sqlite3_exec(db, selectMaxRowNumber, &setRowCounterCallback, &rowCounter, &err)) {
            NSLog(@"%s", err);
            sqlite3_free(err);
        }
        
        if (sqlite3_close(db))
            NSLog(@"DB: close error");
    }
    
    return self;
}

// callback-функция для восстановления счетчика
static int setRowCounterCallback(void *rowCounterPointer,
                                 int numberOfColumns,
                                 char **columnText,
                                 char **columnNames) {
    rowCounter = (columnText[0] != nil) ? (atoi(columnText[0]) + 1) : 0;
    
    return 0;
}

// Снаружи ячейки добавляются только на вершину
- (void) addCell:(CellData *)cell {
    [self addCell:cell withIndex:rowCounter];
    rowCounter++;
}

// Изнутри - в любое место (для реализации replace и exchange)
- (void) addCell:(CellData *)cell withIndex:(NSUInteger)index {
    sqlite3 *db = 0;
    const char *dbPath = [[DataBaseManagerSingleton dataBasePath:YES] UTF8String];
    
    if (sqlite3_open(dbPath, &db))
        NSLog(@"DB: open error");
    
    const char *title = [cell.title UTF8String];
    const char *date = [[TableViewDataSingleton stringFromDate:cell.date] UTF8String];
    
    NSData *image = UIImagePNGRepresentation(cell.image);
    
    const char *insertNewCell = "INSERT INTO Cells VALUES(?, ?, ?, ?)";
    sqlite3_stmt *insertStatement;
    if (sqlite3_prepare_v2(db, insertNewCell, -1, &insertStatement, nil))
        NSLog(@"Add: prepare error");
    
    sqlite3_bind_text(insertStatement, 1, title, strlen(title), SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2, date, strlen(date), SQLITE_TRANSIENT);
    sqlite3_bind_blob(insertStatement, 3, [image bytes], [image length], SQLITE_TRANSIENT);
    sqlite3_bind_int(insertStatement, 4, index);
    
    sqlite3_step(insertStatement);
    
    sqlite3_finalize(insertStatement);
    
    if (sqlite3_close(db))
        NSLog(@"DB: close error");
    
    [cell setDataBaseIndex:index];
}

- (void) removeCellAtIndex:(NSUInteger)index {
    sqlite3 *db = 0;
    const char *dbPath = [[DataBaseManagerSingleton dataBasePath:YES] UTF8String];
    char *err = 0;
    
    if (sqlite3_open(dbPath, &db))
        NSLog(@"DB: open error");
    
    char *query;
    query = (char *)malloc(sizeof(char) * 1000);
    sprintf(query, "DELETE FROM Cells WHERE rowNumber=%d;", index);
    
    if (sqlite3_exec(db, query, nil, nil, &err)) {
        printf("%s", err);
        sqlite3_free(err);
    }

    if (sqlite3_close(db))
        NSLog(@"DB: close error");
    
    free(query);
}

- (void) replaceCellAtIndex:(NSUInteger)index withCell:(CellData *)cell {
    [self removeCellAtIndex:index];
    [self addCell:cell withIndex:index];
}

- (void) exchangeCellAtIndex:(NSUInteger)idx1 withCellAtIndex:(NSUInteger)idx2 {
    [self removeCellAtIndex:idx1];
    [self removeCellAtIndex:idx2];
    [self addCell:[[TableViewDataSingleton instance] objectAtIndex:idx1] withIndex:idx2];
    [self addCell:[[TableViewDataSingleton instance] objectAtIndex:idx2] withIndex:idx1];
}

- (NSMutableArray *) dataArrayFromDB {
    sqlite3 *db = 0;
    const char *dbPath = [[DataBaseManagerSingleton dataBasePath:NO] UTF8String];
    
    NSMutableArray *dataArray = [NSMutableArray array];
    
    sqlite3_open(dbPath, &db);
    
    const char *selectQuery = "SELECT title, date, image, rowNumber FROM Cells ORDER BY rowNumber ASC";
    sqlite3_stmt *selectStatement;
    sqlite3_prepare_v2(db, selectQuery, -1, &selectStatement, nil);
    
    while (sqlite3_step(selectStatement) != SQLITE_DONE) {
        char *cTitle = (char *)sqlite3_column_text(selectStatement, 0);
        NSString *title = [NSString stringWithCString:cTitle encoding:NSUTF8StringEncoding];
        
        char *dateCString = (char *)sqlite3_column_text(selectStatement, 1);
        NSString *dateString = [NSString stringWithCString:dateCString encoding:NSUTF8StringEncoding];
        NSDate *date = [TableViewDataSingleton dateFromString:dateString];
    
        NSData *imageData = [NSData dataWithBytes:sqlite3_column_blob(selectStatement, 2)
                                           length:sqlite3_column_bytes(selectStatement, 2)];
        UIImage *image = [UIImage imageWithData:imageData];
    
        NSUInteger index = sqlite3_column_int(selectStatement, 3);
    
        CellData *cell = [[CellData alloc] initWithTitle:title withDate:date withImage:image withDataBaseIndex:index];
        [dataArray addObject:cell];
        [cell release];
    } 
    
    sqlite3_finalize(selectStatement);
    
    sqlite3_close(db);
    
    return dataArray;
}

@end
