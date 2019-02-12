// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ZW/BumpedSpecular" 
{
	Properties
	{
		_MainTex("Main Texture",2D) = "white"{}
		_NormalTex("Normal Texture",2D) = "white"{}
		_Color("AmbientColor" , Color) = (1,1,1,1)
		_Gloss("SpecularGloss",Float) = 1.0
		_SpeculatColor("SpeculatColor",Color) = (1,1,1,1)
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			#pragma vertex vert
			#pragma fragment frag

			sampler2D _MainTex;
			sampler2D _NormalTex;
			float _Gloss;
			fixed4 _Color;
			fixed4 _SpeculatColor;
			struct a2v
			{
				fixed4 vertex:POSITION;
				float4 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
				float4 tangent:TANGENT;
			};
			struct v2f
			{
				fixed4 pos:SV_POSITION;
				float4 uv_MainTex:TEXCOORD0;
				float4 uv_NormalTex:TEXCOORD1;

				float4 TtoW0 : TEXCOORD2;
				float4 TtoW1 : TEXCOORD3;
				float4 TtoW2 : TEXCOORD4;
			};
			v2f vert(a2v i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.uv_MainTex = i.texcoord;
				o.uv_NormalTex = i.texcoord;

				float3 worldPos = mul(unity_ObjectToWorld,i.vertex).xyz;
				float3 worldNormal = UnityObjectToWorldNormal(i.normal);
				float3 worldTangent = mul(unity_ObjectToWorld,i.tangent).xyz;
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * i.tangent.w; 
				
                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);  
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);  
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);  

				return o;
			}
			fixed4 frag(v2f v):SV_Target
			{
				fixed4 MainTexColor = tex2D(_MainTex,v.uv_MainTex);
				
				fixed4 NormalTexColor = tex2D(_NormalTex,v.uv_NormalTex);
				fixed3 bumpNormal = UnpackNormal(NormalTexColor);
				
				fixed3 albedo = MainTexColor.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				float3 tangent_Normal = normalize(half3(dot(v.TtoW0.xyz, bumpNormal),dot(v.TtoW1.xyz, bumpNormal), dot(v.TtoW2.xyz, bumpNormal)));
				
				float3 worldPos = float3(v.TtoW0.w, v.TtoW1.w, v.TtoW2.w);
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				float3 tangent_LightDir =normalize(lightDir + viewDir);
				
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(tangent_Normal,tangent_LightDir));
				
				fixed3 halfDir = normalize(lightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _SpeculatColor * pow( max(0, dot(halfDir,bumpNormal)),_Gloss); 

				
				UNITY_LIGHT_ATTENUATION(atten, v, worldPos);
				return fixed4(ambient+(diffuse+specular)*atten,1.0);
			}
			ENDCG
		}
	}
	FallBack "Specular"
}
