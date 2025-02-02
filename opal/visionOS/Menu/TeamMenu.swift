//
//  TeamMenu.swift
//
//  Created by Vik Parth on 9/27/24.
//

import SwiftUI

enum Team : String, Identifiable, CaseIterable, Equatable
{
    //Current teammates
    case kris, vik, jason, pablo
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
        case.pablo:
            "Pablo Vela"
        }
    }
    
    var about: String{
        switch self{
        case.kris:
            "Spatial designer and creative director building uncharted virtual worlds"
        case.vik:
            "Hologram specialist exploring the intersection of light and matter"
        case.jason:
            "Software architect specializing in gaming and reality distortion fields"
        case.pablo:
            "Computer Vision engineer exploring the nature of Gaussian splats"
        }
    }
}
 
struct TeamMenu: View {
    var body: some View {
        ZStack{
            VStack{
                Text("Meet the team")
                    .monospaced()
                    .font(.system(size: 30, weight: .bold))
                    .padding()
                VStack {
                    HStack {
                        TeamCard(team: .vik)
                        TeamCard(team: .kris)
                    }
                    HStack {
                        TeamCard(team: .jason)
                        TeamCard(team: .pablo)
                    }
                }
            }
            
            //Render Opals
            BubbleView()
        }
        .padding()
        .background(){
            Image("interior-shot-02")
        }
    }
}

struct TeamCard: View {
    let team: Team
    var body: some View {
        VStack(alignment: .leading) {
            Image(team.name)
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .frame(width: 200, height: 200)
            Text(team.fullname)
                .font(.system(size: 24, weight: .bold))
            Text(team.about)
                .font(.system(size: 16))
        }
        .frame(width: 300, height: 300)
        .padding()
        .glassBackgroundEffect()
    }
}

#Preview {
    TeamMenu()
}
