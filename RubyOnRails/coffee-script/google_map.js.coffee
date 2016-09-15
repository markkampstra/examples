@map = null
@map_markers = {}
@route
@last_location = null

$ ->  
  initialize = ->
    if $('#map-canvas').length == 0
      return
    @map_markers = {}
    @route = null
    
    $('#add-current-location').click (event) ->
      event.preventDefault();
      navigator.geolocation.getCurrentPosition(geo_location)
  
    lat = $('#map-canvas').data('lat')
    lng = $('#map-canvas').data('lng')
    zoom = $('#map-canvas').data('zoom')
    static_map = $('#map-canvas').data('static-map')
    small_static_map = $('#map-canvas').data('small-static-map')
    homepage = $('#map-canvas').data('home')
    map_draggable = $('#map-canvas').data('draggable')
    large_map_url = $('#map-canvas').data('large-map-url')
    
    if lat == '' #or lng == ''
      lat = 9.877
      lng = 276.129
    if zoom == ''
      zoom = 8
    mapOptions =
      center: new google.maps.LatLng(lat, lng)
      zoom: zoom
      mapTypeId: google.maps.MapTypeId.HYBRID
    
    if small_static_map
      mapOptions['draggable'] = false
      mapOptions['zoom'] = zoom-1
      mapOptions['disableDoubleClickZoom'] = true
      mapOptions['keyboardShortcuts'] = false
      mapOptions['mapTypeControl'] = false
      mapOptions['disableDefaultUI'] = true
      mapOptions['zoomControl'] = false
      mapOptions['scrollwheel'] = false

    @map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)
    if large_map_url
      new google.maps.event.addListener map, "click", ->
        document.location.href = large_map_url
        
    if !static_map and !homepage
      $('#markers li').each ->
        add_marker_to_map(this)
    
      add_route_to_map(homepage)
    else
      $('.static-marker').each ->
        add_static_marker_to_map(this, homepage)
        
      if map_markers
        tmp_m = $(Object.keys(map_markers)).first()[0]
        if tmp_m
          map_markers[tmp_m].setVisible(true)
        tmp_m = $(Object.keys(map_markers)).last()[0]
        if tmp_m
          map_markers[tmp_m].setVisible(true)
      add_route_to_map(homepage)

    if map_draggable
      new google.maps.event.addListener map, "dragend", ->
        save_position()
      new google.maps.event.addListener map, "zoom_changed", ->
        save_position()
      
    if $('#last-location').length > 0
      set_last_location()

    save_position = ->
      $('#current_pos').html map.getCenter().toString() 
      lat = map.getCenter().lat()
      lng = map.getCenter().lng()
      zoom = map.getZoom()
      save_url = $('#map-canvas').data('position-url')
      $.post(save_url, {lat: lat, lng: lng, zoom: zoom})
      
    return
  google.maps.event.addDomListener window, "load", initialize
  google.maps.event.addDomListener(window, 'page:load', initialize)

  $('#add-marker').click (event) -> 
    event.preventDefault();
    add_marker_url = $(this).data('add-marker')
    $.post(add_marker_url, {lat: map.getCenter().lat(), lng:map.getCenter().lng()})
    
  if $('#markers').length > 0
    $('#markers').sortable()
    
@add_marker_to_map = (obj) ->
  lat = $(obj).data('lat')
  lng = $(obj).data('lng')
  pos = new google.maps.LatLng(lat, lng)
  marker_id = $(obj).data('marker-id')
  marker = new google.maps.Marker({map: @map, position: pos, draggable: true, marker_id: marker_id})
  map_markers['marker-'+ marker_id] = marker
  google.maps.event.addListener marker, "mouseover", (e) ->
    $('#marker-' + this.marker_id).effect("highlight", 1000)
    
  google.maps.event.addListener marker, "dragend", (e) ->
    update_marker_url = $('#map-canvas').data('update-marker')        
    $.post(update_marker_url, {marker_id:this.marker_id, lat:e.latLng.lat(), lng: e.latLng.lng()})

@add_static_marker_to_map = (obj, homepage) ->
  lat = $(obj).data('lat')
  lng = $(obj).data('lng')
  pos = new google.maps.LatLng(lat, lng)
  marker_id = $(obj).data('marker-id')
  marker = new google.maps.Marker({map: @map, position: pos, draggable: false, marker_id: marker_id})
  #if homepage
  marker.setVisible(false)
  map_markers['marker-'+ marker_id] = marker

@add_route_to_map = (homepage) ->
  if @route
    @route.setMap(null)
  coords = []
  for m in Object.keys(map_markers)
    coords.push(map_markers[m].position)
    
  line_symbol =
    path: google.maps.SymbolPath.FORWARD_CLOSED_ARROW
  if homepage
   icons = []
  else
    icons = [{icon: line_symbol, offset: '25%'}, {icon: line_symbol, offset: '50%'},{icon: line_symbol, offset: '75%'}]
  @route = new google.maps.Polyline(
      path: coords,
      icons: 
        icons
      geodesic: true,
      strokeColor: '#FCFF61',
      strokeOpacity: 1.0,
      strokeWeight: 4
    );
  @route.setMap(@map);
  
@geo_location = (position) ->
  lat = position.coords.latitude
  lng = position.coords.longitude

  add_current_location_url = $('#add-current-location').data('add-current-location')
  $.post(add_current_location_url, {lat:lat, lng:lng})
  
@set_last_location = ->
  if $('#last-location').data('draggable') == 1
    draggable = true
  else
    draggable = false
  last_position = new google.maps.LatLng $('#last-location').data('lat'), $('#last-location').data('lng')
  
  if @last_location
    @last_location.setVisible(false)
  @last_location = new google.maps.Marker 
    icon: new google.maps.MarkerImage $('#last-location').data('icon')
    position: last_position
    map: @map
    draggable: draggable
  google.maps.event.addDomListener last_location, "dragend", (e) ->
    $.post $('#last-location').data('update-current-location'),
      lat: e.latLng.lat()
      lng: e.latLng.lng()
      id: $('#last-location').data('location-id')
  
  if $('#goto-last-location').length > 0
    $('#goto-last-location').click ->
      map.setCenter(last_position)
      return false


  