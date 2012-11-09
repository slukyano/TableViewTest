//
//  TableCell.m
//  TableViewTest
//
//  Created by Администратор on 08.11.12.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import "TableCell.h"

@implementation TableCell
@synthesize TextLabel,DateLabel,ImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [TextLabel release];
    TextLabel = nil;
    [DateLabel release];
    DateLabel = nil;
    [ImageView release];
    ImageView = nil;
    [super dealloc];
}
@end
