TERRAIN_TILE_LENGTH = 50
TERRAIN_CHUNK_SIZE = 256

tree = require './tree.ls'

export class Terrain
  (terrain-gen) ->
    @terrain-gen = terrain-gen

  # Returns an object for the terrain at chunk X, Z.
  at: (X, Z) ->
    chunk = new THREE.Object3D!
      ..position.x = X * TERRAIN_CHUNK_SIZE * TERRAIN_TILE_LENGTH
      ..position.z = Z * TERRAIN_CHUNK_SIZE * TERRAIN_TILE_LENGTH

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
        ..z = z * TERRAIN_TILE_LENGTH
        ..y = @terrain-gen.get-y chunk.position.x + ..x, chunk.position.z + ..z
    geometry.computeVertexNormals!

    material = new THREE.MeshPhongMaterial {
      color: 0x994422
    }
    chunk.add new THREE.Mesh geometry, material

    for i til 1000
      chunk.add (tree.generate-tree tree.pine
        ..position.x = TERRAIN_CHUNK_SIZE * TERRAIN_TILE_LENGTH * Math.random!
        ..position.z = TERRAIN_CHUNK_SIZE * TERRAIN_TILE_LENGTH * Math.random!
        ..position.y = @terrain-gen.get-y ..position.x, ..position.z)

    chunk
