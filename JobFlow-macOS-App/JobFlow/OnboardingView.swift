import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var isPresented: Bool
    @State private var currentStep = 0
    
    let steps = [
        OnboardingStep(
            icon: "briefcase.fill",
            title: "Welcome to JobFlow",
            description: "Track your job applications effortlessly. Stay organized, never miss a deadline, and land your dream job.",
            color: .blue
        ),
        OnboardingStep(
            icon: "plus.circle.fill",
            title: "Add Your First Job",
            description: "Click the '+New Job' button in the top right to add your first application. Track company, position, status, and more.",
            color: .green
        ),
        OnboardingStep(
            icon: "square.grid.2x2.fill",
            title: "Switch Between Views",
            description: "Use List view for details, Timeline for chronology, or Kanban for visual workflow. Switch anytime with the segmented control.",
            color: .purple
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            ThemeColors.backgroundDeep(for: themeManager.currentTheme)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Progress indicators
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Capsule()
                            .fill(currentStep >= index ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: currentStep == index ? 40 : 30, height: 6)
                            .animation(.easeInOut(duration: 0.3), value: currentStep)
                    }
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Step content
                VStack(spacing: 24) {
                    Image(systemName: steps[currentStep].icon)
                        .font(.system(size: 80))
                        .foregroundColor(steps[currentStep].color)
                        .transition(.scale.combined(with: .opacity))
                    
                    Text(steps[currentStep].title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(ThemeColors.textPrimary(for: themeManager.currentTheme))
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                    
                    Text(steps[currentStep].description)
                        .font(.system(size: 16))
                        .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .fixedSize(horizontal: false, vertical: true)
                        .transition(.opacity)
                }
                .id(currentStep) // Force re-render for animation
                
                Spacer()
                
                // Navigation buttons
                HStack(spacing: 16) {
                    if currentStep > 0 {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep -= 1
                            }
                        }) {
                            Text("Back")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(ThemeColors.textSecondary(for: themeManager.currentTheme))
                                .frame(width: 120, height: 50)
                                .background(ThemeColors.cardBackground(for: themeManager.currentTheme))
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if currentStep < steps.count - 1 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep += 1
                            }
                        } else {
                            isPresented = false
                        }
                    }) {
                        Text(currentStep == steps.count - 1 ? "Get Started" : "Next")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(steps[currentStep].color)
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 60)
                .padding(.bottom, 60)
            }
        }
        .frame(width: 600, height: 500)
    }
}

struct OnboardingStep {
    let icon: String
    let title: String
    let description: String
    let color: Color
}
