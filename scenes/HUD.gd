extends Control

func _ready():
	set_process(true)

func _process(delta):
	update()

func _draw():
	var d = get_viewport_rect().size
	draw_x(Vector2(d.x / 2 - 5, d.y / 2 - 5 + 40), Vector2(d.x / 2 + 5, d.y / 2 + 5 + 40))

func draw_x(tl, br):
	draw_line(tl, br, Color.green)
	draw_line(Vector2(tl.x, br.y), Vector2(br.x, tl.y), Color.green)