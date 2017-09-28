window.perlin = perlin = require './perlin.ls'

CHUNK_SIZE = 16 # number of tiles per chunk (along one side)
TILE_LENGTH = 128 # game units between cached points
SCALE_FACTOR = 2 * 64 * 64 / TILE_LENGTH # number of tiles per perlin noise chunk (along one side)
HEIGHT_SCALE = 4000
SEED = Date.now!

# The buffer is split into CHUNK_SIZE×CHUNK_SIZE chunks.
# The buffer is indexed by (buffer_x, buffer_z).
# A chunk is indexed by (chunk_idx), where chunk_idx = chunk_x + chunk_z * CHUNK_SIZE.

export class TerrainGen
  ->
    @buffer = {}

  TILE_LENGTH: TILE_LENGTH
  CHUNK_SIZE: CHUNK_SIZE

  # Returns the chunk at the specified buffer coordinate.
  # Creates it if it doesn't exist.
  # buffer_x, buffer_z: Integer indices into the buffer.
  get-chunk: (buffer_x, buffer_z) ->
    if not @buffer[buffer_x]
      @buffer[buffer_x] = {}
    if not @buffer[buffer_x][buffer_z]
      @buffer[buffer_x][buffer_z] = new Float32Array CHUNK_SIZE * CHUNK_SIZE
        ..fill -1
    @buffer[buffer_x][buffer_z]

  # Public. Call this thing from outside.
  # x, z: Floats. Cached at level of TILE_LENGTH
  get-y: (x, z) ->
    if x % TILE_LENGTH == 0 and z % TILE_LENGTH == 0
      x /= TILE_LENGTH
      z /= TILE_LENGTH
      buffer_x = Math.floor x / CHUNK_SIZE
      buffer_z = Math.floor z / CHUNK_SIZE
      chunk_x = x - buffer_x * CHUNK_SIZE
      chunk_z = z - buffer_z * CHUNK_SIZE
      chunk_idx = chunk_x + chunk_z * CHUNK_SIZE
      chunk = @get-chunk buffer_x, buffer_z
      if chunk[chunk_idx] < 0
        chunk[chunk_idx] = perlin.pnoise2 x/SCALE_FACTOR, z/SCALE_FACTOR, 0.4, 8, SEED
      chunk[chunk_idx] * HEIGHT_SCALE

    else
      # Interpolate from nearest cached points
      intx = Math.floor x / TILE_LENGTH
      fracx = x / TILE_LENGTH - intx
      intz = Math.floor z / TILE_LENGTH
      fracz = z / TILE_LENGTH - intz

      # These calls are all cached
      v1 = this.get-y intx * TILE_LENGTH, intz * TILE_LENGTH
      v2 = this.get-y (intx + 1) * TILE_LENGTH, intz * TILE_LENGTH
      v3 = this.get-y intx * TILE_LENGTH, (intz + 1) * TILE_LENGTH
      v4 = this.get-y (intx + 1) * TILE_LENGTH, (intz + 1) * TILE_LENGTH

      # Linear interpolation
      i1 = fracx * (v2 - v1) + v1
      i2 = fracx * (v4 - v3) + v1

      fracz * (i2 - i1) + i1
