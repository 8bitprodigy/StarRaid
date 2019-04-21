extends Control

const RETICLE_RADIUS = 3
const LADDER_RADIUS = 50
const HOMING_RADIUS = 5

onready var ship = $"../../"
var drawn = false
var draw_reticle = true

var homing_reticle = null # Vector2 position of where to draw homing reticle when actively_locking_on is true
var actively_locking_on = false # Attempting to lock on
var fully_locked = false # True when the homing_reticle is confirmed LOCKED ON

func _ready():
	set_process(true)

func _process(delta):
	update()

func _draw():
	var d = get_viewport_rect().size
	var c = d / 2
	
	if draw_reticle: # Cannon targeting reticle
		var pos = $"../yaw/Camera".unproject_position($"../..".translation + $"../..".transform.basis * Vector3(0, 0, -15))
		draw_unfilled_circle(pos, RETICLE_RADIUS, Color.green) # circle
		draw_line(pos - Vector2(0, RETICLE_RADIUS), pos - Vector2(0, RETICLE_RADIUS*2), Color.green, 1) # top line
		draw_line(pos - Vector2(RETICLE_RADIUS, 0), pos - Vector2(RETICLE_RADIUS*2, 0), Color.green, 1) # left line
		draw_line(pos + Vector2(RETICLE_RADIUS, 0), pos + Vector2(RETICLE_RADIUS*2, 0), Color.green, 1) # right line
	
	#draw_pitch_ladder(d, c)
	
	if actively_locking_on: # there is a homing reticle
		$Lock.visible = true
		if homing_reticle != null:
			# Draw the rectangle
			draw_rect(Rect2(homing_reticle - Vector2(HOMING_RADIUS, HOMING_RADIUS), Vector2(HOMING_RADIUS * 2, HOMING_RADIUS * 2)), Color.green, false)
			
			if fully_locked: # make a diamond when fully locked in
				# all points
				var top = Vector2(homing_reticle.x, homing_reticle.y - HOMING_RADIUS - 2)
				var left = Vector2(homing_reticle.x - HOMING_RADIUS - 2, homing_reticle.y)
				var right = Vector2(homing_reticle.x + HOMING_RADIUS + 2, homing_reticle.y)
				var bottom = Vector2(homing_reticle.x, homing_reticle.y + HOMING_RADIUS + 2)
				
				draw_line(left, top, Color.green) # top left diag
				draw_line(right, top, Color.green) # top right diag
				draw_line(left, bottom, Color.green) # bottom left diag
				draw_line(right, bottom, Color.green) # bottom right diag
		
		if not fully_locked:
			# Draw X over "LOCK" on GUI
			var tl = $Lock.rect_position
			var tr = $Lock.rect_position + Vector2($Lock.rect_size.x, 0)
			var bl = $Lock.rect_position + Vector2(0, $Lock.rect_size.y)
			var br = $Lock.rect_position + $Lock.rect_size
			draw_line(tl, br, Color.red)
			draw_line(tr, bl, Color.red)
	else: $Lock.visible = false

func draw_pitch_ladder(d, c):
	var left = Vector2(-LADDER_RADIUS, 0)
	var right = Vector2(LADDER_RADIUS, 0)
	var roll_rot = ship.rotation.z
	#top = top.rotated(roll_rot)
	#bottom = bottom.rotated(roll_rot)
	
	var lines = [] # [[Vector2, Vector2]]
	
	for deg in range(ship.rotation_degrees.x, -ship.rotation_degrees.x, 5): # deg becomes the Y
		# if line would be on screen:
		# add line to array
		lines.append([Vector2(-LADDER_RADIUS, deg * 3), Vector2(LADDER_RADIUS, deg * 3)])
	
	for line in lines:
		# rotate each line around the origin
		var l = line[0].rotated(roll_rot) # left point
		var r = line[1].rotated(roll_rot) # right point
		# draw every line stacked ontop of each other
		draw_line(Vector2(c.x + l.x, c.y + l.y), Vector2(c.x + r.x, c.y + r.y), Color.green, 1)
	
	#draw_line(Vector2(c.x + top.x, top.y + 50 + (180-100)/2), Vector2(c.x + bottom.x, bottom.y + 50 + (180-100)/2), Color.green, 1)

func draw_x(tl: Vector2, br: Vector2):
	draw_line(tl, br, Color.green, 1)
	draw_line(Vector2(tl.x, br.y), Vector2(br.x, tl.y), Color.green, 1)

func draw_unfilled_circle(circle_center: Vector2, radius: float, color: Color, width = 1, resolution: float = 1):
	var draw_counter = 1.0
	var vec_radius = Vector2(radius, 0)
	var line_origin = vec_radius + circle_center
	var line_end = Vector2()
	
	while draw_counter <= 360.0:
		line_end = vec_radius.rotated(deg2rad(draw_counter)) + circle_center
		draw_line(line_origin, line_end, color, width)
		draw_counter += 1.0 / resolution
		line_origin = line_end
	
	line_end = vec_radius.rotated(deg2rad(360)) + circle_center
	draw_line(line_origin, line_end, color, width)
