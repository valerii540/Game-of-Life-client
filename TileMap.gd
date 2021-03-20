extends TileMap

var timer = Timer.new()
var screen_stretch = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED,SceneTree.STRETCH_ASPECT_KEEP, Vector2(1, 1), 0.5)
	var e = $HTTPRequest.connect("request_completed", self, "_on_request_completed")
	if e:
		print("HTTP internal failure: %s" % e)
	
	timer.set_wait_time(0.5)
	timer.connect("timeout", self, "_update")
	add_child(timer)
	
	timer.start()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP and event.pressed:
			screen_stretch += 0.1
			get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED, SceneTree.STRETCH_ASPECT_KEEP, Vector2(1, 1), screen_stretch)
		elif event.button_index == BUTTON_WHEEL_DOWN and event.pressed:
			screen_stretch -= 0.1
			get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED, SceneTree.STRETCH_ASPECT_KEEP, Vector2(1, 1), screen_stretch)

func _update():
	timer.set_paused(true)
	$HTTPRequest.request("http://localhost:8080/board")
	
func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		
		var epoch = json.result['e']
		var matrix = json.result['m']
		
		print("epoch: %s" % epoch)
		print_matrix(matrix)
		
		for i in range(0, matrix.size()):
			for j in range(0, matrix[0].size()):
				set_cell(j, i, matrix[i][j])
	else:
		printerr("HTTP requset failure: code %d" % response_code)
	
	timer.set_paused(false)

func print_matrix(matrix):
	for row in matrix:
		print(row)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
