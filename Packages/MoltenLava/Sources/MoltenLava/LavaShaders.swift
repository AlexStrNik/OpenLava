import Metal

struct LavaUniforms {
    var scale: SIMD2<Float>
}

func makeLavaLibrary(device: MTLDevice) -> MTLLibrary {
  let metalSource = """
    #include <metal_stdlib>
    using namespace metal;

    struct Uniforms {
        float2 scale; // width/height scaling factor
    };

    struct VertexOut {
        float4 position [[position]];
        float2 texCoord;
    };

    vertex VertexOut vertex_main(uint vid [[vertex_id]],
                                 constant Uniforms& uniforms [[buffer(0)]]) {
        float2 positions[4] = {
            float2(-1.0, -1.0),
            float2( 1.0, -1.0),
            float2(-1.0,  1.0),
            float2( 1.0,  1.0)
        };

        float2 texCoords[4] = {
            float2(0.0, 1.0),
            float2(1.0, 1.0),
            float2(0.0, 0.0),
            float2(1.0, 0.0)
        };

        VertexOut out;
        float2 scaled = positions[vid] * uniforms.scale;
        out.position = float4(scaled, 0.0, 1.0);
        out.texCoord = texCoords[vid];
        return out;
    }

    fragment float4 fragment_main(VertexOut in [[stage_in]],
                                  texture2d<float> tex [[ texture(0) ]]) {
        constexpr sampler s(filter::linear, address::clamp_to_edge);
        return tex.sample(s, in.texCoord);
    }
    """

  do {
    return try device.makeLibrary(source: metalSource, options: nil)
  } catch {
    fatalError("Metal compile error: \(error)")
  }
}
