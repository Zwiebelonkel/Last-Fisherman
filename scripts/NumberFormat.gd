extends RefCounted
## Shared display formatting. Gameplay and save data keep their full numeric values.

const SUFFIXES := ["", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"]


static func compact(value: float, small_decimals: int = 0) -> String:
	if not is_finite(value):
		return str(value)
	if absf(value) < 1000.0:
		return ("%.*f" % [small_decimals, value]) if small_decimals > 0 else str(int(value))

	var scaled := value
	var tier := 0
	while absf(scaled) >= 1000.0 and tier < SUFFIXES.size() - 1:
		scaled /= 1000.0
		tier += 1
	# Rounding at a boundary should show 1M, rather than 1000K.
	if absf(snappedf(scaled, 0.01)) >= 1000.0 and tier < SUFFIXES.size() - 1:
		scaled /= 1000.0
		tier += 1
	var digits := "%.2f" % scaled
	while digits.ends_with("0"):
		digits = digits.left(-1)
	if digits.ends_with("."):
		digits = digits.left(-1)
	return digits + SUFFIXES[tier]
