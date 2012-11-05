//
//  UserDataLoader.m
//  TableViewTest
//
//  Created by LSA on 31/10/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import "UserDataLoader.h"
#import "TableViewDataSingleton.h"
#import "CellData.h"

@interface UserDataLoader ()
{
    NSMutableArray *_dataArray;
    CellData *_tempCell;
    BOOL _insideTheTable;
    BOOL _insideTheCell;
    BOOL _insideTheDate;
    BOOL _insideTheImage;
}

@end

@implementation UserDataLoader

@synthesize delegate;

- (id) init {
    if (self = [super init])
    {
        _insideTheTable = NO;
        _insideTheCell = NO;
        _insideTheDate = NO;
        _insideTheImage = NO;
        _dataArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) dealloc {
    [_dataArray release];
    
    [super dealloc];
}

- (NSMutableArray *) dataArray {
    return _dataArray;
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"table"])
    {
        _insideTheTable = YES;
    }
    else if ([elementName isEqualToString:@"cell"])
    {
        if (_insideTheTable) {
            _insideTheCell = YES;
            
            NSString *thisTitle = [attributeDict objectForKey:@"title"];
            if (thisTitle)
                _tempCell = [[CellData alloc] initWithTitle:thisTitle withDate:nil withImage:nil];
            else
                [parser abortParsing];
        }
        else {
            [parser abortParsing];
        }
    }
    else if ([elementName isEqualToString:@"date"])
    {
        if (_insideTheCell) 
            _insideTheDate = YES;
        else
            [parser abortParsing];
    }
    else if ([elementName isEqualToString:@"image"])
    {
        if (_insideTheCell)
            _insideTheImage = YES;
        else
            [parser abortParsing];
    }
    else
    {
        [parser abortParsing];
    }
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"table"] && _insideTheTable)
        _insideTheTable = NO;
    else if ([elementName isEqualToString:@"cell"] && _insideTheCell)
    {
        [_dataArray addObject:_tempCell];
        [_tempCell release];
        
        _insideTheCell = NO;
    }
    else if ([elementName isEqualToString:@"date"] && _insideTheDate)
        _insideTheDate = NO;
    else if ([elementName isEqualToString:@"image"] && _insideTheImage)
        _insideTheImage = NO;
    else
        [parser abortParsing];
}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (_insideTheDate)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterFullStyle];
        [dateFormatter setDateStyle:NSDateFormatterFullStyle];
        NSDate *newDate = [dateFormatter dateFromString:string];
        [dateFormatter release];
        
        [_tempCell setDate:newDate];
    }
    else if (_insideTheImage)
    {
        // преобразование строки в изображение
    }
    else
    {
        [parser abortParsing];
    }
        
}

- (void) parserDidEndDocument:(NSXMLParser *)parser {
    [delegate loader:self didEndLoadingDataArray:self.dataArray];
}

@end
