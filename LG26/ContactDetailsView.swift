//
//  ContactDetailsView.swift
//  LG26
//
//  Created by Alex on 2025-09-22.
//

import SwiftUI

struct ContactDetailsView: View {
    let contact: Contact
    @Environment(\.dismiss) private var dismiss
    //@Environment(\.safeAreaInsets) private var safeAreaInsets
    
    @State private var scrollY: CGFloat = 0
    @State private var headerHeight: CGFloat = 0
    
    // Tracks accumulated collapse distance (0...180) across drags
    @State private var dragAccumulated: CGFloat = 0
    
    // Collapsing progress: 0 at rest, 1 when scrolled up by ~180pts (relative to headerHeight baseline)
    private var collapseProgress: CGFloat {
        // scrollY starts near headerHeight (because content is padded by headerHeight).
        // As you scroll up, scrollY decreases. Using (headerHeight - scrollY) makes progress start immediately.
        let y = max(0, headerHeight - scrollY)
        return min(1, y / 406)
    }
    
    // Compute the overlay header height (nav + avatar) from known layout + safe area
    private var computedHeaderHeight: CGFloat {
        // Top safe area + nav top padding (10) + nav button height (44)
        // + avatar block: top padding (40) + circle height (300) + bottom padding (12)
        //safeAreaInsets.top + 10 + 44 + 40 + 300 + 12
        let base: CGFloat = 10 + 44 + 40 + 300 + 12
        return  base
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Liquid gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    contact.color.opacity(0.25),
                    Color.blue.opacity(0.25),
                    Color.cyan.opacity(0.2),
                    Color.mint.opacity(0.15)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Scrollable content (role/name + actions + details). We pad by headerHeight so it starts below the overlay header.
            ScrollView(.vertical, showsIndicators: false) {
                ZStack(alignment: .top) {

                    VStack(spacing: 0) {
                        
                        // Role and name (now inside ScrollView)
                        VStack(spacing: 8) {
                            Text(contact.name)
                                .font(.system(size: 36, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                                .minimumScaleFactor(0)
                                .offset(y: -10 * collapseProgress)
                                .scaleEffect(1 - 3*collapseProgress<=0 ?0 : 1 - 3*collapseProgress)
                                .opacity(1 - collapseProgress)
                            //Text(collapseProgress.description)
                                //.font(.system(size: 36, weight: .semibold, design: .rounded))
                                //.foregroundStyle(.white)
                              
                        }
                        .padding(.top, 12)
                        .animation(.spring(response: 0.45, dampingFraction: 0.9), value: collapseProgress)
                        
                        // Action buttons (now inside ScrollView)
                        HStack(spacing: 20) {
                            ContactDActionButton(icon: "message.fill")
                            ContactDActionButton(icon: "phone.fill")
                            ContactDActionButton(icon: "video.fill")
                            ContactDActionButton(icon: "envelope.fill")
                        }
                        .padding(.top, 10)
                        .offset(y: -10 * collapseProgress)
                        .opacity(1 - collapseProgress)
                        .animation(.spring(response: 0.45, dampingFraction: 0.9), value: collapseProgress)
                        
                        // Contact info section
                        VStack(spacing: 0) {
                            // Contact photo & poster card (kept as-is)
                            HStack {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .frame(width: 64, height: 64)
                                        
                                        Text(contact.initials)
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundStyle(.primary)
                                    }
                                    
                                    Text("Contact Photo & Poster")
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundStyle(.primary)
                                        
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            // Contact details (updated to use contact data)
                            VStack(spacing: 0) {
                                VStack(spacing: 0) {
                                    ContactDInfoRow(label: "mobile", value: contact.phoneNumber)
                                       
                                    ContactDInfoRow(label: "email", value: contact.email, isLast: true)
                                }
                                .conditionalGlassEffect()
                                ContactDInfoRow(label: "mobile", value: contact.phoneNumber)
                                ContactDInfoRow(label: "email", value: contact.email, isLast: true)
                                    .conditionalGlassEffect()
                                ContactDInfoRow(label: "mobile", value: contact.phoneNumber)
                                    .conditionalGlassEffect()
                                ContactDInfoRow(label: "email", value: contact.email, isLast: true)
                                    .conditionalGlassEffect()
                                ContactDInfoRow(label: "mobile", value: contact.phoneNumber)
                                ContactDInfoRow(label: "email", value: contact.email, isLast: true)
                            }
                            .padding(.top, 20)
                            .padding(.bottom, 40)
                        }
                        
                    }
                    .padding(.top, headerHeight) // reserve space under the overlay header (nav bar + avatar)
//                    .overlay(alignment: .top) {
//                        ZStack(alignment: .top) {
//                            Rectangle()
//                                .fill(.indigo.opacity(0.3))
//                            Rectangle()
//                                .fill(.ultraThinMaterial)
//                                .opacity(0.1)
//                        }
//                    }
                }
            }
            // Track drag to synthesize a "collapse distance" (0...180), then map it back to scrollY
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        let delta = -value.translation.height // up drag -> positive collapse
                        let current = max(0, min(180, dragAccumulated + delta))
                        let newScrollY = headerHeight - current
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            scrollY = newScrollY
                        }
                    }
                    .onEnded { value in
                        let delta = -value.translation.height
                        let predicted = -value.predictedEndTranslation.height
                        // Approximate deceleration by adding a fraction of the extra predicted movement
                        let extra = max(0, predicted - delta) * 0.2
                        let final = max(0, min(180, dragAccumulated + delta + extra))
                        dragAccumulated = final
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                            scrollY = headerHeight - final
                        }
                    }
            )
            
            
            // Overlay header layer: Top navigation bar + Avatar (pinned)
            VStack(spacing: 0) {
                // Top navigation bar (custom)
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundStyle(.primary)
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Text("Edit")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.primary)
                            .frame(height: 44)
                            .padding(.horizontal, 20)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                // Centered, docked title that fades/scales in as you collapse
                .overlay {
                    Text(contact.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .opacity(collapseProgress)
                        .scaleEffect(0.9 + 0.3 * collapseProgress)
                        .offset(y: 2 - 2 * collapseProgress) // tiny settle movement
                        .allowsHitTesting(false)
                }
                .overlay(alignment: .top) {
                    // Subtle top overlay that fades in as you scroll
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .opacity(collapseProgress * 0.2)
                        .ignoresSafeArea(edges: .top)
                        .frame(height: 0) // the ignoresSafeArea makes it extend upward
                }
                
                // Avatar only (collapsing header visual)
                ZStack {
                    // Main crystal glass circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.25),
                                    .white.opacity(0.15),
                                    .white.opacity(0.05),
                                    .white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 300, height: 300)
                        .overlay {
                            // Inner crystal reflection
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            .white.opacity(0.3),
                                            .white.opacity(0.1),
                                            .clear
                                        ],
                                        center: UnitPoint(x: 0.3, y: 0.3),
                                        startRadius: 10,
                                        endRadius: 80
                                    )
                                )
                        }
                        .overlay {
                            // Crystal border with multiple layers
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.8),
                                            .white.opacity(0.4),
                                            .white.opacity(0.1),
                                            .white.opacity(0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        }
                        .overlay {
                            // Outer glow border
                            Circle()
                                .stroke(
                                    .white.opacity(0.2),
                                    lineWidth: 0.5
                                )
                                .blur(radius: 1)
                        }
                        .shadow(color: .white.opacity(0.1), radius: 0, x: 0, y: 1)
                        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                        .shadow(color: .black.opacity(0.05), radius: 40, x: 0, y: 20)
                    
                    // Crystal highlight effect
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.4),
                                    .clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .frame(width: 140, height: 70)
                        .offset(y: -30)
                        .blur(radius: 1)
                    
                    Image(systemName: "person")
                        .font(.system(size: 200, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(width: 80, height: 80)
                    
                    //Text(contact.initials)
                        //.font(.system(size: 80, weight: .bold, design: .rounded))
                        //.foregroundStyle(.white)
                        //.shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
                .padding(.top, 40)
                .padding(.bottom, 12)
                .scaleEffect(1 - 1.5 * collapseProgress)
                .offset(y: -20 * collapseProgress)
                .animation(.spring(response: 0.45, dampingFraction: 0.9), value: collapseProgress)
            }
        }
        // Initialize header height and baseline scroll position
        .onAppear {
            headerHeight = computedHeaderHeight
            scrollY = headerHeight // baseline (no collapse)
            dragAccumulated = 0
        }
        // Update on safe-area changes (e.g., rotation)
