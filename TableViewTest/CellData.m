//
//  CellData.m
//  TableViewTest
//
//  Created by LSA on 04/11/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import "CellData.h"

@implementation CellData

- (id) initWithTitle:(NSString *)title withDate:(NSDate *)date withImage:(NSObject *)image {
    self = [super init];
    if (self) {
        self.title = title;
        self.date = date;
        self.image = image;
    }
    
    return self;
}

@end
