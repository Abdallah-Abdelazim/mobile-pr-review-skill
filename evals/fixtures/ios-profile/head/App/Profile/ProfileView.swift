import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var loadCount = 0

    var body: some View {
        VStack {
            Text(viewModel.profile?.name ?? "Loading…")
        }
        .onAppear {
            viewModel.onLoaded = { loadCount += 1 }
            Task { await viewModel.load() }
        }
    }
}

#Preview {
    ProfileView()
}
