import SwiftUI

struct ToastNotification: View {
    @EnvironmentObject var themeManager: ThemeManager
    let message: String
    let icon: String
    let onUndo: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            
            if let onUndo = onUndo {
                Divider()
                    .background(Color.white.opacity(0.3))
                    .frame(height: 20)
                
                Button(action: onUndo) {
                    Text("Undo")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.black.opacity(0.85))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// Toast Manager for showing toasts
class ToastManager: ObservableObject {
    @Published var toast: ToastData?
    
    func show(_ message: String, icon: String = "checkmark.circle.fill", onUndo: (() -> Void)? = nil) {
        toast = ToastData(message: message, icon: icon, onUndo: onUndo)
        
        // Auto-dismiss after 5 seconds if there's an undo action, 3 seconds otherwise
        let duration: Double = onUndo != nil ? 5.0 : 3.0
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            if self?.toast?.id == self?.toast?.id {
                self?.toast = nil
            }
        }
    }
    
    func dismiss() {
        toast = nil
    }
}

struct ToastData: Identifiable {
    let id = UUID()
    let message: String
    let icon: String
    let onUndo: (() -> Void)?
}

// View modifier for showing toasts
struct ToastModifier: ViewModifier {
    @ObservedObject var toastManager: ToastManager
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let toast = toastManager.toast {
                VStack {
                    Spacer()
                    
                    ToastNotification(
                        message: toast.message,
                        icon: toast.icon,
                        onUndo: toast.onUndo
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: toastManager.toast != nil)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

extension View {
    func toast(_ toastManager: ToastManager) -> some View {
        modifier(ToastModifier(toastManager: toastManager))
    }
}
