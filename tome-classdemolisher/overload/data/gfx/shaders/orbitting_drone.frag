uniform sampler2D tex;
uniform float tick;
uniform float tick_start;
uniform float time_factor;
uniform float noup;
uniform float cylinderRotationSpeed; //rotation speed of the aura, min: 0, max: 10, def: 1
uniform float cylinderRadius; //radius of the cylinder aura. min: 0.2, max: 0.5, def: 0.45
uniform float cylinderVerticalPos; //vertical position of the cylinder. 0 is in the middle. min: -0.2, max: 0.2
uniform float cylinderHeight; //height of the cylinder. min: 0.1, max: 1.0, default: 0.4
uniform float appearTime; //normalized appearance time. min: 0.01, max: 3.0, default: 1.0f
uniform float unbalancedSize;

void main(void)
{
  vec2 pos = vec2(0.5, 0.5) - gl_TexCoord[0].xy;

  vec4 resultColor = vec4(0.0, 0.0, 0.0, 0.0);

  float normTime = (tick - tick_start) / time_factor;
  float alpha = normTime * cylinderRotationSpeed;
  
  // increased y is further down
  float dirY = 1.0;
  float startY = -0.1 + cylinderVerticalPos;
  if(noup == 2.0)
  {
    dirY = -1.0;
  }
  vec2 tmp = vec2(0, 0) - gl_TexCoord[0].xy;
  tmp.x = tmp.x - (tmp.x * 0.1 * sin(alpha)) - cylinderRadius * 0.60 * cos(alpha);
  tmp.y = tmp.y - (tmp.x * 0.05 * sin(alpha)) + startY + cylinderRadius * cylinderHeight * sin(alpha);
  resultColor = texture2D(tex, tmp);
  if(sin(alpha)*dirY < 0)
  {
    resultColor.a = 0;
  }
  gl_FragColor = resultColor * gl_Color;
}
