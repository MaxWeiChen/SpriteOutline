// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Sprites/SpriteOutline"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1,1,1,1)
        [HideInInspector] _Flip ("Flip", Vector) = (1,1,1,1)
        [PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
        [PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0

        [MaterialToggle] _Outline ("Outline", Float) = 0
        _OutlineColor ("Outline Color", Color ) = (1,1,1,1)
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend One OneMinusSrcAlpha

        Pass
        {
        CGPROGRAM
            #pragma vertex SpriteVert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_instancing
            #pragma multi_compile _ PIXELSNAP_ON
            #pragma multi_compile _ ETC1_EXTERNAL_ALPHA
            #include "UnitySprites.cginc"

            float _Outline;
            float4 _OutlineColor;
            float4 _MainTex_TexelSize;

            fixed4 frag(v2f IN) : SV_Target
            {
                fixed4 col = SampleSpriteTexture (IN.texcoord) * IN.color;
                col.rgb *= col.a;

                if ( _Outline > 0 && col.a == 0 && IN.color.a > 0)
                {
                    fixed4 pixelUp = tex2D( _MainTex, IN.texcoord + fixed2(0,_MainTex_TexelSize.y));
                    fixed4 pixelDown = tex2D( _MainTex, IN.texcoord - fixed2(0,_MainTex_TexelSize.y));
                    fixed4 pixelRight = tex2D( _MainTex, IN.texcoord + fixed2(_MainTex_TexelSize.x,0));
                    fixed4 pixelLeft = tex2D( _MainTex, IN.texcoord - fixed2(_MainTex_TexelSize.x,0));
                         
                    if ( pixelUp.a != 0 || pixelDown.a != 0  || pixelRight.a != 0  || pixelLeft.a != 0)
                    {
                        col = _OutlineColor;
                    }
                }

                return col * IN.color;
            }
        ENDCG
        }
    }
}
