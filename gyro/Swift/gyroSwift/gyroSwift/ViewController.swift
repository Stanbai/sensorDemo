//
//  ViewController.swift
//  gyroSwift
//
//  Created by Stan on 2017-05-28.
//  Copyright © 2017 stan. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    var manager = CMMotionManager()
    var ballView : STBallView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ballView = STBallView.init(frame: view.bounds)
        playBall()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func playBall() {
        ballView!.backgroundColor = UIColor.clear
        view.addSubview(ballView!)
        
        manager.deviceMotionUpdateInterval = 1 / 60
        //注意一下，在Swift没有了NSOperation。被OperationQueue取代了。
        manager.startDeviceMotionUpdates(to: OperationQueue.main) { (motion, error) in
            
            self.ballView!.accelleration = (motion?.gravity)!
            //开启主队列异步线程，更新球的位置。
            DispatchQueue.main.async {
                self.ballView!.updateLocation(multiplier: 5000)
            }
        }
        
        
    }
    
    //    MARK: - 陀螺仪的两种获取数据方法PUSH & PULL
    private func useGyroPull() {
        //判断陀螺仪可不可用
        if manager.isGyroAvailable {
            //设置陀螺仪多久采样一次
            manager.gyroUpdateInterval = 0.1
            //开始更新，后台线程开始运行。这是Pull方式。
            manager.startGyroUpdates()
            
        }
        //获取并处理陀螺仪数据。这里我们就只是简单的做了打印。
        print("X = \(manager.gyroData?.rotationRate.x ?? 0)","Y = \(manager.gyroData?.rotationRate.y ?? 0)","Z = \(manager.gyroData?.rotationRate.z ?? 0)")
    }
    
    private func useGyroPush() {
        //判断陀螺仪可不可用
        if manager.isGyroAvailable {
            //设置陀螺仪多久采样一次
            manager.gyroUpdateInterval = 0.1
            //Push方式获取和处理数据，这里我们一样只是做了简单的打印。把采样的工作放在了主线程中。
            manager.startGyroUpdates(to: OperationQueue.main, withHandler: { (gyroData, error) in
                print("X = \(self.manager.gyroData?.rotationRate.x ?? 0)","Y = \(self.manager.gyroData?.rotationRate.y ?? 0)","Z = \(self.manager.gyroData?.rotationRate.z ?? 0)")
                
            })
        } else {
            print("陀螺仪不可用")
        }
    }
    
}
