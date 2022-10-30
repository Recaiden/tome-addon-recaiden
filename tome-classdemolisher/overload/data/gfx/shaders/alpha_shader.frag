uniform sampler2D tex;
uniform sampler2D base;
uniform sampler2D mask;
uniform float tick;

void main(void)
{
	vec4 basecolor = texture2D(base, gl_TexCoord[0].xy);
	vec4 maskcolor = texture2D(mask, gl_TexCoord[0].xy);
	gl_FragColor = vec4(basecolor.r, basecolor.g, basecolor.b, basecolor.a * maskcolor.r);
}
