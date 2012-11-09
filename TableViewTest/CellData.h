//
//  CellData.h
//  TableViewTest
//
//  Created by LSA on 04/11/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CellData : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) UIImage *image;
@property (assign) NSUInteger dataBaseIndex;

- (id) initWithTitle:(NSString *)title withDate:(NSDate *)date withImage:(UIImage *)image;
- (id) initWithTitle:(NSString *)title withDate:(NSDate *)date withImage:(UIImage *)image withDataBaseIndex:(NSUInteger)dataBaseIndex;

@end
