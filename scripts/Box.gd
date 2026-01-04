extends Area2D

var state :int  = 0 
var colour :Color = Color.WHITE 
var coord :Array = [0,0,0,0]


signal box_clicked(box)
signal box_hovered(box)
signal unhover(box)

func colourCheck():
	if state == 1:
		colour = Color(1,0.5,0.5)
	elif state == 2:
		colour = Color(0.5,0.5,1)
	else:
		if get_parent().turn == 1:
			colour = Color(1,0.5,0.5)
		elif get_parent().turn == 2:
			colour = Color(0.5,0.5,1)


func _on_mouse_entered():
	colourCheck()
	#emit_signal("box_hovered",self)

func _on_mouse_exited():
	#emit_signal("unhover")
	pass

func recieve_colour(received):
	$AnimatedSprite2D.modulate = received

func win(recieved):
	$AnimatedSprite2D.play(recieved)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and state == 0 and get_parent().gameover != true:
		if(get_parent().turn==get_parent().yourturn or get_parent().mode == 0):
			clicked()
			
	colourCheck()
	emit_signal("unhover")
	emit_signal("box_hovered",self)

func clicked():
	state = get_parent().turn 
	$AnimatedSprite2D.modulate = Color.WHITE
	emit_signal("unhover")
	
	if state == 1:
		$AnimatedSprite2D.play("X")
	if state == 2:
		$AnimatedSprite2D.play("O")
	emit_signal("box_clicked",self)
	
		
