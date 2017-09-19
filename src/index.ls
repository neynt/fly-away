{TerrainGen} = require './terrain-gen.ls'
terrain-gen = new TerrainGen!
{Terrain} = require './terrain.ls'
terrain = new Terrain terrain-gen
tree = require './tree.ls'

console.log terrain-gen.get-y 0, 0
console.log terrain-gen.get-y 0, 1

document.addEventListener \DOMContentLoaded, ->
  W = window.innerWidth
  H = window.innerHeight
  dxrot = 0
  dyrot = 0

  # Tree
  tree-obj = tree.generate-tree tree.pine
  plane = terrain.at 0, 0

  light = new THREE.DirectionalLight 0xffffff, 0.8
    ..position.y = 1

  pointlight = new THREE.PointLight!
    ..position.y = 400000

  camera = new THREE.PerspectiveCamera 45, W / H, 0.1, 1000000
    ..position.y = 4000

  scene = new THREE.Scene!
    ..add plane
    ..add tree-obj
    ..add light
    ..add new THREE.AmbientLight 0x404040
    ..add pointlight
    ..background = new THREE.Color 0xC6E5F4

  renderer = new THREE.WebGLRenderer!
    ..setSize W, H

  controls = new THREE.OrbitControls camera, document, renderer.domElement

  document.body.appendChild renderer.domElement

  animate = ->
    request-animation-frame animate
    tree-obj.rotation.y += 0.01
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
