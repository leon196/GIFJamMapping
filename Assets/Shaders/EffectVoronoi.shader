Shader "_EffectVoronoi"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_noiseTex ("Noise", 2D) = "white" {}
		_noiseTexNMap ("Noise NMap", 2D) = "white" {}
		_UVEdge ("_UVEdge", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Utils.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 normal : TEXCOORD1;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				o.normal = v.normal;

				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _PositionTexture;
			sampler2D _NormalTexture;
			sampler2D _noiseTex;
			sampler2D _noiseTexNMap;
			sampler2D _UVEdge;
			float _TimeElapsed;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed noise = tex2D(_noiseTex, i.uv).r;
				fixed3 noiseNMap = tex2D(_noiseTexNMap, i.uv).rgb;
				fixed uvEdge = tex2D(_UVEdge, i.uv).r;
				fixed3 normaltex = tex2D(_NormalTexture, i.uv).rgb;
				normaltex = normaltex*2.0 - 1.0;

				float3 finalNormal = noiseNMap*2.0 - 1.0;
//				finalNormal *= 1000.0;
//				finalNormal += i.normal * 2.0;
				finalNormal += normaltex * 2.0;
				finalNormal = normalize(finalNormal);
				finalNormal = dot(finalNormal,float3(0,-5,0)) * float3(0.3,0.3,0.8);
//				noiseNMap = normalize(noiseNMap);
//				return float4(i.normal,1.0);
//				return fixed4(normaltex* 2.0 - 1.0,1.0);

				float mixHardness = 5;
				float speed = 1.0;
				float controlTime = _TimeElapsed * speed;
				controlTime = fmod(controlTime,2.0);


				noise *= mixHardness;
				noise -= mixHardness;
				float shift = abs(1.0 - (controlTime)) * mixHardness;

				noise +=  shift;
				noise = saturate(noise);

				float highlight = 1-abs(noise*2-1);
				float dotVert = (dot(normaltex,float3(0,5,0)) + 1);


				float3 col = lerp(finalNormal * noiseNMap * 1.5,dotVert*0.2-uvEdge*dotVert,noise);
				col += highlight * float3(1.0,0.2,0.2) * 5.0;
				//col += highlight
				//noise = abs(noise);
//				fixed4 noiseNMap = tex2D(_noiseTexNMap, i.uv);
				return float4(col,1.0);;
//				fixed4 position = tex2D(_PositionTexture, i.uv);
//				fixed4 normal = tex2D(_NormalTexture, i.uv) * 2. - 1.;
//				fixed4 color = fixed4(1,1,1,1);
				// color.rgb = float3(1,1,1) * sin(length(position) * PI2 + _TimeElapsed * PI2);
//				color.rgb = float3(1,1,1) * sin(length(position.xz) * PI2 + _TimeElapsed * PI2);
				// float shade = dot(normal, rotateX(rotateY(float3(1,0,0), _TimeElapsed * PI2 * 2), _TimeElapsed * PI2)) * 0.5 + 0.5;
				// color.rgb = float3(1,1,1) * shade;
//				return color;
			}
			ENDCG
		}
	}
}
