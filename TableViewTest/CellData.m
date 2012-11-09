//
//  CellData.m
//  TableViewTest
//
//  Created by LSA on 04/11/2012.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import "CellData.h"

@implementation CellData

- (id) initWithTitle:(NSString *)title withDate:(NSDate *)date withImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.title = title;
        self.date = date;
        self.image = image;
    }
    
    return self;
}

- (id) initWithTitle:(NSString *)title withDate:(NSDate *)date withImage:(UIImage *)image withDataBaseIndex:(NSUInteger)dataBaseIndex {
    self = [super init];
    if (self) {
        self.title = title;
        self.date = date;
        self.image = image;
        self.dataBaseIndex = dataBaseIndex;
    }
    
    return self;
}

- (void) dealloc {
    [self.title release];
    //self.title = nil;
    [self.image release];
    //self.image = nil;
    [self.date release];
    //self.date = nil;
    [super dealloc];
    
}
@end
