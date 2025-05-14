enum LavaVersion: Int, Decodable {
  case v1 = 1
}

struct LavaImage: Decodable {
  let url: String
}

struct LavaKeyFrame: Decodable {
  let imageIndex: Int
}

struct LavaDiffFrame: Decodable {
  let diffs: [[Int]]
}

enum LavaFrame: Decodable {
  case key(LavaKeyFrame)
  case diff(LavaDiffFrame)

  private enum CodingKeys: String, CodingKey {
    case type
    case imageIndex
    case diffs
  }

  enum FrameType: String, Decodable {
    case key
    case diff
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(
      keyedBy: CodingKeys.self
    )

    let type = try container.decode(
      FrameType.self,
      forKey: .type
    )

    switch type {
    case .key:
      let imageIndex = try container.decode(
        Int.self, forKey: .imageIndex
      )
      self = .key(LavaKeyFrame(imageIndex: imageIndex))
    case .diff:
      let diffs = try container.decode(
        [[Int]].self, forKey: .diffs
      )
      self = .diff(LavaDiffFrame(diffs: diffs))
    }
  }
}

struct LavaManifest: Decodable {
  let version: LavaVersion
  let fps: Int
  let cellSize: Int
  let diffImageSize: Int
  let width: Int
  let height: Int
  let density: Int
  let alpha: Bool
  let images: [LavaImage]
  let frames: [LavaFrame]
}
