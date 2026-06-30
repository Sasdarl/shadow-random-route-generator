extends Node2D
var base : Node2D;
var stages : CanvasGroup;
var bosses : CanvasGroup;
var lines : Array;

func _ready() -> void:
	base = self.get_parent();
	stages = self.get_node("Stage Slots");
	bosses = self.get_node("Boss Slots");
	pass;

func _process(_delta: float) -> void:
	stages.position = Vector2(0,0);
	bosses.position = Vector2(0,0);

func highlight_route(route_to_disp, slots_to_disp) -> void:
	lines = Array();
	var now_slot : int;
	var prev_slot : int;
	for i in range(len(slots_to_disp)): slots_to_disp[i].active = false;

	var alignment = 2;
	slots_to_disp[0].active = true;
	alignment += route_to_disp[0]-1;
	prev_slot = 0;

	for i in range(2):
		if alignment < 1: alignment = 1;
		now_slot = 1 + i*3 + alignment-1;
		slots_to_disp[now_slot].active = true;
		alignment += route_to_disp[i+1]-1;

		lines += [[prev_slot, now_slot]];
		prev_slot = now_slot;
	
	for i in range(3):
		now_slot = 7 + i*5 + alignment;
		slots_to_disp[now_slot].active = true;
		alignment += route_to_disp[i+3]-1;

		lines += [[prev_slot, now_slot]];
		prev_slot = now_slot;
	alignment -= route_to_disp[5]-1;

	now_slot = 22 + alignment*2 + route_to_disp[5];
	slots_to_disp[now_slot].active = true;
	lines += [[prev_slot, now_slot]];
	prev_slot = now_slot;

	if base and base.route: base.route.route = route_to_disp[6];
	queue_redraw();
	return;

func _draw() -> void:
	if base and base.route and base.route.route >= 0:
		var s1;
		var s2;
		#var offset = self.global_position;
		for i in range(len(lines)):
			if lines[i][0] < 22: s1 = stages.get_child(lines[i][0]);
			else: s1 = bosses.get_child(lines[i][0]-22);
			if lines[i][1] < 22: s2 = stages.get_child(lines[i][1]);
			else: s2 = bosses.get_child(lines[i][1]-22);
			draw_line(s1.position, s2.position, Color("#004967"), 7);
	pass;
