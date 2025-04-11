// Title: That Old CRT
// Author: MaddestLabs

SamplerState Sampler;
Texture2D contentTexture : register(t0);
Texture2D bgTexture : register(t1);

cbuffer PixelShaderSettings
{
    float Time;
    float Scale;
    float2 Resolution;
    float4 Background;
};

// Gaussian blur constants
#define SCALED_GAUSSIAN_SIGMA (2.0f * Scale)
static const float M_PI = 3.14159265f;

float rnd(float2 c) {
    return frac(sin(dot(c.xy, float2(12.9898,78.233))) * 43758.5453);
}

float3 hsl2rgb(float3 c) {
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float3 rgbShift(float2 uv, float offset) {
    float3 color;
    color.r = contentTexture.Sample(Sampler, uv + float2(offset, 0.0)).r;
    color.g = contentTexture.Sample(Sampler, uv).g;
    color.b = contentTexture.Sample(Sampler, uv - float2(offset, 0.0)).b;
    return color;
}

// Gaussian 2D function for bloom effect
float Gaussian2D(float x, float y, float sigma) {
    return 1 / (sigma * sqrt(2 * M_PI)) * exp(-0.5 * (x * x + y * y) / sigma / sigma);
}

// Blur function for bloom
float3 Blur(float2 tex_coord, float sigma, float sampleCount) {
    float width, height;
    float2 dimensions = Resolution;
    width = dimensions.x;
    height = dimensions.y;

    float texelWidth = 1.0f / width;
    float texelHeight = 1.0f / height;

    float3 color = float3(0, 0, 0);
    float totalWeight = 0.0f;
    
    for (float x = 0; x < sampleCount; x++) {
        float2 samplePos = float2(0, 0);
        samplePos.x = tex_coord.x + (x - sampleCount / 2.0f) * texelWidth;

        for (float y = 0; y < sampleCount; y++) {
            samplePos.y = tex_coord.y + (y - sampleCount / 2.0f) * texelHeight;
            
            float weight = Gaussian2D(x - sampleCount / 2.0f, y - sampleCount / 2.0f, sigma);
            totalWeight += weight;
            
            color += rgbShift(samplePos, 0.0005) * weight;
        }
    }
    
    return color / totalWeight;
}

float3 tex(float2 uv, float bSize, float3 bColor, bool isFrame, float fSize) {
    float iTime = Time;
    float2 iResolution = Resolution;

    float bgReflect = 0.75;
    float grilleLvl = 0.95; // Range: 0.0, 3.0
    float grilleDensity = 800.0; // Range: 0.0, 1000.0
    float scanlineLvl = 0.8; // Range: 0.05, 3.0
    float scanlines = 1.0; // Range:  1.0, 6.0
    float rgbOffset = 0.0005;
    float noiseLevel = 0.1;
    float flicker = 0.1;
    float glassTint = 0.5;
    float glassHue = 0.6;
    float glassSat = 0.5;
    float screenTint = 0.0;
    float screenHue = 0.27;
    float screenSat = 1.0;
    float bloomEnabled = 0.0; // Largley increases compile/start time when set above 0.0
    float bloomLow = 0.3f;
    float bloomHigh = 0.8f;
    float bloomRate = 3.0f;
    float vignetteStart = 0.25; //Range: 0.0, 2.0
    float vignetteLvl = 20.0; //Range: 1.0, 20.0
    float hSync = 0.0009; // Range: 0.0, 3.0

    // Bloom calculation
    float t = (sin(iTime * bloomRate) + 1.0f) * 0.5f;
    float bloomIntensity = lerp(bloomLow, bloomHigh, t);
    
    // Configure parameters for horizontal sync wave
    float time = iTime * 5.0;
    float size = lerp(0.0, hSync, 0.1);
    float hWave = sin(uv.y * 10.0 + time) * size;
    float3 color;
    
    // Use borderColor if within border width
    bool isBorder = 
        (uv.x < bSize || uv.x > 1.0 - bSize || 
         uv.y < bSize || uv.y > 1.0 - bSize);
    
    if (isBorder && bSize > 0.0) {
        // DISTORT - Horizontal Sync
        float2 buv = uv;
        buv.x += hWave;
        
        // Calculate normalized coordinates within the screen area
        // This properly maps the border area to screen coordinates
        float2 screenUV = (uv - float2(bSize, bSize)) / (1.0 - 2.0 * bSize);
        
        // Check if the normalized coordinates are within bounds
        if (screenUV.x < 0.0 || screenUV.x > 1.0 || screenUV.y < 0.0 || screenUV.y > 1.0) {
            // If out of bounds, use border color
            color = bColor;
        } else {
            // If in bounds but in border area, apply RGB shift to screen content
            // for reflection effect
            color = rgbShift(screenUV, rgbOffset);
        }
    } else {
        // For non-border screen area, scale UV coordinates properly
        float2 screenUV = (uv - float2(bSize, bSize)) / (1.0 - 2.0 * bSize);
        
        // Apply horizontal sync distortion
        screenUV.x += hWave;
        
        if (screenUV.x < 0.0 || screenUV.x > 1.0 || screenUV.y < 0.0 || screenUV.y > 1.0) {
            // If out of bounds after distortion, use border color
            color = bColor;
        } else {
            // Otherwise sample with RGB offset
            color = rgbShift(screenUV, rgbOffset);
        }
    }
    
    // FX Aperture Grille
    if (grilleLvl > 0.0) {
        float grillePattern = sin(uv.x * grilleDensity * 3.14159);
        grillePattern = grilleLvl + (1.0 - grilleLvl) * grillePattern;
        color *= (0.5 + 0.5 * grillePattern);
    }
    
    // FX Scanlines
    if (scanlineLvl > 0.05) {
        float scanlinePattern = sin(uv.y * iResolution.y * 3.14159 / scanlines);
        color *= (scanlineLvl + (1.0 - scanlineLvl) * scanlinePattern);
    }
    
    // FX Noise
    if (noiseLevel > 0.0) {
        float timeFactor = iTime * 1.0;
        float noise = rnd(uv + timeFactor);
        color += noise * noiseLevel * 0.5;
    }

    // FX Screen tint
    if (screenTint > 0.0) {
        float l = dot(color, float3(0.2126, 0.7152, 0.0722));
        float3 screen = hsl2rgb(float3(screenHue, screenSat, l));
        color = float3(lerp(color, float3(screen), screenTint));
    }
    
    // FX Glass tint
    if (glassTint > 0.0) {
        float t = 0.5 + 0.5 * uv.y;
        float3 tintColor = hsl2rgb(float3(glassHue, glassSat, t));
        color += tintColor * glassTint;
    }

    // FX Flicker
    if (flicker > 0.0) {
        float f = 1.0 + 0.25 * sin(iTime * 60.0) * flicker;
        color *= f;
    }

    // FX Reflection
    if (bgReflect > 0.0) {
        float4 reflection = bgTexture.Sample(Sampler, uv);
        // decrease contrast and brightness of reflection
        float3 dimmed = reflection.rgb * 0.1;
        float contrast = 0.5;
        float3 adjusted = 0.5f + (dimmed - 0.5f) * contrast;
        color += adjusted * bgReflect;
    }
    
    // FX Bloom
    if (bloomEnabled > 0.0) {
        float sampleCount = 5;
        float3 bloom = Blur(uv, SCALED_GAUSSIAN_SIGMA, sampleCount);
        color += bloom * bloomIntensity;
    }
    
    // FX Vignette
    if (isFrame) uv = (uv - 0.5) * (1.0 / (1.0 - fSize)) + 0.5;
    uv *= (1.0 - uv.yx);
    color *= pow(uv.x * uv.y * vignetteLvl, vignetteStart);

    return color;
}

float4 main(float4 fragCoord : SV_POSITION, float2 hlsluv : TEXCOORD) : SV_TARGET
{
    float iTime = Time;
    float2 iResolution = Resolution;
    float4 fragColor;

    float2 uv = fragCoord / iResolution.xy;
    float2 center = float2(0.5, 0.5);
    float alpha = 1.0;
    float distanceFromCenter = length(uv - center);
    // Calculate pixel size in UV coordinates
    float2 pxSize = 1.0 / iResolution.xy;
    // Calculate curvature
    float curveStrength = 0.5; // Range: 0.0, 5.0
    float curveDistance = 5.0; // Range: 0.0, 5.0
    uv += (uv - center) * pow(distanceFromCenter, curveDistance) * curveStrength;
    // Calculate Frame and Border sizes and set colors
    float frameSize = 10.0;
    float frameHue = 0.0;
    float frameSat = 0.0;
    float frameLight = 0.04;
    if (frameLight == 0.0) alpha = 0.0;
    float frameReflect = 0.4;
    float frameGrain = 0.1;
    float borderSize = 0.0;
    float borderHue = 0.0;
    float borderSat = 0.0;
    float borderLight = 0.0;
    
    float3 bColor = hsl2rgb(float3(borderHue, borderSat, borderLight));
    
    float frame = frameSize * pxSize.x;
    float border = borderSize * pxSize.x;
    // Calculate scaled UV coordinates with offset
    float2 suv = (uv - float2(frame, frame)) / (1.0 - 2.0 * (frame));

    float3 color;

    // Check if pixel is in frame region
    bool isFrame = (uv.x < frame || uv.x > (1.0 - frame) ||
                    uv.y < frame || uv.y > (1.0 - frame));
   
    // Determine color based on region
    if (isFrame) {
        // Calculate frame intensity based on distance to center
        float frame = 100.0;
        // Set frame lightness to 0.0 for black frame
        float nX = frame / iResolution.x;
        float nY = frame / iResolution.y;
        float intensity = 0.0;
        // Calculate minimum distance to frame
        float distX = min(uv.x, 1.0-uv.x);
        float distY = min(uv.y, 1.0-uv.y);
        float minDist = min(distX, distY);
        // Scale intensity based on distance, closer to center gets darker
        intensity = lerp(frameLight, 0.0, minDist / max(nX, nY) * 4.0);
        // Adjust coordinates for reflection
        float2 f = border / iResolution.xy;
        if (suv.x < f.x) {
            suv.x = f.x - (suv.x - f.x);
        } else if (suv.x > 1.0 - f.x) {
            suv.x = 1.0 - f.x - (suv.x - (1.0 - f.x));
        }
        if (suv.y < f.y) {
            suv.y = f.y - (suv.y - f.y);
        } else if (suv.y > 1.0 - f.y) {
            suv.y = 1.0 - f.y - (suv.y - (1.0 - f.y));
        }
        // Blur frame
        float3 blurred = float3(0.0, 0.0, 0.0);
        float blur = 2.0 / iResolution.x;
        float frameBlur = 1.0; // Range: 1.0, 6.0
        int r = int(frameBlur);
        for (int x = -r; x <= r; x++) {
            for (int y = -r; y <= r; y++) {
                float2 blurPos = suv + float2(float(x) * blur, float(y) * blur);
                // Don't draw border reflection unless it's large
                float b = 0.0;
                if (border > 0.03) b = border * 0.5;
                blurred += tex(blurPos, b, bColor, isFrame, frameSize);
            }
        }
        blurred /= 32.0;
        color = hsl2rgb(float3(frameHue, frameSat, intensity));
        color *= 1.0 - frameGrain * rnd(suv);
        color += blurred * frameReflect * 0.5;
    } else {
        color = tex(suv, border, bColor, isFrame, frameSize);
    }

    fragColor = float4(color, alpha);
    return fragColor;
}