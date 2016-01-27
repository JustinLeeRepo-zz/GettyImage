//
//  ViewController.h
//  GettyImage
//
//  Created by Justin Lee on 1/26/16.
//  Copyright © 2016 Justin Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PictureViewController.h"

@interface ViewController : UIViewController<UITextFieldDelegate>

//@property (nonatomic, strong) NSString *previousTextFieldContent;
//@property (nonatomic, strong) UITextRange *previousSelection;
@property (nonatomic, strong) PictureViewController *pictureViewController;

@end
