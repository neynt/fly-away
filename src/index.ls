{ Terrain } = require './terrain.ls'
t = new Terrain!
console.log t.get-height 3, 5

tree = require './tree.ls'

document.addEventListener \DOMContentLoaded, ->
  W = window.innerWidth
  H = window.innerHeight
  dxrot = 0
  dyrot = 0

  # Tree
  tree-obj = tree.generate-tree tree.pine

  # 3D scene
  SIZE = 200
  geometry = new THREE.PlaneGeometry 100*SIZE, 100*SIZE, SIZE, SIZE
  for i til geometry.vertices.length
    x = i % (SIZE + 1)
    y = Math.floor i / (SIZE + 1)
    geometry.vertices[i].z = t.get-height x, y

  material = new THREE.MeshPhysicalMaterial {
    color: 0x994422
  }

  plane = new THREE.Mesh geometry, material
    ..rotation.x = 3 * Math.PI / 2

  light = new THREE.DirectionalLight 0xffffff, 0.8
    ..position.z = 1

  pointlight = new THREE.PointLight!
    ..position.y = 400000

  camera = new THREE.PerspectiveCamera 45, W / H, 0.1, 1000000
    ..position.y = 4000

  scene = new THREE.Scene!
    ..add plane
    ..add tree-obj
    ..add light
    ..add new THREE.AmbientLight 0x808080
    ..add pointlight

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
