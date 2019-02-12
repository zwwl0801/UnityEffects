// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ZW/MotionBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BlurAmount("BlurAmount",Float) = 1.0
	}
	SubShader
	{
		CGINCLUDE
		struct a2v
		{
			float4 vertex:POSITION;
			float2 texcoord:TEXCOORD0;
		};
		struct v2f
		{
			float4 pos:SV_POSITION;
			float2 uv:TEXCOORD0;
		};
		sampler2D _MainTex;
		float _BlurAmount;
		v2f vert(a2v i)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(i.vertex);
			o.uv = i.texcoord;
			return o;
		}
		fixed4 fragRGB(v2f i):SV_Target
		{
			fixed4 col;
			col = tex2D(_MainTex,i.uv);
			col.a = _BlurAmount;
			return col;
		}
		fixed4 fragA(v2f i):SV_Target
		{
			fixed4 col;
			col = tex2D(_MainTex,i.uv);
			return col;
		}
		ENDCG

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment fragRGB
			ENDCG
		}
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment fragA
			ENDCG
		}
	}
}
