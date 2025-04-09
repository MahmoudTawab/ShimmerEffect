//
//  FakeLoadingView.swift
//  Wafid
//
//  Created by Mahmoud on 09/04/2025.
//

import SwiftUI

/// A view that displays a fake loading skeleton with shimmer effect.
struct FakeLoadingView: View {
    @State private var isDarkMode = false
    let isLoading: Bool = true

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    // Main top rectangle with shimmer
                    RoundedRectangle(cornerRadius: 18)
                        .fill(shimmerBaseColor)
                        .frame(height: 200)
                        .loadingStyle(
                            isLoading: isLoading,
                            cornerRadius: 18,
                            corners: [.topLeft, .bottomRight],
                            isDarkMode: isDarkMode,
                            shimmerLTR: true
                        )

                    // Title line placeholder
                    RoundedRectangle(cornerRadius: 6)
                        .fill(shimmerBaseColor)
                        .frame(width: 180, height: 20)
                        .loadingStyle(
                            isLoading: isLoading,
                            cornerRadius: 12,
                            corners: [.allCorners],
                            isDarkMode: isDarkMode,
                            shimmerLTR: true
                        )

                    // Subtitle line placeholder
                    RoundedRectangle(cornerRadius: 6)
                        .fill(shimmerBaseColor)
                        .frame(width: 250, height: 14)
                        .loadingStyle(
                            isLoading: isLoading,
                            cornerRadius: 10,
                            corners: [.allCorners],
                            isDarkMode: isDarkMode,
                            shimmerLTR: true
                        )

                    Divider()

                    // List of placeholder items
                    ForEach(0..<8, id: \.self) { _ in
                        HStack(spacing: 16) {
                            // Image placeholder
                            RoundedRectangle(cornerRadius: 10)
                                .fill(shimmerBaseColor)
                                .frame(width: 60, height: 60)
                                .loadingStyle(
                                    isLoading: isLoading,
                                    cornerRadius: 12,
                                    corners: [.topRight, .bottomLeft],
                                    isDarkMode: isDarkMode,
                                    shimmerLTR: true
                                )

                            VStack(alignment: .leading, spacing: 8) {
                                // Title line
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(shimmerBaseColor)
                                    .frame(width: 150, height: 16)
                                    .loadingStyle(
                                        isLoading: isLoading,
                                        cornerRadius: 6,
                                        corners: [.allCorners],
                                        isDarkMode: isDarkMode,
                                        shimmerLTR: true
                                    )

                                // Subtitle line
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(shimmerBaseColor)
                                    .frame(width: 80, height: 14)
                                    .loadingStyle(
                                        isLoading: isLoading,
                                        cornerRadius: 6,
                                        corners: [.allCorners],
                                        isDarkMode: isDarkMode,
                                        shimmerLTR: true
                                    )
                            }

                            Spacer()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Fake Loading")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isDarkMode.toggle()
                    }) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                    }
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }

    /// Base shimmer background color depending on the current mode
    private var shimmerBaseColor: Color {
        isDarkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.3)
    }
}


/// A ViewModifier that applies a shimmer loading effect to any SwiftUI View.
public struct Shimmer: ViewModifier {

    /// Shimmer rendering modes:
    /// - `mask`: applies the shimmer as a mask.
    /// - `overlay`: blends shimmer on top using the given BlendMode.
    /// - `background`: puts shimmer behind the content.
    public enum Mode {
        case mask
        case overlay(blendMode: BlendMode = .sourceAtop)
        case background
    }

    // Animation for the shimmer movement
    private let animation: Animation

    // The gradient used for shimmer effect
    private let gradient: Gradient

    // Start and end values for shimmer band travel
    private let min, max: CGFloat

    // How the shimmer is rendered
    private let mode: Mode

    // Optional radius for corner clipping
    private let circleRadius: CGFloat?

    // Specific corners to round
    private let maskedCorners: UIRectCorner

    // Dark mode toggle
    private let isDarkMode: Bool

    // Shimmer direction: true = LTR, false = RTL
    private let shimmerLTR: Bool

    // Used to trigger animation only once per change
    @State private var isInitialState = true

    // To detect direction change and restart animation
    @State private var previousDirection: Bool

    /// Initialize shimmer with customizable options.
    public init(
        animation: Animation = Self.defaultAnimation,
        gradient: Gradient? = nil,
        bandSize: CGFloat = 0.3,
        mode: Mode = .background,
        circleRadius: CGFloat? = nil,
        maskedCorners: UIRectCorner = .allCorners,
        isDarkMode: Bool = false,
        shimmerLTR: Bool = false
    ) {
        self.animation = animation
        self.gradient = gradient ?? (isDarkMode ? Self.darkModeGradient : Self.defaultGradient)
        self.min = 0 - bandSize
        self.max = 1 + bandSize
        self.mode = mode
        self.circleRadius = circleRadius
        self.maskedCorners = maskedCorners
        self.isDarkMode = isDarkMode
        self.shimmerLTR = shimmerLTR
        self.previousDirection = shimmerLTR
    }

    /// Default animation config
    public static let defaultAnimation = Animation.linear(duration: 1.5).delay(0.25).repeatForever(autoreverses: false)

