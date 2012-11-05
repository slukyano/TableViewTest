//
//  CellData.h
//  TableViewTest
//
//  Created by LSA on 04/11/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CellData : NSObject

@property (retain) NSString *title;
@property (retain) NSDate *date;
@property (retain) NSObject *image; // !!! NSObject нужно будет изменить

- (id) initWithTitle:(NSString *)title withDate:(NSDate *)date withImage:(NSObject *)image;

@end
