# Porting and Reference Notes

This project is a MoonBit reimplementation inspired by local reference projects under `Ref-code/`. No source file from those projects was copied into `espviz`.

## Main Reference

- Project: `PyPointChargePotentialSolver`
- Local path: `Ref-code/Potential_solver-master`
- Upstream link: not provided in the local reference package
- License: GNU GPL v3
- Files inspected: `README.rst`, `electrostatic_potential_solver.py`, `gaussians_to_grid.pyx`, and `examples/nacl_example.py`
- Reference scope: problem framing, input concepts, grid output, slice visualization workflow

The GPL reference performs a periodic-boundary FFT Poisson solve over a 3D grid after collocating Gaussian charge distributions. `espviz` does not port that implementation. Instead, it implements a direct point-charge Coulomb evaluator for 2D slices:

```text
phi(point) = k * sum(q_i / r_i)
```

Sampling at a point charge is singular. `espviz` rejects sample points inside `minimum_distance` instead of smoothing or clipping the physics. This avoids copying GPL implementation structure and keeps the first MoonBit version dependency-free.

## Other References Considered

- `Ref-code/multipoles-master`
  - Upstream link: https://github.com/maroba/multipoles
  - License: MIT
  - Reference scope: multipole terminology and point-charge examples only
- `Ref-code/resp-master`
  - Upstream link: https://github.com/cdsgroup/resp
  - License: BSD-3-Clause
  - Reference scope: RESP/ESP fitting context only
- `Ref-code/ESP_DNN-master`
  - Upstream link: https://github.com/AstexUK/esp-surface-generator
  - License: Apache-2.0
  - Reference scope: electrostatic potential as a molecular ML target only

## Compatibility Differences

- `espviz` samples a 2D plane directly; it does not build a 3D charge grid.
- `espviz` has no periodic boundary conditions.
- `espviz` does not solve Poisson's equation with FFT.
- `espviz` accepts atoms as MoonBit values, not NumPy arrays or molecular file formats.
- Output formats are dependency-free text formats: SVG, PPM, and CSV.

## Planned Migration Path

1. Add a small parser for `.xyzq` files: `Element x y z charge`.
2. Add optional 3D grid generation and trilinear slicing.
3. Add periodic-boundary modes after MoonBit numerical and FFT ecosystem support is mature.
4. Add behavior comparisons against small Python reference cases using generated CSV fixtures.
