extends Control

var drawn = false

func _ready():
	set_process(true)

func _process(delta):
	update()

func _draw():
	var d = get_viewport_rect().size
	
	# Reticle
	# draw_x(Vector2(d.x / 2 - 5, d.y / 2 - 5 + 40), Vector2(d.x / 2 + 5, d.y / 2 + 5 + 40))
	# Reticle needs to be replaced with the standard unfilled circle and three lines out of it: left, top, right
	draw_unfilled_circle(d/2, 10, Color.green)
	
	# Roll gyroscope
	var top = Vector2(0, -50)
	var bottom = Vector2(0, 50)
	var roll_rot = $"../../../".rotation.z
	top = top.rotated(roll_rot - deg2rad(90))
	bottom = bottom.rotated(roll_rot - deg2rad(90))
	draw_line(Vector2(top.x + (d.x/2), top.y + 50 + (180-100)/2), Vector2(bottom.x + (d.x/2), bottom.y + 50 + (180-100)/2), Color.green, 3)

func draw_x(tl: Vector2, br: Vector2):
	draw_line(tl, br, Color.green, 3)
	draw_line(Vector2(tl.x, br.y), Vector2(br.x, tl.y), Color.green, 3)

func draw_unfilled_circle(circle_center: Vector2, radius: float, color: Color, width = 1, resolution: float = 1):
	var draw_counter = 1
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
