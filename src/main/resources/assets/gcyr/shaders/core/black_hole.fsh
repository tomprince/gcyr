#version 150

uniform sampler2D Sampler0;

uniform mat4 IViewRotMat;
uniform mat4 ModelViewMat;
uniform float GameTime;
uniform vec3 Light0_Direction;

in vec2 texCoord0;
in vec3 ViewPos;

out vec4 fragColor;


int frameCounter = int(fract(GameTime * 1200.));
float frameTimeCounter = fract(GameTime * 1200. * 6.);
const float PI = 3.14159265359;

float BlueNoise(const float ir){
    return fract(texelFetch(Sampler0, ivec2(gl_FragCoord.xy)%64, 0).x + ir * (frameCounter % 64));
}

float saturate(float x){
    return clamp(x, 0.0, 1.0);
}

vec3 curve(vec3 x){
    return x * x * (3.0 - 2.0 * x);
}

float atan2(vec2 v){
    return v.x == 0.0 ?
    (1.0 - step(abs(v.y), 0.0)) * sign(v.y) * PI * 0.5 :
    atan(v.y / v.x) + step(v.x, 0.0) * sign(v.y) * PI;
}

vec3 Blackbody(float temperature){
    // https://en.wikipedia.org/wiki/Planckian_locus
    const vec4[2] xc = vec4[2](
    vec4(-0.2661293e9, -0.2343589e6, 0.8776956e3, 0.179910), // 1667k <= t <= 4000k
    vec4(-3.0258469e9, 2.1070479e6, 0.2226347e3, 0.240390)// 4000k <= t <= 25000k
    );
    const vec4[3] yc = vec4[3](
    vec4(-1.1063814, -1.34811020, 2.18555832, -0.20219683), // 1667k <= t <= 2222k
    vec4(-0.9549476, -1.37418593, 2.09137015, -0.16748867), // 2222k <= t <= 4000k
    vec4(3.0817580, -5.87338670, 3.75112997, -0.37001483)// 4000k <= t <= 25000k
    );

    float temperatureSquared = temperature * temperature;
    vec4 t = vec4(temperatureSquared * temperature, temperatureSquared, temperature, 1.0);

    float x = dot(1.0 / t, temperature < 4000.0 ? xc[0] : xc[1]);
    float xSquared = x * x;
    vec4 xVals = vec4(xSquared * x, xSquared, x, 1.0);

    vec3 xyz = vec3(0.0);
    xyz.y = 1.0;
    xyz.z = 1.0 / dot(xVals, temperature < 2222.0 ? yc[0] : temperature < 4000.0 ? yc[1] : yc[2]);
    xyz.x = x * xyz.z;
    xyz.z = xyz.z - xyz.x - 1.0;

    const mat3 xyzToSrgb = mat3(
    3.24097, -0.96924, 0.05563,
    -1.53738, 1.87597, -0.20398,
    -0.49861, 0.04156, 1.05697
    );

    return max(xyzToSrgb * xyz, vec3(0.0));
}

//www.shadertoy.com/view/lstSRS

mat3 RotateMatrix(float x, float y, float z){
    mat3 matx = mat3(1.0, 0.0, 0.0,
    0.0, cos(x), sin(x),
    0.0, -sin(x), cos(x));

    mat3 maty = mat3(cos(y), 0.0, -sin(y),
    0.0, 1.0, 0.0,
    sin(y), 0.0, cos(y));

    mat3 matz = mat3(cos(z), sin(z), 0.0,
    -sin(z), cos(z), 0.0,
    0.0, 0.0, 1.0);

    return maty * matx * matz;
}

void WarpSpace(inout vec3 eyevec, inout vec3 raypos){
    vec3 origin = vec3(0.0, 0.0, 0.0);

    float singularityDist = distance(raypos, origin);
    float warpFactor = 1.0 / (singularityDist * singularityDist + 0.000001);

    vec3 singularityVector = normalize(origin - raypos);

    float warpAmount = 0.06;

    eyevec = normalize(eyevec + singularityVector * warpFactor * warpAmount);
}

