//
//  ViewController.m
//  magnetometer
//
//  Created by Stan on 2017-06-07.
//  Copyright © 2017 stan. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>
//引入地图功能所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>
//引入定位功能所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

//使用相机需要导入这个
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate,BMKLocationServiceDelegate>
@property(strong,nonatomic)CMMotionManager *manager;
@property (weak, nonatomic) IBOutlet UILabel *physicalLocation;
@property (weak, nonatomic) IBOutlet UILabel *magnetometerInfo;


/**
 相机相关的属性

 */

//媒体管理会话
@property (strong, nonatomic) AVCaptureSession *session;
//输入数据对象
@property (strong, nonatomic) AVCaptureDeviceInput *captureInput;
//输出数据对象
@property (strong, nonatomic) AVCaptureStillImageOutput *captureOutput;
//图像预览层，实时显示捕获的图像
@property(nonatomic)AVCaptureVideoPreviewLayer *previewLayer;
//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property(nonatomic)AVCaptureDevice *device;


@property(strong,nonatomic)BMKLocationService *baiduLocationService;



@end

static CGFloat multiplier = 5;
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initCamera];

    [self setupBackground];
    
    [self.baiduLocationService startUserLocationService];
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)setupBackground {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sky"]];
    
    //    这张星空图是4000*2800的大小，要让它完全超出屏幕
    imageView.frame = CGRectMake(-self.view.frame.size.width, -(self.view.frame.size.height * 0.5), self.view.frame.size.width * 3, self.view.frame.size.height * 2);
    imageView.center = self.view.center;
    
    //    在相机层的下面添加这个背景星空图片
    [self.view insertSubview:imageView atIndex:1];
    
    //    开始使用陀螺仪
    if (self.manager.gyroAvailable) {
        self.manager.gyroUpdateInterval = 1 / 60;
        //        使用当前进程，也就是UI的进程
        [self.manager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
            
            //            做一下防抖动的处理，如果手机旋转的不太大，就不执行操作
            if (fabs(gyroData.rotationRate.x) * multiplier < 0.2 && fabs(gyroData.rotationRate.y) * multiplier < 0.2) {
                return ;
            }
            
            //            让背景图片开始随着屏幕进行移动
            CGFloat imageRotationX = imageView.center.x + gyroData.rotationRate.x * multiplier;
            CGFloat imageRotationY = imageView.center.y + gyroData.rotationRate.y * multiplier;
            
            //            因为背景图的大小事屏幕宽度的三倍，高度的两倍。为了防止超出边界，进行限制
            if (imageRotationX > self.view.frame.size.width * 1.5) {
                imageRotationX = self.view.frame.size.width * 1.5;
            }
            
            if(imageRotationX < (- self.view.frame.size.width * 0.5)){
                imageRotationX=(- self.view.frame.size.width * 0.5);
            }
            
            if (imageRotationY > self.view.frame.size.height) {
                imageRotationY = self.view.frame.size.height;
            }
            if (imageRotationY < 0) {
                imageRotationY = 0;
            }
            
            //            动画进行背景图变化
            [UIView animateWithDuration:0.3 delay:0.05 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction |
             UIViewAnimationOptionCurveEaseOut animations:^{
                 imageView.center = CGPointMake(imageRotationX, imageRotationY);
             } completion:nil];
            
        }];
    }
}

#pragma mark - 百度地图
/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {
    self.magnetometerInfo.numberOfLines = 0;
    self.magnetometerInfo.text = [NSString stringWithFormat:@"磁北：%.0f,真北：%.0f \n偏移：%.0f \nx:%.1f y:%.1f z:%.1f",
                                  userLocation.heading.magneticHeading,userLocation.heading.trueHeading,userLocation.heading.headingAccuracy,userLocation.heading.x,userLocation.heading.y,userLocation.heading.z];
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    self.physicalLocation.numberOfLines = 0;
    self.physicalLocation.text = [NSString stringWithFormat:@"经度:%f \n纬度:%f \n高度:%f",userLocation.location.coordinate.longitude,userLocation.location.coordinate.latitude,userLocation.location.altitude];
}

