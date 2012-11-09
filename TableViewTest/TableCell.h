//
//  TableCell.h
//  TableViewTest
//
//  Created by Администратор on 08.11.12.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *TextLabel;
@property (retain, nonatomic) IBOutlet UILabel *DateLabel;
@property (retain, nonatomic) IBOutlet UIImageView *ImageView;

@end
