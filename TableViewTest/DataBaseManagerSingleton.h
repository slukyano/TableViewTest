//
//  DataBaseManagerSingleton.h
//  TableViewTest
//
//  Created by LSA on 07/11/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CellData.h"

@interface DataBaseManagerSingleton : NSObject

+ (DataBaseManagerSingleton *) instance;
- (void) addCell:(CellData *)cell;
// Индексы - индексы в базе, а не номер строки!
- (void) removeCellAtIndex:(NSUInteger)index;
- (void) replaceCellAtIndex:(NSUInteger)index withCell:(CellData *)cell;
- (void) exchangeCellAtIndex:(NSUInteger)idx1 withCellAtIndex:(NSUInteger)idx2;
- (NSMutableArray *) dataArrayFromDB;

@end
