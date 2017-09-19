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
  SIZE = 100
  geometry = new THREE.PlaneGeometry SIZE, SIZE, SIZE, SIZE
  for i til geometry.vertices.length
    x = i % SIZE
    y = Math.floor i / SIZE
    geometry.vertices[i].z = t.get-height x, y

  material = new THREE.MeshPhongMaterial(
    color: 0x994422,
    wireframe: true)

  plane = new THREE.Mesh geometry, material

  light = new THREE.DirectionalLight 0xffffff, 0.8
    ..position.z = 90

  camera = new THREE.PerspectiveCamera 75, W / H, 0.1, 1000
    ..position.z = 100

  scene = new THREE.Scene!
    ..add plane
    ..add tree-obj
    ..add light
    ..add new THREE.AmbientLight 0x404040

  renderer = new THREE.WebGLRenderer!
    ..setSize W, H

  document.body.appendChild renderer.domElement

  animate = ->
    request-animation-frame animate
    tree-obj.rotation.y += 0.01
    plane.rotation
      ..x += dxrot / 1000
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

  # User input handlers
  do ->
    mouse-down-x = 0
    mouse-down-y = 0
    on-mouse-move = (event) ->
      dx = event.clientX - mouse-down-x
      dy = event.clientY - mouse-down-y
      dxrot := dy * Math.abs(dy) / 1000
      dyrot := dx * Math.abs(dx) / 1000
      console.log "drag (#{dx}, #{dy})"
    on-mouse-up = (event) ->
      dxrot := 0
      dyrot := 0
      document.removeEventListener
        .. \mousemove, on-mouse-move
        .. \mouseup, on-mouse-up
        .. \mouseout, on-mouse-up
    document.addEventListener \mousedown, (event) ->
      event.preventDefault!
      mouse-down-x := event.clientX
      mouse-down-y := event.clientY
      document.addEventListener
        .. \mousemove, on-mouse-move
        .. \mouseup, on-mouse-up
        .. \mouseout, on-mouse-up
