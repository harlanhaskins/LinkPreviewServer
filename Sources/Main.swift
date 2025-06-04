import Foundation
import Hummingbird
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

struct LinkPreviewResponse: Codable, ResponseCodable {
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
struct Main {
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

    static func main() async throws {
        let router = Router()
            .addMiddleware {
                RequestLoggerMiddleware()
                CORSMiddleware(
                    allowOrigin: .originBased,
                    allowHeaders: [.accept, .authorization, .contentType, .origin],
                    allowMethods: [.get, .options]
                )
            }

        configure(router: router)

        let app = Application(
            router: router,
            configuration: .init(address: .hostname("127.0.0.1", port: 8077))
        )
        try await app.runService()
    }

    static func configure(router: some RouterMethods) {
        router.on("/preview", method: .options) { _, _ in
            Response(status: .ok)
        }

        router.get("/preview") { req, ctx in
            guard var urlString = req.uri.queryParameters["url"] else {
                throw HTTPError(.badRequest, message: "Must provide 'url' parameter")
            }

            // Prepend HTTPS if not provided
            if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
                urlString = "https://\(urlString)"
            }

            guard let url = URL(string: String(urlString)) else {
                throw HTTPError(.badRequest, message: "Invalid URL: \(urlString)")
            }

            do {
                return try await fetchLinkPreview(url: url)
            } catch {
                var response = LinkPreviewResponse()
                response.canonicalURL = url
                return response
            }
        }
    }
}
