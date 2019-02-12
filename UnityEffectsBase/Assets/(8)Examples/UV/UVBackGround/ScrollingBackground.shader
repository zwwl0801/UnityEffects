Shader "ZW/ScrollingBackground"
{
	Properties
	{
		_BackGroudTexture ("BackGround Texture",2D) = "white" {}
		_MainTex ("Texture", 2D) = "white" {}
		_Multiplier("Multiplier",Float) = 1
		_ScrollX("ScrollX",Float) = 1
		_Scroll2X("Scroll2X",Float) = 1
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
				float4 texcoord : TEXCOORD1;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			sampler2D _BackGroudTexture;
			float4 _BackGroudTexture_ST;

			float _Multiplier ;

			float _ScrollX;
			float _Scroll2X;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex) + frac((float2(_ScrollX,0))*_Time.y);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BackGroudTexture)+ frac((float2(_Scroll2X,0))*_Time.y);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col1 = tex2D(_MainTex, i.uv.xy);
				fixed4 col2 = tex2D(_BackGroudTexture, i.uv.zw);

				fixed4 col = lerp(col2,col1,col1.a);
				col.rgb *= _Multiplier; 
				return col;
			}
			ENDCG
		}
	}
}
