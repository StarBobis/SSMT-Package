#define VERTEX_COUNT IniParams[0].x
#define POSE_ID IniParams[0].y

Texture1D<float4> IniParams : register(t120);

cbuffer cb0_struct : register(b0) {
    uint4 cb0[6];
}

struct t0_t {
    float3 position;
    float3 normal;
    float4 tangent;
};
struct t1_t {
    float2 weight;
    uint2 index;
};

StructuredBuffer<t0_t> t0 : register(t20);
StructuredBuffer<t1_t> t1 : register(t21);
StructuredBuffer<float4x4> t2 : register(t22);

RWStructuredBuffer<float> u0 : register(u0);
RWStructuredBuffer<float> u1 : register(u1);
RWStructuredBuffer<float> u2 : register(u2);
RWStructuredBuffer<float> u3 : register(u3);
RWStructuredBuffer<float> u4 : register(u4);
RWStructuredBuffer<float> u5 : register(u5);
RWStructuredBuffer<float> u6 : register(u6);

[numthreads(64, 1, 1)]
void main(uint3 vThreadID: SV_DispatchThreadID) {
    if (vThreadID.x >= (uint)VERTEX_COUNT) {
        return;
    }

    if (POSE_ID < 40 || POSE_ID > 49) {
        // invalid- we leave
        return;
    }

    uint slot = (uint)POSE_ID % 10;
    uint offset = cb0[slot < 4 ? 4 : 5][slot % 4];

    t0_t pos = t0[vThreadID.x];
    t1_t blend = t1[vThreadID.x];

    float4 pose_0 = (+blend.weight.x * t2[blend.index.x + offset][0].xyzw + blend.weight.y * t2[blend.index.y + offset][0].xyzw);
    float4 pose_1 = (+blend.weight.x * t2[blend.index.x + offset][1].xyzw + blend.weight.y * t2[blend.index.y + offset][1].xyzw);
    float4 pose_2 = (+blend.weight.x * t2[blend.index.x + offset][2].xyzw + blend.weight.y * t2[blend.index.y + offset][2].xyzw);

    float4x3 mat_43 = {
        pose_0.x, pose_1.x, pose_2.x,
        pose_0.y, pose_1.y, pose_2.y,
        pose_0.z, pose_1.z, pose_2.z,
        pose_0.w, pose_1.w, pose_2.w
    };
    float3x3 mat_33 = {
        mat_43[0],
        mat_43[1],
        mat_43[2]
    };

    float3 _position = mul(float4(pos.position, 1), mat_43);
    float3 _normal = normalize(mul(pos.normal.xyz, mat_33));
    float3 _tangent = normalize(mul(pos.tangent.xyz, mat_33));

    float output[10] = { 
        _position.x,
        _position.y,
        _position.z,
        _normal.x,
        _normal.y,
        _normal.z,
        _tangent.x,
        _tangent.y,
        _tangent.z,
        pos.tangent.w
    };

    uint id = vThreadID.x * 10;
    uint i = 0;
    [forcecase]
    switch(slot) {
        case 0: for (; i < 10; ++i) u0[id + i] = output[i]; break;
        case 1: for (; i < 10; ++i) u1[id + i] = output[i]; break;
        case 2: for (; i < 10; ++i) u2[id + i] = output[i]; break;
        case 3: for (; i < 10; ++i) u3[id + i] = output[i]; break;
        case 4: for (; i < 10; ++i) u4[id + i] = output[i]; break;
        case 5: for (; i < 10; ++i) u5[id + i] = output[i]; break;
        case 6: for (; i < 10; ++i) u6[id + i] = output[i]; break;
    }

    return;
}
