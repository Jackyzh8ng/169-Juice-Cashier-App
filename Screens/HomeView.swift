//
//  HomeView.swift
//  169 Juice Cashir App
//
//  Created by Jacky Zheng on 2025-09-09.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedFlavours: Set<Flavour> = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                // CUP
                NavigationLink {
                    FlavourSelect(selected: $selectedFlavours)
                } label: {
                    Label("Cup", systemImage: "cup.and.saucer")
                        .font(.title)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }

                // PINEAPPLE
                NavigationLink {
                    FlavourSelect(selected: $selectedFlavours)
                } label: {
                    Label("Pineapple", systemImage: "carrot") // placeholder
                        .font(.title)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.yellow)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }

                // WATERMELON (currently stays here)
                Button(action : {
                    print("Watermelon tapped")
                }) {
                    Label("Watermelon", systemImage: "leaf") // placeholder
                        .font(.title)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
            }
            .padding()
            .navigationTitle("169 Juice")
        }
    }
}