#pragma mark - 磁力计的两种获取数据方法PUSH & PULL
//PUSH的方法获取数据
- (void)pushMagnetometer {
    //    判断磁力计是否可用
    if (self.manager.magnetometerAvailable) {
        //        设置磁力计采样频率
        self.manager.magnetometerUpdateInterval = 0.1;
        
        //Push方式获取和处理数据，这里我们一样只是做了简单的打印。把采样的工作放在了主线程中。
        [self.manager startMagnetometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMagnetometerData * _Nullable magnetometerData, NSError * _Nullable error) {
            NSLog(@"X = %f,Y = %f,Z = %f",magnetometerData.magneticField.x,magnetometerData.magneticField.y,magnetometerData.magneticField.z);
        }];
    } else {
        NSLog(@"It cannot be used!");
    }
}


//PULL的方法获取数据
- (void)pullMagnetometer {
    //    判断磁力计是否可用
    if (self.manager.magnetometerAvailable) {
        //        设置磁力计采样频率
        self.manager.magnetometerUpdateInterval = 0.1;
        
        //开始更新，后台线程开始运行。这是Pull方式。
        [self.manager startMagnetometerUpdates];
        NSLog(@"X = %f,Y = %f,Z = %f",self.manager.magnetometerData.magneticField.x,self.manager.magnetometerData.magneticField.y,self.manager.magnetometerData.magneticField.z);
        
    } else {
        NSLog(@"It cannot be used!");
    }
}


#pragma mark - 相机
//初始化摄像头
- (void)initCamera {
    //再次确认是否已经获得了相机权限
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authorizationStatus) {
        case AVAuthorizationStatusAuthorized:
            //继续
            [self providVideoLayer];
            break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            // 用户明确地拒绝授权，或者相机设备无法访问
            NSLog(@"用户明确地拒绝授权，或者相机设备无法访问");
            break;
        case AVAuthorizationStatusNotDetermined:
            //            没有被授权，再次要求授权
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    //继续
                    [self providVideoLayer];
                } else {
                    //用户拒绝，无法继续
                    NSLog(@"用户明确地拒绝授权");
                }
            }];
            break;
    }
    //        设置一下视频预览层的大小
    self.view.layer.masksToBounds = YES;
    self.previewLayer.frame = self.view.bounds;
    //插入图层在最顶端
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
}

//提供视频输出层及内容
- (void)providVideoLayer {

    //5. 添加输入数据对象和输出对象到会话中
    if ([self.session canAddInput:self.captureInput]) {
        [self.session addInput:self.captureInput];
    }
    if ([self.session canAddOutput:self.captureOutput]) {
        [self.session addOutput:self.captureOutput];
    }
    //开始启动
    [self.session startRunning];
    if ([self.device lockForConfiguration:nil]) {
        if ([self.device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [self.device setFlashMode:AVCaptureFlashModeAuto];
        }
        //自动白平衡
        if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [self.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [self.device unlockForConfiguration];
    }
}




#pragma mark - 懒加载

//获取后置摄像头设备对象
- (AVCaptureDevice *)device {
    if (!_device) {
        NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *camera in cameras) {
            //取得后置摄像头
            if (camera.position == AVCaptureDevicePositionBack) {
                _device = camera;
            }
        }
    }
    return _device;
}


//创建视频预览图层
- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}


//输出数据对象
- (AVCaptureStillImageOutput *)captureOutput {
    if (!_captureOutput) {
        _captureOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *setting = @{ AVVideoCodecKey:AVVideoCodecJPEG };
        [_captureOutput setOutputSettings:setting];
    }
    return _captureOutput;
}


//输入数据对象
- (AVCaptureDeviceInput *)captureInput {
    if (!_captureInput) {
        NSError *error = nil;
        _captureInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:&error];
        if (error) {
            NSLog(@"创建输入数据对象错误");
        }
    }
    return _captureInput;
}


//创建媒体管理会话
- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        //判断分辨率是否支持1280*720，支持就设置为1280*720
        if( [_session canSetSessionPreset:AVCaptureSessionPresetPhoto] ) {
            _session.sessionPreset = AVCaptureSessionPresetPhoto;
        }
    }
    return _session;
}
- (CMMotionManager *)manager {
    if (!_manager) {
        _manager = [[CMMotionManager alloc] init];
    }
    return _manager;
}

- (BMKLocationService *)baiduLocationService {
    if (!_baiduLocationService) {
        _baiduLocationService = [[BMKLocationService alloc] init];
        _baiduLocationService.delegate = self;
    }
    return _baiduLocationService;
}


@end
