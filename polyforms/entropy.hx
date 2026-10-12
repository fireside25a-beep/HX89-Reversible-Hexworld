HX87P1
# Entropy chooses one of ten spatial directions from the origin.
CELL 0 0 0 0 0 12 0 0 0
CELL 1 0 0 0 0 1 88 0 0
CELL -1 0 0 0 0 1 88 0 0
CELL 0 1 0 0 0 1 89 0 0
CELL 0 -1 0 0 0 1 89 0 0
CELL 0 0 1 0 0 1 90 0 0
CELL 0 0 -1 0 0 1 90 0 0
CELL 0 0 0 1 0 1 87 0 0
CELL 0 0 0 -1 0 1 87 0 0
CELL 0 0 0 0 1 1 86 0 0
CELL 0 0 0 0 -1 1 86 0 0
# Each branch emits one axis letter, then lands on an explicit HALT cell.
# This keeps sparse-field exits distinguishable from intentional termination.
CELL 2 0 0 0 0 0 0 0 0
CELL -2 0 0 0 0 0 0 0 0
CELL 0 2 0 0 0 0 0 0 0
CELL 0 -2 0 0 0 0 0 0 0
CELL 0 0 2 0 0 0 0 0 0
CELL 0 0 -2 0 0 0 0 0 0
CELL 0 0 0 2 0 0 0 0 0
CELL 0 0 0 -2 0 0 0 0 0
CELL 0 0 0 0 2 0 0 0 0
CELL 0 0 0 0 -2 0 0 0 0
