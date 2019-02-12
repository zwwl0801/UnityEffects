Shader "ZW/FlowAnimation"
{
	Properties
	{
		_MainTex ("MainTexture", 2D) = "white" {}
		_FlowTex ("FlowTexture", 2D) = "white" {}
		_FlowSpeed("FlowSpeed",Float) = 1.0
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
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv_MainTex : TEXCOORD0;
				float2 uv_FlowTex : TEXCOORD1;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _FlowTex;
			float4 _FlowTex_ST;
			float _FlowSpeed;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv_MainTex = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv_FlowTex = TRANSFORM_TEX(v.uv, _FlowTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col1 = tex2D(_MainTex, i.uv_MainTex);
				float2 uv_animat = i.uv_FlowTex;

				uv_animat.y   +=  (_FlowSpeed * _Time.y);
				fixed4 col2 = tex2D(_FlowTex, uv_animat);


				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);

				fixed finalColor = col1 + col2;

				return finalColor ;
			}
			ENDCG
		}
	}
}
