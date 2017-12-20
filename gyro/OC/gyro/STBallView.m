//
//  STBallView.m
//  gyro
//
//  Created by Stan on 2017-05-24.
//  Copyright © 2017 stan. All rights reserved.
//

#import "STBallView.h"


@interface STBallView ()
//图片的宽高
@property (nonatomic, assign) CGFloat imageWidth;
@property (nonatomic, assign) CGFloat imageHeight;
//当前ImageView位置
@property (nonatomic, assign) CGPoint currentPoint;

//X方向速度
@property (nonatomic, assign) CGFloat ballXVelocity;
//Y方向速度
@property (nonatomic, assign) CGFloat ballYVelocity;
@end
@implementation STBallView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        
        [self setupUI];
    }
    return self;
}


- (void)setupUI{
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.imageWidth, self.imageHeight)];
    self.imageView.image = [UIImage imageNamed:@"ball"];
    
    [self addSubview:self.imageView];
    //    设定球的初始位置
    self.currentPoint = self.center;
    self.imageView.center = self.currentPoint;
}


//重写currentPoint的set方法
- (void)setCurrentPoint:(CGPoint)currentPoint{
    _currentPoint = currentPoint;
    
    //    判断球是否在X轴方向碰触到了左侧边缘。如果碰触到了，不让其出界，同时将X方向的加速度反向减半
    if (_currentPoint.x <= self.imageWidth / 2) {
        _currentPoint.x = self.imageWidth / 2;
        self.ballXVelocity = - self.ballXVelocity / 2;
    }
    
    //    判断球是否在X轴方向碰触到了右侧边缘。如果碰触到了，不让其出界，同时将X方向的加速度反向减半
    if (_currentPoint.x >= self.bounds.size.width - self.imageWidth / 2 ) {
        _currentPoint.x = self.bounds.size.width - self.imageWidth / 2 ;
        self.ballXVelocity = - self.ballXVelocity / 2;
    }
    
    //    判断球是否在Y轴方向碰触到了上侧边缘。如果碰触到了，不让其出界，同时将X方向的加速度反向减半
    if (_currentPoint.y <= self.imageHeight / 2) {
        _currentPoint.y = self.imageHeight / 2;
        self.ballYVelocity = - self.ballYVelocity / 2;
    }
    
    //    判断球是否在Y轴方向碰触到了下侧边缘。如果碰触到了，不让其出界，同时将X方向的加速度反向减半
    if (_currentPoint.y >= self.bounds.size.height - self.imageHeight / 2) {
        _currentPoint.y = self.bounds.size.height - self.imageHeight / 2;
        self.ballYVelocity = - self.ballYVelocity / 2;
    }
    
    //    重新设置imageView的位置
    self.imageView.center = _currentPoint;
}

- (void)updateLocation{
    static NSDate *lastUpdateTime = nil;
    if (lastUpdateTime) {
        //        计算两次更新之间有多长时间
        NSTimeInterval updatePeriod = [[NSDate date] timeIntervalSinceDate:lastUpdateTime];
        
        //        计算球现在的速度。速度= 速度 + 加速度*时间
        self.ballXVelocity = self.ballXVelocity + (self.accelleration.x * updatePeriod);
        self.ballYVelocity = self.ballYVelocity + (self.accelleration.y * updatePeriod);
        
        //设置当前的imageView的中心点。后面乘以1000，是为了让小球位移的快一些，很明显能够看到效果。
        self.currentPoint = CGPointMake(self.currentPoint.x + self.ballXVelocity * updatePeriod * 5000, self.currentPoint.y - self.ballYVelocity * updatePeriod * 5000);
        NSLog(@"currentPoint.x = %f",self.currentPoint.x);
    }
    
    //    更新时间
    lastUpdateTime = [NSDate date];
}


- (CGFloat)imageWidth{
    return 50;
}

- (CGFloat)imageHeight{
    return 50;
}
@end
