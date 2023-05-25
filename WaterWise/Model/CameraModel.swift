//
//  CameraModel.swift
//  WaterWise
//
//  Created by Leonard Theodorus on 19/05/23.
//

import Foundation
import AVFoundation
import SwiftUI
class CameraModel : NSObject, AVCapturePhotoCaptureDelegate,ObservableObject{
    @Published var isTaken = false
    @Published var session = AVCaptureSession()
    @Published var denied : Bool = false
    @Published var output = AVCapturePhotoOutput()
    @Published var cameraPreviewLayer = AVCaptureVideoPreviewLayer()
    @Published var imageTaken : UIImage = UIImage()
    @Published var isFinished = false
    @Published var backCameraDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back)
    let photoSettings = AVCapturePhotoSettings()
    func requestAuthorizationForCamera(){
        
        switch AVCaptureDevice.authorizationStatus(for: .video){
            case .authorized:
                if session.isRunning{
                    session.stopRunning()
                }
                cameraSetup()
            case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) {[weak self] granted in
                if granted{
                    if ((self?.session.isRunning) != nil){
                        self?.session.stopRunning()
                    }
                    self?.cameraSetup()
                }
            }
            case .denied:
                denied.toggle()
                return
            default:
                return
        }
    }
    func cameraSetup(){
        do{
            
            self.session.beginConfiguration()
            self.session.sessionPreset = AVCaptureSession.Preset.photo
            //CaptureDevice yang dituju
            let input = try AVCaptureDeviceInput(device: backCameraDevice!)
            if self.session.canAddInput(input){
                self.session.addInput(input)
            }
            if self.session.canAddOutput(output){
                self.session.addOutput(output)
            }
            self.session.commitConfiguration()
        }
        catch{
            print(error.localizedDescription)
        }
    }
    func takePicture(){
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
       
        DispatchQueue.main.async {
            withAnimation {
                self.isTaken.toggle()
            }
        }
    }
    func retakePicture(){
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
        DispatchQueue.main.async {
            withAnimation {
                self.isTaken.toggle()
            }
        }
    }
    func enableFlash(){
        do{
            if((backCameraDevice?.hasTorch) != nil){
                try backCameraDevice?.lockForConfiguration()
                backCameraDevice?.torchMode = .on
                photoSettings.flashMode = .on
                backCameraDevice?.unlockForConfiguration()
            }
        }
        catch{
            print(error.localizedDescription)
        }
    }
    func disableFlash(){
        do{
            if((backCameraDevice?.hasTorch) != nil){
                try backCameraDevice?.lockForConfiguration()
                backCameraDevice?.torchMode = .off
                photoSettings.flashMode = .off
                backCameraDevice?.unlockForConfiguration()
            }
        }
        catch{
            print(error.localizedDescription)
        }
    }
    func toggleFlash(){
        if ((backCameraDevice?.hasTorch) != nil){
            self.session.beginConfiguration()
            if backCameraDevice?.isTorchActive == false{
                self.enableFlash()
            }
            else{
                self.disableFlash()
            }
            self.session.commitConfiguration()
        }
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil{
            return
        }
        guard let data = photo.fileDataRepresentation() else {return}
        withAnimation {
            DispatchQueue.main.async {
                self.imageTaken = UIImage(data: data) ?? UIImage()
            }
            
        }
        
        
    }
}
