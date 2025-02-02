//
//  TeamView.swift
//  opal
//
//  Created by Vik Parth on 1/29/25.
//

import SwiftUI

enum Team: String, Identifiable, CaseIterable, Equatable {
    case vik, pablo, jason, kris
    var id: Self { self }
    var name: String { rawValue.lowercased() }
    
    var fullname: String {
        switch self {
        case .vik: "Vik Parth"
        case .pablo: "Pablo Vela"
        case .jason: "Jason Wong"
        case .kris: "Kris Layng"
        }
    }
    
    var about: String {
        switch self {
        case .vik: "Hologram specialist exploring the intersection of light and matter"
        case .pablo: "Computer Vision engineer exploring the nature of Gaussian splats"
        case .jason: "Software architect specializing in gaming and reality distortion fields"
        case .kris: "Spatial designer and creative director building uncharted virtual worlds"
        }
    }
}

struct TeamView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Meet the team")
                .font(.title)
                .bold()
                .padding(.top)
            
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    TeamCard(member: .vik)
                    TeamCard(member: .pablo)
                }
                HStack(spacing: 20) {
                    TeamCard(member: .jason)
                    TeamCard(member: .kris)
                }
            }
            .padding()
        }
    }
}

struct TeamCard: View {
    let member: Team
    var body: some View {
        VStack(alignment: .leading) {
            Image(member.name)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            Text(member.fullname)
                .font(.headline)
                .padding(.top, 4)
            
            Text(member.about)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 2)
        }
        .padding(10)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 3)
    }
}
