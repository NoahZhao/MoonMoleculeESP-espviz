# espviz

`espviz` is a MoonBit library and CLI for visualizing a molecular electrostatic-potential slice from assigned atomic partial charges. It is meant for small molecules, teaching demos, and quick inspection of force-field or charge-fitting models without Python, NumPy, or plotting dependencies.

The current implementation evaluates the classical point-charge Coulomb potential on a 2D plane and exports the grid as SVG, PPM, or CSV. The default SVG is a complete visualization with a heatmap, colorbar, numeric range, atom projections, and element labels. Red means negative potential, white is near neutral, and blue means positive potential.

## Project Status

- Main language: MoonBit.
- Core API: molecule atoms, plane sampling, potential grid, CSV/PPM/SVG renderers.
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

Then open `http://127.0.0.1:8080/examples/espviz_3d.html`. The page shows a 3D molecule, an interactive ESP slice plane, atom labels, a continuous van der Waals contour colored by ESP, a colorbar, orbit controls, and toggles for atoms/slice/exterior ESP/rotation. It loads Three.js from a CDN, so the browser needs network access for the first load.

The 3D page also accepts a custom molecule in the editor. Use one atom per line:

```text
Element x y z charge
C 0.000 0.000 0.000 -0.20
O 1.220 0.000 0.000 -0.35
H -0.610 0.940 0.000 0.28
H -0.610 -0.940 0.000 0.27
```

The columns are element symbol, x coordinate, y coordinate, z coordinate, and partial charge. The fourth column is the z coordinate in Angstrom; the fifth column is the charge in elementary-charge units. Blank lines and `#` comments are ignored. The frontend preserves this coordinate system, infers simple bonds from covalent radii for display, redraws the slice, and colors the continuous union of atomic van der Waals contours by electrostatic potential.

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

## Reproduce

```bash
moon check
moon test
moon run cmd/main summary
moon run cmd/main svg > examples/water.svg
```

CI runs the same check/build/test/smoke-test flow in `.github/workflows/ci.yml`.

## Design Notes

The visualizer uses:

```text
phi(point) = 14.3996454784255 * sum(q_i / r_i)
```

Coordinates are Angstrom, charges are elementary-charge units, and the potential unit is eV per unit positive test charge. The model is physically meaningful only outside point-charge singularities. `minimum_distance` defines an excluded radius around atoms; sampling inside that radius raises an error instead of hiding the singularity.

This is not an ab initio quantum-chemistry ESP calculator: it does not solve the electronic Schrodinger equation, does not compute electron density, and does not fit charges. It visualizes the atom-centered monopole approximation implied by charges supplied by the user or by a sample model. See `docs/SCIENTIFIC_MODEL.md` for the scientific assumptions and limits. This is intentionally different from a full periodic FFT Poisson solver; see `docs/PORTING.md` for the reference comparison and migration notes.

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
