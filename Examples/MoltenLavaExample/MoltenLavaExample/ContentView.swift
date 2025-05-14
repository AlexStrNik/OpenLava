//
//  ContentView.swift
//  MoltenLavaExample
//
//  Created by Aleksandr Strizhnev on 14.05.2025.
//

import SwiftUI
import MoltenLava

struct ContentView: View {
    @State var renderer = LavaRenderer()
    
    var body: some View {
        VStack {
            LavaView(
                renderer: renderer
            )
            .frame(width: 64, height: 64)
            .onAppear {
                try? renderer.loadLavaAsset(
                    assetURL: Bundle.main.url(
                        forResource: "m13HomepageExperiencesTabInitialAnimationSelectedLavaAssets",
                        withExtension: nil
                    )!
                )
                renderer.play()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
