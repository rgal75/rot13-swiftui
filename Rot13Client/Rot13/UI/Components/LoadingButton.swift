import SwiftUI

struct LoadingButton: View {
    let isLoading: Bool
    let action: () -> Void
    let id: String
    let title: String

    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
            } else {
                Button(title) {
                    action()
                }
                .id(id)
                .bold()
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(Color.accentColor)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .shadow(radius: 2)
            }
        }
        .frame(height: 44)
    }
}
