{TerrainGen} = require './terrain-gen.ls'
terrain-gen = new TerrainGen!
{Terrain} = require './terrain.ls'
terrain = new Terrain terrain-gen

const view-distance = 10000
const chunk-length = terrain-gen.CHUNK_SIZE * terrain-gen.TILE_LENGTH
const chunk-view-distance = Math.ceil view-distance / chunk-length

document.addEventListener \DOMContentLoaded, ->
  W = window.innerWidth
  H = window.innerHeight
  dxrot = 0
  dyrot = 0

  lighttarget = new THREE.Object3D!
    ..position.x = terrain-gen.CHUNK_SIZE * terrain-gen.TILE_LENGTH * 0.5
    ..position.z = terrain-gen.CHUNK_SIZE * terrain-gen.TILE_LENGTH * 0.5
    ..position.y = 0

  light = new THREE.DirectionalLight 0x999999, 0.8
    ..position.x = 0
    ..position.z = 0
    ..position.y = 6000
    ..castShadow = true
    ..target = lighttarget
  light.shadow.camera
    ..far = 100000
    ..left = -100000
    ..right = 100000
    ..bottom = -100000
    ..top = 100000
    ..updateProjectionMatrix!

  camera = new THREE.PerspectiveCamera 45, W / H, 0.1, 1000000
    # Centre of group of chunks
    ..position.x = terrain-gen.CHUNK_SIZE * terrain-gen.TILE_LENGTH
    ..position.z = terrain-gen.CHUNK_SIZE * terrain-gen.TILE_LENGTH
    ..position.y = 4000

  scene = new THREE.Scene!
    ..add lighttarget
    ..add light
    ..background = new THREE.Color 0x111F2A

  renderer = new THREE.WebGLRenderer!
    ..shadowMap.enabled = true
    ..shadowMap.type = THREE.PCFSoftShadowMap
    ..castShadow = true
    ..setSize W, H

  chunks-loaded = {}
  is-chunk-loaded = (x, z) ->
    if not chunks-loaded[x]
      false
    else
      !!chunks-loaded[x][z]
  mark-chunk-loaded = (x, z) ->
    if not chunks-loaded[x]
      chunks-loaded[x] = {}
    chunks-loaded[x][z] = true
  mark-chunk-unloaded = (x, z) ->
    if chunks-loaded[x] and chunks-loaded[x][z]
      delete chunks-loaded[x][z]
  load-chunk = (x, z) ->
    chunk = terrain.at x, z
    scene.add chunk
    mark-chunk-loaded x, z
    # create an unloader
    unloader = ->
      my-x = Math.floor camera.position.x / chunk-length
      my-z = Math.floor camera.position.z / chunk-length
      if (my-x - x)^2 + (my-z - z)^2 > chunk-view-distance^2
        scene.remove chunk
        mark-chunk-unloaded x, z
      else
        window.setTimeout unloader, 10000
    unloader!

  document.body.appendChild renderer.domElement

  animate = ->
    request-animation-frame animate

    # Load a chunk
    my-x = Math.floor camera.position.x / chunk-length
    my-z = Math.floor camera.position.z / chunk-length
    (->
      for d til chunk-view-distance
        for dx from -d to d
          if dx^2 + d^2 > chunk-view-distance^2
            continue
          if not is-chunk-loaded my-x + dx, my-z + d
            load-chunk my-x + dx, my-z + d
            return
          if not is-chunk-loaded my-x + dx, my-z - d
            load-chunk my-x + dx, my-z - d
            return
        for dz from -d to d
          if dz^2 + d^2 > chunk-view-distance^2
            continue
          if not is-chunk-loaded my-x + d, my-z + dz
            load-chunk my-x + d, my-z + dz
            return
          if not is-chunk-loaded my-x - d, my-z + dz
            load-chunk my-x - d, my-z + dz
            return
    )()

    # Move the camera
    camera.position.z -= 10
    camera.position.y = 400 + terrain-gen.get-y camera.position.x, camera.position.z

    renderer.render scene, camera
  animate!

  # Resize handler
  window.addEventListener \resize, ->
    # Update W and H in upper scope
    W := window.innerWidth
    H := window.innerHeight
    camera.aspect = W / H
    camera.updateProjectionMatrix!
    renderer.setSize W, H
