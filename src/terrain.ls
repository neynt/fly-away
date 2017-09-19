{TerrainGen} = require './terrain-gen.ls'
t = new TerrainGen!

TERRAIN_TILE_LENGTH = 50
TERRAIN_CHUNK_SIZE = 256

export generate-terrain = (X, Y) ->
  geometry = new THREE.PlaneGeometry \
    TERRAIN_TILE_LENGTH * TERRAIN_CHUNK_SIZE,
    TERRAIN_TILE_LENGTH * TERRAIN_CHUNK_SIZE,
    TERRAIN_CHUNK_SIZE,
    TERRAIN_CHUNK_SIZE
  for i til geometry.vertices.length
    x = i % (TERRAIN_CHUNK_SIZE + 1)
    y = Math.floor i / (TERRAIN_CHUNK_SIZE + 1)
    geometry.vertices[i].z = t.get-height x, y
  geometry.computeVertexNormals!

  material = new THREE.MeshPhongMaterial {
    color: 0x994422
  }

  new THREE.Mesh geometry, material
    ..rotation.x = 3 * Math.PI / 2
