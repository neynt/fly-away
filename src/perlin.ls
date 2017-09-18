# Magic numbers
T_NOISE_GEN = 20287.0
OCTAVE_NOISE_GEN = 14737.0
SEED_NOISE_GEN = 21269.0
X_NOISE_GEN = 707933.0
Y_NOISE_GEN = 39607.0
Z_NOISE_GEN = 43063.0

# Noise generation
export noise = (t, octave, seed) ->
  n = (T_NOISE_GEN * t + OCTAVE_NOISE_GEN * octave + SEED_NOISE_GEN * seed) .&. 0x7fffffff
  n = (n .>>. 13) .^. n
  1 - ((n * ((n * n * 53849 + 1421737) .&. 0x7fffffff) + 468185813) .&. 0x7fffffff) / 1073741824.0

export noise2 = (x, y, octave, seed) ->
  n = (X_NOISE_GEN * x + Y_NOISE_GEN * y + OCTAVE_NOISE_GEN * octave + SEED_NOISE_GEN * seed) .&. 0x7fffffff
  n = (n .>>. 13) .^. n
  1 - ((n * ((n * n * 53849 + 1421737) .&. 0x7fffffff) + 468185813) .&. 0x7fffffff) / 1073741824.0

export noise3 = (x, y, z, octave, seed) ->
  n = (X_NOISE_GEN * x + Y_NOISE_GEN * y + Z_NOISE_GEN * z + OCTAVE_NOISE_GEN * octave + SEED_NOISE_GEN * seed) .&. 0x7fffffff
  n = (n .>>. 13) .^. n
  1 - ((n * ((n * n * 53849 + 1421737) .&. 0x7fffffff) + 468185813) .&. 0x7fffffff) / 1073741824.0

# Interpolation of values
export interpolate = (a, b, x) ->
  ft = x * Math.PI
  f = (1 - Math.cos(ft)) * 0.5
  a * (1 - f) + b * f

# Interpolated noise
export inoise = (x, octave, seed) ->
  intx = Math.floor(x)
  fracx = x - intx

  n1 = noise(intx, octave, seed)
  n2 = noise(intx + 1, octave, seed)

  interpolate(n1, n2, fracx)

export inoise2 = (x, y, octave, seed) ->
  intx = Math.floor(x)
  fracx = x - intx
  inty = Math.floor(y)
  fracy = y - inty

  v1 = noise2(intx, inty, octave, seed)
  v2 = noise2(intx + 1, inty, octave, seed)
  v3 = noise2(intx, inty + 1, octave, seed)
  v4 = noise2(intx + 1, inty + 1, octave, seed)

  i1 = interpolate(v1, v2, fracx)
  i2 = interpolate(v3, v4, fracx)
  interpolate(i1, i2, fracy)

export inoise3 = (x, y, z, octave, seed) ->
  intx = Math.floor(x)
  fracx = x - intx
  inty = Math.floor(y)
  fracy = y - inty
  intz = Math.floor(z)
  fracz = z - intz

  v1 = noise3(intx, inty, intz, octave, seed)
  v2 = noise3(intx + 1, inty, intz, octave, seed)
  v3 = noise3(intx, inty + 1, intz, octave, seed)
  v4 = noise3(intx + 1, inty + 1, intz, octave, seed)
  v5 = noise3(intx, inty, intz + 1, octave, seed)
  v6 = noise3(intx + 1, inty, intz + 1, octave, seed)
  v7 = noise3(intx, inty + 1, intz + 1, octave, seed)
  v8 = noise3(intx + 1, inty + 1, intz + 1, octave, seed)

  i1 = interpolate(v1, v2, fracx)
  i2 = interpolate(v3, v4, fracx)
  i3 = interpolate(v5, v6, fracx)
  i4 = interpolate(v7, v8, fracx)

  j1 = interpolate(i1, i2, fracy)
  j2 = interpolate(i3, i4, fracy)

  interpolate(j1, j2, fracz)

# Perlin noise
export pnoise = (x, persist, octaves, seed) ->
  total = 0
  for i from 0 til octaves
    frequency = Math.pow(2, i)
    amplitude = Math.pow(persist, i)
    total += inoise(x * frequency, i, seed) * amplitude

export pnoise2 = (x, y, persist, octaves, seed) ->
  total = 0
  for i from 0 til octaves
    frequency = Math.pow(2, i)
    amplitude = Math.pow(persist, i)
    total += inoise2(x * frequency, y * frequency, i, seed) * amplitude

export pnoise3 = (x, y, z, persist, octaves, seed) ->
  total = 0
  for i from 0 til octaves
    frequency = Math.pow(2, i)
    amplitude = Math.pow(persist, i)
    total += inoise3(x * frequency, y * frequency, z * frequency, i, seed) * amplitude
