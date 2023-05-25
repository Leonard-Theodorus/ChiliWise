//
//  ImagePicker.swift
//  WaterWise
//
//  Created by Leonard Theodorus on 19/05/23.
//
import SwiftUI
import PhotosUI
struct ImagePicker : UIViewControllerRepresentable{
    @Binding var plantPhoto : UIImage
    @Binding var onCamPreview : Bool
    @StateObject var camera : CameraModel
    func makeUIViewController(context: Context) ->  UIImagePickerController{
        var config = PHPickerConfiguration()
        config.filter = .images
//        let picker = PHPickerViewController(configuration: config)
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = context.coordinator
        return picker
        
    }
        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
//    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    func makeCoordinator() -> Coordinator {
        return Coordinator(photoPicker: self)
    }
    
        class Coordinator : NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
            let photoPicker : ImagePicker
            init(photoPicker : ImagePicker){
                self.photoPicker = photoPicker
            }
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                if let image = info[.editedImage] as? UIImage{
                    DispatchQueue.global(qos: .background).async {
                        if !self.photoPicker.camera.session.isRunning{
                            self.photoPicker.camera.session.startRunning()
                        }
                        self.photoPicker.plantPhoto = image
                    }
    
                }
                else{
                    //show an alert kalo imagenya nil
                }
                photoPicker.onCamPreview.toggle()
                photoPicker.camera.isFinished = true
                picker.dismiss(animated: true)
    
            }
        }
//    final class Coordinator : NSObject, PHPickerViewControllerDelegate{
//        let photoPicker : ImagePicker
//        init(photoPicker : ImagePicker){
//            self.photoPicker = photoPicker
//
//        }
//        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//            picker.dismiss(animated: true)
//            guard let provider = results.first?.itemProvider else {return}
//            if provider.canLoadObject(ofClass: UIImage.self){
//                DispatchQueue.global(qos: .background).async {
//                    if !self.photoPicker.camera.session.isRunning{
//                        self.photoPicker.camera.session.startRunning()
//                    }
//                    DispatchQueue.main.async {
//                        provider.loadObject(ofClass: UIImage.self) { image, _ in
//                            self.photoPicker.plantPhoto = (image as? UIImage)!
//
//                        }
//
//                    }
//                }
//            }
//            photoPicker.onCamPreview.toggle()
//            photoPicker.camera.isFinished = true
//        }
//    }
    
}
