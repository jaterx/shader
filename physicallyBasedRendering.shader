//this shader will enable basic physically based rendering techinque used in modern 3D video games
//composed with Fresnel Reflectance, GGX Normal Distribution and Cook-Torrance Geometry Shadow
//fog is disbaled, can be enabled by restoring the original code at own interests
//tested with Unity 5.5
//an empty material file is least needed
//phong shading is for testing and comparison purpose only
//Unity ShaderLab Code

//Written by Jater (Ruohao) Xu, 2017

Shader "Unlit/physicallyBasedRendering"
{
    Properties
    {
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
            // make fog work
            #pragma multi_compile_fog
            
            #include "UnityCG.cginc"

            float4 _SpecularColor;
            float4 _Color;
            float4 _Metallic;
            
            // vertex shader inputs
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                half3 normal: NORMAL;
            };

            // vertex shader outputs ("vertex to fragment")
            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                //float3 viewDir : POSITION1; //the view direction "v" variable that needs to be passed
                float3 normal : NORMAL; //the normal "h" variable that needs to be passed
                //lighting position "l" is not gonna be changed, so "l" will be declared in the fragment shader
                float3 worldPos : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
              
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            // vertex shader
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                //transform the normal direction
                o.normalDir = UnityObjectToWorldNormal(v.normal);

                //transform the object according to its world position.
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            // pixel shader
            fixed4 frag (v2f i) : SV_Target
            {
            	//lighting intensity (different from 2 scenes)
            	float lightingIntensity = 2;

                //sample the texture, T in variable stands for transformed position
                //the "l" variable, stands for the lighting direction that will be used for calculation
                float3 lightDirT = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.worldPos.xyz, _WorldSpaceLightPos0.w));
                //the "v" variable, stands for the view direction that will be used for calculation
                float viewDirT = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                //the "n" variable, stands for the normal direction that will be used for calculation
                float normalDirT = normalize(i.normalDir);
                //the "h" variable, stands for the halfway vector that will be used for calculation (in this case should be the normal of micro surfaces of an object)
                float halfway = normalize(viewDirT + lightDirT);

                float3 specColor = lerp(_SpecularColor.rgb, _Color.rgb, _Metallic * 0.5);

                //the default output that display the texture only, without any physically based rendering techniques
                fixed4 col = tex2D(_MainTex, i.uv);

               	//Fresnel Reflectance
               	//for visable testing purpose, using F0=0.6, reflection for copper according to the chart, the color of copper will match the marble texture I choose the best
               	float f0 = 0.9;
               	float fresnel = specColor + (1 - specColor) * pow((1 - dot(lightDirT, halfway)), 5);
               	//fresnel checked;

               	//GGX Normal Distribution Function
               	//for visiable testing purpose, using alpha = 1.2
               	float pi = 3.1415926; //declare pi for calculation          
               	float nDOTmSQUARE = pow(dot(halfway, halfway), 2);
               	//roughness variable, denoted as alpha, I choose it to be 0.8 for better visual representation purpose
               	//declare some variable that will be used in following calculations
               	float alpha = 0.8;
               	float alphaSQUARE = alpha * alpha;
               	float normalizedGGX = (1 - nDOTmSQUARE) / nDOTmSQUARE;
               	float ggx = (1.0/pi) * pow((alpha/(nDOTmSQUARE * (alphaSQUARE + normalizedGGX))), 2);
               	//ggx checked;

               	//Phong Normal Distribution Function (for comparsion test with ggx purpose only)
               	//this function is for testing and comparing purpose only (compare GGX with Phong to see if the result is right or wrong),this is not a part of the assignment
               	//the result will not be enabled
               	float nDOTmALPHA = pow(dot(normalDirT, halfway), alpha);
               	float phong = ((alpha + 2) / 2 * pi) * nDOTmALPHA;
               	//phong shading checked;

               	//Cook-Torrance Geometry Function
               	//declare some variable that will be used in following calculations
               	float nDOTh = dot(normalDirT, halfway);
               	float nDOTv = dot(normalDirT, viewDirT);
               	float vDOTh = dot(viewDirT, halfway);
               	float nDOTl = dot(normalDirT, lightDirT);
               	float ctgf = min(1.0, min(2 * nDOTh * nDOTv / vDOTh, 2 * nDOTh * nDOTl / vDOTh));
               	//use min() function to ensure energy conservation is at most less or equal than 1
               	//cook-torrance checked;

               	//single effect result (uncomment for testing purposes)
               	//return col; //uncheck this line to see the texture only effect
               	//return col * fresnel; //uncheck this line to see the texture + fresnel only effect
                //return col * phong; //uncheck this line to see the texture + phong only effect
               	//return col * ggx; //uncheck this line to see the texture + ggx only effect
               	//return col * ctgf; //uncheck this line to see the texture + Cook-Torrance only effect

               	//combination result (uncomment for testing purposes)
               	//return col * fresnel * phong; //uncomment this line for phong shading result (testing purpose only)
               	//return col * fresnel * ggx; //uncomment this line for original lighting result plus fresnel reflectance plus ggx normal distribution only

               	//final result
               	return col * (fresnel * ggx * ctgf / (4 * nDOTl * nDOTv)) * lightingIntensity; //final result
            }
            ENDCG
        }
    }
}
