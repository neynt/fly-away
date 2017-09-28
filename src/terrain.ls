tree = require './tree.ls'

export class Terrain
  (terrain-gen) ->
    @terrain-gen = terrain-gen

  # Returns an object for the terrain at chunk X, Z.
  at: (X, Z) ->
    offsetx = X * @terrain-gen.CHUNK_SIZE * @terrain-gen.TILE_LENGTH
    offsetz = Z * @terrain-gen.CHUNK_SIZE * @terrain-gen.TILE_LENGTH

    chunk = new THREE.Object3D!
      ..position.x = offsetx
      ..position.z = offsetz

    geometry = new THREE.PlaneGeometry \
      @terrain-gen.TILE_LENGTH * @terrain-gen.CHUNK_SIZE,
      @terrain-gen.TILE_LENGTH * @terrain-gen.CHUNK_SIZE,
      @terrain-gen.CHUNK_SIZE,
      @terrain-gen.CHUNK_SIZE
    for i til geometry.vertices.length
      x = @terrain-gen.TILE_LENGTH * (i % (@terrain-gen.CHUNK_SIZE + 1))
      z = @terrain-gen.TILE_LENGTH * Math.floor i / (@terrain-gen.CHUNK_SIZE + 1)
      geometry.vertices[i]
        ..x = x
        ..z = z
        ..y = @terrain-gen.get-y offsetx + x, offsetz + z
    geometry.computeVertexNormals!

    material = new THREE.MeshLambertMaterial {
      color: 0x994422 / 0x11 * 0xa
    }
    chunk.add (new THREE.Mesh geometry, material
      ..castShadow = true
      ..receiveShadow = true)

    for i til 100
      if Math.random! * Math.random! * 2000 > @terrain-gen.get-y offsetx, offsetz
        chunk.add (tree.generate-tree tree.pine
          ..position.x = @terrain-gen.CHUNK_SIZE * @terrain-gen.TILE_LENGTH * Math.random!
          ..position.z = @terrain-gen.CHUNK_SIZE * @terrain-gen.TILE_LENGTH * Math.random!
          ..position.y = @terrain-gen.get-y offsetx + ..position.x, offsetz + ..position.z)

    chunk
