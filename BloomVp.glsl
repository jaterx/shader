//this is a vertex shader, combined fragment shader is needed
//an empty material file is least needed
//geometry shader is not needed
//tested with OGRE3D 1.9
//GLSL Code

//Written by Jater (Ruohao) Xu, 2016

#version 400

in vec3 vertex;
in vec2 uv0;

uniform mat4 world_mat;
uniform mat4 view_mat;
uniform mat4 projection_mat;

out vec2 uv;

void main()
{
    gl_Position = projection_mat * view_mat * world_mat * vec4(vertex, 1.0);
	uv = uv0; 
}


