//
//  PopoverImageViewController.h
//  TableViewTest
//
//  Created by Администратор on 07.11.12.
//  Copyright (c) 2012 Администратор. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImagePickerDelegate
- (void)imageSelected:(NSDate *)newImage;
@end

@interface PopoverImageViewController : UIViewController {
    id<ImagePickerDelegate> _delegate;
}

@property (nonatomic, assign) id<ImagePickerDelegate> delegate;
@end
