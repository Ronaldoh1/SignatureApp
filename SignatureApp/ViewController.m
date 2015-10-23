//
//  ViewController.m
//  SignatureApp
//
//  Created by Ronald Hernandez on 10/22/15.
//  Copyright © 2015 Wahoo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
//tracks your fingers
@property CGPoint lastPoint;
//tracks way of drawing
@property CGPoint moveBack;
//tracks where you are currently
@property CGPoint currentPoint;

//tracks where you're toouching
@property CGPoint location;
//tells where you last released
@property NSDate *lastClick;

@property BOOL mouseWasSwiped;

//need two images to capture the image.
@property UIImageView *drawImage;
@property UIImageView *frontImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //draw the image saved
    self.drawImage = [defaults objectForKey:@"drawImageKey"];
    //start the image with nothing.
    self.drawImage = [[UIImageView alloc] initWithImage:nil];
    //make the image frame same as that of the view.
    self.drawImage.frame = self.view.frame;
    [self.view addSubview:self.drawImage];

    //*Add -Clear Button to UIView
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    //set the frame
    clearButton.frame = CGRectMake(self.view.frame.size.width - 100, self.view.frame.size.height - 50, 100, 35);
    clearButton.backgroundColor = [UIColor orangeColor];
    //add title for normal state
    [clearButton setTitle:@"Clear" forState:UIControlStateNormal];

    [clearButton addTarget:self action:@selector(clearSignature) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearButton];

    //*Add -Save Button to UIView
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    //set the frame
    saveButton.frame = CGRectMake(self.view.frame.size.width - 100, self.view.frame.size.height - 200, 100, 35);
    saveButton.backgroundColor = [UIColor orangeColor];
    //add title for normal state
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];

    [saveButton addTarget:self action:@selector(saveSignature) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveButton];


}
-(void)saveSignature{
    NSLog(@"save signature ");

}
-(void)clearSignature{

    NSLog(@"clear signature");

}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    self.mouseWasSwiped = NO;

    UITouch *touch = [[event allTouches] anyObject];

//    if ([touch tapCount] == 2) {
//        self.drawImage = nil;
//    }
//
//    self.location = [touch locationInView:touch.view];


    self.lastPoint =[touch locationInView:self.view];


    [super touchesBegan:touches withEvent:event];

}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    self.mouseWasSwiped = YES;

    UITouch *touch = [touches anyObject];
    self.currentPoint = [touch locationInView:self.view];


    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.drawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 1);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x, self.lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), self.currentPoint.x, self.currentPoint.y);
    CGContextStrokePath(UIGraphicsGetCurrentContext());

    [self.drawImage setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.lastPoint = self.currentPoint;
    [self.view addSubview:self.drawImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
