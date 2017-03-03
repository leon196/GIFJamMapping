Shader "Hidden/Effect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _PositionTexture;
			sampler2D _NormalTexture;
			float _TimeElapsed;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 position = tex2D(_PositionTexture, i.uv);
				fixed4 normal = tex2D(_NormalTexture, i.uv) * 2. - 1.;
				fixed4 color = fixed4(1,1,1,1);
				// color.rgb = float3(1,1,1) * sin(length(position) * PI2 + _TimeElapsed * PI2);
				color.rgb = float3(1,1,1) * sin(length(position.xz) * PI2 + _TimeElapsed * PI2);
				// float shade = dot(normal, rotateX(rotateY(float3(1,0,0), _TimeElapsed * PI2 * 2), _TimeElapsed * PI2)) * 0.5 + 0.5;
				// color.rgb = float3(1,1,1) * shade;
				return color;
			}
			ENDCG
		}
	}
}
