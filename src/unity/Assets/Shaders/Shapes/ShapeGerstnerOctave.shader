// This file is subject to the MIT License as seen in the root of this folder structure (LICENSE)

// A single Gerstner Octave
Shader "Ocean/Shape/Gerstner Octave"
{
	Properties
	{
		_Amplitude ("Amplitude", float) = 1
		_Wavelength("Wavelength", range(0,120)) = 100
		_Angle ("Angle", range(-180, 180)) = 0
		_Steepness("Steepness", range(0, 5)) = 0.1
		_SpeedMul("Speed Mul", range(0, 1)) = 1.0
	}

	Category
	{
		Tags{ "Queue" = "Transparent" }

		SubShader
		{
			Pass
			{
				Name "BASE"
				Tags { "LightMode" = "Always" }
				//Blend One One
			
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fog
				#include "UnityCG.cginc"
				#include "MultiscaleShape.cginc"

				#define PI 3.141592653

				struct appdata_t {
					float4 vertex : POSITION;
					float2 texcoord : TEXCOORD0;
				};

				struct v2f {
					float4 vertex : SV_POSITION;
					float3 worldPos : TEXCOORD0;
					float2 uv : TEXCOORD1;
				};

				uniform float _Wavelength;

				v2f vert( appdata_t v )
				{
					v2f o;
					o.vertex = UnityObjectToClipPos( v.vertex );

					o.uv = o.vertex.xy;
					o.uv.y = -o.uv.y;
					o.uv.xy = 0.5*o.uv.xy + 0.5;

					o.worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;

					// if wavelength is too small, kill this quad so that it doesnt render any shape
					if( !SamplingIsAppropriate( _Wavelength ) )
						o.vertex.xy *= 0.;

					return o;
				}

				// respects the gui option to freeze time
				uniform float _MyTime;
				uniform float _MyDeltaTime;

				uniform float _Amplitude;
				uniform float _Angle;
				uniform float _Steepness;
				uniform float _SpeedMul;

				float4 frag (v2f i) : SV_Target
				{
					float2 distToEdge = min(i.uv,1. - i.uv) * _ScreenParams.xy;
					float thr = 5.;
					if (distToEdge.x > .75 * thr
						&& distToEdge.y > .75 * thr )
					{
						clip(-1.);
					}

					float C = _SpeedMul * ComputeDriverWaveSpeed(_Wavelength);
					// direction
					float2 D = float2(cos(PI * _Angle / 180.0), sin(PI * _Angle / 180.0));
					// wave number
					float k = 2. * PI / _Wavelength;

					float2 displacedPos = i.worldPos.xz;

					// use fixed point iteration to solve for sample position, to compute displacement.
					// this could be written out to a texture and used to displace foam..

					// samplePos + disp(samplePos) = displacedPos
					// error = displacedPos - disp(samplePos)
					// iteration: samplePos += displacedPos - disp(samplePos)

					// start search at displaced position
					float2 samplePos = displacedPos;
					//for (int i = 0; i < 8; i++)
					//{
					//	float x_ = dot(D, samplePos);
					//	float2 error = displacedPos - (samplePos + _Steepness * -sin(k*(x_ + C*_MyTime)) * D);
					//	// move to eliminate error
					//	samplePos += 0.7 * error;
					//}

					float x = dot(D, samplePos);
					float y0 = /*_Amplitude **/ cos(k*(x + C*(_MyTime - _MyDeltaTime)));
					float y1 = /*_Amplitude **/ cos(k*(x + C*_MyTime));

					return float4(/*_MyDeltaTime*_MyDeltaTime**/y1, y0, 0., 0.);
				}

				ENDCG
			}
		}
	}
}
