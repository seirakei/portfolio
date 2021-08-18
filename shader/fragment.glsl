#extension GL_EXT_shader_texture_lod : enable
#extension GL_OES_standard_derivatives : enable

#define USE_UV
#define USE_NORMALMAP
#define TONE_MAPPING
#define PHYSICAL

varying float vScale;

uniform vec3 diffuse;
uniform vec3 emissive;
uniform float roughness;
uniform float metalness;
uniform float opacity;
uniform float uTime;
uniform float uRandom;
uniform float uScale;
uniform vec3 scale;
uniform float mouse;

#ifdef USE_SHEEN
  uniform vec3 sheen;
#endif

varying vec3 vViewPosition;
varying vec3 vPosition;

#ifndef FLAT_SHADED
  varying vec3 vNormal;
  #ifdef USE_TANGENT
    varying vec3 vTangent;
    varying vec3 vBitangent;
  #endif
#endif

#include <common>
#include <packing>
// <dithering_pars_fragment>

#include <color_pars_fragment>
#include <map_pars_fragment>
#include <uv2_pars_fragment>
#include <uv_pars_fragment>

//< alphamap_pars_fragment>
// <lightmap_pars_fragment>
// <emissivemap_pars_fragment>

#include <bsdfs>
#include <cube_uv_reflection_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_physical_pars_fragment>
// <fog_pars_fragment>

#include <lights_pars_begin>
#include <lights_physical_pars_fragment>
#include <shadowmap_pars_fragment>
// <bumpmap_pars_fragment>

#include <normalmap_pars_fragment>
// <clearcoat_normalmap_pars_fragment>

#include <metalnessmap_pars_fragment>
#include <roughnessmap_pars_fragment>


float map(float value, float min1, float max1, float min2, float max2) {
  return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

void main() {
  float smoothScale = pow(vScale, .5);
  smoothScale = clamp(1. - smoothScale, 0., 1.);

  vec3 c = 0.5 + 0.5 * cos(
    smoothScale * 5. + vPosition.xyz * 0.65 + vec3(0., 2., 4.)
  );

  c = mix(c, vec3(0.), smoothScale);

  float depthFactor = smoothstep(-1., 1., cameraPosition.z - vViewPosition.z);
  c = mix(c * .2, c, depthFactor);

  float alpha = clamp(mix(0., 6., depthFactor), 0.25, 1.);
  vec4 diffuseColor = vec4(clamp(c, 0., 1.), alpha);

  ReflectedLight reflectedLight = ReflectedLight(vec3(0.0), vec3(0.0), vec3(0.0), vec3(0.0));
  vec3 totalEmissiveRadiance = emissive + c * clamp(vScale, .35, 1.);

  // <map_fragment>
  // <color_fragment>
  // <alphamap_fragment>
  // <alphatest_fragment>

  #include <roughnessmap_fragment>
  #include <metalnessmap_fragment>
  #include <normal_fragment_begin>
  #include <normal_fragment_maps>
  // <clearcoat_normal_fragment_begin>
  // <clearcoat_normal_fragment_maps>
  // <emissivemap_fragment>

  #include <lights_physical_fragment>
  #include <lights_fragment_begin>
  #include <lights_fragment_maps>
  #include <lights_fragment_end>

  vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + reflectedLight.directSpecular + reflectedLight.indirectSpecular + totalEmissiveRadiance;
  gl_FragColor = vec4(outgoingLight, diffuseColor.a);

  #include <tonemapping_fragment>
  #include <encodings_fragment>
  // <fog_fragment>
  // <premultiplied_alpha_fragment>
  // <dithering_fragment>
}