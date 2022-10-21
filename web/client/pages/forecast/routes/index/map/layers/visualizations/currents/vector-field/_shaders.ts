export const vs = `
  precision highp float;

  attribute float a_index;

  uniform sampler2D u_particles;
  uniform float u_particles_res;

  varying vec2 v_particle_pos;

  void main() {
      vec4 color = texture2D(u_particles, vec2(
          fract(a_index / u_particles_res),
          floor(a_index / u_particles_res) / u_particles_res));

      // decode current particle position from the pixel's RGBA value
      v_particle_pos = vec2(
          color.r / 255.0 + color.b,
          color.g / 255.0 + color.a);

      gl_PointSize = 1.0;
      gl_Position = vec4(2.0 * v_particle_pos.x - 1.0, 1.0 - 2.0 * v_particle_pos.y, 0, 1);
  }`

export const fs = `
  precision highp float;

  uniform sampler2D u_vector;
  uniform vec2 u_vector_min;
  uniform vec2 u_vector_max;
  //uniform sampler2D u_color_ramp;

  uniform vec4 u_bounds;
  uniform vec4 u_data_bounds;

  varying vec2 v_particle_pos;

  vec2 returnLonLat(float x_domain, float y_domain, vec2 pos) {

      //need value between 0 and 1, which fract accomplishes
      float mercator_x = fract(u_bounds.x + pos.x * x_domain);
      float mercator_y = u_bounds.w + pos.y * y_domain;

      float lon = mercator_x * 360.0 - 180.0;
      float lat2 = 180.0 - mercator_y * 360.0;
      float lat = 360.0 / 3.141592654 * atan(exp(lat2 * 3.141592654/180.0)) - 90.0;

      return vec2(lon, lat);
  }

  void main() {

      //convert from 0-1 to degrees for proper texture value lookup
      float x_domain = abs(u_bounds.x - u_bounds.z);
      float y_domain = abs(u_bounds.y - u_bounds.w);

      vec2 coordinate = returnLonLat(x_domain, y_domain, v_particle_pos);
      float lon = coordinate.x;
      float lat = coordinate.y;

      //discard if out of bounds
      if (
          lat > u_data_bounds.w || lat < u_data_bounds.y ||
          lon > u_data_bounds.z || lon < u_data_bounds.x
      ) {
          discard;
      }

      gl_FragColor = vec4(1.0, 1.0, 1.0, 0.33);
  }`

export const vsQuad = `
  precision highp float;

  attribute vec2 a_pos;

  varying vec2 v_tex_pos;

  void main() {
      v_tex_pos = a_pos;
      gl_Position = vec4(1.0 - 2.0 * a_pos, 0, 1);
  }`

export const fsScreen = `
  precision highp float;

  uniform sampler2D u_screen;
  uniform float u_opacity;

  varying vec2 v_tex_pos;

  void main() {
      vec4 color = texture2D(u_screen, 1.0 - v_tex_pos);
      // a hack to guarantee opacity fade out even with a value close to 1.0
      gl_FragColor = vec4(floor(255.0 * color * u_opacity) / 255.0);
  }`

export const fsUpdate = `
  precision highp float;

  uniform sampler2D u_particles;
  uniform sampler2D u_vector;
  uniform vec2 u_vector_res;
  uniform vec2 u_vector_min;
  uniform vec2 u_vector_max;
  uniform float u_rand_seed;
  uniform float u_speed_factor;
  uniform float u_drop_rate;
  uniform float u_drop_rate_bump;
  uniform vec4 u_bounds;
  uniform vec4 u_data_bounds;

  varying vec2 v_tex_pos;

  // pseudo-random generator
  const vec3 rand_constants = vec3(12.9898, 78.233, 4375.85453);
  float rand(const vec2 co) {
      float t = dot(rand_constants.xy, co);
      return fract(sin(t) * (rand_constants.z + t));
  }

  // vector magnitude lookup; use manual bilinear filtering based on 4 adjacent pixels for smooth interpolation
  vec2 lookup_vector(const vec2 uv) {
      // return texture2D(u_vector, uv).rg; // lower-res hardware filtering
      vec2 px = 1.0 / u_vector_res;
      vec2 vc = (floor(uv * u_vector_res)) * px;
      vec2 f = fract(uv * u_vector_res);
      vec2 tl = texture2D(u_vector, vc).rg;
      vec2 tr = texture2D(u_vector, vc + vec2(px.x, 0)).rg;
      vec2 bl = texture2D(u_vector, vc + vec2(0, px.y)).rg;
      vec2 br = texture2D(u_vector, vc + px).rg;
      return mix(mix(tl, tr, f.x), mix(bl, br, f.x), f.y);
  }

  vec2 returnLonLat(float x_domain, float y_domain, vec2 pos) {

      //need value between 0 and 1, which fract accomplishes
      float mercator_x = fract(u_bounds.x + pos.x * x_domain);
      float mercator_y = u_bounds.w + pos.y * y_domain;

      float lon = mercator_x * 360.0 - 180.0;
      float lat2 = 180.0 - mercator_y * 360.0;
      float lat = 360.0 / 3.141592654 * atan(exp(lat2 * 3.141592654/180.0)) - 90.0;

      return vec2(lon, lat);
  }

  void main() {
      vec4 color = texture2D(u_particles, v_tex_pos);
      vec2 pos = vec2(
          color.r / 255.0 + color.b,
          color.g / 255.0 + color.a); // decode particle position from pixel RGBA

      //convert from 0-1 to degrees for proper texture value lookup
      float x_domain = abs(u_bounds.x - u_bounds.z);
      float y_domain = abs(u_bounds.y - u_bounds.w);

      vec2 coordinate = returnLonLat(x_domain, y_domain, pos);
      float lon = coordinate.x;
      float lat = coordinate.y;

      float lon_domain = u_data_bounds.z - u_data_bounds.x;
      float lat_domain = u_data_bounds.w - u_data_bounds.y;

      vec2 pos_lookup = vec2(
          (lon - u_data_bounds.x) / lon_domain,
          (lat - u_data_bounds.y) / lat_domain
      );

      vec2 velocity = mix(u_vector_min, u_vector_max, lookup_vector(pos_lookup));
      float speed_t = length(velocity) / length(u_vector_max);

      // take EPSG:4236 distortion into account for calculating where the particle moved
      //float distortion = cos(radians(lat));
      vec2 offset = vec2(velocity.x , -velocity.y) * 0.0001 * u_speed_factor;

      // update particle position, wrapping around the date line
      pos = fract(1.0 + pos + offset);

      // a random seed to use for the particle drop
      vec2 seed = (pos + v_tex_pos) * u_rand_seed;

      // drop rate is a chance a particle will restart at random position, to avoid degeneration
      float drop_rate = u_drop_rate + speed_t * u_drop_rate_bump;
      float drop = step(1.0 - drop_rate, rand(seed));

      vec2 random_pos = vec2(
          rand(seed + 1.3),
          rand(seed + 2.1));
      pos = mix(pos, random_pos, drop);

      // encode the new particle position back into RGBA
      gl_FragColor = vec4(
          fract(pos * 255.0),
          floor(pos * 255.0) / 255.0);
  }`
