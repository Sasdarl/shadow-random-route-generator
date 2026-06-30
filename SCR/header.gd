extends Node2D;
var direction = 1;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if self.name == "Header 2": direction = -1;
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position[0] -= delta*50*direction;
	if self.position[0]*direction <= -980:
		self.position[0] += (980*direction)-(delta*direction);
	pass;