float Calculate3DNoise(vec3 position){
    vec3 p = floor(position);
    vec3 b = curve(fract(position));

    vec2 uv = 17.0 * p.z + p.xy + b.xy;
    vec2 rg = texture(Sampler0, (uv + 0.5) / 64.0).zy;

    return mix(rg.x, rg.y, b.z);
}

float CalculateCloudFBM(vec3 position, vec3 shift){
    const int octaves = 4;
    const float octAlpha = 0.87;
    const float octScale = 2.5;
    const float octShift = (octAlpha / octScale) / octaves;

    float accum = 0.0;
    float alpha = 0.5;

    for (int i = 0; i < octaves; i++) {
        accum += alpha * Calculate3DNoise(position);
        position = (position + shift) * octScale;
        alpha *= octAlpha;
    }

    return accum + octShift;
}

float pcurve(float x, float a, float b){
    float k = pow(a + b, a + b) / (pow(a, a) * pow(b, b));
    return k * pow(x, a) * pow(1.0 - x, b);
}

void main(){
    fragColor = vec4(0.0);

    vec3 worldPos = mat3(IViewRotMat) * ViewPos;
    vec3 worldDir = normalize(worldPos);

    const float steps = 50.0;
    const float rSteps = 1.0 / steps;
    const float stepLength = 0.2;

    const float discRadius = 2.25;
    const float discWidth = 3.5;
    const float discInner = discRadius - discWidth * 0.5;
    const float discOuter = discRadius + discWidth * 0.5;

    float noise = BlueNoise(1.61803398);

    vec3 eye = -Light0_Direction * 8.0;
    vec3 rayPos = eye + worldDir * 3.0;

    mat3 rotation = RotateMatrix(0.1, 0.0, -0.35);

    vec3 result = vec3(0.0);
    float transmittance = 1.0;

    rayPos += worldDir * stepLength * noise;

    for (int i = 0; i < steps; i++){
        if (transmittance < 0.0001) break;

        WarpSpace(worldDir, rayPos);
        rayPos += worldDir * stepLength;

        {
            vec3 discPos = rotation * rayPos;

            float r = length(discPos);
            float p = atan2(-discPos.zx);
            float h = discPos.y;

            float radialGradient = 1.0 - saturate((r - discInner) / discWidth * 0.5);
            float dist = abs(h);

            float discThickness = 0.1;
            discThickness *= radialGradient;

            float fr = abs(r - discInner) + 0.4;
            fr = fr * fr;
            float fade = fr * fr * 0.04;
            float bloomFactor = 1.0 / (h * h * 40.0 + fade + 0.00002);
            bloomFactor *= saturate(2.0 - abs(dist) / discThickness);
            bloomFactor = bloomFactor * bloomFactor;

            float dr = pcurve(radialGradient, 4.0, 0.9);
            float density = dr;

            density *= saturate(1.0 - abs(dist) / discThickness);
            density = saturate(density * 0.7);
            density = saturate(density + bloomFactor * 0.1);

            if (density > 0.0001){
                vec3 discCoord = vec3(r, p * (1.0 - radialGradient * 0.5), h * 0.1) * 3.5;

                float fbm = CalculateCloudFBM(discCoord, frameTimeCounter * vec3(0.1, 0.07, 0.0));
                float fbm2 = fbm * fbm;
                density *= fbm2 * fbm2 * fbm;
                density *= dr;

                float gr = 1.0 - radialGradient;
                gr = gr * gr;
                float glowStrength = 1.0 / (gr * gr * 400.0 + 0.002);
                vec3 glow = Blackbody(2700.0 + glowStrength * 50.0) * glowStrength;

                float stepTransmittance = exp(-density * 5.0);
                float integral = 1.0 - stepTransmittance;
                transmittance *= stepTransmittance;

                result += integral * transmittance * glow;
            }

            vec2 t = vec2(1.0, 0.01);
            float torusDist = length(length(discPos + vec3(0.0, -0.05, 0.0)) - t);
            float bloomDisc = 1.0 / (pow(torusDist, 3.5) + 0.001);
            vec3 col = Blackbody(12000.0);
            bloomDisc *= step(0.5, r);

            result += col * bloomDisc * 0.1 * transmittance;
        }
    }
    result *= rSteps;

    fragColor *= transmittance;
    fragColor += vec4(result, 1.0);
}
