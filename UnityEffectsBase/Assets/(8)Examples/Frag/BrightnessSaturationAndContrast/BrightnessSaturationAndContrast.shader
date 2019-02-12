Shader "ZW/BrightnessSaturationAndContrast"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		//_Brightness("Brightness",Float) = 1
		_Brightness("Brightness",Range(0,3)) = 1
		_Saturation("Saturatin",Range(0,3)) = 1
		_Contrast("Contrast",Range(0,3)) = 1
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
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Brightness;
			float _Saturation;
			float _Contrast;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				//Brightness
				fixed4 col0 = tex2D(_MainTex, i.uv);
				fixed4 col  = col0*_Brightness;
				//
				fixed SaturatinItem = 0.2125 *col.r + 0.7154*col.g + 0.0721*col.b;
				fixed4 SaturatinCol = fixed4(SaturatinItem,SaturatinItem,SaturatinItem,SaturatinItem);
				col = lerp(SaturatinCol,col,_Saturation);
				//Contrast
				fixed ContrastItem = 0.5;
				fixed4 ContrastCol = fixed4(0.5,0.5,0.5,0.5);
				col = lerp(ContrastCol,col,_Contrast);
				return col;
			}
			ENDCG
		}
	}
}
