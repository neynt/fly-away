document.addEventListener \DOMContentLoaded, ->
  W = window.innerWidth
  H = window.innerHeight

  # 3D scene
  geometry = new THREE.PlaneGeometry 60, 60, 9, 9
  plane = new THREE.Mesh \
    geometry,
    (new THREE.MeshPhongMaterial color: 0xff0000)
  light = new THREE.DirectionalLight 0xffffff, 0.5
    ..position.y = 100
    ..position.z = 10
  camera = new THREE.PerspectiveCamera 75, W / H, 0.1, 1000
    ..position.z = 50
  scene = new THREE.Scene!
    ..add plane
    ..add light
    ..add new THREE.AmbientLight 0x404040
  renderer = new THREE.WebGLRenderer!
    ..setSize W, H
  document.body.appendChild renderer.domElement

  animate = ->
    request-animation-frame animate
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
