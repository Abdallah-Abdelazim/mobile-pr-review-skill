import Foundation
import Combine

struct Profile: Decodable {
    let name: String
    let avatarURL: String
}

final class ProfileViewModel: ObservableObject {
    @Published var profile: Profile?
    var onLoaded: (() -> Void)?
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func load() async {
        let url = URL(string: "https://api.example.com/me")!
        guard let (data, _) = try? await session.data(from: url) else { return }
        profile = try? JSONDecoder().decode(Profile.self, from: data)
        onLoaded?()
    }
}
