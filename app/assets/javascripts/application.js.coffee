#
#= require jquery
#= require jquery-ui
#= require jquery_ujs
#= require autocomplete-rails
#= require datepicker-fr-CH
#= require prototype
#= require effects
#= require controls
#= require dragdrop
#= require_self
#= require builder
#= require slider
#= require rest_in_place
#= require scriptaculous
#= require spectrum
# Place your application-specific JavaScript functions and classes here
# This file is automatically included by javascript_include_tag :defaults

# set focus on first form element

window.onload = ->
  myform = document.forms[0]
  if myform
    Form.focusFirstElement myform

# fade out flash after 5 secs
document.observe 'dom:loaded', ->
  setTimeout hideFlashMessages, 5000

hideFlashMessages = ->
  $$('p#notice, p#warning, p#error').each (e) ->
    if e
      Effect.Fade e, duration: 5.0


jQuery.datepicker.setDefaults jQuery.datepicker.regional['fr-CH']
jQuery ->
  jQuery('.datepicker').datepicker
    showOn: 'button'
    buttonImage: jQuery("#calendar_path").val()
    buttonImageOnly: true
    buttonText: 'Select date'
  jQuery('.colorPicker').spectrum
    allowEmpty: false
    showPaletteOnly: true
    showPalette: true
    palette: [
      [
        'black'
        'white'
        'blanchedalmond'
      ]
      [
        'red'
        'ffff00'
        'orange'
      ]
      [
        'blue'
        'violet'
        'grey'
      ]
    ]

 # element_clicked = (event, element, properties) ->
 #   if properties.type != 'block' or !properties.reservation_id
 #     return
 #   window.location = 'test'
 #   return

 # element_mousedown = (event, element, properties) ->
 #   if properties.type != 'block' or !properties.reservable
 #     return
 #   currently_reserving = true
 #   offsets = $('tableContainer').cumulativeOffset()
 #   orig_x = Math.floor((event.pointerX() - (offsets[0])) / tile_size)
 #   y = Math.floor((event.pointerY() - (offsets[1])) / tile_size)
 #   selector = grid.add_item(
 #     type: 'block'
 #     rect: [
 #       orig_x
 #       y
 #       0
 #       1
 #     ]
 #     color: 'orange')
 #   return

 # element_mousemove = (event, element, properties) ->
 #   if properties.type != 'block' or !currently_reserving
 #     return
 #   offsets = $('tableContainer').cumulativeOffset()
 #   x = event.pointerX() - (offsets[0])
 #   x -= x % grid.tile_size
 #   x += grid.tile_size
 #   selector.animate { width: x - (orig_x * grid.tile_size) }, 0
 #   return

 # element_mouseup = (event, element, properties) ->
 #   if properties.type != 'block'
 #     return
 #   start = new Date
 #   offsets = $('tableContainer').cumulativeOffset()
 #   x = Math.floor((event.pointerX() - (offsets[0])) / tile_size)
 #   y = Math.floor((event.pointerY() - (offsets[1])) / tile_size)
 #   arr = date_add(start, orig_x - rooms_offset)
 #   dep = date_add(start, x - rooms_offset + 1)
 #   if dep < arr
 #     return
 #   room = rooms[y - dates_offset]
 #   window.location = ''
 #   return

 # date_add = (date, days) ->
 #   d = new Date(date)
 #   d.setDate d.getDate() + days
 #   d

 # ruby_date = (d) ->
 #   d.getDate() + '/' + d.getMonth() + 1 + '/' + d.getFullYear()

 # currently_reserving = false
 # selector = null
 # orig_x = null
 # rooms = []
 # tile_size = 12.8
 # rooms_offset = 4
 # dates_offset = 2
 # items = []
 # grid = new Grid('tableContainer', rooms_offset)
 # grid.set_handlers
 #   click: element_clicked
 #   mousedown: element_mousedown
 #   mousemove: element_mousemove
 #   mouseup: element_mouseup
 # grid.add_items items
