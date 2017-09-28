# TODO: create global meshes for each type of tree, select from meshes
# since creating new meshes for each tree consumes too many resources

tree1-generated-materials = false
tree1-trunk-geometry = 0
tree1-trunk-material = 0
tree1-leaf-geometry1 = 0
tree1-leaf-geometry2 = 0
tree1-leaf-geometry3 = 0
tree1-leaf-material = 0


generate-pine-tree = ->
  trunk-height = 8
  trunk-top-radius = 10
  trunk-bot-radius = 15
  leaf-height = 20
  leaf-overlap = 10
  leaf-radius = 25
  leaf-radius-shrink = 3

  if tree1-generated-materials == false
    tree1-generated-materials := true
    tree1-trunk-geometry := new THREE.CylinderGeometry trunk-top-radius,
      trunk-bot-radius,
      trunk-height,
      5 # segments
    tree1-trunk-material := new THREE.MeshPhongMaterial color: 0x8b4513

    tree1-leaf-geometry1 := new THREE.ConeGeometry leaf-radius - leaf-radius-shrink,
      leaf-height,
      5 # segments
    tree1-leaf-geometry2 := new THREE.ConeGeometry leaf-radius - leaf-radius-shrink * 2,
      leaf-height,
      5 # segments
    tree1-leaf-geometry3 := new THREE.ConeGeometry leaf-radius - leaf-radius-shrink * 3,
      leaf-height,
      5 # segments
    tree1-leaf-material := new THREE.MeshPhongMaterial color: 0x556b2f


  tree = new THREE.Object3D!

  tree.add ((new THREE.Mesh tree1-trunk-geometry,
    (tree1-trunk-material))
    ..position.y = trunk-height / 2)
  tree.add (( new THREE.Mesh tree1-leaf-geometry1,
    (tree1-leaf-material))
    ..position.y = trunk-height + leaf-height / 2 + (leaf-height - leaf-overlap)
    ..rotation.y = 2 * Math.PI * Math.random!)
  tree.add (( new THREE.Mesh tree1-leaf-geometry2,
    (tree1-leaf-material))
    ..position.y = trunk-height + leaf-height / 2 + (leaf-height - leaf-overlap) * 1
    ..rotation.y = 2 * Math.PI * Math.random!)
  tree.add (( new THREE.Mesh tree1-leaf-geometry3,
    (tree1-leaf-material))
    ..position.y = trunk-height + leaf-height / 2 + (leaf-height - leaf-overlap) * 2
    ..rotation.y = 2 * Math.PI * Math.random!)

  tree

export pine = "pine"

pine-tree = generate-pine-tree!

export generate-tree = (type) ->
  if type == pine
    generate-pine-tree!
