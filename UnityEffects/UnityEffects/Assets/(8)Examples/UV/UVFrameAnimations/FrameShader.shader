Shader "ZW/FrameShader"
{
	Properties
	{
		_speed("Speed",Float) = 20.0
		_rowNum("MRow",Int) = 4
		_columnNum("MColumn",Int) = 8
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
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			int _rowNum;
			int _columnNum;
			float _speed;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float index = floor(_Time.y * _speed);
				float row = floor(index / _rowNum);
				float column = index - row*_rowNum;

				half2 muv = i.uv + half2(column,-row);
				muv.x /= _rowNum ;
				muv.y /= _columnNum;
				// sample the texture
				fixed4 col = tex2D(_MainTex, muv);
				return col;
			}
			ENDCG
		}
	}
}
