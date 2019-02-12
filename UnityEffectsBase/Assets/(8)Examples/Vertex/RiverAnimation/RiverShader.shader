// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ZW/RiverShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Magnitude ("Distortion Magnitude", Float) = 1
 		_Frequency ("Distortion Frequency", Float) = 1
 		_InvWaveLength ("Distortion Inverse Wave Length", Float) = 10
 		_Speed ("Speed", Float) = 0.5
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
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			float _Magnitude;
			float _Frequency;
			float _InvWaveLength;
			float _Speed;
			
			v2f vert (appdata v)
			{
				v2f o;
				float4 offset ;
				offset.yzw = float3(0,0,0);
				//振幅，角频，初相位
				offset.x = sin(_Frequency * _Time.y + v.vertex.x*_InvWaveLength +v.vertex.y * _InvWaveLength+ v.vertex.z * _InvWaveLength)* _Magnitude;
				o.vertex = UnityObjectToClipPos(v.vertex + offset);

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv +=  float2(0.0, _Time.y * _Speed);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
