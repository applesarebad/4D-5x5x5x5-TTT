extends Node2D
@onready var Box = preload("res://Scenes/Box.tscn")
@export var length :int = 5
@export var boxlength: int = 32
@export var boxspace: int = 4
@export var gridspace: int = 12
@export var hovermode = "adjacent"
var boxes = {}  # Dictionary: key = Vector4

var turn = 1
var gameover = false

func _ready():
	
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
func _on_box_clicked(box):
	
	for line in check_possible_lines(box.coord):
		var states = [] 
		for point in line:
			states.append(boxes[point].state)
		if states.count(states[0]) == length:
			print("win!!")
			$wins.visible = true
			gameover = true
			for point in line:
				if turn == 1:
					boxes[point].win("red")
				else:
					boxes[point].win("blue")
			
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
	var neighbors = []
	for line in check_possible_lines(coord):
		for point in line:
			boxes[point].recieve_colour(box.colour)
		#for cell in boxes:
			#var neighboring = true
			#neighboring = check_adjacent(cell,coord)
			#if neighboring == true: 
				#neighbors.append(cell)
	
	for cell in neighbors:
		boxes[cell].recieve_colour(box.colour)
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
	return lines
	
func check_linear(cell,coord):
	var direction = [cell[0]-coord[0],cell[1]-coord[1],cell[2]-coord[2],cell[3]-coord[3]]
	pass
								
func _on_unhover():
	for cell in boxes:
		boxes[cell].recieve_colour(Color.WHITE)
	


func _on_area_2d_mouse_exited():
	for cell in boxes:
		boxes[cell].recieve_colour(Color.WHITE)


func _on_reset_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().reload_current_scene()


func _on_reset_mouse_entered():
	$Reset/Sprite2D.modulate = Color(0.6,0.6,0.6)


func _on_reset_mouse_exited():
	$Reset/Sprite2D.modulate = Color.WHITE
