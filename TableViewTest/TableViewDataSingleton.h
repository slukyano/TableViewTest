//
//  TableViewDataSingleton.h
//  TableViewTest
//
//  Created by LSA on 26/10/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserDataLoader.h"

@interface TableViewDataSingleton : NSObject <UserDataLoaderDelegate>

// Массив с данными ячеек
@property (retain) NSMutableArray *dataArray;

// Возвращает указатель на экземпляр
+ (TableViewDataSingleton *) instance;
- (NSUInteger) count;
- (id) objectAtIndex:(NSUInteger)index;
- (void) addObject:(id)anObject;
- (void) removeObjectAtIndex:(NSUInteger)index;
- (void) exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
- (void) replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
- (void) loader:(UserDataLoader *)loader didEndLoadingDataArray:(NSMutableArray *)newDataArray;

@end
