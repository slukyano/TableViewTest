//
//  UserDataLoader.h
//  TableViewTest
//
//  Created by LSA on 31/10/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UserDataLoaderDelegate;

@interface UserDataLoader : NSObject <NSXMLParserDelegate>

@property (retain) NSObject <UserDataLoaderDelegate> *delegate;

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
- (void) parserDidEndDocument:(NSXMLParser *)parser;

@end

@protocol UserDataLoaderDelegate <NSObject>

- (void) loader:(UserDataLoader *)loader didEndLoadingDataArray:(NSMutableArray *)newDataArray;

@end
