// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ZW/BloomTest"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BloomTex ("BloomTex",2D) = "white" {}
		_LuminanceThreshold("LuminanceThreshold",Float) = 1.0
		_BlurSize ("Blur Size", Float) = 1.0
	}
	SubShader
	{
		CGINCLUDE
		#include "UnityCG.cginc"
		
		sampler2D _MainTex;
		float4 _MainTex_ST;
		sampler2D _BloomTex;
		float4 _BloomTex_ST;
		float _LuminanceThreshold;
		float _BlurSize;
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

		/////将特别亮的区域渲染到一张图上////////////////////////////////////////////////////////////
		fixed luminance(fixed4 lcolor)
		{
			return 0.2125*lcolor.r+ 0.7154*lcolor.g+0.0721*lcolor.b;
		}
		mv2f vertBright(ma2v i)
		{
			mv2f o;
			o.pos = UnityObjectToClipPos(i.vertex);
			o.uv.xy = i.texcoord;
			o.uv.zw = i.texcoord;
			return o;
		}
		fixed4 fragBright(mv2f i):SV_Target
		{
			fixed4 c = tex2D(_MainTex,i.uv.xy);
			fixed val = clamp( luminance(c)- _LuminanceThreshold,0.0,1.0);
			return c*val;
		}
		/////////////////////////////////////////////////////////////////
		ENDCG

		ZTest Always
		Cull Off
		//ZWrite Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vertBright
			#pragma fragment fragBright
			ENDCG
		}
		UsePass "ZW/Gaussian/GAUSSIAN_ZW1"
		
		UsePass "ZW/Gaussian/GAUSSIAN_ZW2"
		
		Pass 
		{  
			CGPROGRAM  
			#pragma vertex vertBloom  
			#pragma fragment fragBloom  
			
			ENDCG  
		}
	}
}
