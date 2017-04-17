//this shader will enable toon shading that used mostly in animated video games
//an empty material file is least needed
//this is a vertex shader, combined fragment shader is needed
//geometry shader is not needed
//tested with OGRE3D 1.9
//GLSL Code

//Written by Jater (Ruohao) Xu, 2016

#version 400

// Attributes passed automatically by OGRE
in vec3 vertex;
in vec3 normal;
in vec4 colour;

// Attributes passed with the material file
uniform mat4 world_mat;
uniform mat4 view_mat;
uniform mat4 projection_mat;
uniform mat4 normal_mat;
uniform vec3 light_position;

// Attributes forwarded to the fragment shader
out vec3 position_interp;
out vec3 normal_interp;
out vec3 light_pos;


void main()
{
    gl_Position = projection_mat * view_mat * world_mat * vec4(vertex, 1.0);

    position_interp = vec3(view_mat * world_mat * vec4(vertex, 1.0));
	
	normal_interp = vec3(normal_mat * vec4(normal, 0.0));

    light_pos = vec3(view_mat * vec4(light_position, 1.0));
}
