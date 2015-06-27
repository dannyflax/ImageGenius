//
//  ViewController.h
//  ImageGenius
//
//  Created by Danny Flax on 3/20/15.
//  Copyright (c) 2015 Danny Flax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+Resize.h"

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImage *myImg;
    UIImageView *imgView;
    float threshold;
    UIImage *originalImage;
    UILabel *calcLbl;
    bool flips;
    float num;
    
    bool cancelsLoading;
    bool isLoading;
    
    CGImageRef imageRef;
    unsigned char *imgData;
    NSUInteger width;
    NSUInteger height;
}
@property (nonatomic, retain) UISlider *slider;
@end
