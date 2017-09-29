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

    scan-range = 20
    max-growable-scan-difference = 20
    for i til 30
      targx = @terrain-gen.CHUNK_SIZE * @terrain-gen.TILE_LENGTH * Math.random!
      targz = @terrain-gen.CHUNK_SIZE * @terrain-gen.TILE_LENGTH * Math.random!

      targy = @terrain-gen.get-y offsetx + targx, offsetz + targz
      scan-points = [@terrain-gen.get-y(offsetx + targx + scan-range, offsetz + targz),
        @terrain-gen.get-y(offsetx + targx - scan-range, offsetz + targz),
        @terrain-gen.get-y(offsetx + targx, offsetz + targz + scan-range),
        @terrain-gen.get-y(offsetx + targx, offsetz + targz - scan-range)]

      console.log 'XI'
      max-scan-difference = 0
      for scan-point in scan-points
        scan-difference = Math.abs(targy - scan-point)
        console.log ' X'
        console.log scan-difference
        if scan-difference > max-scan-difference
          max-scan-difference := scan-difference
      console.log max-scan-difference

      if Math.random! * max-growable-scan-difference < max-growable-scan-difference - max-scan-difference
        console.log 'TREE'
        console.log max-growable-scan-difference - max-scan-difference
        chunk.add (tree.generate-tree tree.pine
          ..position.x = targx
          ..position.z = targz
          ..position.y = targy)

    chunk
