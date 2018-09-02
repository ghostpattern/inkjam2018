// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Explosion"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		[HDR]_Color("Color", Color) = (8,7.592157,7.309804,1)
		[HDR]_ColorEdge("Color Edge", Color) = (8,7.592157,7.309804,1)
		_Texture0("Texture 0", 2D) = "white" {}
		_Progression("Progression", Range( 0 , 1)) = 0
		_VertexOffset("Vertex Offset", Range( 0 , 1)) = 1
		_PanSpeed("Pan Speed", Range( 0 , 1)) = 1
		_ExpansionPower("Expansion Power", Range( 0 , 2)) = 1
		_YOffset("YOffset", Range( 0.5 , 5)) = 0.5
		[HDR]_FresnelColor("Fresnel Color", Color) = (8,7.592157,7.309804,1)
		_FresnelScale("Fresnel Scale", Float) = 0
		_FresnelPower("Fresnel Power", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			float2 uv_texcoord;
		};

		uniform float _Progression;
		uniform float _ExpansionPower;
		uniform float _YOffset;
		uniform sampler2D _Texture0;
		uniform float _PanSpeed;
		uniform float4 _Texture0_ST;
		uniform float _VertexOffset;
		uniform float4 _Color;
		uniform float4 _FresnelColor;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform float4 _ColorEdge;
		uniform float _Cutoff = 0.5;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float2 temp_cast_0 = (_PanSpeed).xx;
			float2 uv_Texture0 = v.texcoord.xy * _Texture0_ST.xy + _Texture0_ST.zw;
			float2 panner32 = ( _Time.y * temp_cast_0 + uv_Texture0);
			float4 tex2DNode5 = tex2Dlod( _Texture0, float4( panner32, 0, 0.0) );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 ase_vertexNormal = v.normal.xyz;
			float lerpResult22 = lerp( -0.5 , 1.0 , ( 1.0 - pow( ( 1.0 - _Progression ) , _ExpansionPower ) ));
			v.vertex.xyz += ( ( ( 1.0 - pow( ( 1.0 - _Progression ) , _ExpansionPower ) ) * _YOffset * float3(0,1,0) ) + ( ( ( ( tex2DNode5.g * ase_worldPos ) * ase_vertexNormal ) * ( _VertexOffset * ( 1.0 - pow( ( 1.0 - _Progression ) , _ExpansionPower ) ) ) ) + ( lerpResult22 * ase_vertexNormal ) ) );
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV45 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode45 = ( 0.0 + _FresnelScale * pow( 1.0 - fresnelNdotV45, _FresnelPower ) );
			float4 lerpResult48 = lerp( _Color , _FresnelColor , fresnelNode45);
			float2 temp_cast_0 = (_PanSpeed).xx;
			float2 uv_Texture0 = i.uv_texcoord * _Texture0_ST.xy + _Texture0_ST.zw;
			float2 panner32 = ( _Time.y * temp_cast_0 + uv_Texture0);
			float4 tex2DNode5 = tex2D( _Texture0, panner32 );
			float temp_output_26_0 = ( ( 1.0 - pow( ( 1.0 - _Progression ) , _ExpansionPower ) ) + tex2DNode5.r );
			float4 lerpResult13 = lerp( lerpResult48 , _ColorEdge , saturate( (0.0 + (temp_output_26_0 - 0.9) * (1.0 - 0.0) / (1.0 - 0.9)) ));
			o.Emission = lerpResult13.rgb;
			o.Alpha = 1;
			clip( step( temp_output_26_0 , 1.0 ) - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows vertex:vertexDataFunc 

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
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
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
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
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
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
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
2699;98;2234;1230;1446.291;900.353;1;True;True
Node;AmplifyShaderEditor.RangedFloatNode;7;-1738,61;Float;False;Property;_Progression;Progression;4;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;43;-1416.2,32.81143;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;4;-1964,249;Float;True;Property;_Texture0;Texture 0;3;0;Create;True;0;0;False;0;e43c2a70a4c8a5c4a86cdfa7a3720b5f;e43c2a70a4c8a5c4a86cdfa7a3720b5f;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-1510.2,208.8114;Float;False;Property;_ExpansionPower;Expansion Power;7;0;Create;True;0;0;False;0;1;1.5;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;41;-1267.2,81.81143;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;33;-1530.2,733.8114;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;-1643.2,476.8114;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;34;-1552.2,615.8114;Float;False;Property;_PanSpeed;Pan Speed;6;0;Create;True;0;0;False;0;1;0.014;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;44;-1094.2,70.81143;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;32;-1212.2,616.8114;Float;False;3;0;FLOAT2;0.1,0.7;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;31;-732,592;Float;False;883;327;Warp Offset;7;16;18;21;29;19;20;36;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;16;-682,692;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;5;-983,314;Float;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RelayNode;40;-879.2,75.81143;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;15;-476,414;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RelayNode;29;-383,809;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;30;-282,255;Float;False;342;181;Sphere Size;2;23;22;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;54;-1152.982,-680.6912;Float;False;1065.442;367.4;Fresnel;5;49;50;45;48;55;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-381,734;Float;False;Property;_VertexOffset;Vertex Offset;5;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-452,644;Float;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-1056.87,-477.0836;Float;False;Property;_FresnelPower;Fresnel Power;11;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-1102.982,-611.4688;Float;False;Property;_FresnelScale;Fresnel Scale;10;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-244,642;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-124.2,796.8114;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-432,164;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;22;-271,305;Float;False;3;0;FLOAT;-0.5;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;53;-726.7234,923.8114;Float;False;677.5234;397.3134;YOffset;3;52;37;38;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;12;-266,-20;Float;False;5;0;FLOAT;0;False;1;FLOAT;0.9;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;45;-788.0987,-515.2912;Float;False;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-3,691;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;55;-514.291,-628.353;Float;False;Property;_FresnelColor;Fresnel Color;9;1;[HDR];Create;True;0;0;False;0;8,7.592157,7.309804,1;0,0,0,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;37;-584.2,1046.811;Float;False;Constant;_Vector0;Vector 0;7;0;Create;True;0;0;False;0;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-73,346;Float;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;3;-670,-276;Float;False;Property;_Color;Color;1;1;[HDR];Create;True;0;0;False;0;8,7.592157,7.309804,1;0.9883373,0.9779882,0.9624646,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;52;-676.7234,1206.125;Float;False;Property;_YOffset;YOffset;8;0;Create;True;0;0;False;0;0.5;0.5;0.5;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;10;-657,-98;Float;False;Property;_ColorEdge;Color Edge;2;1;[HDR];Create;True;0;0;False;0;8,7.592157,7.309804,1;3.56487,3.56487,3.56487,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-218.2,973.8114;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;14;-72,-29;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;24;134,396;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;48;-271.5403,-469.6038;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;6;-46,141;Float;False;2;0;FLOAT;1;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;39;328.8,547.8114;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;13;-9,-187;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;2;1016.51,-64.92;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;Explosion;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.5;True;True;0;False;TransparentCutout;;AlphaTest;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;43;0;7;0
WireConnection;41;0;43;0
WireConnection;41;1;42;0
WireConnection;35;2;4;0
WireConnection;44;0;41;0
WireConnection;32;0;35;0
WireConnection;32;2;34;0
WireConnection;32;1;33;0
WireConnection;5;0;4;0
WireConnection;5;1;32;0
WireConnection;40;0;44;0
WireConnection;29;0;40;0
WireConnection;18;0;5;2
WireConnection;18;1;16;0
WireConnection;19;0;18;0
WireConnection;19;1;15;0
WireConnection;36;0;21;0
WireConnection;36;1;29;0
WireConnection;26;0;40;0
WireConnection;26;1;5;1
WireConnection;22;2;40;0
WireConnection;12;0;26;0
WireConnection;45;2;49;0
WireConnection;45;3;50;0
WireConnection;20;0;19;0
WireConnection;20;1;36;0
WireConnection;23;0;22;0
WireConnection;23;1;15;0
WireConnection;38;0;40;0
WireConnection;38;1;52;0
WireConnection;38;2;37;0
WireConnection;14;0;12;0
WireConnection;24;0;20;0
WireConnection;24;1;23;0
WireConnection;48;0;3;0
WireConnection;48;1;55;0
WireConnection;48;2;45;0
WireConnection;6;0;26;0
WireConnection;39;0;38;0
WireConnection;39;1;24;0
WireConnection;13;0;48;0
WireConnection;13;1;10;0
WireConnection;13;2;14;0
WireConnection;2;2;13;0
WireConnection;2;10;6;0
WireConnection;2;11;39;0
ASEEND*/
//CHKSM=18FE3FE13EB81E1DC3845FB3A5B56AB016BB1ACD