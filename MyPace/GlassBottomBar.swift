//
//  GlassBottomBar.swift
//  MyPace
//
//  Created by Carlos Felipe Araújo on 09/12/25.
//

import SwiftUI

enum MainTab {
    case run
    case history
    case settings
}

struct GlassBottomBar: View {
    @Binding var selectedTab: MainTab
    
    var body: some View {
        HStack(spacing: 32) {
            tabButton(
                icon: "figure.run",
                title: "Início",
                tab: .run
            )
            
            tabButton(
                icon: "clock.arrow.circlepath",
                title: "Histórico",
                tab: .history
            )
            
            tabButton(
                icon: "gearshape",
                title: "Config.",
                tab: .settings
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial) // efeito "liquid glass"
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(radius: 20)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    @ViewBuilder
    private func tabButton(icon: String, title: String, tab: MainTab) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                
                Text(title)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .foregroundStyle(selectedTab == tab ? Color.primary : Color.secondary)
            .opacity(selectedTab == tab ? 1.0 : 0.7)
            .scaleEffect(selectedTab == tab ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var selectedTab: MainTab = .run
    
    VStack {
        Spacer()
        GlassBottomBar(selectedTab: $selectedTab)
    }
}
