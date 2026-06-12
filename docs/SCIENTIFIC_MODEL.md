# Scientific Model

`espviz` visualizes the electrostatic potential implied by assigned atomic partial charges. It is a classical atom-centered monopole post-processing tool, not an ab initio quantum-chemistry solver.

## Quantum-Chemistry Reference

The molecular electrostatic potential used in quantum chemistry is normally defined from nuclei and electron density:

```text
V(r) = sum_A Z_A / |r - R_A| - integral rho(r') / |r - r'| dr'
```

In atomic units this expression is in Hartree per unit positive charge. In Angstrom and elementary-charge units, the same Coulomb kernel is multiplied by `14.3996454784255 eV Angstrom / e^2`.

This quantum-chemistry MEP requires nuclear charges `Z_A` and an electron density `rho`, usually from a Hartree-Fock or density-functional calculation. `espviz` does not have electron density, basis functions, orbital coefficients, or a density matrix, and therefore cannot compute an ab initio MEP from first principles.

## Implemented Formula

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
- It does not compute electron density, molecular orbitals, nuclei-electron attraction from first principles, or charge fitting.
- It does not optimize molecular geometry. Input coordinates must already represent the intended molecular structure.
- It does not include exchange-correlation effects, polarization, dielectric screening, periodic images, or Gaussian charge smearing.
- It is singular at point-charge positions. The implementation rejects samples inside `minimum_distance` instead of smoothing or clipping the singularity.

## Input Requirements

- Coordinates must use Angstrom consistently.
- Charges must use elementary-charge units.
- The molecule must contain at least one atom.
- The sampled plane should not pass through atom centers unless those grid points are intentionally excluded with `minimum_distance`.
- Neutrality is not required for an isolated finite point-charge potential, but `is_nearly_neutral` is provided because many molecular charge models are expected to be neutral.

## Visualization Choices

The color scale is a rendering operation only. Negative potential is mapped to red, positive potential is mapped to blue, and values near zero are white. It does not change the computed potential values.

Atom circles in the SVG are projected markers. They help interpret the heatmap but are not part of the electrostatic calculation.

The 3D frontend's molecule presets use common gas-phase geometries to make molecular shape recognizable: for example water is bent, ammonia is trigonal pyramidal, methane is tetrahedral, carbon dioxide is linear, and formaldehyde is trigonal planar at carbon. They are still compact demo inputs, not optimized quantum-chemistry geometries.

The 3D frontend's exterior ESP surface is the continuous boundary of the union of atomic van der Waals spheres, extracted from the signed-distance field `min_i(|r - R_i| - r_vdw_i) = 0`. ESP values are evaluated at the generated surface vertices using the same partial-charge Coulomb formula. This surface is not an electron-density isosurface, solvent-accessible surface, or quantum-chemistry molecular surface.

The slice selector uses literal Cartesian planes in the input coordinate system:

- `x plane`: `x = constant`, with in-plane axes `y` and `z`.
- `y plane`: `y = constant`, with in-plane axes `x` and `z`.
- `z plane`: `z = constant`, with in-plane axes `x` and `y`.
