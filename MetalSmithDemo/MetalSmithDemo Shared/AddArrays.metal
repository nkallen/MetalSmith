#include <metal_stdlib>
using namespace metal;

kernel void add_arrays(device const float* inA,
                       device const float* inB,
                       device float* result,
                       uint gid [[thread_position_in_grid]])
{
    result[gid] = inA[gid] + inB[gid];
}
