//
//  TeamMenu.swift
//
//  Created by Vik Parth on 9/27/24.
//

import SwiftUI

enum Team : String, Identifiable, CaseIterable, Equatable
{
    //Current teammates
    case kris, vik, jason
    var id: Self{self}
    var name: String{rawValue.lowercased()}
    
    var fullname: String{
        switch self{
        case.kris:
            "Kris Layng"
        case.vik:
            "Vik Parth"
        case.jason:
            "Jason Wong"
        }
    }
    
    var about: String{
        switch self{
        case.kris:
            "Spatial experience designer and creative director building uncharted virtual worlds"
        case.vik:
            "Engineer and physicist exploring the intersection of light and matter"
        case.jason:
            "Software architect specialized in gaming and reality distortion fields"
        }
    }
}
 

struct TeamMenu: View {
    var body: some View {
        //Spacer()
        VStack{
            //Render Team Overview
            Text("Meet the team")
                .monospaced()
                .font(.system(size: 30, weight: .bold))
                .padding(.top, 250)
            
            //Render Opals
            BubbleView()
            
            //Render Team information
            HStack{
                ForEach(Team.allCases){ team in
                    VStack(alignment: .leading) {
                        Image("\(team.name)")
                            .resizable()
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .frame(width: 200, height: 200)
                        Text(team.fullname)
                            .font(.system(size: 25, weight: .bold))
                        Text(team.about)
                            .font(.system(size: 14))
                    }
                    .frame(width: 250, height: 300)
                    .padding(20)
                    .glassBackgroundEffect()
                    
                }
            }
        }
        .padding()
        .background(){
            Image("interior-shot-02")
        }
    }
}

#Preview {
    TeamMenu()
}
