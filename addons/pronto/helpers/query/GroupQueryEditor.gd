@tool
extends HBoxContainer

signal changed_query

var query: GroupQuery

func set_query(q: GroupQuery):
	query = q

func _ready():
	var groups = Utils.all_used_groups(null)
	$OptionButton.clear()
	for index in range(groups.size()):
		var group = groups[index]
		$OptionButton.add_item(group)
		if group == query.group:
			$OptionButton.select(index)

func _change(index):
	query.group = $OptionButton.get_item_text(index)
	changed_query.emit()
