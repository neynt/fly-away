document.add-event-listener \DOMContentLoaded, ->
  canvas = document.get-element-by-id 'main_canvas'
  ctx = canvas.get-context '2d'

  animate = ->
    ctx.fill-style = '#ff0000'
    ctx.fill-rect 5, 5, canvas.width - 10, canvas.height - 10
    window.request-animation-frame animate
  animate!

  # make canvas fill whole page
  on-resize = ->
    canvas.width = window.inner-width
    canvas.height = window.inner-height

  window.add-event-listener 'resize', on-resize
  on-resize!
