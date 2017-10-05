generate-pine-tree = do ->
  trunk-height = 40
  trunk-top-radius = 20
  trunk-bot-radius = 30
  leaf-height = 100
  leaf-overlap = 50
  leaf-radius = 125
  leaf-radius-shrink = 15

  tree1-trunk-geometry = new THREE.BufferGeometry!
    ..fromGeometry new THREE.CylinderGeometry trunk-top-radius,
      trunk-bot-radius,
      trunk-height * 4,
      5 # segments
  tree1-trunk-material = new THREE.MeshPhongMaterial color: 0x8b4513

  make-leaf-geometry = (shrinkage) ->
    new THREE.BufferGeometry!
      ..fromGeometry new THREE.ConeGeometry leaf-radius - leaf-radius-shrink * shrinkage,
        leaf-height,
        5 # segments
  tree1-leaf-geometry = for i from 1 to 5
    make-leaf-geometry i

  tree1-leaf-material = new THREE.MeshPhongMaterial color: 0x556b2f

  ->
    tree = new THREE.Object3D!

    tree.add ((new THREE.Mesh tree1-trunk-geometry,
      (tree1-trunk-material))
      ..position.y = trunk-height / 2)
      ..castShadow = true

    if Math.random! < 0.03
      # 3% of trees are stumps
      return tree

    # First three layers of leaves
    for i til 3
      tree.add (( new THREE.Mesh tree1-leaf-geometry[i],
        (tree1-leaf-material))
        ..position.y = trunk-height + leaf-height / 2 + (leaf-height - leaf-overlap) * i
        ..rotation.y = 2 * Math.PI * Math.random!)
        ..castShadow = true

    #30% chance of extra tall tree
    if Math.random! * 100 < 30
      tree.add (( new THREE.Mesh tree1-leaf-geometry[3],
        (tree1-leaf-material))
        ..position.y = trunk-height + leaf-height / 2 + (leaf-height - leaf-overlap) * 3
        ..rotation.y = 2 * Math.PI * Math.random!)
        ..castShadow = true

      #40% chance of extra tall tree being extra extra tall
      if Math.random! * 100 < 40
        tree.add (( new THREE.Mesh tree1-leaf-geometry[4],
          (tree1-leaf-material))
          ..position.y = trunk-height + leaf-height / 2 + (leaf-height - leaf-overlap) * 4
          ..rotation.y = 2 * Math.PI * Math.random!)
          ..castShadow = true

    tree

export pine = "pine"

# Use a pool of 256 pine trees
pine-trees = for i til 256
  generate-pine-tree!

export generate-tree = (type) ->
  if type === pine
    pine-trees[Math.floor(Math.random! * pine-trees.length)].clone!
