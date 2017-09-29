{TerrainGen} = require './terrain-gen.ls'
terrain-gen = new TerrainGen!
{Terrain} = require './terrain.ls'

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
    ..fog = new THREE.Fog 0x5C767D, 7000, 10000
    ..background = new THREE.Color 0x5C767D #0x111F2A

  renderer = new THREE.WebGLRenderer!
    ..shadowMap.enabled = true
    ..shadowMap.type = THREE.PCFSoftShadowMap
    ..castShadow = true
    ..setSize W, H

  terrain = new Terrain terrain-gen, scene

  document.body.appendChild renderer.domElement

  animate = ->
    request-animation-frame animate

    # Load a chunk
    chunk-length = terrain-gen.CHUNK_SIZE * terrain-gen.TILE_LENGTH
    cx = Math.floor camera.position.x / chunk-length
    cz = Math.floor camera.position.z / chunk-length
    terrain.do-work cx, cz

    # Move the camera and light
    cur-y = terrain-gen.get-y camera.position.x, camera.position.z
    nxt-y = terrain-gen.get-y camera.position.x, camera.position.z - 1000
    dy = cur-y - nxt-y

    light.position.z -= 20
    lighttarget.position.z -= 20
    camera.position.z -= 20
    camera.position.y = 400 + cur-y

    ideal-rot-x = -0.9*(Math.atan2(dy, 1000))
    camera.rotation.x = 0.98 * camera.rotation.x + 0.02 * ideal-rot-x

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
