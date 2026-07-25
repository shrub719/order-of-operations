extends Node

# operator ids
const EQUALITY := 10
const ADDITION := 11
const MULTIPLICATION := 12
const SUBTRACTION := 13
const SWAPIFICATION := 15
const GLYPH_EQUALITY := 16
const GLYPH_SWAPIFICIATION := 17

func get_numerical_neighbours(left, right, up, down):
	var neighbours = []
	if left != null and left.is_number(): neighbours.append(left)
	if right != null and right.is_number(): neighbours.append(right)
	if up != null and up.is_number(): neighbours.append(up)
	if down != null and down.is_number(): neighbours.append(down)
	return neighbours
	
func add(slf, left, right, up, down):
	var numerical_neighbours = get_numerical_neighbours(left, right, up, down)
	if len(numerical_neighbours) < 2: return false

	var sum = 0
	for block in numerical_neighbours:
		sum += block.get_type()
		block.destroy()
	sum = sum % 10

	slf.next_type = sum
	slf.shine()
	return true

func multiply(slf, left, right, up, down):
	var numerical_neighbours = get_numerical_neighbours(left, right, up, down)
	if len(numerical_neighbours) < 2: return false

	var product = 1
	for block in numerical_neighbours:
		product *= block.get_type()
		block.destroy()
	product = product % 10

	slf.next_type = product
	slf.shine()
	return true

func subtract(slf, left, right):
	if left == null or left.is_operator(): return false
	if right == null or right.is_operator(): return false

	var difference = abs(left.get_type() - right.get_type())
	left.destroy()
	right.destroy()
	slf.next_type = difference
	slf.shine()
	return true

func eq(slf, left, right, queue_block_at):
	if left != null and right != null: return false
	if left == null and right == null: return false
	if (left != null and left.is_operator()) or (right != null and right.is_operator()): return false
	var next_type = left.get_type() if left != null else right.get_type()
	
	if left == null:
		queue_block_at.call(slf.get_grid_position() - Vector2(1, 0), next_type)
	elif right == null:
		queue_block_at.call(slf.get_grid_position() + Vector2(1, 0), next_type)
	
	slf.destroy()
	return true

func glyph_eq(slf, left, right, queue_block_at):
	if left != null and right != null: return false
	if left == null and right == null: return false
	if (left != null and left.is_operator()) or (right != null and right.is_operator()): return false
	var next_type = left.get_type() if left != null else right.get_type()
	
	if left == null:
		queue_block_at.call(slf.get_grid_position() - Vector2(1, 0), next_type)
	elif right == null:
		queue_block_at.call(slf.get_grid_position() + Vector2(1, 0), next_type)
	
	return true

func swap(slf, left, right, queue_block_at):
	if left != null and left.is_operator(): return false
	if right != null and right.is_operator(): return false
	if left == null and right == null: return false

	if left == null:
		var next_type = right.get_type()
		queue_block_at.call(slf.get_grid_position() - Vector2(1, 0), next_type)
		right.destroy()
	elif right == null:
		var next_type = left.get_type()
		queue_block_at.call(slf.get_grid_position() + Vector2(1, 0), next_type)
		left.destroy()
	else:
		var left_type = left.get_type()
		var right_type = right.get_type()
		left.destroy()
		right.destroy()
		queue_block_at.call(slf.get_grid_position() - Vector2(1, 0), right_type)
		queue_block_at.call(slf.get_grid_position() + Vector2(1, 0), left_type)

	slf.destroy()
	return true

func glyph_swap(slf, left, right, queue_block_at):
	if left != null and left.is_operator(): return false
	if right != null and right.is_operator(): return false
	if left == null and right == null: return false

	if left == null:
		var next_type = right.get_type()
		queue_block_at.call(slf.get_grid_position() - Vector2(1, 0), next_type)
		right.destroy()
	elif right == null:
		var next_type = left.get_type()
		queue_block_at.call(slf.get_grid_position() + Vector2(1, 0), next_type)
		left.destroy()
	else:
		var left_type = left.get_type()
		var right_type = right.get_type()
		left.destroy()
		right.destroy()
		queue_block_at.call(slf.get_grid_position() - Vector2(1, 0), right_type)
		queue_block_at.call(slf.get_grid_position() + Vector2(1, 0), left_type)

	return true



	
