# LinkPreviewServer

This is a very simple single-route test server for [LinkPreviewSwift](https://github.com/harlanhaskins/LinkPreviewSwift).

## Usage

There's only one endpoint:

```
GET /preview?url=<url to search>
```

You'll receive a JSON response in the following format:

```json
{
  "title": "GitHub - harlanhaskins\/LinkPreviewSwift: A Swift library for generating link previews client-side or server-side",
  "canonicalURL": "https:\/\/github.com\/harlanhaskins\/LinkPreviewSwift",
  "description": "A Swift library for generating link previews client-side or server-side - harlanhaskins\/LinkPreviewSwift",
  "image": {
    "url": "https:\/\/opengraph.githubassets.com\/def7352badc7111ae7fd6b43862abd358508f5e58bbb252efd77e12f7e1665db\/harlanhaskins\/LinkPreviewSwift",
    "height": 600,
    "width": 1200
  },
  "faviconURL": "https:\/\/github.githubassets.com\/favicons\/favicon.svg"
}
```

## Author

Harlan Haskins ([harlan@harlanhaskins.com](mailto:harlan@harlanhaskins.com))
