//
//  ViewController.m
//  ImageGenius
//
//  Created by Danny Flax and Qinwan Rabbani on 3/20/15.
//  Copyright (c) 2015 Danny Flax and Qinwan Rabbani. All rights reserved.

#import "ViewController.h"
#import "SecondViewController.h"

@interface ViewController ()

@end

@implementation ViewController

typedef struct color {
    float red;
    float green;
    float blue;
    float shade;
    float hue;
    float saturation;
} gColor;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    float viewWidth = self.view.frame.size.width;
    float viewHeight = self.view.frame.size.height;
    
    self.view.multipleTouchEnabled = true;
    
    isLoading = false;
    cancelsLoading = false;
    
    flips = false;
    threshold = .34;
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background.png"]];
    [self.view addSubview:backgroundView];
    
    float w = 320;
    float h = 320;
    imgView = [[UIImageView alloc] initWithFrame:CGRectMake((viewWidth - w)/2.0, 30.0, w, h)];
    
    [imgView setBackgroundColor:[UIColor colorWithRed:(215.0/255.0) green: (193.0/255.0) blue:(10.0/255.0) alpha:(1.0)]];
    [imgView.layer setBorderColor:[UIColor colorWithRed:(108.0/255.0) green: (97.0/255.0) blue:(5.0/255.0) alpha:(1.0)].CGColor];
    [imgView.layer setBorderWidth:3.0];
    
    [imgView setContentMode:UIViewContentModeScaleAspectFit];
    originalImage = [UIImage imageNamed:@"23cm salt 1~01.jpg"];
    
    myImg = [UIImage imageWithCGImage:originalImage.CGImage];
    [self loadImgData];
    [self filter];
    imgView.image = myImg;
    
    [self.view addSubview:imgView];
    
    
    calcLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 380.0, self.view.frame.size.width, 50.0)];
    [calcLbl setTextAlignment:NSTextAlignmentCenter];
    [calcLbl setFont:[UIFont fontWithName:@"Thonburi-Bold" size: 30]];
    calcLbl.textColor = [UIColor colorWithRed:(215.0/255.0) green: (193.0/255.0) blue:(10.0/255.0) alpha:(1.0)];
    [self.view addSubview:calcLbl];
    
    calcLbl2 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 410.0, self.view.frame.size.width, 50.0)];
    [calcLbl2 setTextAlignment:NSTextAlignmentCenter];
    [calcLbl2 setFont:[UIFont fontWithName:@"Thonburi-Bold" size: 15]];
    calcLbl2.textColor = [UIColor colorWithRed:(215.0/255.0) green: (193.0/255.0) blue:(10.0/255.0) alpha:(1.0)];
    [self.view addSubview:calcLbl2];
    
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(10.0, 360.0, self.view.frame.size.width - 20.0, 30.0)];
    [self.slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventTouchUpInside];
    [self.slider setThumbImage:[UIImage imageNamed:@"Slider.png"] forState:(UIControlStateNormal)];
    [self.view addSubview:self.slider];
    
    [self.slider setMinimumValue:0.0];
    [self.slider setMaximumValue:1.0];
    
    [self.slider setValue:threshold animated:NO];
    
    
    UIButton *fButton = [[UIButton alloc] initWithFrame:CGRectMake((viewWidth - 328.0), (viewHeight-280.0), 240.0, 80.0)];
    [fButton
     setBackgroundImage:[UIImage imageNamed:@"Invert.png"]
     forState:UIControlStateNormal];
    [fButton addTarget:self action:@selector(flip:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fButton];
    
    UIButton *cButton = [[UIButton alloc] initWithFrame:CGRectMake((viewWidth - 328.0), (viewHeight-175.0), 240.0, 80.0)];
    [cButton
     setBackgroundImage:[UIImage imageNamed:@"Calculate.png"]
     forState:UIControlStateNormal];
    [cButton addTarget:self action:@selector(calculate:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cButton];
    
    UIButton *hButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 675.0, 50.0, 50.0)];
    [hButton
     setBackgroundImage:[UIImage imageNamed:@"Help.png"]
     forState:UIControlStateNormal];
    [hButton addTarget:self action:@selector(helpButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hButton];
    
    UIButton *pButton = [[UIButton alloc] initWithFrame:CGRectMake((viewWidth-65), 675.0, 55.0, 55.0)];
    [pButton
     setBackgroundImage:[UIImage imageNamed:@"Cam.png"]
     forState:UIControlStateNormal];
    [pButton addTarget:self action:@selector(camButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pButton];}

-(void)helpButton:(id)sender {
    ViewController *second = [[SecondViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:second animated:YES completion:NULL];
}

-(IBAction)calculate:(id)sender{
    float main = num;
    float tot = main;
    if (threshold > 0.1 && threshold < .9) {
        float oldThreshold = threshold;
        threshold = oldThreshold + .03;
        [self filter];
        float upper = num;
        
        threshold = oldThreshold - .03;
        [self filter];
        float lower = num;
        
        threshold = oldThreshold;
        num = main;
        
        tot = (upper + main + lower)/3.0;
        
        [calcLbl setText:[NSString stringWithFormat:@"%i Cells", (int)main]];
        [calcLbl2 setText:[NSString stringWithFormat:@"(Max Range: %i - %i Cells)", (int)lower,(int)upper]];    }
    else{
        [calcLbl setText:[NSString stringWithFormat:@"%i cells", (int)tot]];
    }   
}

-(IBAction)sliderChanged:(id)sender{
        threshold = self.slider.value;
        [self refreshImage];
}

-(IBAction)flip:(id)sender{
    flips = !flips;
    [self refreshImage];
}

-(void)refreshImage{
    [self filter];
    imgView.image = myImg;
    [calcLbl setText:@""];
    [calcLbl2 setText:@""];}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadImgData{
    myImg = [UIImage imageWithCGImage:originalImage.CGImage];
    imageRef = [myImg CGImage];
    width = CGImageGetWidth(imageRef);
    height = CGImageGetHeight(imageRef);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    imgData = malloc(height * width * 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(imgData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
}

- (void) filter{
    unsigned char *newData = malloc(height * width * 4);
    for (int i = 0; i < width*height*4; i++) {
        newData[i] = imgData[i];
    }
    
    float conc = 0.0;
    
    for (int ii = 0 ; ii < width * height; ++ii)
    {
        int x = ii%width;
        int y = (ii - ii%width) / width;
        
        gColor *color = [self getColorDataAtX:x Y:y width:(int)width storage:imgData];
        
            int rad = 1;
            if (x > rad && y > rad && x+rad < width && y+rad < height) {
                float pos = 0.0;
                float tot = (2*rad)*(2*rad);
                
                for (int dx = -rad; dx < rad; dx++) {
                    for (int dy = -rad; dy < rad; dy++) {

                            gColor *dColor = [self getColorDataAtX:x+dx Y:y+dy width:(int)width storage:imgData];
                            bool is = [self isInRange:dColor];
                            if (is) {
                                (pos++);
                            }
                            free(dColor);
                    }
                }
                
                float shade = pos/tot;

                if (shade > .33) {
//                    color->red = 1.0;
//                    color->blue = 1.0;
//                    color->green = 1.0;
                }
                else{
                    conc++;
                    color->red = 0.0;
                    color->blue = 0.0;
                    color->green = 0.0;
                }
                
            }
            else{
//                color->red = 1.0;
//                color->blue = 1.0;
//                color->green = 1.0;
            }
  
        [self setColorDataAtX:x Y:y width:(int)width color:color storage:newData];
        
        free(color);
        
    }
    
    float yeastDiam = width * (4.0/288.0);
    float yeastArea = M_PI * (yeastDiam/2) * (yeastDiam/2);
    
    num = conc/yeastArea;
    
    CGContextRef ctx = CGBitmapContextCreate(newData,
                                width,
                                height,
                                8,
                                CGImageGetBytesPerRow( imageRef ),
                                CGImageGetColorSpace( imageRef ),
                                kCGImageAlphaPremultipliedLast );

    
    myImg = [UIImage imageWithCGImage:CGBitmapContextCreateImage (ctx)];

    free(newData);
}




-(bool)isInRange:(gColor *)color{
    return flips ? (color->saturation) < threshold : (color->saturation) > threshold;
}

- (gColor *)getColorDataAtX:(int)x Y:(int)y width:(int)w storage:(unsigned char*)rawData{
    return [self getColorDataAtIndex:4*(y*w+x) storage:rawData];
}

- (void)setColorDataAtX:(int)x Y:(int)y width:(int)w  color:(gColor *)color storage:(unsigned char*)rawData{
    [self setColorDataAtIndex:4*(y*w+x) color:color storage:rawData];
}

- (gColor *)getColorDataAtIndex:(int)ind storage:(unsigned char *)rawData{
    // Get color values to construct a UIColor
    CGFloat red   = (rawData[ind]     * 1.0) / 255.0;
    CGFloat green = (rawData[ind + 1] * 1.0) / 255.0;
    CGFloat blue  = (rawData[ind + 2] * 1.0) / 255.0;
    
    struct color *c = malloc(sizeof(struct color));
    c->blue = blue;
    c->red = red;
    c->green = green;
    
    [self calculateShadeAndHue:c];
    
    return c;
}

- (void)setColorDataAtIndex:(int)ind color:(gColor *)color storage:(unsigned char *)rawData {
    // Get color values to construct a UIColor
    rawData[ind] = color->red*255.0;
    rawData[ind + 1] = color->green*255.0;
    rawData[ind + 2] = color->blue*255.0;
}

-(double)calculateShadeAndHue:(gColor *)c{
    float whiteFactor = 0.0;
    c->hue = -1.0;
    
    float red = c->red;
    float blue = c->blue;
    float green = c->green;
    
    if (red <= blue && red <= green) {
        /** From green to blue - 120-240 **/
        whiteFactor = red;
        blue -= red;
        green -= red;
        red = 0.0;
        
        double x = green*1.0 + blue*sqrt(3)/2;
        double y = green*0.0 + blue*.5;
        float angle = 0.0;
        if (sqrt(x*x + y*y) < .000001) {
            angle = -1.0;
        }
        else{
            angle = acos(x/sqrt(x*x + y*y));
        }
        c->hue = 120.0 + angle*180.0/M_PI;
    }
    else if(c->green <= c->blue && c->green <= c->red){
        /** From blue to red - 240-360 **/
        whiteFactor = green;
        blue -= green;
        red -= green;
        green = 0.0;
        
        double x = blue*1.0 + red*sqrt(3)/2;
        double y = blue*0.0 + red*.5;
        float angle = 0.0;
        if (sqrt(x*x + y*y) < .000001) {
            angle = -1.0;
        }
        else{
            angle = acos(x/sqrt(x*x + y*y));
        }
        c->hue = 240.0 + angle*180.0/M_PI;
    }
    else if(c->blue <= c->green && c->blue <= c->red){
        /** From red to green - 0-120 **/
        whiteFactor = blue;
        red -= blue;
        green -= blue;
        blue = 0.0;
        
        double x = red*1.0 + green*sqrt(3)/2;
        double y = red*0.0 + green*.5;
        float angle = 0.0;
        if (sqrt(x*x + y*y) < .000001) {
            angle = -1.0;
        }
        else{
            angle = acos(x/sqrt(x*x + y*y));
        }
        c->hue = angle*180.0/M_PI;
    }
    
    c->saturation = whiteFactor;
    c->shade = sqrt(blue*blue + green*green + red*red);
    
    return c->hue;
}

#pragma mark - Touch Methods
-(IBAction)camButton:(id)sender{
    [self promptForPicture:UIImagePickerControllerSourceTypePhotoLibrary];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if ([touch tapCount] == 2) {
        [self promptForPicture:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

#pragma mark - ImagePicker Methods

-(void)promptForPicture:(UIImagePickerControllerSourceType)sourceType{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:^(void){
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *picked = [info valueForKey:UIImagePickerControllerOriginalImage];
    float h = CGImageGetHeight(picked.CGImage);
    float w = CGImageGetWidth(picked.CGImage);
    
    float max = 3000000.0;
    
    
//    [picked resizedImage:CGSizeMake(<#CGFloat width#>, <#CGFloat height#>) interpolationQuality:kCGInterpolationHigh];
    
    if (h*w > max) {
        
    }
    else{
        originalImage = picked;
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    picker = nil;
    
    [self loadImgData];
    [self refreshImage];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
