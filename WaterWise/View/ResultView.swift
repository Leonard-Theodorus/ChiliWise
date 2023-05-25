//
//  ResultView.swift
//  WaterWise
//
//  Created by Leonard Theodorus on 22/05/23.
//

import SwiftUI

struct ResultView: View {
    @Binding var result : String
    @Binding var plantPhoto : UIImage
    @StateObject var camera : CameraModel
    @StateObject var classifierInstance : ImageClassifier
    var body: some View {
        NavigationView {
            ZStack{
                if result == healthyResult{
                    Color.leaf_green
                        .ignoresSafeArea()
                }
                else if result == leafSpotResult || result == leafCurlResult{
                    Color.marroon
                        .ignoresSafeArea()
                }
                else{
                    Color.grayBackground
                        .ignoresSafeArea()
                }
                VStack{
                    HStack{
                        Spacer()
                        if camera.imageTaken == UIImage(){
                            Image(uiImage: plantPhoto)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 192, height: 256)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(result == healthyResult ? Color.leaf_green : Color.marroon)
                                        .shadow(radius: 6, x: 5, y: 2)
                                )
                            
                        }
                        else if result == ""{
                            EmptyView()
                        }
                        else{
                            Image(uiImage: camera.imageTaken)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 192, height: 256)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(result == healthyResult ? Color.leaf_green : Color.marroon)
                                        .shadow(radius: 6, x: 5, y: 2)
                                )
                            
                        }
                        Spacer()
                    }
                    .padding(.bottom, 34)
                    if result == healthyResult{
                        Text(healthyMessage).fontWeight(.bold)
                            .font(.custom(fontName, fixedSize: 30))
                            .fontWidth(.init(-0.62))
                            .padding(.bottom, 4)
                        Text("\(round(classifierInstance.confidenceLevels.magnitude * 100))" + "%" + " Sehat!")
                            .foregroundColor(Color.leaf_green)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 3)
                            .background(
                            RoundedRectangle(cornerRadius: 8.5)
                                .fill(.white)
                        )
                            .padding(.bottom, 17)
                        Text(healthyDetail).fontWeight(.semibold)
                            .font(.custom(fontName, size: 16))
                            .fontWidth(.init(-0.33))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 57)
                            .padding(.bottom, 43)
                        
                        
                    }
                    else if result == leafCurlResult || result == leafSpotResult{
                        Text(sickMessage).fontWeight(.bold)
                            .font(.custom(fontName, fixedSize: 30))
                            .fontWidth(.init(-0.62))
                            .padding(.bottom, 13.6)
                        Text("\(round(classifierInstance.confidenceLevels.magnitude * 100))" + "%" + " Potensi Sakit!")
                            .foregroundColor(Color.marroon)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 3)
                            .background(
                            RoundedRectangle(cornerRadius: 8.5)
                                .fill(.white)
                            
                        )
                            .padding(.bottom, 5)
                        Text(sickMessageBody1).fontWeight(.semibold)
                            .font(.custom(fontName, size: 16))
                            .fontWidth(.init(-0.33))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 50)
                            .padding(.bottom, 32)
                        
                        Text(sickMessageBody2).fontWeight(.semibold)
                            .font(.custom(fontName, size: 16))
                            .fontWidth(.init(-0.33))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 70)
                            .padding(.bottom, 16)
                    }
                    else{
                        Image("WrongLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 160.68, height: 131.39)
                        
                        Text(plantNotDetectedText)
                            .fontWeight(.bold)
                            .font(.custom(fontName, size: 22))
                            .fontWidth(.init(-0.33))
                            .foregroundColor(Color.grayResult)
                            .padding(.top, 12.61)
                            .padding(.horizontal, 57)
                        
                        Text(invalidPhotoText)
                            .fontWeight(.regular)
                            .font(.custom(fontName, size: 14))
                            .fontWidth(.init(-0.29))
                            .foregroundColor(Color.grayResult)
                            .multilineTextAlignment(.center)
                            .padding(.top, 1)
                            .padding(.horizontal, 71)
                            .padding(.bottom, 40.36)
                        
                        
                    }
                    NavigationLink{
                        HomeView()
                    } label: {
                        Text(returnToHome)
                            .fontWeight(.semibold)
                            .font(.custom(fontName, size: 16))
                            .fontWidth(.init(-0.33))
                            .foregroundColor(result == "" ? Color.grayBackground : Color.leaf_green)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(result == "" ? Color.leaf_green : Color.creme)
                                    
                            )
                    }
                    .navigationBarBackButtonHidden(true)
                    
                }
            }
            .onDisappear{
                result = ""
            }
        }
        .navigationBarBackButtonHidden()
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView(result: .constant(""), plantPhoto: .constant(UIImage()), camera: CameraModel(), classifierInstance: ImageClassifier())
    }
}
