extends Node2D
@onready var Box = preload("res://Scenes/Box.tscn")
@export var length :int = 5
@export var boxlength: int = 32
@export var boxspace: int = 4
@export var gridspace: int = 12
var boxes = {}  # Dictionary: key = Vector4
var prevCoord : Array = [-1,-1,-1,-1]
var prevCol = Color(0.5,0.5,1)

var mode
var yourturn = 0
var turn = 1
var gameover = false
var oppID
var hovermode = 2

func _ready():
	GDSync.expose_func(send_info)
	GDSync.expose_func(iwantrematch)
	$wins.visible = false
	$Reset.visible = false
	for i in range(length):
		for j in range(length):
			for k in range(length):
				for l in range(length):
					var box = Box.instantiate()
					box.coord = [i,j,k,l]
					add_child(box)
					box.box_clicked.connect(_on_box_clicked)
					box.box_hovered.connect(_on_box_hovered)
					box.unhover.connect(_on_unhover)
					box.position = Vector2(
					200+(boxlength+boxspace)*k+(length*(boxlength+boxspace)+gridspace)*i,
					35+(boxlength+boxspace)*l+(length*(boxlength+boxspace)+gridspace)*j
					)
					var key = box.coord
					boxes[key] = box
					
func setup():
	if(mode == 1):
		$you.visible = true
		$Reset.visible = false
		if(yourturn == 1):
			$you/indicator.play("X")
		else:
			$you/indicator.play("O")
	elif(mode == 0):
		$you.visible = false


func _on_box_clicked(box):
	
	prevCoord = box.coord
	prevCol = box.colour
	boxes[box.coord].recieve_colour(box.colour)
	
	if(turn == yourturn and mode == 1):
		send_info.rpc_id(oppID,box.coord)
		GDSync.call_func_on(oppID,send_info,[box.coord])
	
	for line in check_possible_lines(box.coord):
		var states = [] 
		for point in line:
			states.append(boxes[point].state)
		if states.count(states[0]) == length:
			print("win!!")
			$wins.visible = true
			$Reset.visible = true
			$Reset/rematchLabel.visible = false
			gameover = true
			for point in line:
				if turn == 1:
					boxes[point].win("red")
					
					
				else:
					boxes[point].win("blue")
			if turn == 1:
				get_parent().xwin += 1
			else:
				get_parent().owin += 1
			if yourturn == turn:
				get_parent().youwin += 1
			else:
				get_parent().youlose += 1
					
	
	if turn == 1 and gameover == false:
		turn = 2
		$Sprite2D.modulate = Color(0.8,0.8,1)
		$AnimatedSprite2D.play("O")
		
		
	elif turn == 2 and gameover == false:
		turn = 1
		$Sprite2D.modulate = Color(1,0.8,0.8)
		$AnimatedSprite2D.play("X")

