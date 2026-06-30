extends Panel
var focused = false;

func _on_mouse_entered() -> void:
	focused = true;
	pass;

func _on_mouse_exited() -> void:
	focused = false;
	pass;
