extends TileMap

var timer = Timer.new()
var _screen_stretch = 1.0
var _screen_stretch_step = 0.01


var dragging = false
var _previousPosition: Vector2 = Vector2(0, 0);

func _ready():
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
			_screen_stretch += _screen_stretch_step
			get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED, SceneTree.STRETCH_ASPECT_EXPAND, Vector2(1, 1), _screen_stretch)
			print(_screen_stretch)
		elif event.button_index == BUTTON_WHEEL_DOWN and event.pressed:
			if _screen_stretch - _screen_stretch_step > 0.1:
				_screen_stretch -= _screen_stretch_step
				get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED, SceneTree.STRETCH_ASPECT_EXPAND, Vector2(1, 1), _screen_stretch)
			print(_screen_stretch)
		elif event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				_previousPosition = event.position
				dragging = true
			else:
				dragging = false
	elif dragging and event is InputEventMouseMotion:
		position += (event.position - _previousPosition)
		_previousPosition = event.position

func _update():
	timer.set_paused(true)
	$HTTPRequest.request("http://localhost:8080/board")
	
func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		
		var epoch = json.result['e']
		var matrix = json.result['m']
		
		#print("epoch: %s" % epoch)
		#print_matrix(matrix)
		
		for i in range(0, matrix.size()):
			for j in range(0, matrix[0].size()):
				set_cell(j, i, matrix[i][j])
	elif response_code == 0:
		printerr("Server unavailable")
	else:
		printerr("HTTP requset failure: code %d" % response_code)
	
	timer.set_paused(false)

func print_matrix(matrix):
	for row in matrix:
		print(row)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
