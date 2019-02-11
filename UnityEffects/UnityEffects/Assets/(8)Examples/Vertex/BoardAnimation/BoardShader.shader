// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/BoardShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MultiIndex("MultiIndex",Float) = 1
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "DisableBatching"="True"}
		LOD 100

		Pass
		{
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
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
			float _MultiIndex;
			fixed4 _Color;
			v2f vert (appdata v)
			{
				v2f o;
				float3 center = float3(0,0,0);
				float3 viewer = mul(unity_WorldToObject,float4(_WorldSpaceCameraPos,1));
				float3 normalDir = viewer - center;
				//_MultiIndex = 1;法线方向为观察视角时所得到的效果，广告牌都完全面向照相机。
				//_MultiIndex = 0; 固定指向上的方向为（0,1，0）时所得到的效果，广告牌虽然最大限度朝向照相机，但其指向上的方向并未发生改变。
				normalDir.y *= _MultiIndex;
				normalDir = normalize(normalDir);
				float3 upDir = abs(normalDir.y) > 0.9999?float3(0,0,1):float3(0,1,0);
				float3 rightDir = normalize(cross(upDir,normalDir));
				upDir = normalize(cross(normalDir,rightDir));

				float3 centerOffs = v.vertex.xyz - center; 
				float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;
              
			  //新的平面是在object space下的，还需要转换到屏幕投影空间；
				o.vertex = UnityObjectToClipPos(float4(localPos, 1));
				o.uv = TRANSFORM_TEX(v.uv,_MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				col.rgb *= _Color.rgb;
				return col;
			}
			ENDCG
		}
	}
}
