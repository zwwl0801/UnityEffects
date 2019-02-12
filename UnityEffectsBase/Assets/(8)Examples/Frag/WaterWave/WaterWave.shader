Shader "ZW/WaterWave"
{
	Properties
	{
		_MainTex ("MainTexture", 2D) = "white" {}
		_NoiseTex ("NoiseTexture", 2D) = "white" {}
		_WaveXSpeed("WaveXSpeed", Range(-0.1, 0.1)) = 0.01
		_WaveYSpeed("WaveYSpeed", Range(-0.1, 0.1)) = 0.01
		_Distortion("Distortion",Range(0,100)) = 10
		_ReflCubemap("ReflCubemap",Cube) = "_Skybox"{}
		_Color("MainColor",Color) = (0,0.15,0.115,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		GrabPass
		{
			"_RefractionTex"
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float4 normal:NORMAL;
				float4 tangent: TANGENT;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv_MainTex : TEXCOORD0;
				float2 uv_NoiseTex : TEXCOORD1;

				float4 srcPos:TEXCOORD6;

				float4 TtoW0 : TEXCOORD3;
				float4 TtoW1 : TEXCOORD4;
				float4 TtoW2 : TEXCOORD5;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;
			float _WaveXSpeed;
			float _WaveYSpeed;
			float _Distortion;
			samplerCUBE _ReflCubemap;
			sampler2D _RefractionTex;
			float4 _RefractionTex_TexelSize;//得到纹理的纹素大小
			fixed4 _Color;
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv_MainTex = TRANSFORM_TEX(v.texcoord,_MainTex);
				o.uv_NoiseTex = TRANSFORM_TEX(v.texcoord,_NoiseTex);

				o.srcPos = ComputeGrabScreenPos(v.vertex);

				float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldTangent = UnityObjectToWorldDir(v.tangent);
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w; 
	
				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);  
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);  
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
			
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				float2 speed = _Time.y * float2(_WaveXSpeed,_WaveYSpeed);


				//切线空间计算
				//噪声贴图是使用的切线空间下的贴图
				//在切线空间计算切线
				fixed3 m_normal1 = UnpackNormal(tex2D(_NoiseTex, i.uv_NoiseTex - speed  ));
				fixed3 m_normal2 = UnpackNormal(tex2D(_NoiseTex, i.uv_NoiseTex + speed  ));
				fixed3 dest_normal = normalize(m_normal1 + m_normal2);
				//计算offset 在切线空间
				float2 offset = dest_normal.xy * _Distortion * _RefractionTex_TexelSize.xy;
				i.srcPos.xy = offset * i.srcPos.z + i.srcPos.xy;
				fixed3 refrColor = tex2D(_RefractionTex,i.srcPos.xy/i.srcPos.w).rgb; 
				//将法线从切线空间转换到世界空间
				fixed3 bumpWorld = normalize(half3(dot(i.TtoW0.xyz,dest_normal),dot(i.TtoW1.xyz,dest_normal),dot(i.TtoW2.xyz,dest_normal) ));
				float4 texColor = tex2D(_MainTex,i.uv_MainTex + speed);
				float3 reflDir = reflect(-viewDir,bumpWorld);
				float3 reflColor = texCUBE(_ReflCubemap,reflDir).rgb * texColor.rgb *_Color.rgb;
				
				fixed fresnel = pow(1-saturate(dot(viewDir,dest_normal)),4);
				fixed3 finalColor = reflColor * fresnel + refrColor*(1 - fresnel);
				return fixed4(finalColor.rgb,1);;
			}
			ENDCG
		}
	}
}
