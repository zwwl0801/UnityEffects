// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ZW/Dissolve" 
{
	Properties 
	{
		_BurnAmount ("Burn Amount", Range(0.0, 1.0)) = 0.0
		_LineWidth("Burn Line Width", Range(0.0, 0.2)) = 0.1
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BumpNormalTex ("Normal Map", 2D) = "bump" {}
		_BurnFirstColor("Burn First Color", Color) = (1, 0, 0, 1)
		_BurnSecondColor("Burn Second Color", Color) = (1, 0, 0, 1)
		_BurnTex("Burn Map", 2D) = "white"{}
	}
	SubShader 
	{
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry" }
		Pass
		{
			Tags { "LightMode"="ForwardBase" }
			Cull Off
			CGPROGRAM
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			
			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 texcoord:TEXCOORD0;
			}; 
			struct v2f
			{
				float4 pos:SV_POSITION;
				float2 uv_MainTex:TEXCOORD0;
				float2 uv_Bump:TEXCOORD1;
				float2 uv_Burn:TEXCOORD2;
				float3 lightDir_Tangent:TEXCOORD3;
				float3 worldPos:TEXCOORD4;
				SHADOW_COORDS(5)
			};
			sampler2D _MainTex;
			sampler2D _BumpNormalTex;
			sampler2D _BurnTex;
			fixed4 _BurnFirstColor;
			fixed4 _BurnSecondColor;
			float _BurnAmount;
			float _LineWidth;
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv_MainTex = v.texcoord;
				o.uv_Bump = v.texcoord;
				o.uv_Burn = v.texcoord;
				TANGENT_SPACE_ROTATION;
				o.lightDir_Tangent = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
  				TRANSFER_SHADOW(o);
				return o;
			}
			fixed4 frag(v2f i):SV_Target
			{
				fixed3 burnTexColor = tex2D(_BurnTex,i.uv_Burn).rgb;
				float burnTexAmount = burnTexColor.r;
				//镂空效果
				clip(burnTexAmount - _BurnAmount);

				fixed3 albedo = tex2D(_MainTex,i.uv_MainTex).rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 m_tangentNormal = UnpackNormal(tex2D(_BumpNormalTex,i.uv_Bump));
				float3 m_tangentLightDir = normalize(i.lightDir_Tangent);

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(m_tangentNormal,m_tangentLightDir));
				//如果参数小于起点，linstep 将返回 0。
				//如果参数大于终点，linstep 将返回 1。
				//下图将根据时间顺序比较 smoothstep 和 linstep 返回的值:
				//noiseValue= 1;代表的消融的边界
				//noiseValue = 0 ；代表正常的颜色
				float noiseValue = 1 - smoothstep(0.0,_LineWidth,burnTexColor.r - _BurnAmount);
				fixed3 burnColor = lerp(_BurnFirstColor,_BurnSecondColor,noiseValue);
				burnColor = pow(burnColor, 5);

				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				
				fixed3 lightColor = ambient + diffuse * atten;

				//烧毁
				//inline float step( float _Y, float _X )
				//如果_X 大于或等于_Y，返回 1;否则 0，
				//保证当_BurnAmount = 0时不显示任何消融的效果。
				fixed3 finanColor = lerp(lightColor,burnColor,noiseValue * step(0.0001, _BurnAmount));
				return fixed4(finanColor.rgb,1);;
			}
			ENDCG
		}
	}
}