//        .onChange(of: safeAreaInsets) { _, _ in
//            let newHeader = computedHeaderHeight
//            headerHeight = newHeader
//            // Keep the same collapse distance after a change
//            scrollY = newHeader - dragAccumulated
//        }
        // Hide default nav bar since we provide a custom one
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct ContactDActionButton: View {
    let icon: String
    
    var body: some View {
        Button(action: {}) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))
                .frame(width: 56, height: 56)
                //.background(.ultraThinMaterial, in: Circle())
                .conditionalGlassEffect()
                .overlay {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.2), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                }
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
}

struct ContactDInfoRow: View {
    let label: String
    let value: String
    var isLast: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(.white)
                    
                    if !value.isEmpty {
                        Text(value)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(.white)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            if !isLast {
                Divider()
                    .background(.quaternary)
                    .padding(.leading, 20)
            }
        }
    }
}

struct ConditionalGlassEffect: ViewModifier {
    var color: Color
    var shape: Shape
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            // Apply the glass effect when available (uses default style).
            content.glassEffect(.regular.tint(color),in: shape)
        } else {
            content
        }
    }
}

extension View {
    func conditionalGlassEffect(_ color: Color = .blue.opacity(0.5), in shape: some Shape = RoundedRectangle(cornerRadius: 16)) -> some View {
        modifier(ConditionalGlassEffect(color: color,shape: shape))
    }
}

#Preview("Contact Details - Light") {
    NavigationStack {
        ContactDetailsView(contact: Contact.sampleContacts[0])
    }
}

#Preview("Contact Details - Dark") {
    NavigationStack {
        ContactDetailsView(contact: Contact.sampleContacts[1])
            .preferredColorScheme(.dark)
    }
}
