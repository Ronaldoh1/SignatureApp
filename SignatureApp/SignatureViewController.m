//
//  ViewController.m
//  SignatureApp
//
//  Created by Ronald Hernandez on 10/22/15.
//  Copyright © 2015 Wahoo. All rights reserved.
//

#import "SignatureViewController.h"

@interface SignatureViewController ()
//tracks where you are currently
@property CGPoint currentPoint;

//tracks where you're toouching
//tracks your fingers
@property CGPoint previousPoint1;
@property CGPoint previousPoint2;
@property CGPoint location;
@property BOOL mouseWasSwiped;

//ImageView to capture the signature.
@property UIImageView *signatureBoard;

//Subviews
@property UIButton *clearButton;
@property UIButton *saveButton;

@end

@implementation SignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    /*-------------------------------
     **Add UIImage for BlackLine
     **------------------------------*/
    UIImageView *blackLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"blackLine.png"]];
    //set the frame
    blackLine.frame = CGRectMake(30, self.view.frame.size.height - 50, self.view.frame.size.width - 150, 25);


    [self.view addSubview:blackLine];

    /*-------------------------------
     **Add UIImage for X
     **------------------------------*/
    UIImageView *xMark = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"x.png"]];
    //set the frame
    xMark.frame = CGRectMake(0, self.view.frame.size.height - 70, 70, 70);

    [self.view addSubview:xMark];

    /*-------------------------------
     **Set Up Image for Drawing & Add to View
     **------------------------------*/


    //start the image with nothing.
    self.signatureBoard = [[UIImageView alloc] initWithImage:nil];
    //make the image frame same as that of the view.
    self.signatureBoard.frame = self.view.frame;

    [self.view addSubview:self.signatureBoard];



    /*-------------------------------
     **Add Clear Button to UIView
     **------------------------------*/
    self.clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    //set the frame
    self.clearButton.frame = CGRectMake(self.view.frame.size.width - 120, self.view.frame.size.height - 70, 100, 35);
    self.clearButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:128 alpha:1];
    self.clearButton.tintColor = [UIColor whiteColor];
    //add title for normal state
    [self.clearButton setTitle:@"Clear" forState:UIControlStateNormal];

    [self.clearButton addTarget:self action:@selector(clearSignature) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.clearButton];

    /*-------------------------------
     **Add Save Button to UIView
     **------------------------------*/

    self.saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    //set the frame
    self.saveButton.frame = CGRectMake(self.view.frame.size.width - 120, 10, 100, 35);
    self.saveButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:128 alpha:1];
    self.saveButton.tintColor = [UIColor whiteColor];
    //add title for normal state
    [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];

    [self.saveButton addTarget:self action:@selector(saveSignature) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveButton];





}
/*-------------------------------
 **Clear Signature
 **------------------------------*/
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    self.mouseWasSwiped = NO;

    UITouch *touch = [[event allTouches] anyObject];

    //initialize to the current touch point.
    self.previousPoint1 = [touch previousLocationInView:self.view];
    self.previousPoint2 = [touch previousLocationInView:self.view];
    self.currentPoint = [touch locationInView:self.view];
    [super touchesBegan:touches withEvent:event];
    
}
/*------------------------------------------
 **Capture Image when User Moves Finger
 **----------------------------------------*/

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    self.mouseWasSwiped = YES;

    UITouch *touch = [touches anyObject];


    self.previousPoint2 = self.previousPoint1;
    self.previousPoint1 = [touch previousLocationInView:self.view];
    self.currentPoint = [touch locationInView:self.view];





    // calculate mid point
    CGPoint mid1 = [self calculateMidPointWith:self.previousPoint1 andWith:self.previousPoint2];
    CGPoint mid2 = [self calculateMidPointWith:self.currentPoint andWith:self.previousPoint1];
    //CGPoint mid2 = midPoint(currentPoint, previousPoint1);

    UIGraphicsBeginImageContext(self.signatureBoard.frame.size);
    [self.signatureBoard.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapSquare);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 6.0);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 1);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeColorBurn);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), mid1.x, mid1.y);

    // Use QuadCurve will give us a smoother line
    CGContextAddQuadCurveToPoint(UIGraphicsGetCurrentContext(), self.previousPoint1.x, self.previousPoint1.y, mid2.x, mid2.y);

    //CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), self.currentPoint.x, self.currentPoint.y);
    CGContextStrokePath(UIGraphicsGetCurrentContext());

    [self.signatureBoard setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.signatureBoard.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.previousPoint2 = self.currentPoint;
    [self.view addSubview:self.signatureBoard];
}

#pragma Helper Methods
/*-------------------------------
 **Save Signatures
 **------------------------------*/

-(void)saveSignature{

    self.clearButton.alpha = 0;
    self.saveButton.alpha = 0;
    UIGraphicsBeginImageContextWithOptions(self.signatureBoard.bounds.size, NO,0.0);
    [self.signatureBoard.image drawInRect:CGRectMake(0, 0, self.signatureBoard.frame.size.width, self.signatureBoard.frame.size.height)];
    UIImage *SaveImage = [self captureSignatureArea:self.signatureBoard.frame];
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(SaveImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    self.saveButton.alpha = 1.0;
    self.clearButton.alpha = 1.0;


}
/*-------------------------------
 **Capture Image of Signature
 **------------------------------*/
-(UIImage *)captureSignatureArea:(CGRect)captureFrame {
    CALayer *layer;
    layer = self.view.layer;
    UIGraphicsBeginImageContext(self.view.bounds.size);
    CGContextClipToRect (UIGraphicsGetCurrentContext(),captureFrame);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenImage;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    // Was there an error?
    if (error != nil){

        [self displayAlertWithTitle:@"Error" andWithMessage:@"Image could not be saved.Please try again"];

    } else {
        [self displayAlertWithTitle:@"Success!! " andWithMessage:@"Image was successfully saved in photoalbum"];

    }
}

/*-------------------------------
 **Display
 **------------------------------*/
-(void)displayAlertWithTitle:(NSString *)title andWithMessage:(NSString *)message{


    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];

                         }];


    [alert addAction:ok];

    [self presentViewController:alert animated:YES completion:nil];
}
/*-------------------------------
 **Clear Signature
 **------------------------------*/

-(void)clearSignature{

    self.signatureBoard.image = nil;

}

/*-------------------------------
 **Calculate MidPoint
 **------------------------------*/

-(CGPoint)calculateMidPointWith:(CGPoint )point1 andWith:(CGPoint)point2{

    return CGPointMake((point1.x + point2.x) * 0.5, (point1.y + point2.y) * 0.5);

}

@end
