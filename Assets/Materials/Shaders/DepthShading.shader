// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DepthShading"
{
	Properties
	{
		[HDR]_Color("Color", Color) = (0,0.3476925,1,1)
		_Distance("Distance", Float) = 0
		_DistanceOffset("Distance Offset", Float) = 0
		[HDR]_ColorFar("Color Far", Color) = (1,0,0,1)
		_FresnelColor("Fresnel Color", Color) = (1,1,1,1)
		_Fresnel("Fresnel", Float) = 0
		_FresnelScale("Fresnel Scale", Float) = 0
		_FresnelPower("Fresnel Power", Float) = 1
		[Toggle]_FresnelInversion("Fresnel Inversion", Float) = 1
		[Toggle]_BrokenFresnel("Broken Fresnel", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float customSurfaceDepth9;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float4 _ColorFar;
		uniform float4 _Color;
		uniform float _Distance;
		uniform float _DistanceOffset;
		uniform float4 _FresnelColor;
		uniform float _FresnelInversion;
		uniform float _BrokenFresnel;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform float _Fresnel;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 customSurfaceDepth9 = ase_vertex3Pos;
			o.customSurfaceDepth9 = -UnityObjectToViewPos( customSurfaceDepth9 ).z;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			c.rgb = ( ase_lightAtten * ase_lightColor ).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
			float cameraDepthFade9 = (( i.customSurfaceDepth9 -_ProjectionParams.y - _DistanceOffset ) / _Distance);
			float4 lerpResult10 = lerp( _ColorFar , _Color , saturate( ( 1.0 - cameraDepthFade9 ) ));
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float4 transform66 = mul(unity_ObjectToWorld,float4( ase_vertexNormal , 0.0 ));
			float fresnelNdotV15 = dot( lerp(transform66,float4( (WorldNormalVector( i , ase_vertexNormal )) , 0.0 ),_BrokenFresnel).xyz, ase_worldViewDir );
			float fresnelNode15 = ( 0.0 + _FresnelScale * pow( 1.0 - fresnelNdotV15, _FresnelPower ) );
			float temp_output_26_0 = saturate( fresnelNode15 );
			float lerpResult59 = lerp( 0.0 , ( 1.0 - temp_output_26_0 ) , _Fresnel);
			float lerpResult31 = lerp( 0.0 , temp_output_26_0 , _Fresnel);
			float4 lerpResult19 = lerp( lerpResult10 , _FresnelColor , lerp(lerpResult59,lerpResult31,_FresnelInversion));
			o.Emission = lerpResult19.rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float1 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.x = customInputData.customSurfaceDepth9;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.customSurfaceDepth9 = IN.customPack1.x;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15600
2699;86;2234;1242;515.7708;-59.9976;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;52;-1061.217,364.1762;Float;False;1642.684;464.8685;Fresnel;14;18;67;68;20;59;31;28;60;26;15;22;16;66;21;;1,1,1,1;0;0
Node;AmplifyShaderEditor.NormalVertexDataNode;18;-1006.044,474.3912;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;67;-832.7708,665.9976;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;66;-572.7708,488.9976;Float;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;53;-435.3334,-444.5345;Float;False;1011.873;797.9767;Color;9;10;11;7;6;9;33;2;5;54;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-375.2458,651.0112;Float;False;Property;_FresnelScale;Fresnel Scale;6;0;Create;True;0;0;False;0;0;0.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;68;-627.7708,685.9976;Float;False;Property;_BrokenFresnel;Broken Fresnel;9;0;Create;True;0;0;False;0;0;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-377.2458,737.011;Float;False;Property;_FresnelPower;Fresnel Power;7;0;Create;True;0;0;False;0;1;1.99;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;16;-377.2668,507.0865;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;2;-390.3709,-406.0416;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;15;-165.7187,488.6137;Float;False;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-358.3709,-134.0414;Float;False;Property;_Distance;Distance;1;0;Create;True;0;0;False;0;0;19.09;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-422.3709,-6.041431;Float;False;Property;_DistanceOffset;Distance Offset;2;0;Create;True;0;0;False;0;0;3.44;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;26;66.82941,485.2302;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CameraDepthFade;9;-70.37094,-150.0414;Float;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;54.6684,743.2371;Float;False;Property;_Fresnel;Fresnel;5;0;Create;True;0;0;False;0;0;4.46;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;6;201.629,-86.04143;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;60;133.2292,630.9976;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;11;89.62904,9.958584;Float;False;Property;_ColorFar;Color Far;3;1;[HDR];Create;True;0;0;False;0;1,0,0,1;0.3773585,0.3773585,0.3773585,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;59;308.5293,702.114;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;7;86.86623,184.9687;Float;False;Property;_Color;Color;0;1;[HDR];Create;True;0;0;False;0;0,0.3476925,1,1;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;54;395.2292,-68.00244;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;51;149.2116,871.7985;Float;False;917.7266;487.6357;Lighting;2;48;62;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;31;309.8294,580.2302;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;20;387.7701,408.7504;Float;False;Property;_FresnelColor;Fresnel Color;4;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;10;422.8661,56.96882;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ToggleSwitchNode;55;722.2292,593.9976;Float;False;Property;_FresnelInversion;Fresnel Inversion;8;0;Create;True;0;0;False;0;1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;48;169.7843,939.8849;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;61;271.2292,1082.998;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;515.2292,995.9976;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;19;717.2595,356.2613;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1153.2,360.3999;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;DepthShading;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;67;0;18;0
WireConnection;66;0;18;0
WireConnection;68;0;66;0
WireConnection;68;1;67;0
WireConnection;15;0;68;0
WireConnection;15;4;16;0
WireConnection;15;2;21;0
WireConnection;15;3;22;0
WireConnection;26;0;15;0
WireConnection;9;2;2;0
WireConnection;9;0;5;0
WireConnection;9;1;33;0
WireConnection;6;0;9;0
WireConnection;60;0;26;0
WireConnection;59;1;60;0
WireConnection;59;2;28;0
WireConnection;54;0;6;0
WireConnection;31;1;26;0
WireConnection;31;2;28;0
WireConnection;10;0;11;0
WireConnection;10;1;7;0
WireConnection;10;2;54;0
WireConnection;55;0;59;0
WireConnection;55;1;31;0
WireConnection;62;0;48;0
WireConnection;62;1;61;0
WireConnection;19;0;10;0
WireConnection;19;1;20;0
WireConnection;19;2;55;0
WireConnection;0;2;19;0
WireConnection;0;13;62;0
ASEEND*/
//CHKSM=01C96B96C8E3C5A21F684A64782CE70B9D2678CC