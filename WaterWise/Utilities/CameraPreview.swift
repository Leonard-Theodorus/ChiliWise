//
//  CameraPreview.swift
//  WaterWise
//
//  Created by Leonard Theodorus on 19/05/23.
//
import SwiftUI
import AVFoundation
struct CameraPreview : UIViewRepresentable{
    @StateObject var camera : CameraModel
    @Binding var zoomScale : CGFloat
    @Binding var plantPhoto : UIImage
    private let pinchGesture = UIPinchGestureRecognizer()
    private let backCameraDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back)
//    let didFinishProcessingPhoto : (Result<AVCapturePhoto, Error>) -> ()
    func makeCoordinator() -> Coordinator {
        return Coordinator(cameraPreview: self)
    }
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.zoom))
        view.addGestureRecognizer(pinchGesture)
        guard let device = backCameraDevice else {return UIView()}
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = zoomScale
            if device.videoZoomFactor < 1.0{
                device.videoZoomFactor = 1.0
            }
            device.unlockForConfiguration()
        } catch {
            print("Failed to configure zoom: \(error)")
        }
        camera.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: camera.session)
        
        camera.cameraPreviewLayer.frame = view.frame
        camera.cameraPreviewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.cameraPreviewLayer)
        DispatchQueue.global(qos: .background).async {
            camera.session.startRunning()
        }
        
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let device = backCameraDevice else {return}
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = zoomScale
            device.unlockForConfiguration()
        } catch {
            print("Failed to update zoom: \(error)")
        }
    }
    final class Coordinator: NSObject {
        let cameraPreviewInstance : CameraPreview
        private var currentZoomScale: CGFloat = CGFloat()
        init(cameraPreview : CameraPreview) {
            self.cameraPreviewInstance = cameraPreview
            currentZoomScale = cameraPreviewInstance.zoomScale
//            self.didFinishProcessingPhoto = didFinishProcessingPhoto
        }
        @objc func zoom(_ pinch: UIPinchGestureRecognizer) {
            guard let device = cameraPreviewInstance.backCameraDevice
              else { return }
            let scaleFactor = min(max(pinch.scale * currentZoomScale, 1.0), device.activeFormat.videoMaxZoomFactor)
            print(scaleFactor)
            if pinch.state == .ended {
              currentZoomScale = scaleFactor
            }
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = scaleFactor
                defer { device.unlockForConfiguration() }
                if device.videoZoomFactor < 1.0{
                    device.videoZoomFactor = 1.0
                }
                
                
            } catch {
                print(error)
            }
        }
    }

    
}
