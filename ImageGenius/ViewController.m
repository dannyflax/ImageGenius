//
//  ViewController.m
//  ImageGenius
//
//  Created by Danny Flax on 3/20/15.
//  Copyright (c) 2015 Danny Flax. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

typedef struct color {
    float red;
    float green;
    float blue;
    float shade;
    float hue;
} gColor;

- (void)viewDidLoad {
    [super viewDidLoad];
    myImg = [UIImage imageNamed:@"Blistex.jpg"];
    
    [self grayscale];
    
    float w = 300;
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, w, w*myImg.size.height/myImg.size.width)];
    [imgView setContentMode:UIViewContentModeScaleToFill];
    imgView.image = myImg;
    [self.view addSubview:imgView];
    
//    int count = MAX(test.size.width*test.size.height,500);
//    gColor *rgba = [ViewController getRGBAsFromImage:test atX:0 andY:0 count:count];
//    
//    for (int i = 0; i < count; i++) {
//        [self calculateShadeAndHue:rgba[i]];
////        NSLog(@"%f", rgba[i].hue);
//    }
//    //NSLog(@"%@",@"hai");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void) grayscale{
    CGContextRef ctx;
    CGImageRef imageRef = [myImg CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = malloc(height * width * 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    int maX = 0;
    int miX = (int)width;
    int maY = 0;
    int miY = (int)height;
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    int byteIndex = (int)((bytesPerRow * 0) + 0 * bytesPerPixel);
    for (int ii = 0 ; ii < width * height ; ++ii)
    {
        int x = ii%width;
        int y = (ii - ii%width) / width;
        
//        NSLog(@"X: %i, Y: %i", x,y);
        
        // Get color values to construct a UIColor
        CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
        CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
        CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
        
        
        gColor c;
        c.blue = blue;
        c.red = red;
        c.green = green;
        c.hue = [self calculateHue:c];
        c.shade = [self calculateShade:c];
        
        float hue = c.hue;
        float shade = c.shade;
        
        if (hue > 15.0 && hue < 25.0 && shade < .50) {
//            NSLog(@"%f", shade);
            rawData[byteIndex] = (255.0/2.0 + shade*255.0);
            rawData[byteIndex+1] = 0.0;
            rawData[byteIndex+2] = 0.0;
            
            if (x > maX) {
                maX = x;
            }
            if (x < miX){
                miX = x;
            }
            
            if (y > maY) {
                maY = y;
            }
            if (y < miY){
                miY = y;
            }
            
            
        }
        else{
            red = 0.0;
            blue = 0.0;
            green = 0.0;
            rawData[byteIndex] = red*255.0;
            rawData[byteIndex+1] = green*255.0;
            rawData[byteIndex+2] = blue*255.0;
        }
        
        byteIndex += 4;
    }
    
    
    int h = maY - miY;
    int w = (maX - miX);
    NSLog(@"\nMax X: %i, Min X: %i\nMax Y: %i, Min Y: %i\nWidth: %i, Height: %i\nAspect: %f",maX, miX, maY, miY, w, h, (float)h / (float)w);
    
    
    ctx = CGBitmapContextCreate(rawData,
                                CGImageGetWidth( imageRef ),
                                CGImageGetHeight( imageRef ),
                                8,
                                CGImageGetBytesPerRow( imageRef ),
                                CGImageGetColorSpace( imageRef ),
                                kCGImageAlphaPremultipliedLast );
    
    imageRef = CGBitmapContextCreateImage (ctx);  
    UIImage* rawImage = [UIImage imageWithCGImage:imageRef];  
    
    CGContextRelease(ctx);  
    
    myImg = rawImage;
//    [self.imageView setImage:self.workingImage];
    
    free(rawData);
    
}


//
//+ (gColor *)getRGBAsFromImage:(UIImage*)image atX:(int)x andY:(int)y count:(int)count
//{
//    gColor *result = malloc(count * sizeof(gColor));
//    //NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
//    
//    // First get the image into your data buffer
//    CGImageRef imageRef = [image CGImage];
//    NSUInteger width = CGImageGetWidth(imageRef);
//    NSUInteger height = CGImageGetHeight(imageRef);
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
//    NSUInteger bytesPerPixel = 4;
//    NSUInteger bytesPerRow = bytesPerPixel * width;
//    NSUInteger bitsPerComponent = 8;
//    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
//                                                 bitsPerComponent, bytesPerRow, colorSpace,
//                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
//    CGColorSpaceRelease(colorSpace);
//    
//    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
//    CGContextRelease(context);
//    
//    // Now your rawData contains the image data in the RGBA8888 pixel format.
//    NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
//    for (int i = 0 ; i < count ; ++i)
//    {
//        CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
//        CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
//        CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
////        CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
//        byteIndex += bytesPerPixel;
//        
//        struct color c;
//        c.red = red;
//        c.blue = blue;
//        c.green = green;
//        //UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
//        result[i] = c;
//    }
//    
//    free(rawData);
//    
//    return result;
//}


-(double)calculateHue:(gColor)c{
    float whiteFactor = 0.0;
    c.hue = -1.0;
    
    if (c.red <= c.blue && c.red <= c.green) {
        /** Between blue and green - 120-240 **/
        whiteFactor = c.red;
        c.blue -= c.red;
        c.green -= c.red;
        c.red = 0.0;
        
        double x = c.green*1.0 + c.blue*sqrt(3)/2;
        double y = c.green*0.0 + c.blue*.5;
        float angle = 0.0;
        if (sqrt(x*x + y*y) < .000001) {
            angle = -1.0;
        }
        else{
            angle = acos(x/sqrt(x*x + y*y));
        }
        c.hue = angle*180.0/M_PI;
    }
    else if(c.green <= c.blue && c.green <= c.red){
        
    }
    else if(c.blue <= c.green && c.blue <= c.red){
        
    }
    
    return c.hue;
}


-(double)calculateShade:(gColor)c{
    float whiteFactor = 0.0;
    c.hue = -1.0;
    
    if (c.red <= c.blue && c.red <= c.green) {
        /** Between blue and green - 120-240 **/
        whiteFactor = c.red;
        c.blue -= c.red;
        c.green -= c.red;
        c.red = 0.0;
        
        c.shade = sqrt(c.blue*c.blue + c.green*c.green);
    }
    else if(c.green <= c.blue && c.green <= c.red){
        
    }
    else if(c.blue <= c.green && c.blue <= c.red){
        
    }
    
    return c.shade;
}



@end
