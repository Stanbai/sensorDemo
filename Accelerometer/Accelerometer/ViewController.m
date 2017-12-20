//
//  ViewController.m
//  Accelerometer
//
//  Created by Stan on 2017-05-24.
//  Copyright © 2017 stan. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface ViewController ()
@property(strong,nonatomic)CMMotionManager *manager;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];

    [self keepBalance];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self useAccelerometerPull];
    if ( self.manager.accelerometerActive) {
        [self.manager stopAccelerometerUpdates];
        NSLog(@"关闭啦");
    }
}
#pragma mark - 让图片始终水平
- (void)keepBalance{
        if (self.manager.accelerometerAvailable) {
            //设置加速计采样频率
            self.manager.accelerometerUpdateInterval = 0.01f;
            [self.manager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
//                计算图片的水平倾斜角度。这里没有实现Z轴的形变，所以咱们只能在XY轴上变换。有兴趣的童鞋自己实现Z轴好不好？
                double rotation = atan2(accelerometerData.acceleration.x, accelerometerData.acceleration.y) - M_PI;
                self.imageView.transform = CGAffineTransformMakeRotation(rotation);
            }];
        }
}


#pragma mark - 加速计的两种获取数据方法PUSH & PULL

- (void)useAccelerometerPull{
    
    //判断加速度计可不可用
    if (self.manager.accelerometerAvailable){
        //设置加速计多久采样一次
        self.manager.accelerometerUpdateInterval = 0.1;
        //开始更新，后台线程开始运行。这是Pull方式。
        [self.manager startAccelerometerUpdates];
    }
    //获取并处理加速度计数据。这里我们就只是简单的做了打印。
    NSLog(@"X = %f,Y = %f,Z = %f",self.manager.accelerometerData.acceleration.x,self.manager.accelerometerData.acceleration.y,self.manager.accelerometerData.acceleration.z);
}

- (void)useAccelerometerPush{
    //判断加速度计可不可用，判断加速度计是否开启
    if (self.manager.accelerometerAvailable){
        //设置加速计多久采样一次
        self.manager.accelerometerUpdateInterval = 0.1;
        //Push方式获取和处理数据，这里我们一样只是做了简单的打印。把采样的工作放在了主线程中。
        [self.manager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                           withHandler:^(CMAccelerometerData *accelerometerData, NSError *error){
                                               NSLog(@"X = %f,Y = %f,Z = %f",self.manager.accelerometerData.acceleration.x,self.manager.accelerometerData.acceleration.y,self.manager.accelerometerData.acceleration.z);
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




@end
