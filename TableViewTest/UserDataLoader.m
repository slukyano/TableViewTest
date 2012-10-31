//
//  UserDataLoader.m
//  TableViewTest
//
//  Created by LSA on 31/10/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import "UserDataLoader.h"
#import "TableViewDataSingleton.h"

@interface UserDataLoader ()
{
    NSMutableArray *_dataArray;
    BOOL _insideTheTable;
}

@end

@implementation UserDataLoader

@synthesize delegate;

- (id) init
{
    if (self = [super init])
    {
        _insideTheTable = NO;
        _dataArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) dealloc
{
    [_dataArray release];
    
    [super dealloc];
}

- (NSMutableArray *) dataArray
{
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
        if (_insideTheTable)
        {
            NSString *thisTitle = [attributeDict objectForKey:@"title"];
            if (thisTitle)
                [_dataArray addObject:thisTitle];
            else
                [parser abortParsing];
        }
        else
        {
            [parser abortParsing];
        }
    }
    else
    {
        [parser abortParsing];
    }
}

- (void) parserDidEndDocument:(NSXMLParser *)parser
{
    [delegate loader:self didEndLoadingDataArray:self.dataArray];
}

@end
