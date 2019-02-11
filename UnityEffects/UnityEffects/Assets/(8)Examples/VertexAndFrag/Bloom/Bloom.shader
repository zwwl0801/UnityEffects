// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ZW/Bloom"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BloomTex ("BloomTex",2D) = "white" {}
	}
	SubShader
	{
		CGINCLUDE
		#include "UnityCG.cginc"
		
		sampler2D _MainTex;
		float4 _MainTex_ST;
		sampler2D _BloomTex;
		float4 _BloomTex_ST;

		struct ma2v
		{
			float4 vertex:POSITION;
			half2 texcoord:TEXCOORD0;
		};
		struct mv2f
		{
			float4 pos:SV_POSITION;
			half4 uv:TEXCOORD0;
		};
		mv2f vertBloom(ma2v i)
		{
			mv2f o;
			o.pos  = UnityObjectToClipPos (i.vertex);
			o.uv.xy = i.texcoord;
			o.uv.zw = i.texcoord;
			return o;
		}
		fixed4 fragBloom(mv2f i):SV_Target
		{
			fixed4 col;
			col = tex2D(_MainTex,i.uv.xy)+tex2D(_BloomTex,i.uv.zw);
			return col;
		}
		ENDCG

		ZTest Always
		Cull Off
		//ZWrite Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vertBloom
			#pragma fragment fragBloom
			ENDCG
		}
	}
}
