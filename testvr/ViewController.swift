//
//  ViewController.swift
//  testvr
//
//  Created by nixinyu on 16/7/26.
//  Copyright © 2016年 nixinyu. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation

class ViewController: UIViewController,UIAccelerometerDelegate{
    
    @IBOutlet weak var capturedImage: UIImageView!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var spinner:UIActivityIndicatorView!
    @IBOutlet weak var startButton:UIButton!
    @IBOutlet weak var processing:UITextField!
    @IBOutlet weak var currentAngleShow:UITextField!
    @IBOutlet weak var runtimeAngleShow:UITextField!
    @IBOutlet weak var runtimePitch:UITextField!
    
    
    @IBAction func startcaptureButton(sender: AnyObject) {
        self.startcapture()
    }
    var imageArray:[UIImage] = []
    var panoramaArray:[UIImage] = []
    var isCaptureEnd = false
    var nextCapture = true
    var isforth = true
    var currentAngle = 0.0
    var takedNum = 0.0
    let deltaAngle = 15.0
    let segmentAngle = 180.0
    let segmentAngleBack = 10.0
    let imageRectWidth = CGFloat(600)
    let imageRectHeight = CGFloat(800)

    
    func captureImage(){
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            videoConnection.videoScaleAndCropFactor = 1
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    
                    var image = UIImage(CGImage: cgImageRef!, scale: 1, orientation: UIImageOrientation.Right)
                    self.resizeImage(&image)
                    
                    //                    var newImage:UIImage?
                    //                    self.processing.text = "stitching..."
                    //                    if self.capturedImage.image == nil {
                    //                        newImage = image
                    //                    }else{
                    //                        newImage = CVWrapper.processWithOpenCVImage1(self.capturedImage.image,image2: image)
                    //                    }
                    //                    if newImage != nil {
                    //                        self.nextCapture = true
                    //                        self.takedNum+=1
                    //                        self.capturedImage.image = newImage
                    //                        self.processing.text = "go next " + String(self.takedNum)
                    //                        print("go next")
                    //                    }else{
                    //                        self.nextCapture = false
                    //                        self.processing.text = "stitch fail"
                    //                        print("stitch fail")
                    //                    }
                    //
                    //                    if self.takedNum % (ceil(self.segmentAngle/self.deltaAngle)) == 0 {
                    //                        UIImageWriteToSavedPhotosAlbum(self.capturedImage.image!, self, #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    //                        self.imageArray.append(self.capturedImage.image!.copy() as! UIImage)
                    //                        self.capturedImage.image = nil
                    //                        //                        if self.isforth {
                    //                        //                            self.currentAngle -= self.segmentAngleBack
                    //                        //                        }else{
                    //                        //                            self.currentAngle += self.segmentAngleBack
                    //                        //                            if self.currentAngle >= 180 {
                    //                        //                            self.isforth = true
                    //                        //                                self.currentAngle = 360 - self.currentAngle
                    //                        //                            }
                    //                        //                        }
                    //                    }
                    
                    //                    if self.takedNum % (ceil(self.segmentAngle/self.deltaAngle)) == 0 && self.imageArray.count > 1{
                    //                        UIImageWriteToSavedPhotosAlbum(CVWrapper.processWithArray(self.imageArray) as UIImage, self, #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    //                    }
                    if self.takedNum % (floor(self.segmentAngle/self.deltaAngle)) == 0 && self.imageArray.count > 1{
                        let temppanarama = CVWrapper.processPanoramaWithArray(self.imageArray) as UIImage
                        self.panoramaArray.append(temppanarama)
                        UIImageWriteToSavedPhotosAlbum(temppanarama, self, #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
                        self.imageArray.removeAll()
//                        if self.isforth {
//                            self.currentAngle -= self.segmentAngleBack
//                        }else{
//                            self.currentAngle += self.segmentAngleBack
//                            if self.currentAngle >= 180 {
//                                self.isforth = true
//                                self.currentAngle = 360 - self.currentAngle
//                            }
//                        }
                    }
                    self.takedNum+=1
                    self.capturedImage.image = image
                    self.processing.text = "go next " + String(self.takedNum)
                    self.imageArray.append(image.copy() as! UIImage)
                    
                }
            })
        }
    }
    
    func resizeImage(inout image: UIImage){
        let size = image.size
        
        let targetSize = CGSizeMake(self.imageRectWidth, self.imageRectHeight)
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        image = UIGraphicsGetImageFromCurrentImageContext()
        //newImage = UIImage(data:UIImageJPEGRepresentation(newImage,0.5)!)!
        UIGraphicsEndImageContext()
    }
    
    //    func doStitch() {
    //        //由于图片拼接很费时,显示环形进度条
    //        self.spinner.startAnimating()
    //        //在后台队列拼接图片
    //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
    //            let image1 = UIImage(named:"1.jpg")
    //            let image2 = UIImage(named:"2.jpg")
    //            let image3 = UIImage(named:"3.jpg")
    //            let image4 = UIImage(named:"4.jpg")
    //
    //            let imageArray:[UIImage!] = [image1,image2,image3,image4]
    //            //let imageArray:[UIImage!] = [image1,image2]
    //
    //            let stitchedImage:UIImage = CVWrapper.processWithArray(imageArray) as UIImage
    //
    //            dispatch_async(dispatch_get_main_queue(), {
    //                self.imageView.image = stitchedImage
    //                //停止环形进度条效果
    //                self.spinner.stopAnimating()
    //            })
    //        }
    //    }
    
    func doStitch() -> Void{
        self.processing.text = "stitching..."
        //由于图片拼接很费时,显示环形进度条
        self.spinner.startAnimating()
        //        if self.capturedImage.image != nil {
        //            self.imageArray.append(self.capturedImage.image!.copy() as! UIImage)
        //            self.capturedImage.image = nil
        //        }
        //        for image in self.imageArray {
        //            UIImageWriteToSavedPhotosAlbum(image, self, #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        //        }
        
        if self.imageArray.count > 1{
            let temppanarama = CVWrapper.processPanoramaWithArray(self.imageArray) as UIImage
            self.panoramaArray.append(temppanarama)
            UIImageWriteToSavedPhotosAlbum(temppanarama, self, #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
            self.imageArray.removeAll()
        }
        
        //在后台队列拼接图片
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let stitchedImage:UIImage = CVWrapper.processWithArray(self.panoramaArray) as UIImage
            
            dispatch_async(dispatch_get_main_queue(), {
                self.capturedImage.image = stitchedImage
                //停止环形进度条效果
                self.spinner.stopAnimating()
                UIImageWriteToSavedPhotosAlbum(stitchedImage, self, #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
                self.processing.text = "finish"
                
                print("finish")
            })
        }
    }
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var ball:UIImageView!
    var speedX:UIAccelerationValue=0
    var speedY:UIAccelerationValue=0
    var motionManager = CMMotionManager()
    
    var q = 0.1;   // process noise
    var r = 0.1;   // sensor noise
    var p = 0.1;   // estimated error
    var k = 0.5;   // kalman filter gain
    
    var motionLastRoll = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func startcapture(){
        self.processing.text = "start"
        print("start")
        self.takedNum = 0
        self.imageArray.removeAll()
        self.panoramaArray.removeAll()
        self.isCaptureEnd = false
        self.nextCapture = true
        isforth = true
        var lastTake = false
        self.motionManager.stopDeviceMotionUpdates()
        self.capturedImage.image = nil
        if(motionManager.deviceMotionAvailable){
            motionManager.startDeviceMotionUpdates()
            sleep(1)
            motionManager.deviceMotionUpdateInterval = 1/60
            let queue = NSOperationQueue.currentQueue()
            motionManager.startDeviceMotionUpdatesToQueue(queue!, withHandler:{ (accelerometerData : CMDeviceMotion?, error: NSError?) -> Void in
                // translate the attitude
                
                self.currentAngleShow.text = String(self.currentAngle)
                self.runtimeAngleShow.text = String(-1*self.motionLastRoll/M_PI*180)
                self.updateMotionLastRoll(accelerometerData!.attitude)
                if !self.validatePitch(accelerometerData!.attitude) {
                    return
                }
                if self.isforth && self.motionLastRoll < 0 {
                    if floor(-1*self.motionLastRoll/M_PI*180) == self.currentAngle {
                        self.captureImage()
                        //dump(currentAngle)
                        //dump(self.motionLastRoll)
                        if self.nextCapture {
                            if self.currentAngle + self.deltaAngle >= 180{
                                self.currentAngle = 180
                            }else{
                                self.currentAngle += self.deltaAngle
                            }
                        }else{
                            print("go back")
                            self.currentAngle -= 1
                        }
                    }
                    if(self.currentAngle == 180){
                        self.isforth = false
                        
//                        let temppanarama = CVWrapper.processPanoramaWithArray(self.imageArray) as UIImage
//                        self.panoramaArray.append(temppanarama)
//                        UIImageWriteToSavedPhotosAlbum(temppanarama, self, #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
//                        self.imageArray.removeAll()
                        
                        //                        UIImageWriteToSavedPhotosAlbum(CVWrapper.processWithArray(self.imageArray) as UIImage, self, #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    }
                }
                if !self.isforth && self.motionLastRoll > 0{
                    if ceil(self.motionLastRoll/M_PI*180) == self.currentAngle {
                        self.captureImage()
                        //                        dump(currentAngle)
                        //                        dump(self.motionLastRoll)
                        if self.nextCapture {
                            if self.currentAngle == 1 {
                                lastTake = true
                            }else if self.currentAngle - self.deltaAngle <= 0{
                                self.currentAngle = 1
                            }else{
                                self.currentAngle -= self.deltaAngle
                            }
                        }else{
                            print("go back")
                            self.currentAngle += 1
                            if self.currentAngle >= 180 {
                                self.isforth = true
                                self.currentAngle = 180 - 1
                            }
                        }
                    }
                    if(lastTake && !self.isCaptureEnd){
                        self.isCaptureEnd = true
                        self.motionManager.stopDeviceMotionUpdates()
                        
//                        let temppanarama = CVWrapper.processPanoramaWithArray(self.imageArray) as UIImage
//                        self.panoramaArray.append(temppanarama)
//                        UIImageWriteToSavedPhotosAlbum(temppanarama, self, #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
//                        self.imageArray.removeAll()
                        
                        self.doStitch()
                        //UIImageWriteToSavedPhotosAlbum(self.capturedImage.image!, self, #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
                        return
                    }
                }
            })
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        //        if didFinishSavingWithError != nil {
        if error != nil {
            print(error)
            self.processing.text = "保存失败"
            print("保存失败")
            return
        }
        self.processing.text = "保存成功"
        print("保存成功")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do {
            try backCamera.lockForConfiguration()
            if backCamera.hasFlash {
                backCamera.flashMode = .Off
            }
            if backCamera.isFocusModeSupported(.Locked) {
                backCamera.focusMode = .Locked
            }
            if backCamera.isWhiteBalanceModeSupported(.AutoWhiteBalance) {
                backCamera.whiteBalanceMode = .ContinuousAutoWhiteBalance
            }
            backCamera.unlockForConfiguration()
        } catch {
            backCamera.unlockForConfiguration()
        }
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession!.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                previewView.layer.addSublayer(previewLayer!)
                
                captureSession!.startRunning()
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer!.frame = previewView.bounds
    }
    
    func updateMotionLastRoll(attitude: CMAttitude) -> Void{
        
        let currentRoll = atan2(2*(attitude.quaternion.w*attitude.quaternion.z+attitude.quaternion.x*attitude.quaternion.y),(1-2*(pow(attitude.quaternion.y,2)+pow(attitude.quaternion.z,2))))
        self.runtimePitch.text = String(atan2(2*(attitude.quaternion.w*attitude.quaternion.x+attitude.quaternion.y*attitude.quaternion.z),(1-2*(pow(attitude.quaternion.x,2)+pow(attitude.quaternion.y,2))))/M_PI*180)
        if (self.motionLastRoll == 0) {
            self.motionLastRoll = currentRoll;
        }
        var x = self.motionLastRoll;
        self.p = self.p + self.q;
        self.k = self.p / (self.p + self.r);
        x = x + self.k*(currentRoll - x);
        self.p = (1 - self.k)*self.p;
        self.motionLastRoll = x;
    }
    
    func validatePitch(attitude: CMAttitude) -> Bool{
        
        let pitch = atan2(2*(attitude.quaternion.w*attitude.quaternion.x+attitude.quaternion.y*attitude.quaternion.z),(1-2*(pow(attitude.quaternion.x,2)+pow(attitude.quaternion.y,2))))/M_PI*180
        if floor(pitch) == 90 {
            return true
        }else{
            return false
        }
    }
    
    func quaternionToEulerFromAttitudeWithRoll(attitude: CMAttitude) -> Double {
        return atan2(2*(attitude.quaternion.w*attitude.quaternion.z+attitude.quaternion.x*attitude.quaternion.y),(1-2*(pow(attitude.quaternion.y,2)+pow(attitude.quaternion.z,2))))
    }// initial configurationvar
    
    func quaternionToEulerFromAttitudeWithPitch(attitude: CMAttitude) -> Double {
        return atan2(2*(attitude.quaternion.w*attitude.quaternion.x+attitude.quaternion.y*attitude.quaternion.z),(1-2*(pow(attitude.quaternion.x,2)+pow(attitude.quaternion.y,2))))
    }// initial configurationvar
    
    func magnitudeFromAttitude(attitude: CMAttitude) -> Double {
        return sqrt(pow(attitude.roll, 2) + pow(attitude.yaw, 2) + pow(attitude.pitch, 2))
    }// initial configurationvar
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

