{TerrainGen} = require './terrain-gen.ls'
terrain-gen = new TerrainGen!
{Terrain} = require './terrain.ls'
terrain = new Terrain terrain-gen

document.addEventListener \DOMContentLoaded, ->
  W = window.innerWidth
  H = window.innerHeight
  dxrot = 0
  dyrot = 0

  chunks_to_load = []
  for i til 10
    for j til 10
      chunks_to_load.push([i, j])

  lighttarget = new THREE.Object3D!
    ..position.x = terrain-gen.CHUNK_SIZE * terrain-gen.TILE_LENGTH * 0.5
    ..position.z = terrain-gen.CHUNK_SIZE * terrain-gen.TILE_LENGTH * 0.5
    ..position.y = 0

  light = new THREE.DirectionalLight 0xffffff, 0.8
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
    ..add new THREE.AmbientLight 0x404040
    ..background = new THREE.Color 0xC6E5F4

  renderer = new THREE.WebGLRenderer!
    ..shadowMap.enabled = true
    ..shadowMap.type = THREE.PCFSoftShadowMap
    ..setSize W, H

  controls = new THREE.OrbitControls camera, document, renderer.domElement
    ..target.x = terrain-gen.CHUNK_SIZE * terrain-gen.TILE_LENGTH
    ..target.z = terrain-gen.CHUNK_SIZE * terrain-gen.TILE_LENGTH

  document.body.appendChild renderer.domElement

  animate = ->
    request-animation-frame animate
    # Load a chunk
    if chunks_to_load.length > 0
      if Math.random! < 0.1
        c = chunks_to_load.shift!
        scene.add terrain.at c[0], c[1]
    camera.rotation
      ..y += dyrot / 1000
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
