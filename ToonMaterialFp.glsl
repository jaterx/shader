//this shader will enable toon shading that used mostly in animated video games
//an empty material file is least needed
//this is a fragment shader, combined vertex shader is needed
//geometry shader is not needed
//different color ramp and color target can be adjusted
//tested with OGRE3D 1.9
//GLSL Code

//Written by Jater (Ruohao) Xu, 2016

#version 400

// Attributes passed from the vertex shader
in vec3 position_interp;
in vec3 normal_interp;
in vec4 colour_interp;
in vec3 light_pos;

// Attributes passed with the material file
uniform vec4 ambient_colour;
uniform vec4 diffuse_colour;

void main() 
{
    //Toon shading, for toon shading, usually the element "Specular" is not used, so we only need to calculate the diffuse and specular value and transfer them according to the color ramp to a single diffuse value
	//Interpolated normal for fragment, Light-source direction, view direction
	vec3 N, L, V;
	//the variable that will determine the color ramp level according to its incoming diffuse amount
	vec4 rampLevel;
	vec4 rampLevel2;

	// Compute Lambertian lighting Id
    N = normalize(normal_interp);
    
	L = (light_pos - position_interp);
	L = normalize(L);

	V = - position_interp; // Eye position is (0, 0, 0) in view coordinates
    V = normalize(V);

	//Compute the diffuse amount
	float Id = max(dot(N, L), 0.0);

	//ramp level 1
	if (Id > 0.75)
		rampLevel = vec4(0.5,0.5,1.0,1.0);
	else if (Id > 0.5)
		rampLevel = vec4(0.4,0.4,1.0,1.0);
	else if (Id > 0.25)
		rampLevel = vec4(0.3,0.3,1.0,1.0);
	else
		rampLevel = vec4(0.2,0.2,1.0,1.0);

	//ramp level 2
	if (Id > 0.9)
		rampLevel2 = vec4(0.5,1.0,0.5,1.0);
	else if (Id > 0.6)
		rampLevel2 = vec4(0.4,1.0,0.4,1.0);
	else if (Id > 0.3)
		rampLevel2 = vec4(0.3,1.0,0.3,1.0);
	else
		rampLevel2 = vec4(0.2,1.0,0.2,1.0);

	//draw the outline as its thresholding angle between the viewing direction and the fragment's interpolated normal.
	if (max(dot(N, V), 0.0) < 0.2)
		rampLevel = vec4(0.0,0.0,0.0,1.0);
	if (max(dot(N, V), 0.0) < 0.2)
		rampLevel2 = vec4(0.0,0.0,0.0,1.0);
		
	// Assign light to the fragment
	//final result 1
	gl_FragColor = ambient_colour + rampLevel;
	//final result 2, uncomment the following line to see the toon shading no.2
	//gl_FragColor = ambient_colour + rampLevel2;

	//Debug without diffuse to check if toon shading is effective
	//gl_FragColor = ambient_colour;
					
	// For debugging purpose, we can display the different values
	//gl_FragColor = ambient_colour;
	//gl_FragColor = diffuse_colour;
	//gl_FragColor = specular_colour;
	//gl_FragColor = colour_interp;
	//gl_FragColor = vec4(N.xyz, 1.0);
	//gl_FragColor = vec4(L.xyz, 1.0);
	//gl_FragColor = vec4(V.xyz, 1.0);
}
