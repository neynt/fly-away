TERRAIN_TILE_LENGTH = 50
TERRAIN_CHUNK_SIZE = 256

export class Terrain
  (terrain-gen) ->
    @terrain-gen = terrain-gen

  # Returns a mesh of the terrain at chunk X, Z.
  at: (X, Z) ->
    geometry = new THREE.PlaneGeometry \
      TERRAIN_TILE_LENGTH * TERRAIN_CHUNK_SIZE,
      TERRAIN_TILE_LENGTH * TERRAIN_CHUNK_SIZE,
      TERRAIN_CHUNK_SIZE,
      TERRAIN_CHUNK_SIZE
    for i til geometry.vertices.length
      x = i % (TERRAIN_CHUNK_SIZE + 1)
      z = Math.floor i / (TERRAIN_CHUNK_SIZE + 1)
      geometry.vertices[i]
        ..x = x * TERRAIN_TILE_LENGTH
        ..y = @terrain-gen.get-y x, z
        ..z = z * TERRAIN_TILE_LENGTH
    geometry.computeVertexNormals!

    material = new THREE.MeshPhongMaterial {
      color: 0x994422
    }

    new THREE.Mesh geometry, material
