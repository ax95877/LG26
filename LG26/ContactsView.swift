//
//  ContactsView.swift
//  LG26
//
//  Created by Alex on 2025-09-22.
//

import SwiftUI

struct Contact: Identifiable {
    let id = UUID()
    let name: String
    let phoneNumber: String
    let email: String
    let initials: String
    let color: Color
    
    static let sampleContacts = [
        Contact(name: "Emily Johnson", phoneNumber: "+1 (555) 123-4567", email: "emily.j@email.com", initials: "EJ", color: .blue),
        Contact(name: "Michael Chen", phoneNumber: "+1 (555) 987-6543", email: "m.chen@email.com", initials: "MC", color: .green),
        Contact(name: "Sarah Williams", phoneNumber: "+1 (555) 456-7890", email: "sarah.w@email.com", initials: "SW", color: .purple),
        Contact(name: "David Rodriguez", phoneNumber: "+1 (555) 321-0987", email: "d.rodriguez@email.com", initials: "DR", color: .orange),
        Contact(name: "Jessica Taylor", phoneNumber: "+1 (555) 654-3210", email: "j.taylor@email.com", initials: "JT", color: .pink),
        Contact(name: "Alex Thompson", phoneNumber: "+1 (555) 789-0123", email: "alex.t@email.com", initials: "AT", color: .teal),
        Contact(name: "Lisa Anderson", phoneNumber: "+1 (555) 147-2580", email: "l.anderson@email.com", initials: "LA", color: .red),
        Contact(name: "Ryan Parker", phoneNumber: "+1 (555) 369-2580", email: "ryan.p@email.com", initials: "RP", color: .indigo),
        Contact(name: "Emma Davis", phoneNumber: "+1 (555) 258-1470", email: "emma.d@email.com", initials: "ED", color: .cyan),
        Contact(name: "James Wilson", phoneNumber: "+1 (555) 741-8520", email: "james.w@email.com", initials: "JW", color: .mint)
    ]
}

struct ContactsView: View {
    @State private var contacts = Contact.sampleContacts
    @State private var searchText = ""
    
    var filteredContacts: [Contact] {
        if searchText.isEmpty {
            return contacts
        } else {
            return contacts.filter { contact in
                contact.name.localizedCaseInsensitiveContains(searchText) ||
                contact.phoneNumber.contains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
//                LinearGradient(
//                    gradient: Gradient(colors: [
//                        Color(.systemBackground),
//                        Color(.systemGray6).opacity(0.3)
//                    ]),
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//                .ignoresSafeArea()
                
                // Liquid gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.red.opacity(0.25),
                        Color.blue.opacity(0.25),
                        Color.cyan.opacity(0.2),
                        Color.mint.opacity(0.15)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    // Contacts list
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredContacts) { contact in
                                NavigationLink {
                                    ContactDetailsView(contact: contact)
                                } label: {
                                    ContactRow(contact: contact)
                                }
                                .buttonStyle(.plain)
                                
                                if contact.id != filteredContacts.last?.id {
                                    Divider()
                                        .padding(.leading, 80)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("Contacts")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16, weight: .medium))
                
                TextField("Search contacts", text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isEditing = true
                        }
                    }
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                    }
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isEditing ? Color.accentColor : Color.clear, lineWidth: 2)
                    )
            )
            
            if isEditing {
                Button("Canel") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isEditing = false
                        text = ""
                        hideKeyboard()
                    }
                }
                .foregroundColor(.accentColor)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isEditing)
        .animation(.easeInOut(duration: 0.3), value: text.isEmpty)
    }
}

struct ContactRow: View {
    let contact: Contact
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                contact.color.opacity(0.8),
                                contact.color
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Text(contact.initials)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
            .shadow(color: contact.color.opacity(0.3), radius: 4, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(contact.phoneNumber)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(.tertiaryLabel))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
//        .background(
//            RoundedRectangle(cornerRadius: 0)
//                .fill(Color(.systemBackground))
//                .scaleEffect(isPressed ? 0.98 : 1.0)
//        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
//        .onLongPressGesture(minimumDuration: 0) { 
//            // On press
//            withAnimation(.easeInOut(duration: 0.1)) {
//                isPressed = true
//            }
//        } onPressingChanged: { pressing in
//            if !pressing {
//                withAnimation(.easeInOut(duration: 0.1)) {
//                    isPressed = false
//                }
//            }
//        }
    }
}

// This sheet-based detail view remains if you need it elsewhere.
// It is not used by the NavigationStack flow above.
struct ContactDetailView: View {
    let contact: Contact
    @Binding var isPresented: Bool
    @State private var dragOffset = CGSize.zero
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.9
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        contact.color.opacity(0.1),
                        Color(.systemBackground)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Large avatar
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        contact.color.opacity(0.8),
                                        contact.color
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        Text(contact.initials)
                            .font(.system(size: 42, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .shadow(color: contact.color.opacity(0.4), radius: 20, x: 0, y: 10)
                    .scaleEffect(scale)
                    
                    VStack(spacing: 8) {
                        Text(contact.name)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(contact.email)
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    
                    // Action buttons
                    HStack(spacing: 20) {
                        ContactActionButton(icon: "phone.fill", label: "Call", color: .green)
                        ContactActionButton(icon: "message.fill", label: "Text", color: .blue)
                        ContactActionButton(icon: "envelope.fill", label: "Email", color: .purple)
                    }
                    .padding(.top, 20)
                    
                    // Contact info
                    VStack(spacing: 16) {
                        ContactInfoRow(icon: "phone", title: "Phone", value: contact.phoneNumber)
                        ContactInfoRow(icon: "envelope", title: "Email", value: contact.email)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            isPresented = false
                        }
                    }
                    .foregroundColor(.accentColor)
                    .font(.system(size: 17, weight: .medium))
                }
            }
        }
        .opacity(opacity)
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                opacity = 1
                scale = 1
            }
        }
    }
}

struct ContactActionButton: View {
    let icon: String
    let label: String
    let color: Color
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white)
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }
        }
    }
}

struct ContactInfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ContactsView()
}
