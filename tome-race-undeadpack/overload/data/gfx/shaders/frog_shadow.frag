uniform sampler2D tex;
uniform float tick;

void main(void)
{	
	vec4 frag = texture2D(tex, gl_TexCoord[0].xy);
	
	float lum = frag[0];
	if (frag[1] > lum) lum = frag[1];
	if (frag[2] > lum) lum = frag[2];
	
	lum = lum * 4;
	lum += 3 * sin(tick/500);
	
	for (int i = 0; i < 7; ++i){
		if (lum > 1){
			lum = 2 - lum;
		}
		if (lum < 0){
			lum = -lum;
		}
	}
	
	if (lum < .5) lum = lum + (lum - .5) ;
	if (lum < 0) lum = 0;
	
	float y_mod = gl_TexCoord[0].y;
	y_mod += 0.2*sin(-tick/200 + gl_TexCoord[0].y * 8);
	
	float filterlum = sin(tick/300 + y_mod*16) * sin(tick/500 + gl_TexCoord[0].x*16);
	
	if (filterlum < .5) filterlum = 0;
	if (filterlum > .6) filterlum = 1;
	
	float invfilter = sin(tick/450) * .5 + .5;
	filterlum = invfilter + filterlum - 2*filterlum*invfilter;
	
	float flt_R = filterlum;
	
	gl_FragColor.r = lum * (.1 + flt_R*.3);
	gl_FragColor.g = lum * .1;
	gl_FragColor.b = lum * .1;
	gl_FragColor.a = frag[3];
}
