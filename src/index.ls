{TerrainGen} = require './terrain-gen.ls'
terrain-gen = new TerrainGen!
{Terrain} = require './terrain.ls'
{Pilot} = require './pilot'

document.addEventListener \DOMContentLoaded, ->
  W = window.innerWidth
  H = window.innerHeight
  dxrot = 0
  dyrot = 0

  light-target = new THREE.Object3D!
    ..position.x = terrain-gen.CHUNK_SIZE * terrain-gen.TILE_LENGTH * 0.5
    ..position.z = terrain-gen.CHUNK_SIZE * terrain-gen.TILE_LENGTH * 0.5
    ..position.y = 0

  light = new THREE.DirectionalLight 0x222222, 0.8
    ..position.x = 0
    ..position.z = 0
    ..position.y = 6000
    ..castShadow = true
    ..target = light-target
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

  spotlight = new THREE.SpotLight 0xffffff, 1, 10000, 0.5, 1, 1
  spotlight.target = camera

  scene = new THREE.Scene!
    ..add light-target
    ..add light
    ..add spotlight
    ..fog = new THREE.Fog 0x111F2A, 7000, 10000
    ..background = new THREE.Color 0x111F2A

  renderer = new THREE.WebGLRenderer!
    ..shadowMap.enabled = true
    ..shadowMap.type = THREE.PCFSoftShadowMap
    ..castShadow = true
    ..setSize W, H

  terrain = new Terrain terrain-gen, scene

  pilot = new Pilot terrain-gen, camera

  document.body.appendChild renderer.domElement

  animate = ->
    request-animation-frame animate

    # Load a chunk
    chunk-length = terrain-gen.CHUNK_SIZE * terrain-gen.TILE_LENGTH
    cx = Math.floor camera.position.x / chunk-length
    cz = Math.floor camera.position.z / chunk-length
    terrain.do-work cx, cz

    # Move the camera and light
    light.position.z -= 20
    light-target.position.z -= 20
    pilot.tick!
    spotlight.position.addVectors camera.position, new THREE.Vector3 0, -10 * (Math.tan camera.rotation.x), 10

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