    /// Light mode gradient
    public static let defaultGradient = Gradient(colors: [
        .black.opacity(0.3),
        .black.opacity(0.5),
        .black,
        .black.opacity(0.5),
        .black.opacity(0.3)
    ])
    
    /// Dark mode gradient
    public static let darkModeGradient = Gradient(colors: [
        .white.opacity(0.1),
        .white.opacity(0.3),
        .white.opacity(0.5),
        .white.opacity(0.3),
        .white.opacity(0.1)
    ])

    // Start point of gradient based on direction
    var startPoint: UnitPoint {
        shimmerLTR
            ? (isInitialState ? UnitPoint(x: min, y: min) : UnitPoint(x: 1, y: 1))
            : (isInitialState ? UnitPoint(x: max, y: min) : UnitPoint(x: 0, y: 1))
    }

    // End point of gradient based on direction
    var endPoint: UnitPoint {
        shimmerLTR
            ? (isInitialState ? UnitPoint(x: 0, y: 0) : UnitPoint(x: max, y: max))
            : (isInitialState ? UnitPoint(x: 1, y: 0) : UnitPoint(x: min, y: max))
    }

    /// Applies shimmer effect and resets animation on direction change
    public func body(content: Content) -> some View {
        applyingGradient(to: content)
            .clipShape(CustomClipShape(cornerRadius: circleRadius ?? 0, corners: maskedCorners))
            .animation(animation, value: isInitialState)
            .onChange(of: shimmerLTR) { newValue in
                if previousDirection != newValue {
                    isInitialState = true
                    previousDirection = newValue
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isInitialState = false
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isInitialState = false
                }
            }
    }

    /// Adds gradient as background/overlay/mask to content
    @ViewBuilder public func applyingGradient(to content: Content) -> some View {
        let gradient = LinearGradient(gradient: gradient, startPoint: startPoint, endPoint: endPoint)
        switch mode {
        case .mask:
            content.mask(gradient)
        case let .overlay(blendMode):
            content.overlay(gradient.blendMode(blendMode))
        case .background:
            content.background(gradient)
        }
    }
}


/// A custom shape for rounding specific corners
struct CustomClipShape: Shape {
    var cornerRadius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        return Path(path.cgPath)
    }
}


public extension View {

    /// Apply shimmer conditionally with full customization
    @ViewBuilder func shimmering(
        active: Bool = true,
        animation: Animation = Shimmer.defaultAnimation,
        gradient: Gradient? = nil,
        bandSize: CGFloat = 0.3,
        mode: Shimmer.Mode = .mask,
        circleRadius: CGFloat? = nil,
        maskedCorners: UIRectCorner = .allCorners,
        overlayColor: Color? = nil,
        isDarkMode: Bool = false,
        shimmerLTR: Bool = false
    ) -> some View {
        if active {
            let actualOverlayColor = overlayColor ?? (isDarkMode
                ? Color(red: 0.85, green: 0.85, blue: 0.85)
                : Color(red: 0.85, green: 0.85, blue: 0.85))

            self
                .overlay(actualOverlayColor)
                .modifier(Shimmer(
                    animation: animation,
                    gradient: gradient,
                    bandSize: bandSize,
                    mode: mode,
                    circleRadius: circleRadius,
                    maskedCorners: maskedCorners,
                    isDarkMode: isDarkMode,
                    shimmerLTR: shimmerLTR
                ))
        } else {
            self
        }
    }

    /// Deprecated version with simplified API
    @available(*, deprecated, message: "Use shimmering(active:animation:gradient:bandSize:) instead.")
    @ViewBuilder func shimmering(
        active: Bool = true,
        duration: Double,
        bounce: Bool = false,
        delay: Double = 0.25
    ) -> some View {
        shimmering(
            active: active,
            animation: .linear(duration: duration).delay(delay).repeatForever(autoreverses: bounce)
        )
    }
}

/// A ViewModifier that applies both redaction and shimmer during loading
struct LoadingModifier: ViewModifier {
    let isLoading: Bool
    let cornerRadius: CGFloat
    let corners: UIRectCorner
    let isDarkMode: Bool
    let shimmerLTR: Bool

    func body(content: Content) -> some View {
        content
            .redacted(reason: isLoading ? .placeholder : [])
            .shimmering(
                active: isLoading,
                animation: Animation.linear(duration: 1.5).delay(0.25).repeatForever(autoreverses: false),
                bandSize: 0.3,
                mode: .mask,
                circleRadius: cornerRadius,
                maskedCorners: corners,
                isDarkMode: isDarkMode,
                shimmerLTR: shimmerLTR
            )
            .animation(.default, value: isLoading)
            .shadow(
                color: isDarkMode ? .black.opacity(0.8) : .white.opacity(0.8),
                radius: 10,
                x: shimmerLTR ? -5 : 5,
                y: shimmerLTR ? -5 : 5
            )
    }
}

/// Easy-to-use loading modifier for any view
extension View {
    func loadingStyle(
        isLoading: Bool,
        cornerRadius: CGFloat = 0,
        corners: UIRectCorner = [],
        isDarkMode: Bool = false,
        shimmerLTR: Bool = false
    ) -> some View {
        self.modifier(LoadingModifier(
            isLoading: isLoading,
            cornerRadius: cornerRadius,
            corners: corners,
            isDarkMode: isDarkMode,
            shimmerLTR: shimmerLTR
        ))
    }
}
