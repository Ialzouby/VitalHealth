//
//  SummaryCardView.swift
//  VitalHealth
//
//  Created by TechnoLab on 11/24/24.
//

import SwiftUI

struct SummaryCardView: View {
    var title: String
    var value: String
    var subtitle: String?
    var icon: String
    var iconColor: Color

    var body: some View {
        HStack {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 24))
            }
            
            // Text Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(value)
                    .font(.title3)
                    .bold()
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
        .padding(.horizontal)
    }
}
