//
//  TabView.swift
//  LG26
//
//  Created by Alex on 2025-09-25.
//

import SwiftUI

struct TabsView: View {
   

    var body: some View {
        TabView() {
            Tab("Contacts", systemImage: "person.crop.circle.fill") {
                ContactsView()
            }
            
            Tab("Calls", systemImage: "clock.fill") {
                ProfileView()
            }
            
            Tab("Keyboard", systemImage: "keyboard") {
                ProfileView()
            }
            
            Tab("Add", systemImage: "plus", role: .search) {
                EmptyView() // Replace with your view
            }
        }
    }
}



#Preview {
    TabsView()
}
