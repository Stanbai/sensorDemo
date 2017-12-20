//
//  ViewController.m
//  gyro
//
//  Created by Stan on 2017-05-24.
//  Copyright © 2017 stan. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "STBallView.h"

@interface ViewController ()
@property(strong,nonatomic)CMMotionManager *manager;

@property(strong,nonatomic)STBallView *ballView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self useGyroPush];
    [self playBall];
    

    
    
    
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self useGyroPull];
    if ( self.manager.gyroActive) {
        [self.manager stopGyroUpdates];
        NSLog(@"关闭啦");
    }else{
        [self playBall];
    }
}

//开启小球的游戏
- (void)playBall{
    self.ballView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.ballView];
    
    self.manager.deviceMotionUpdateInterval = 1 /60;
    
    [self.manager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        self.ballView.accelleration = motion.gravity;
        //    开启主队列异步线程，更新球的位置。
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.ballView updateLocation];
        });


    }];
    

}

#pragma mark - 陀螺仪的两种获取数据方法PUSH & PULL

- (void)useGyroPull{
    
    //判断陀螺仪可不可用
    if (self.manager.gyroAvailable){
        //设置陀螺仪多久采样一次
        self.manager.gyroUpdateInterval = 0.1;
        //开始更新，后台线程开始运行。这是Pull方式。
        [self.manager startGyroUpdates];
    }
    //获取并处理陀螺仪数据。这里我们就只是简单的做了打印。
    NSLog(@"X = %f,Y = %f,Z = %f",self.manager.gyroData.rotationRate.x,self.manager.gyroData.rotationRate.y,self.manager.gyroData.rotationRate.z);
}

- (void)useGyroPush{
    //判断陀螺仪可不可用
    if (self.manager.gyroAvailable){
        //设置陀螺仪多久采样一次
        self.manager.gyroUpdateInterval = 0.1;
        //Push方式获取和处理数据，这里我们一样只是做了简单的打印。把采样的工作放在了主线程中。
        [self.manager startGyroUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
                NSLog(@"X = %f,Y = %f,Z = %f",self.manager.gyroData.rotationRate.x,self.manager.gyroData.rotationRate.y,self.manager.gyroData.rotationRate.z);
        }];

    } else{
        NSLog(@"不可用");
    }
}

#pragma mark - 懒加载

- (CMMotionManager *)manager{
    if (!_manager) {
        _manager = [[CMMotionManager alloc] init];
    }
    return _manager;
}

- (STBallView *)ballView{
    if (!_ballView) {
        _ballView = [[STBallView alloc] initWithFrame:self.view.bounds];
    }
    return _ballView;
}

@end
