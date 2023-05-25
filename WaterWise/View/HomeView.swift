//
//  HomeView.swift
//  WaterWise
//
//  Created by Leonard Theodorus on 22/05/23.
//

import SwiftUI

struct HomeView: View {
    @State var cameraPresent = false
    @StateObject var camera : CameraModel = CameraModel()
    var body: some View {
        NavigationView {
            ZStack{
                Color.creme
                    .ignoresSafeArea()
                VStack{
                    Image(chiliHome)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 232, height: 232)
                    Text(checkTitle)
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .font(.custom(fontName, fixedSize: 30))
                        .fontWidth(.init(-0.62))
                        .padding(.bottom, 33)
                    
                    Text(messageHomeView)
                        .foregroundColor(.black)
                        .fontWeight(.semibold)
                        .font(.custom(fontName, size: 18))
                        .fontWidth(.init(-0.33))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 25)
                        .padding(.bottom, 60)
                    NavigationLink{
                        ContentView(camera: camera)
                    } label: {
                        Text(photoNow)
                            .foregroundColor(.creme)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.leaf_green)
                                    .frame(width: 213, height: 47)
                                    
                            )
                    }
                    .navigationTitle("")
                    
                   
                    
                }
            }
            .onAppear{
                camera.requestAuthorizationForCamera()
            }
        }
        .navigationBarBackButtonHidden()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
