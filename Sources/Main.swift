import Foundation
import Vercel
import LinkPreview

struct MediaMetadata: Codable {
    var url: URL?
    var width: Int?
    var height: Int?

    init?(property: LinkPreviewProperty) {
        guard let url = property.content.map(URL.init(string:)) else {
            return nil
        }
        self.url = url
        if let width = property.metadata["width"].map({ Int($0) }) {
            self.width = width
        }
        if let height = property.metadata["height"].map({ Int($0) }) {
            self.height = height
        }
    }
}

struct LinkPreviewResponse: Codable {
    var title: String?
    var siteName: String?
    var description: String?
    var canonicalURL: URL?
    var image: MediaMetadata?
    var video: MediaMetadata?
    var audioURL: URL?
    var faviconURL: URL?
}

@main
struct Main: ExpressHandler {
    static func fetchLinkPreview(url: URL) async throws -> LinkPreviewResponse {
        let provider = LinkPreviewProvider()
        let preview = try await provider.load(from: url)

        var response = LinkPreviewResponse()
        response.siteName = preview.siteName
        response.audioURL = preview.audioURL
        response.faviconURL = preview.faviconURL
        response.canonicalURL = preview.canonicalURL
        response.title = preview.title
        response.description = preview.description
        if let prop = preview.property(named: "image") {
            response.image = MediaMetadata(property: prop)
        }
        if let prop = preview.property(named: "video") {
            response.video = MediaMetadata(property: prop)
        }
        return response
    }

    static func configure(router: Router) async throws {
        router.options("/preview") { _, res in
            res.cors().status(.ok)
        }

        router.get("/preview") { req, res in
            let res = res.cors()
            guard let components = URLComponents(string: req.path) else {
                return res.status(.badRequest)
            }
            let items = components.queryItems ?? []
            guard var urlString = items.first(where: { $0.name == "url" })?.value else {
                return res.status(.badRequest).send("Must provide 'url' parameter")
            }

            // Prepend HTTPS if not provided
            if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
                urlString = "https://\(urlString)"
            }

            guard let url = URL(string: urlString) else {
                return res.status(.badRequest).send("Invalid URL: \(urlString)")
            }

            do {
                let response = try await fetchLinkPreview(url: url)
                return try res.status(.ok).send(response)
            } catch {
                return res.status(.badRequest).send("error: \(error)")
            }
        }
    }
}
