﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/GreenShader"
{
    Properties
    {
        _Color("Color",Color) = (0,0,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="transparent" }
        LOD 100
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            struct appdata {float4 vertex : POSITION;};

            struct v2f
			{
                float4 vertex : SV_POSITION;
            };

            fixed4 _Color ;

            v2f vert (appdata v)
			{
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
			{
                fixed4 col = fixed4(0,1,0,1);
				return col;
            }
            ENDCG
        }
    }
}
