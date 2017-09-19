window.perlin = perlin = require './perlin.ls'

CHUNK_SIZE = 256
SCALE_FACTOR = 64 * 64
SEED = Date.now!

# The buffer is split into CHUNK_SIZE×CHUNK_SIZE chunks.
# The buffer is indexed by (buffer_x, buffer_z).
# A chunk is indexed by (chunk_idx), where chunk_idx = chunk_x + chunk_z * CHUNK_SIZE.

export class TerrainGen
  ->
    @buffer = {}

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
  # x, z: Floats; integers are cached.
  get-y: (x, z) ->
    if x % 1 != 0 || z % 1 != 0
      2000 * perlin.pnoise2 x/SCALE_FACTOR, z/SCALE_FACTOR, 0.5, 8, SEED
    else
      buffer_x = Math.floor x / CHUNK_SIZE
      buffer_z = Math.floor z / CHUNK_SIZE
      chunk_x = x - buffer_x * CHUNK_SIZE
      chunk_z = z - buffer_z * CHUNK_SIZE
      chunk_idx = chunk_x + chunk_z * CHUNK_SIZE
      chunk = @get-chunk buffer_x, buffer_z
      if chunk[chunk_idx] < 0
        chunk[chunk_idx] = perlin.pnoise2 x/SCALE_FACTOR, z/SCALE_FACTOR, 0.5, 8, SEED
      chunk[chunk_idx] * 2000
