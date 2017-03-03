Shader "Unlit/Mapping"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 vertexWorld : TEXCOORD1;
			};

			sampler2D _MainTex;
			sampler2D _PositionTexture;
			sampler2D _ShaderPassTexture;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertexWorld = mul(UNITY_MATRIX_M, v.vertex);
				v.vertex.xy = v.uv * 2. - 1.;
				v.vertex.z = 1.;
				o.vertex = v.vertex;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_ShaderPassTexture, i.uv);
				col.rgb = i.vertexWorld;
				// col.rg = i.uv;
				return col;
			}
			ENDCG
		}
	}
}
