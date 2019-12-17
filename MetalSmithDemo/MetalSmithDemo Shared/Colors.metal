//
//  Colors.metal
//  MetalSmithDemo
//
//  Created by Nick Kallen on 12/16/19.
//  Copyright © 2019 Nick Kallen. All rights reserved.
//

// From KodeLife

#include <metal_stdlib>
using namespace metal;

kernel void colors(
                   const texture2d<float, access::write> image,
                   const constant float &time,
                   const uint2 gid [[thread_position_in_grid]])
{
    float2 uv = -1. + 2. * float2(gid) / float2(image.get_width(), image.get_height());
    float4 col = float4(
                        abs(sin(cos(time+3.*uv.y)*2.*uv.x+time)),
                        abs(cos(sin(time+2.*uv.x)*3.*uv.y+time)),
                        0.5,
                        1.0);
    image.write(col, gid);
}