func _on_box_hovered(box):
	var coord = box.coord
	var colours = []
	if box.colour == Color(1, 0.5, 0.5):
		colours = [
		Color(1.0, 0.5, 0.5), Color(0.924, 0.0, 0.239, 1.0), Color(1.0, 0.3, 0.3), Color(1.0, 0.341, 0.401, 1.0),
		Color(1.0, 0.4, 0.4), Color(0.984, 0.444, 0.598, 1.0), Color(1.0, 0.484, 0.501, 1.0), Color(0.989, 0.402, 0.701, 1.0),
		Color(1.0, 0.584, 0.387, 1.0), Color(1.0, 0.434, 0.662, 1.0), Color(0.838, 0.107, 0.413, 1.0), Color(0.972, 0.465, 0.745, 1.0),
		Color(0.895, 0.137, 0.626, 1.0), Color(0.951, 0.227, 0.333, 1.0), Color(1.0, 0.481, 0.825, 1.0), Color(0.848, 0.022, 0.273, 1.0), Color(1.0, 0.43, 0.471, 1.0),
		Color(1.0, 0.306, 0.383, 1.0), Color(1.0, 0.337, 0.0, 1.0), Color(0.962, 0.257, 0.384, 1.0), Color(1.0, 0.8, 0.9),
		Color(0.973, 0.312, 0.512, 1.0), Color(1.0, 0.518, 0.742, 1.0), Color(0.925, 0.185, 0.455, 1.0), Color(1.0, 0.658, 0.775, 1.0),
		Color(1.0, 0.548, 0.605, 1.0), Color(1.0, 0.602, 0.702, 1.0), Color(0.882, 0.145, 0.512, 1.0),
		Color(1.0, 0.468, 0.558, 1.0), Color(1.0, 0.72, 0.82, 1.0), Color(0.962, 0.345, 0.595, 1.0), Color(1.0, 0.395, 0.558, 1.0),
		Color(0.894, 0.123, 0.355, 1.0), Color(1.0, 0.56, 0.84, 1.0), Color(1.0, 0.287, 0.455, 1.0), Color(0.977, 0.423, 0.612, 1.0),
		Color(1.0, 0.74, 0.93, 1.0), Color(0.903, 0.165, 0.295, 1.0), Color(1.0, 0.51, 0.63, 1.0), Color(1.0, 0.63, 0.78, 1.0)
	]
	else:
		colours = [
		Color(0.5, 0.5, 1.0, 1.0), Color(0.365, 0.614, 1.0, 1.0), Color(0.419, 0.763, 1.0, 1.0), Color(0.195, 0.354, 1.0, 1.0),
		Color(0.52, 0.446, 1.0, 1.0), Color(0.005, 0.473, 0.768, 1.0), Color(0.527, 0.641, 0.983, 1.0), Color(0.652, 0.537, 1.0, 1.0),
		Color(0.17, 0.724, 1.0, 1.0), Color(0.643, 0.479, 1.0, 1.0), Color(0.183, 0.395, 1.0, 1.0), Color(0.701, 0.596, 1.0, 1.0),
		Color(0.0, 0.701, 0.841, 1.0), Color(0.593, 0.27, 1.0, 1.0), Color(0.0, 0.6, 0.679, 1.0), Color(0.376, 0.45, 1.0, 1.0),
		Color(0.495, 0.652, 1.0, 1.0), Color(0.45, 0.757, 1.0, 1.0), Color(0.534, 0.534, 0.991, 1.0), Color(0.001, 0.305, 0.96, 1.0),
		Color(0.782, 0.412, 1.0, 1.0), Color(0.062, 0.511, 0.903, 1.0), Color(0.344, 0.268, 1.0, 1.0), Color(0.118, 0.803, 1.0, 1.0),
		Color(0.705, 0.325, 0.983, 1.0), Color(0.232, 0.557, 0.991, 1.0), Color(0.901, 0.612, 1.0, 1.0), Color(0.044, 0.429, 0.801, 1.0),
		Color(0.512, 0.188, 1.0, 1.0), Color(0.332, 0.741, 1.0, 1.0), Color(0.003, 0.381, 0.872, 1.0), Color(0.688, 0.22, 1.0, 1.0),
		Color(0.185, 0.865, 1.0, 1.0), Color(0.416, 0.319, 0.966, 1.0), Color(0.067, 0.548, 0.998, 1.0), Color(0.842, 0.503, 1.0, 1.0),
		Color(0.251, 0.296, 1.0, 1.0), Color(0.139, 0.789, 0.942, 1.0), Color(0.594, 0.151, 1.0, 1.0), Color(0.020, 0.462, 0.905, 1.0)
	]
	var i = 0
	for line in check_possible_lines(coord):
		for point in line:
			if(hovermode == 2):
				boxes[point].recieve_colour(colours[i])
			elif(hovermode == 1):
				boxes[point].recieve_colour(box.colour)
			else:
				pass
		i+=1

	boxes[coord].recieve_colour(box.colour)
func check_adjacent(cell,coord):
	for i in range(4):
		if abs(cell[i] - coord[i]) <=1:
			pass
		else:
			return false
	return true
func check_possible_lines(coord):
	var lines = []
	for i in range(-1,2):
			for j in range(-1,2):
				for k in range(-1,2):
					for l in range(-1,2):
						var current_line = []
						for m in range(-length+1,length):
							if (
							0 <= m*i + coord[0] and m*i + coord[0] < length and
							0 <= m*j + coord[1] and m*j + coord[1] < length and
							0 <= m*k + coord[2] and m*k + coord[2] < length and
							0 <= m*l + coord[3] and m*l + coord[3] < length
							):
								current_line.append([m*i+coord[0],m*j+coord[1],m*k+coord[2],m*l+coord[3]])
						if len(current_line) == length:
							lines.append(current_line)
	var unique = []
	for l in lines:
		l.sort()
		if !unique.has(l):
			unique.append(l)
	return unique
						
func _on_unhover():
	for cell in boxes:
		if(cell!= prevCoord):
			boxes[cell].recieve_colour(Color.WHITE)
	if(prevCoord!=[-1,-1,-1,-1]):
		boxes[prevCoord].recieve_colour(prevCol)
	


func _on_area_2d_mouse_exited():
	for cell in boxes:
		if(cell!= prevCoord):
			boxes[cell].recieve_colour(Color.WHITE)
	if(prevCoord!=[-1,-1,-1,-1]):
		boxes[prevCoord].recieve_colour(prevCol)


func _on_reset_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if(mode == 0):
			get_parent()._reset_board()
		if(mode == 1):
			rematch()
	
func _on_reset_mouse_entered():
	if !merematch:
		$Reset/Sprite2D.modulate = Color(0.6,0.6,0.6)


func _on_reset_mouse_exited():
	if !merematch:
		$Reset/Sprite2D.modulate = Color.WHITE
	
	
var merematch = false
var yourematch = false
func rematch():
	merematch = true
	$Reset/rematchLabel.visible = true
	$Reset/rematchLabel.text = "Requesting a rematch"
	$Reset/Sprite2D.modulate = Color(0.4,0.4,0.4)
	setup_rematch()
	iwantrematch.rpc_id(oppID)
	GDSync.call_func_on(oppID,iwantrematch)

@rpc("any_peer", "call_local", "reliable")
func iwantrematch():
	$Reset/rematchLabel.text = "Opponent is looking for a rematch"
	$Reset/rematchLabel.visible = true
	
	yourematch = true
	setup_rematch()
	
func setup_rematch():
	if(merematch and yourematch):
		get_parent()._reset_board()


@rpc("any_peer", "call_local", "reliable")
func send_info(coord):
	boxes[coord].clicked()
