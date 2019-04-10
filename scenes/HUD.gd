extends Control

func _ready():
	set_process(true)

func _process(delta):
	update()

func _draw():
	var d = get_viewport_rect().size
	
	# Reticle
	draw_x(Vector2(d.x / 2 - 5, d.y / 2 - 5 + 40), Vector2(d.x / 2 + 5, d.y / 2 + 5 + 40))
	
	# Roll gyroscope
	var top = Vector2(d.x / 2, d.y / 3)
	var bottom = Vector2(d.x / 2, d.y * (2 / 3))
	var roll_rot = $"../../".rotation.z
	top = top.rotated(roll_rot)
	bottom = bottom.rotated(roll_rot)
	draw_line(top, bottom, Color.green, 3)

func draw_x(tl: Vector2, br: Vector2):
	draw_line(tl, br, Color.green, 2)
	draw_line(Vector2(tl.x, br.y), Vector2(br.x, tl.y), Color.green, 2)
