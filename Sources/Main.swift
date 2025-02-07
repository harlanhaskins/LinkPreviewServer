import Foundation
import FlyingFox
import LinkPreview

struct AVPreview: Codable {
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
    var description: String?
    var canonicalURL: URL?
    var image: AVPreview?
    var video: AVPreview?
    var audioURL: URL?
    var faviconURL: URL?
}

@main
struct Main {
    static func fetchLinkPreview(url: URL) async throws -> LinkPreviewResponse {
        let provider = LinkPreviewProvider()
        let preview = try await provider.load(from: url)

        var response = LinkPreviewResponse()
        response.audioURL = preview.audioURL
        response.faviconURL = preview.faviconURL
        response.canonicalURL = preview.canonicalURL
        response.title = preview.title
        response.description = preview.description
        if let prop = preview.property(named: "image") {
            response.image = AVPreview(property: prop)
        }
        if let prop = preview.property(named: "video") {
            response.video = AVPreview(property: prop)
        }
        return response
    }
    static func main() async throws {
        let server = HTTPServer(port: 8086)
        await server.appendRoute("/preview?url=:url") { request in
            guard let urlString = request.routeParameters["url"],
                  let url = URL(string: urlString) else {
                return HTTPResponse(statusCode: .badRequest)
            }

            let response = try await fetchLinkPreview(url: url)

            let data = try JSONEncoder().encode(response)
            return HTTPResponse(statusCode: .ok, headers: [
                .contentType: "application/json"
            ], body: data)
        }
        try await server.run()
    }
}
