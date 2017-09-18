# TODO: create global meshes for each type of tree, select from meshes
# since creating new meshes for each tree consumes too many resources
generate-pine-tree = ->
  tree = new THREE.Object3D!

  trunk-height = 8
  trunk-top-radius = 10
  trunk-bot-radius = 15
  leaf-height = 20
  leaf-overlap = 10
  leaf-radius = 25
  leaf-radius-shrink = 3

  trunk-geo = new THREE.CylinderGeometry \
    trunk-top-radius,
    trunk-bot-radius,
    trunk-height,
    5 # segments

  tree.add ((new THREE.Mesh \
    trunk-geo,
    (new THREE.MeshPhongMaterial color: 0x8b4513))
    ..position.y = trunk-height / 2)


  for i from 0 til 3
    leaf-geo = new THREE.ConeGeometry \
      leaf-radius - leaf-radius-shrink * i,
      leaf-height,
      5 # segments
    tree.add ((new THREE.Mesh \
      leaf-geo,
      (new THREE.MeshPhongMaterial color: 0x556b2f))
      ..position.y = trunk-height + leaf-height / 2 + (leaf-height - leaf-overlap) * i
      ..rotation.y = 2 * Math.PI * Math.random!)

  tree

export pine = "pine"

export generate-tree = (type) ->
  if type == pine
    generate-pine-tree!
