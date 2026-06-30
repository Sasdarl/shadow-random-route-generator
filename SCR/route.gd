extends Node2D
var route_name : RichTextLabel;
var clear_star : Sprite2D;
var save_data : PackedByteArray;
var cleared;
var names;

var total_cleared = 0;
var route : int;
var prev_route = -1;
var percent : float;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cleared = false;
	route_name = self.get_node("Route Name");
	clear_star = self.get_node("Route Clear");
	
	var route_file = FileAccess.get_file_as_string("res://route_names");
	names = route_file.split("\n");
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	route_name.set_text("#"+"%03d"%(route+1)+": "+names[route]);
	if cleared: clear_star.visible = true;
	else: clear_star.visible = false;
	pass;

func is_cleared(test_route: int = -1):
	var cur_byte;
	var routes = [test_route]
	var cur_total = 0;
	var route_cleared = false;
	if test_route < 0: routes = range(326);
	
	for i in routes:
		route_cleared = false;
		cur_byte = save_data.get(test_route>>3);
		if cur_byte & (1 << (test_route % 8)) != 0:
			route_cleared = true;
			cur_total += 1;
		if test_route == route: cleared = route_cleared;
	
	if test_route < 0: 
		total_cleared = cur_total;
		return cur_total;
	else: return route_cleared;

func toggle_clear(toggle_route: int = -1):
	if toggle_route < 0: toggle_route = route;
	var save_pos = toggle_route>>3;
	var route_save = save_data.get(save_pos);
	save_data.set(save_pos, route_save ^ (1 << toggle_route%8));
	return save_routes();

func save_routes():
	var save_file = FileAccess.open("user://cleared.save", FileAccess.WRITE);
	save_file.store_buffer(save_data);
	save_file.close();
	return get_totals();

func load_routes():
	var save_file = FileAccess.open("user://cleared.save", FileAccess.READ);
	if save_file and save_file.get_length() >= 41: save_data = save_file.get_buffer(41);
	else:
		save_data = PackedByteArray();
		save_data.resize(41);
	if save_file: save_file.close();
	return get_totals();

func get_totals():
	var routes_cleared = 0;
	var stages_cleared = PackedByteArray();
	stages_cleared.resize((22*3)*2);
	
	for i in range(326):
		var stages_went_to = [];
		var cur_stage = 0;
		var cur_path = -1;
		var cur_alignment = 2;
		var cur_range = 1;
		var cur_route = gen_route(i);
		var cur_offset = -1;
		for j in range(6):
			stages_went_to.append(cur_stage);
			cur_path = cur_route[j];
			cur_offset = (cur_stage*3)+cur_path
			stages_cleared[cur_offset*2] += 1;
			if is_cleared(cur_route[6]):
				stages_cleared[cur_offset*2+1] += 1;
				if j == 0: routes_cleared += 1;
			
			cur_alignment += cur_path-1;
			if cur_alignment > 4 or cur_alignment < 0 or (j < 2 and cur_alignment % 4 == 0):
				if j != 5: cur_alignment -= cur_path-1;
			
			cur_stage += cur_range + cur_path-1;
			if j == 0 or j == 2:
				cur_stage += 1;
				cur_range += 2;

	total_cleared = routes_cleared;
	if routes_cleared >= 326: self.get_node("All Clear").visible = true;
	else: self.get_node("All Clear").visible = false;

	var total_text = "%03d" % routes_cleared;
	self.get_node("Total Routes").set_text(total_text + "/326");
	if (routes_cleared < 326):
		var percentage = "%02.1f" % ((float)(routes_cleared)/3.26);
		self.get_node("Percentage").set_text("("+percentage+"%)")
		self.get_node("Percentage").visible = true;
	else:
		self.get_node("Total Routes").set_text("326/326");
		self.get_node("Percentage").visible = false;
	
	percent = (float)(routes_cleared)/3.26;
	return stages_cleared;

func gen_route(new_route = -1):
	var stages = [-1,-1,-1,-1,-1,-1];
	var possible = [[-1,94,138,94,-1],[-1,44,50,44,-1],[10,16,18,16,10],[4,6,6,6,4],[2,2,2,2,2],[1,1,1,1,1]]
	var alignment = 2;
	var next = 0;
	var cur_paths = 0;
	if new_route < 0: new_route = randi() % 326;
	
	for i in range(6):
		for j in range(3):
			if j+alignment-1 < 0 or j+alignment-1 > 4 or possible[i][j+alignment-1] < 0:
				if i != 5: continue;
			if cur_paths + possible[i][j+alignment-1] > new_route:
				next = j;
				break;
			else: cur_paths += possible[i][j+alignment-1];
		stages[i] = next;
		alignment += next-1;
		if alignment > 4 or alignment < 0 or (i < 5 and possible[i][alignment] < 0):
			alignment -= next-1;
	
	return stages + [new_route];
