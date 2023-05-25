//
//  ContentView.swift
//  WaterWise
//
//  Created by Leonard Theodorus on 19/05/23.
//

import SwiftUI
import AVFoundation
import CoreImage
struct ContentView: View {
    @State var showPicker : Bool = false
    @State var photoPlant : UIImage = UIImage()
    @StateObject var camera : CameraModel
    @State var showPhotoLibrary = false
    @State var onCamPreview = false
    @State private var zoomScale: CGFloat = 1.0
    @State private var pointFiveZoom = false
    @State private var oneZoom = true
    @State private var twoZoom = false
    @State private var confirmPhoto = false
    @State private var imageToBeProcessed : CIImage = CIImage()
    @StateObject var classifier : ImageClassifier = ImageClassifier()
    @State var toggleColor = false
    @State var result : String = ""
    var body: some View {
        NavigationView {
            VStack{
                if !onCamPreview{
                    ZStack{
                        CameraPreview(camera: camera, zoomScale: $zoomScale, plantPhoto: $photoPlant)
                            .ignoresSafeArea()
                            .frame(maxHeight: onCamPreview ? 0 : .infinity)
                       
                    }
                    
                }
                //kalo false 1, else 0
                if photoPlant != UIImage(){
                    Image(uiImage: photoPlant)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 393, height: 520)
                        
                }
                if camera.imageTaken != UIImage(){
                    Image(uiImage: camera.imageTaken)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 393, height: 520)
                        .onAppear{
                            if camera.session.isRunning{
                                camera.session.stopRunning()
                            }
                        }
                }
                GeometryReader{ proxy in
                    VStack{
                        Spacer()
                        if !onCamPreview{
                            Text(photoInstruction)
                                .fontWeight(.semibold)
                                .font(.custom(fontName, size: 20))
                                .foregroundColor(.white)
                            
                        }
                        //MARK: Zoom Buttons
                        HStack{
                            Spacer()
                            Button{
                                if pointFiveZoom{
                                    pointFiveZoom.toggle()
                                }
                                if twoZoom{
                                    twoZoom.toggle()
                                }
                                oneZoom.toggle()
                                zoomScale = 1.0
                            } label: {
                                Text("1" + (oneZoom ? "x" : ""))
                                    .foregroundColor(oneZoom ? .yellow : .white)
                                    .background(
                                        Circle()
                                            .fill(.black)
                                            .frame(width: 44, height: 44)
                                    )
                            }
                            .padding(.horizontal, 5)
                            Button{
                                if pointFiveZoom{
                                    pointFiveZoom.toggle()
                                }
                                if oneZoom{
                                    oneZoom.toggle()
                                }
                                
                                twoZoom.toggle()
                                zoomScale = 2.0
                            } label: {
                                Text("2" + (twoZoom ? "x" : ""))
                                    .foregroundColor(twoZoom ? .yellow : .white)
                                    .background(
                                        Circle()
                                            .fill(.black)
                                            .frame(width: 44, height: 44)
                                    )
                            }
                            .padding(.horizontal, 25)
                            
                            Spacer()
                        }
                        .padding()
                        .opacity(onCamPreview ? 0 : 1)
                        //MARK: Camera Toolbars
                        HStack{
                            
                            //MARK: Retake Button
                            if onCamPreview{
                                Spacer()
                                Button {
                                    camera.isTaken.toggle()
                                    onCamPreview.toggle()
                                    withAnimation {
                                        photoPlant = UIImage()
                                        camera.imageTaken = UIImage()
                                    }
                                    
                                    camera.retakePicture()
                                    
                                } label: {
                                    Text(retakeText)
                                        .lineLimit(0)
                                        .foregroundColor(Color.white)
                                        .padding(3)
                                        .background(
                                            RoundedRectangle(cornerRadius: 4)
                                                .foregroundColor(Color.white.opacity(0.3))
                                        )
                                }
                                .padding(.all, 30)
                                .frame(height: 60)
                                .onAppear{
                                    if camera.session.isRunning && photoPlant == UIImage(){
                                        camera.session.stopRunning()
                                    }
                                }
                                .onDisappear{
                                    DispatchQueue.global(qos: .background).async {
                                        if !camera.session.isRunning && photoPlant == UIImage(){
                                            camera.session.startRunning()
                                        }
                                    
                                    }
                                }
                                Spacer()
                                
                                //MARK: Use Photo Button
                                NavigationLink {
                                    ResultView(result: $result, plantPhoto: $photoPlant, camera: camera, classifierInstance: classifier)
                                } label: {
                                    Text(usePhotoText)
                                        .foregroundColor(Color.white)
                                        .padding(3)
                                        .background(
                                            RoundedRectangle(cornerRadius: 4)
                                                .foregroundColor(Color.white.opacity(0.3))
                                        )
                                        .padding(.all, 30)
                                        .frame(height: 60)
                                        .onAppear {
                                            if photoPlant == UIImage(){
                                                photoPlant = camera.imageTaken
                                                
                                            }
                                            confirmPhoto.toggle()
                                           
                                            classifier.processImage(for: imageToBeProcessed)
                                            result = classifier.result
                                            
                                        }

                                }
                                .navigationBarBackButtonHidden()
                                Spacer()
                            }
                            else{
                                Button {
                                    camera.session.stopRunning()
                                    showPhotoLibrary.toggle()
                                    
                                } label: {
                                    Image(systemName: galleryIcon)
                                        .resizable()
                                        .foregroundColor(.white)
                                        .frame(width: 50, height: 44)
                                        .padding(3)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .foregroundColor(Color.white.opacity(0.2))
                                            
                                            
                                        )
                                    
                                }
                                .opacity(onCamPreview ? 0 : 1)
                                .padding(.leading, 30)
                                .sheet(isPresented: $showPhotoLibrary, onDismiss: {
                                    if photoPlant == UIImage(){
                                        DispatchQueue.global(qos: .background).async {
                                            if !camera.session.isRunning{
                                                camera.session.startRunning()
                                            }
                                        }
                                    }
                                    else{
                                        guard let imageToBeProcessed = CIImage(image: photoPlant) else{
                                            return
                                        }
                                        classifier.processImage(for: imageToBeProcessed)
                                        result = classifier.result
                                    }
                                    
                                    
                                }
                                ) {
                                    ImagePicker(plantPhoto: $photoPlant, onCamPreview: $onCamPreview, camera: camera)
                                        .onDisappear{
                                           
                                        }
                                        
                                }
                                
                                Spacer()
                                
                                Button {
                                    camera.imageTaken = UIImage()
                                    camera.takePicture()
                                    onCamPreview.toggle()
                                } label: {
                                    Circle()
                                        .foregroundColor(.white)
                                        .frame(width: 80, height: 80, alignment: .center)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.black.opacity(0.8), lineWidth: 2)
                                                .frame(width: 65, height: 65, alignment: .center)
                                        )
                                }
                                
                                .opacity(onCamPreview ? 0 : 1)
                                .frame(height: 75)
                                
                                Spacer()
                                Button{
                                    camera.toggleFlash()
                                    withAnimation {
                                        toggleColor.toggle()
                                    }
                                    
                                } label: {
                                    Image(systemName: flashIcon)
                                        .resizable()
                                        .foregroundColor(toggleColor ? .yellow : .white)
                                        .frame(width: 44, height: 44)
                                        .padding(3)
                                    
                                    
                                }
                                .padding(.trailing, 30)
                                
                            }
                        }
                        
                        .zIndex(1)
                        .frame(width: proxy.size.width,height: proxy.size.height * 1/3)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.gray.opacity(0.7))
                        )
                        
                    }
                    
                }
                
            }
        }
        .navigationBarBackButtonHidden()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(camera: CameraModel())
    }
}
