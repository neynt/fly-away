tree = require './tree.ls'

VIEW_DISTANCE = 12000

export class Terrain
  (terrain-gen, scene) ->
    @terrain-gen = terrain-gen
    @scene = scene
    @chunks-loaded = {} # map of map of bool
    @to-unload = []
    @cx = 0
    @cz = 0
    @chunk-length = @terrain-gen.CHUNK_SIZE * @terrain-gen.TILE_LENGTH
    @chunk-view-distance = Math.ceil VIEW_DISTANCE / @chunk-length
    @chunk-unload-distance = 2 + Math.ceil VIEW_DISTANCE / @chunk-length

  is-chunk-loaded: (X, Z) ->
    if not @chunks-loaded[X]
      false
    else
      !!@chunks-loaded[X][Z]
  mark-chunk-loaded: (X, Z) ->
    if not @chunks-loaded[X]
      @chunks-loaded[X] = {}
    @chunks-loaded[X][Z] = true
  mark-chunk-unloaded: (X, Z) ->
    if @chunks-loaded[X] and @chunks-loaded[X][Z]
      delete @chunks-loaded[X][Z]
  load-chunk: (X, Z) ->
    chunk = @at X, Z
    @scene.add chunk
    @mark-chunk-loaded X, Z
    # create an unloader
    unloader = ~>
      if (@cx - X)^2 + (@cz - Z)^2 > @chunk-unload-distance^2
        @to-unload.push chunk
        @mark-chunk-unloaded X, Z
      else
        window.setTimeout unloader, 10000
    unloader!

  # Does a load or an unload
  do-work: (cx, cz) ->
    @cx = cx
    @cz = cz
    for d to @chunk-view-distance
      for dx from -d to d
        if dx^2 + d^2 > @chunk-view-distance^2
          continue
        if not @is-chunk-loaded @cx + dx, @cz + d
          @load-chunk @cx + dx, @cz + d
          # Multi-level exit!
          return
        if not @is-chunk-loaded @cx + dx, @cz - d
          @load-chunk @cx + dx, @cz - d
          return
      for dz from -d to d
        if dz^2 + d^2 > @chunk-view-distance^2
          continue
        if not @is-chunk-loaded @cx + d, @cz + dz
          @load-chunk @cx + d, @cz + dz
          return
        if not @is-chunk-loaded @cx - d, @cz + dz
          @load-chunk @cx - d, @cz + dz
          return
    # Unload a chunk instead
    if @to-unload.length > 0
      @scene.remove @to-unload.shift!

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

    canvas = document.createElement 'canvas'
    canvas.width = (@terrain-gen.CHUNK_SIZE + 1)
    canvas.height = (@terrain-gen.CHUNK_SIZE + 1)
    ctx = canvas.getContext '2d'

    scan-range = 20
    max-growable-scan-difference = 20
    for i til geometry.vertices.length
      r = i % (@terrain-gen.CHUNK_SIZE + 1)
      c = Math.floor ((i + 0.5) / (@terrain-gen.CHUNK_SIZE + 1))
      x = @terrain-gen.TILE_LENGTH * r
      z = @terrain-gen.TILE_LENGTH * c
      y = @terrain-gen.get-y offsetx + x, offsetz + z
      geometry.vertices[i]
        ..x = x
        ..z = z
        ..y = y

      scan-points = [@terrain-gen.get-y(offsetx + x + scan-range, offsetz + z),
        @terrain-gen.get-y(offsetx + x - scan-range, offsetz + z),
        @terrain-gen.get-y(offsetx + x, offsetz + z + scan-range),
        @terrain-gen.get-y(offsetx + x, offsetz + z - scan-range)]

      max-scan-difference = 0
      for scan-point in scan-points
        scan-difference = Math.abs(y - scan-point)
        if scan-difference > max-scan-difference
          max-scan-difference := scan-difference

      max-green = 192
      min-green = 96 / 2
      red = 32
      green = 0
      blue = 0
      if max-scan-difference < max-growable-scan-difference
        slopiness = Math.abs(max-growable-scan-difference - max-scan-difference) / max-growable-scan-difference
        green := (max-green - min-green) * slopiness * 2 + min-green
        green := Math.round(green)
      else
        red := 180
        green := 142
        blue := 132
      color = "rgba(#{red}, #{green}, #{blue}, 1.0)"

      ctx.fillStyle = color
      ctx.fillRect r, c, 1, 1

    geometry.computeVertexNormals!

    texture = new THREE.CanvasTexture canvas

    material = new THREE.MeshLambertMaterial {
      color: 0xffffff
      map: texture
    }
    chunk.add (new THREE.Mesh geometry, material
      ..castShadow = true
      ..receiveShadow = true)


    for i til 30
      targx = @terrain-gen.CHUNK_SIZE * @terrain-gen.TILE_LENGTH * Math.random!
      targz = @terrain-gen.CHUNK_SIZE * @terrain-gen.TILE_LENGTH * Math.random!

      targy = @terrain-gen.get-y offsetx + targx, offsetz + targz
      scan-points = [@terrain-gen.get-y(offsetx + targx + scan-range, offsetz + targz),
        @terrain-gen.get-y(offsetx + targx - scan-range, offsetz + targz),
        @terrain-gen.get-y(offsetx + targx, offsetz + targz + scan-range),
        @terrain-gen.get-y(offsetx + targx, offsetz + targz - scan-range)]

      max-scan-difference = 0
      for scan-point in scan-points
        scan-difference = Math.abs(targy - scan-point)
        if scan-difference > max-scan-difference
          max-scan-difference := scan-difference

      if Math.random! * max-growable-scan-difference < max-growable-scan-difference - max-scan-difference
        chunk.add (tree.generate-tree tree.pine
          ..position.x = targx
          ..position.z = targz
          ..position.y = targy)

    chunk
