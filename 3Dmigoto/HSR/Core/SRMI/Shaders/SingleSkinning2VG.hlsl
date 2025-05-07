struct pos_struct {
    float3 position;
    float3 normal;
    float4 tangent;
};
struct blend_struct {
    float2 weight;
    uint2 index;
};
cbuffer cb0_struct : register(b0) {
    uint4 cb0[6];
}

StructuredBuffer<pos_struct> pos_buf : register(t20);
StructuredBuffer<blend_struct> blend_buf : register(t21);
StructuredBuffer<float4x4> skinning : register(t22);
RWStructuredBuffer<pos_struct> result : register(u7);

Texture1D<float4> IniParams : register(t120);
#define VERTEX_COUNT IniParams[0].x
#define POSE_ID IniParams[0].y

[numthreads(64, 1, 1)]
void main(uint3 vThreadID: SV_DispatchThreadID) {
    if (vThreadID.x >= (uint)VERTEX_COUNT) {
        return;
    }
    // slot 0 cb04.x
    // slot 1 cb04.y
    // slot 2 cb04.z
    // slot 3 cb04.w
    // slot 4 cb05.x
    // slot 5 cb05.y
    // slot 6 cb05.z
    // slot 7 cb05.w

    uint offset = 0;
    uint slot = 0;

    if (POSE_ID < 40 || POSE_ID > 49) {
        // invalid- we leave
        return;
    }

    slot = (uint)POSE_ID % 10;
    offset = cb0[slot < 4 ? 4 : 5][slot % 4];

    pos_struct pos = pos_buf[vThreadID.x];
    blend_struct blend = blend_buf[vThreadID.x];

    float4 pose_0 = (blend.weight.x * skinning[blend.index.x + offset][0].xyzw + blend.weight.y * skinning[blend.index.y + offset][0].xyzw);
    float4 pose_1 = (blend.weight.x * skinning[blend.index.x + offset][1].xyzw + blend.weight.y * skinning[blend.index.y + offset][1].xyzw);
    float4 pose_2 = (blend.weight.x * skinning[blend.index.x + offset][2].xyzw + blend.weight.y * skinning[blend.index.y + offset][2].xyzw);

    float4x3 mat_4x3 = {
        pose_0.x, pose_1.x, pose_2.x,
        pose_0.y, pose_1.y, pose_2.y,
        pose_0.z, pose_1.z, pose_2.z,
        pose_0.w, pose_1.w, pose_2.w
    };
    float3x3 mat_3x3 = {
        mat_4x3[0],
        mat_4x3[1],
        mat_4x3[2]
    };

    float3 _position = mul(float4(pos.position, 1), mat_4x3);
    float3 _normal = normalize(mul(pos.normal.xyz, mat_3x3));
    float3 _tangent = normalize(mul(pos.tangent.xyz, mat_3x3));

    result[vThreadID.x].position.xyz = _position.xyz;
    result[vThreadID.x].normal.xyz = _normal.xyz;
    result[vThreadID.x].tangent.xyzw = float4(_tangent.xyz, pos.tangent.w);

    return;
}
