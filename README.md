# espviz

`espviz` is a MoonBit library and CLI for visualizing electrostatic-potential slices. The default workflow visualizes assigned atomic partial charges, which is useful for small molecules, teaching demos, and quick inspection of force-field or charge-fitting models without Python, NumPy, or plotting dependencies.

The core also exposes a density-grid MESP API for the quantum-chemistry formula when external nuclei and electron density data are supplied. It evaluates nuclear charge minus electron-density Coulomb integral on a plane, but it does not generate electron density from molecular orbitals.

The CLI demo evaluates the classical point-charge Coulomb potential on a 2D plane and exports the grid as SVG, PPM, or CSV. The default SVG is a complete visualization with a heatmap, colorbar, numeric range, atom projections, and element labels. Red means negative potential, white is near neutral, and blue means positive potential.

## Project Status

- Main language: MoonBit.
- Core API: assigned-charge atoms, quantum nuclei, electron-density grids, plane sampling, potential grids, CSV/PPM/SVG renderers.
- Example: built-in water molecule demo in `cmd/main`.
- Tests: black-box tests cover potential evaluation, neutrality, cancellation, grid validation, renderers, and diverging ESP color scales.
- License: MIT.

Account-bound tasks still have to be completed by the repository owner:

- Publish the repository to GitHub and GitLink.
- Run `moon login` and `moon publish` to publish `noahzhao/espviz` on mooncakes.io.

## Install

Install the MoonBit toolchain first, then run from this repository root:

```bash
moon check
moon build --target native
moon test
```

When published to mooncakes.io, downstream users can add it with:

```bash
moon add noahzhao/espviz
```

## Usage

Render the built-in water molecule as SVG:

```bash
moon run cmd/main svg > examples/water.svg
```

The generated SVG can be opened directly in a browser. It contains the electrostatic-potential heatmap, atom projection markers, element labels, and a colorbar.

Render a portable ASCII PPM image:

```bash
moon run cmd/main ppm > examples/water.ppm
```

Export raw grid samples:

```bash
moon run cmd/main csv > examples/water.csv
```

The CSV columns are grid indices `ix`, `iy`, and potential. Physical coordinates come from the `Plane` definition used to generate the grid.

Print only the grid range:

```bash
moon run cmd/main summary
```

Open the interactive 3D frontend:

```bash
python3 -m http.server 8080
```

Then open `http://127.0.0.1:8080/examples/espviz_3d.html`. The page shows a 3D molecule, an interactive point-charge ESP slice plane, atom labels, a continuous van der Waals contour colored by the same point-charge ESP, a shared colorbar, orbit controls, and toggles for atoms/slice/exterior ESP/rotation. It loads Three.js from a CDN, so the browser needs network access for the first load.

The 3D page also accepts a custom molecule in the editor. Use one atom per line:

```text
Element x y z charge
C 0.000 0.000 0.000 -0.20
O 1.220 0.000 0.000 -0.35
H -0.610 0.940 0.000 0.28
H -0.610 -0.940 0.000 0.27
```

The columns are element symbol, x coordinate, y coordinate, z coordinate, and partial charge. The fourth column is the z coordinate in Angstrom; the fifth column is the charge in elementary-charge units. Blank lines and `#` comments are ignored. The frontend preserves this coordinate system, infers simple bonds from covalent radii for display, redraws the slice, and colors the continuous union of atomic van der Waals contours by the assigned-charge electrostatic potential.

Additional example inputs:

```text
# Ammonia
N 0.0000 0.0000 0.0000 -0.300
H 0.9340 0.0000 -0.3860 0.100
H -0.4670 0.8090 -0.3860 0.100
H -0.4670 -0.8090 -0.3860 0.100

# Carbon dioxide
O -1.1620 0.0000 0.0000 -0.350
C 0.0000 0.0000 0.0000 0.700
O 1.1620 0.0000 0.0000 -0.350

# Sodium chloride
Na -1.1800 0.0000 0.0000 1.000
Cl 1.1800 0.0000 0.0000 -1.000
```

## Minimal API Example

In another package, add `noahzhao/espviz` to `moon.pkg` imports and use it through an alias such as `@espviz`.

```moonbit
let atoms : Array[@espviz.Atom] = [
  @espviz.make_atom("Na", -1.0, 0.0, 0.0, 1.0),
  @espviz.make_atom("Cl", 1.0, 0.0, 0.0, -1.0),
]

let plane = @espviz.Plane::{
  axis: @espviz.Axis::Z,
  position: 0.0,
  min_a: -3.0,
  max_a: 3.0,
  min_b: -3.0,
  max_b: 3.0,
  width: 96,
  height: 96,
  minimum_distance: 0.001,
}

try @espviz.compute_plane(atoms, plane) catch {
  _ => println("failed to compute potential grid")
} noraise {
  grid => println(@espviz.to_svg(grid))
}
```

For rigorous quantum-chemistry MESP post-processing, supply nuclei and an electron-density grid from an upstream Hartree-Fock or DFT calculation:

```moonbit
let nuclei : Array[@espviz.Nucleus] = [
  @espviz.make_nucleus("H", 0.0, 0.0, 0.0, 1),
]

let densities = FixedArray::make(1, 1.0) // e / Angstrom^3
let density_grid = @espviz.ElectronDensityGrid::{
  origin: @espviz.make_vec3(0.0, 0.0, 0.0),
  spacing: @espviz.make_vec3(1.0, 1.0, 1.0),
  nx: 1,
  ny: 1,
  nz: 1,
  densities_e_per_angstrom3: densities,
}

let potential = @espviz.mesp_at(
  nuclei,
  density_grid,
  @espviz.make_vec3(2.0, 0.0, 0.0),
  minimum_nuclear_distance=0.0,
)
```

## Reproduce

```bash
moon check
moon test
moon run cmd/main summary
moon run cmd/main svg > examples/water.svg
```

CI runs the same check/build/test/smoke-test flow in `.github/workflows/ci.yml`.

## Design Notes

The assigned-charge visualizer uses:

```text
phi(point) = 14.3996454784255 * sum(q_i / r_i)
```

Coordinates are Angstrom, charges are elementary-charge units, and the potential unit is eV per unit positive test charge. The model is physically meaningful only outside point-charge singularities. `minimum_distance` defines an excluded radius around atoms; sampling inside that radius raises an error instead of hiding the singularity.

The rigorous MESP formula is:

```text
V(r) = k * [ sum_A Z_A / |r - R_A| - integral rho(r') / |r - r'| dr' ]
```

`mesp_at` evaluates the integral by direct quadrature over a supplied density grid. True surface MESP maps should use an electron-density isosurface, commonly `rho = 0.001 a.u.` or `0.002 a.u.`; the interactive 3D page currently shows a van der Waals union surface for the assigned-charge model, not that quantum-chemistry isosurface. See `docs/SCIENTIFIC_MODEL.md` for the scientific assumptions and limits.

## Common Pitfalls

- Do not place the sampled plane directly through atom centers unless `minimum_distance` is large enough to exclude those grid points.
- Keep grid sizes modest for CLI use. Runtime is `O(width * height * atoms)`.
- Use partial charges from a force field, RESP/ESP fit, Mulliken/NPA analysis, or another upstream chemistry workflow. The built-in water charges are only a demo.

## Release Checklist

1. Set the final module name in `moon.mod.json`.
2. Confirm `README.md` and `LICENSE` are included.
3. Run `moon check`, `moon build --target native`, and `moon test`.
4. Push the same commit history to GitHub and GitLink.
5. Run `moon login`, then `moon publish`.
