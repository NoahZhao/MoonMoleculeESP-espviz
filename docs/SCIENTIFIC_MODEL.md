# Scientific Model

`espviz` has two explicitly separated electrostatic models:

- Assigned-charge visualization: the original classical atom-centered point-charge approximation.
- Density-grid MESP evaluation: a post-processing API that evaluates the quantum-chemistry electrostatic-potential formula when nuclei and an external electron-density grid are supplied.

It is still not a Hartree-Fock or DFT solver: it does not optimize geometries, compute orbitals, build density matrices, fit charges, or derive electron densities from coordinates.

## Quantum-Chemistry Reference

The molecular electrostatic potential used in quantum chemistry is normally defined from nuclei and electron density:

```text
V(r) = sum_A Z_A / |r - R_A| - integral rho(r') / |r - r'| dr'
```

In atomic units this expression is in Hartree per unit positive charge. In Angstrom and elementary-charge units, `espviz` multiplies the Coulomb kernel by `14.3996454784255 eV Angstrom / e^2`. `rho(r')` is a positive electron number density; the minus sign is the electron charge contribution.

This quantum-chemistry MEP requires nuclear charges `Z_A` and an electron density `rho`, usually from a Hartree-Fock or density-functional calculation. The MoonBit core can integrate a supplied density grid with `mesp_at` and `compute_mesp_plane`; it cannot produce that density grid from first principles. The input audit requires each nucleus element symbol to match its integer nuclear charge, so `O` must have `Z_A = 8`, `C` must have `Z_A = 6`, and so on.

## Implemented Formulas

### Density-grid MESP

For a sample point `r`, `mesp_at` evaluates:

```text
V(r) = k_e * [ sum_A Z_A / |r - R_A|
               - sum_g rho_g * deltaV_g / |r - r_g| ]
```

where:

- `Z_A` is the integer nuclear charge.
- `rho_g` is electron density in `e / Angstrom^3`.
- `deltaV_g` is the density-grid cell volume in `Angstrom^3`.
- Coordinates are Angstrom and the result is `eV/e`.

This is a direct quadrature of the accepted MESP expression over the supplied density samples. Accuracy is controlled by the quality, extent, and spacing of the upstream density grid. Samples exactly on a density-grid point use a finite same-cell spherical average for that cell contribution; samples on or too close to a nucleus are rejected because the nuclear term diverges.

### Assigned point charges

For a sample point `r`, `espviz` evaluates the standard partial-charge, atom-centered monopole approximation:

```text
Phi(r) = k_e * sum_i q_i / |r - R_i|
```

where:

- `R_i` is atom `i` position in Angstrom.
- `q_i` is atom `i` charge in elementary-charge units.
- `k_e = 14.3996454784255 eV Angstrom / e^2`.
- The reported potential is `eV/e`, numerically equivalent to volts for a unit positive test charge.

This approximation replaces the full nuclear-plus-electronic charge distribution by fitted or assigned atom-centered point charges. It can reproduce broad ESP trends outside the molecule when the charges came from a suitable force field or ESP/RESP fitting workflow, but it is not mathematically equivalent to the quantum-chemistry MEP near nuclei, inside the van der Waals envelope, or for anisotropic charge distributions such as lone pairs and pi systems.

## Physical Boundaries

- The model is valid for visualizing a potential from already assigned point charges, such as force-field, RESP/ESP-fit, Mulliken, or NPA charges.
- The density-grid MESP API is valid only when the electron density came from an upstream quantum-chemistry calculation and uses consistent units.
- It does not compute molecular orbitals, nuclei-electron attraction integrals over basis functions, exchange-correlation effects, or charge fitting.
- It does not optimize molecular geometry. Input coordinates must already represent the intended molecular structure.
- It does not include dielectric screening, periodic images, or Gaussian charge smearing unless those effects are already present in the supplied density or charges.
- It is singular at point-charge positions. The implementation rejects samples inside `minimum_distance` instead of smoothing or clipping the singularity.

## Input Requirements

- Coordinates must use Angstrom consistently.
- Charges must use elementary-charge units.
- Nuclei for `mesp_at` must use element symbols and matching integer atomic numbers, not partial charges.
- Density-grid values must be finite, non-negative electron number densities in `e / Angstrom^3`. Use `density_au_to_e_per_angstrom3` for densities stored in atomic units.
- Coordinates, spacing, distances, charges, and densities must be finite numbers; `NaN` and infinities are rejected.
- The molecule must contain at least one atom.
- The sampled plane should not pass through atom centers unless those grid points are intentionally excluded with `minimum_distance`.
- Neutrality is not required for an isolated finite point-charge potential, but `is_nearly_neutral` is provided because many molecular charge models are expected to be neutral.
- For density-grid MESP, `total_electrons`, `total_nuclear_charge`, `net_charge_from_density`, and `is_density_nearly_neutral` are provided so callers can audit whether supplied density integrates to the expected electron count.

## Molecular Surface

The common quantum-chemistry MESP surface is an electron-density isosurface, usually `rho = 0.001 a.u.` and sometimes `0.002 a.u.`. `espviz` exposes `STANDARD_MESP_SURFACE_DENSITY_AU` and `ALTERNATE_MESP_SURFACE_DENSITY_AU` constants plus unit conversion helpers so callers can build such surfaces from an external density grid.

The current CLI renders 2D planes, not surfaces. The 3D frontend's exterior surface is the continuous boundary of the union of atomic van der Waals spheres, extracted from `min_i(|r - R_i| - r_vdw_i) = 0`. That frontend surface is useful for interactive inspection of assigned point-charge models, but it is not the 0.001 a.u. electron-density isosurface used for rigorous MESP surface maps.

## Visualization Choices

The color scale is a rendering operation only. Negative potential is mapped to red, positive potential is mapped to blue, and values near zero are white. It does not change the computed potential values. For comparing different molecules or different surfaces, use a fixed symmetric color scale through `fixed_symmetric_color_scale`; per-grid auto-scaling can make unlike numerical ranges look visually similar.

Atom circles in the SVG are projected markers. They help interpret the heatmap but are not part of the electrostatic calculation.

The 3D frontend's molecule presets use common gas-phase geometries to make molecular shape recognizable: for example water is bent, ammonia is trigonal pyramidal, methane is tetrahedral, carbon dioxide is linear, and formaldehyde is trigonal planar at carbon. They are still compact demo inputs, not optimized quantum-chemistry geometries.

The 3D frontend uses one shared zero-centered color scale for its slice and van der Waals contour so the legend corresponds to both colored objects.

The slice selector uses literal Cartesian planes in the input coordinate system:

- `x plane`: `x = constant`, with in-plane axes `y` and `z`.
- `y plane`: `y = constant`, with in-plane axes `x` and `z`.
- `z plane`: `z = constant`, with in-plane axes `x` and `y`.
