extends Control

const RETICLE_RADIUS = 3
const LADDER_RADIUS = 50
const HOMING_RADIUS = 10

onready var ship = $"../../"
var drawn = false

var homing_reticle = null
var fully_locked = false # true when the homing_reticle is confirmed LOCKED ON

func _ready():
	set_process(true)

func _process(delta):
	update()

func _draw():
	var d = get_viewport_rect().size
	var c = d / 2
	
	# Reticle
	# draw_x(Vector2(d.x / 2 - 5, d.y / 2 - 5 + 40), Vector2(d.x / 2 + 5, d.y / 2 + 5 + 40))
	# Reticle needs to be replaced with the standard unfilled circle and three lines out of it: left, top, right
	var pos = $"../yaw/Camera".unproject_position($"../..".translation + $"../..".transform.basis * Vector3(0, 0, -15))
	draw_unfilled_circle(pos, RETICLE_RADIUS, Color.green) # circle
	draw_line(pos - Vector2(0, RETICLE_RADIUS), pos - Vector2(0, RETICLE_RADIUS*2), Color.green, 1) # top line
	draw_line(pos - Vector2(RETICLE_RADIUS, 0), pos - Vector2(RETICLE_RADIUS*2, 0), Color.green, 1) # left line
	draw_line(pos + Vector2(RETICLE_RADIUS, 0), pos + Vector2(RETICLE_RADIUS*2, 0), Color.green, 1) # right line
	
	#draw_pitch_ladder(d, c)
	
	if homing_reticle != null: # there is a homing reticle
		draw_rect(Rect2(homing_reticle - Vector2(HOMING_RADIUS, HOMING_RADIUS), Vector2(HOMING_RADIUS, HOMING_RADIUS)), Color.green, false)
		if fully_locked: # make a diamond when fully locked in
			pass

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
