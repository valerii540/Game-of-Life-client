extends Node2D

# Drawning
const _rect_size = Vector2(64, 64)

# Game
var _matrix = null

# Input
var _dragging              = false
var _previousPosition      = Vector2(0, 0);
var _screen_stretch        = 1.0
const _screen_stretch_step = 0.01

#Misc
var _timer = Timer.new()

func _draw():
	if _matrix:
		_draw_matrix()

func _ready():
	var e = $HTTPRequest.connect("request_completed", self, "_on_request_completed")
	if e:
		print("HTTP internal failure: %s" % e)

	_timer.set_wait_time(0.5)
	_timer.connect("timeout", self, "_update")
	add_child(_timer)

	_timer.start()

func _update():
	_timer.set_paused(true)
	$HTTPRequest.request("http://localhost:8080/board")

func _on_request_completed(_result, _response_code, _headers, _body):
	if _response_code == 200:
		var json = JSON.parse(_body.get_string_from_utf8())

#		var epoch = json.result['e']
		_matrix = json.result['m']

		#print("epoch: %s" % epoch)
		#print_matrix(matrix)

		update()
	elif _response_code == 0:
		printerr("Server unavailable")
	else:
		printerr("HTTP requset failure: code %d" % _response_code)

	_timer.set_paused(false)

func _draw_matrix():
	for i in range(0, _matrix.size()):
		for j in range(0, _matrix[0].size()):
			var rect = Rect2(Vector2(j * _rect_size.y, i * _rect_size.x), _rect_size)
			match _matrix[i][j]:
				0.0:
					draw_rect(rect, Color.black)
				1.0:
					draw_rect(rect, Color.green)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP and event.pressed:
			_screen_stretch += _screen_stretch_step
			get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED, SceneTree.STRETCH_ASPECT_EXPAND, Vector2(1, 1), _screen_stretch)
		elif event.button_index == BUTTON_WHEEL_DOWN and event.pressed:
			if _screen_stretch - _screen_stretch_step > 0.1:
				_screen_stretch -= _screen_stretch_step
				get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED, SceneTree.STRETCH_ASPECT_EXPAND, Vector2(1, 1), _screen_stretch)
		elif event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				_previousPosition = event.position
				_dragging = true
			else:
				_dragging = false
	elif _dragging and event is InputEventMouseMotion:
		position += (event.position - _previousPosition)
		_previousPosition = event.position
