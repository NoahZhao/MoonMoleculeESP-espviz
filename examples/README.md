# Examples

Generate example artifacts from the repository root:

```bash
moon run cmd/main svg > examples/water.svg
moon run cmd/main ppm > examples/water.ppm
moon run cmd/main csv > examples/water.csv
```

`water.svg` can be opened directly in a browser. It includes a heatmap, atom projections, labels, and a colorbar. `water.ppm` is a plain-text portable pixmap, and `water.csv` contains `ix,iy,potential` grid-index samples for plotting in external tools.

## 3D Frontend

Run a local static server from the repository root:

```bash
python3 -m http.server 8080
```

Open:

```text
http://127.0.0.1:8080/examples/espviz_3d.html
```

The 3D page uses Three.js from a CDN and displays the same classical point-charge ESP model as an interactive slice through a molecule. It also draws a continuous van der Waals contour surface colored by the same assigned-charge ESP, supports orbit controls, and includes toggles for atoms, slice, exterior ESP, and rotation. The slice and contour share one zero-centered colorbar. This page is an assigned-charge demo, not an ab initio MESP viewer.

Use the custom molecule editor with one atom per line:

```text
Element x y z charge
N 0.000 0.000 0.000 -0.30
H 0.934 0.000 -0.386 0.10
H -0.467 0.809 -0.386 0.10
H -0.467 -0.809 -0.386 0.10
```

The columns are element symbol, x coordinate, y coordinate, z coordinate, and assigned partial charge. The fourth column is the z coordinate in Angstrom; the fifth column is the charge in elementary-charge units. The page preserves the input coordinate system, infers simple display bonds, redraws the ESP slice, and recomputes the continuous contour surface. This is not the quantum-chemistry 0.001 a.u. electron-density MESP surface.

Other presets are available in the page: water, ammonia, methane, carbon dioxide, sodium chloride, and formaldehyde. They are compact neutral demonstration charge models and should not be treated as validated quantum-chemistry reference data.
