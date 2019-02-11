// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ZW/Gaussian"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BlurSize("BlurSize",Float) = 1.0
	}
	SubShader
	{
		CGINCLUDE

		#include "UnityCG.cginc"

		sampler2D _MainTex;  
		half4 _MainTex_TexelSize;//MainTex_TexelSize，这个变量的从字面意思是主贴图 _MainTex 的像素尺寸大小，是一个四元数，是 unity 内置的变量，它的值为 Vector4(1 / width, 1 / height, width, height)
		float _BlurSize;

		struct mappdata
		{
			float4 vertex: POSITION;
			float2 texcoord:TEXCOORD0;
		};
		struct ma2f
		{
			float4 pos:SV_POSITION;
			float2 uv[5]:TEXCOORD0;
		};
			
		ma2f HengVertex(mappdata i)
		{
			ma2f o;
			o.pos = UnityObjectToClipPos(i.vertex);
			
			half2 uv = i.texcoord;
			o.uv[0] = uv;
			o.uv[1] = uv + half2(1 * _MainTex_TexelSize.x,0) * _BlurSize;
			o.uv[2] = uv - half2(1 * _MainTex_TexelSize.x,0) * _BlurSize;
			o.uv[3] = uv + half2(2 * _MainTex_TexelSize.x,0) * _BlurSize;
			o.uv[4] = uv - half2(2 * _MainTex_TexelSize.x,0) * _BlurSize;
			return o;
		}
		ma2f ShuVertex(mappdata i)
		{
			ma2f o;
			o.pos = UnityObjectToClipPos(i.vertex);
			
			half2 uv = i.texcoord;
			o.uv[0] = uv;
			o.uv[1] = uv + half2(0.0,1.0 * _MainTex_TexelSize.y) * _BlurSize;
			o.uv[2] = uv - half2(0.0,1.0 * _MainTex_TexelSize.y) * _BlurSize;
			o.uv[3] = uv + half2(0.0,2.0 * _MainTex_TexelSize.y) * _BlurSize;
			o.uv[4] = uv - half2(0.0,2.0 * _MainTex_TexelSize.y) * _BlurSize;
			return o;
		}

		fixed4 frag(ma2f i):SV_Target
		{
			float weight[3] = {0.4026,0.2442,0.0545}; 
			fixed3 sum = tex2D(_MainTex, i.uv[0]).rgb* weight[0];
			for(int index = 1; index < 3 ; index ++)
			{
				sum += tex2D(_MainTex, i.uv[2* index -1]).rgb* weight[index] ;
				sum += tex2D(_MainTex, i.uv[2* index]).rgb* weight[index] ;
			}
			fixed4 col = fixed4(sum,1.0);
			return col;
		}

		ENDCG


		
		ZTest Always
		Cull Off 
		ZWrite Off
		
		Pass 
		{
			NAME "GAUSSIAN_ZW1"
			
			CGPROGRAM
			  
			#pragma vertex ShuVertex  
			#pragma fragment frag
			  
			ENDCG  
		}
		Pass
		{
			NAME "GAUSSIAN_ZW2"
			
			CGPROGRAM  
			
			#pragma vertex HengVertex  
			#pragma fragment frag
			
			ENDCG
		}
	}
}
