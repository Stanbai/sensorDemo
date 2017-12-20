//
//  STBallView.h
//  gyro
//
//  Created by Stan on 2017-05-24.
//  Copyright © 2017 stan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface STBallView : UIView
//X、Y、Z轴的力度值结构体
@property(assign,nonatomic)CMAcceleration accelleration;

@property(strong,nonatomic)UIImageView *imageView;
@property(strong,nonatomic)UIImage *image;


- (void)updateLocation;
@end
