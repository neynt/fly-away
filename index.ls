document.add-event-listener \DOMContentLoaded, ->
  W = window.inner-width
  H = window.inner-height

  # 3D scene
  cube = new THREE.Mesh \
    (new THREE.Box-geometry 1, 1, 1),
    (new THREE.Mesh-phong-material color: 0xff0000)
  light = new THREE.Directional-light 0xffffff, 0.8
    ..position.y = 5
    ..position.z = 10
  camera = new THREE.PerspectiveCamera 75, W / H, 0.1, 1000
    ..position.z = 5
  scene = new THREE.Scene!
    ..add cube
    ..add light
    ..add new THREE.Ambient-light 0x404040
  renderer = new THREE.WebGL-renderer!
    ..set-size W, H
  document.body.append-child renderer.dom-element

  animate = ->
    request-animation-frame animate
    cube.rotation
      ..x += 0.01
      ..y += 0.01
    renderer.render scene, camera
  animate!

  # Resize handler
  window.add-event-listener \resize, ->
    # Update W and H in upper scope
    W := window.inner-width
    H := window.inner-height
    camera.aspect = W / H
    camera.update-projection-matrix!
    renderer.set-size W, H
