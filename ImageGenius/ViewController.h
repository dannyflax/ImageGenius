//
//  ViewController.m
//  ImageGenius
//
//  Created by Danny Flax and Qinwan Rabbani on 3/20/15.
//  Copyright (c) 2015 Danny Flax and Qinwan Rabbani. All rights reserved.

#import <UIKit/UIKit.h>
#import "UIImage+Resize.h"

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImage *myImg;
    UIImageView *imgView;
    float threshold;
    UIImage *originalImage;
    UILabel *calcLbl;
    UILabel *calcLbl2;
    int a;
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
