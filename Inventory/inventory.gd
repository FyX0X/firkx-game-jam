class_name Inventory
extends Node

signal item_added(item_id: String, amount: int)
signal item_removed(item_id: String, amount: int)
signal inventory_changed

@export var inventory_name: String = "DefaultInventoryName"
@export var capacity: int = 10  # max number of distinct stacks

# { "iron": 12, "coal": 5, ... }
var _items: Dictionary = {}

func add_item(item_id: String, amount: int = 1) -> int:
	if amount <= 0:
		return 0
	if not _items.has(item_id) and _items.size() >= capacity:
		return 0  # no room for a new stack, return 0 added
	print("Add item : " + item_id + str(amount))
	_items[item_id] = _items.get(item_id, 0) + amount
	item_added.emit(item_id, amount)
	inventory_changed.emit()
	return amount

func remove_item(item_id: String, amount: int = 1) -> int:
	if not has_item(item_id, amount):
		return 0
	
	_items[item_id] -= amount
	if _items[item_id] <= 0:
		_items.erase(item_id)
	
	item_removed.emit(item_id, amount)
	inventory_changed.emit()
	return amount

func has_item(item_id: String, amount: int = 1) -> bool:
	return _items.get(item_id, 0) >= amount

func get_amount(item_id: String) -> int:
	return _items.get(item_id, 0)

func get_all_items() -> Dictionary:
	return _items.duplicate()

func is_empty() -> bool:
	return _items.is_empty()

func clear():
	_items.clear()
	inventory_changed.emit()


# Inventory Transfer

enum TransferResult {
	SUCCESS,
	INSUFFICIENT_ITEMS,
	NO_CAPACITY,
	INVALID_AMOUNT,
	SAME_INVENTORY,
}

static func transfer(
	from: Inventory,
	to: Inventory,
	item_id: String,
	amount: int = 1
) -> Dictionary:
	if from == to:
		return { "result": TransferResult.SAME_INVENTORY, "amount": 0 }
	if amount <= 0:
		return { "result": TransferResult.INVALID_AMOUNT, "amount": 0 }
	if not from.has_item(item_id, amount):
		return { "result": TransferResult.INSUFFICIENT_ITEMS, "amount": 0 }

	var added := to.add_item(item_id, amount)
	if added <= 0:
		return { "result": TransferResult.NO_CAPACITY, "amount": 0 }

	from.remove_item(item_id, added)
	return { "result": TransferResult.SUCCESS, "amount": added }


static func transfer_partial(
	from: Inventory,
	to: Inventory,
	item_id: String,
	amount: int = 1
) -> Dictionary:
	if from == to:
		return { "result": TransferResult.SAME_INVENTORY, "amount": 0 }
	if amount <= 0:
		return { "result": TransferResult.INVALID_AMOUNT, "amount": 0 }

	var available := from.get_amount(item_id)
	if available <= 0:
		return { "result": TransferResult.INSUFFICIENT_ITEMS, "amount": 0 }

	var added := to.add_item(item_id, mini(amount, available))
	if added <= 0:
		return { "result": TransferResult.NO_CAPACITY, "amount": 0 }

	from.remove_item(item_id, added)
	return { "result": TransferResult.SUCCESS, "amount": added }


## Tries to transfert a maximum amount of item from "from" to "to".
static func transfer_all(from: Inventory, to: Inventory) -> Dictionary:
	if from == to:
		return {}
	var transferred := {}
	for item_id in from.get_all_items():
		var added := to.add_item(item_id, from.get_amount(item_id))
		if added > 0:
			from.remove_item(item_id, added)
			transferred[item_id] = added
	return transferred
