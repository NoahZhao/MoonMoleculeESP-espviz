/// Coulomb constant in eV Angstrom / e^2.
///
/// Converts q/r from e/Angstrom into eV/e when charges are elementary-charge
/// units and coordinates are Angstrom.
pub const COULOMB_EV_ANGSTROM : Double = 14.3996454784255

/// Bohr radius in Angstrom, used to convert electron densities between
/// atomic units and e/Angstrom^3.
pub const BOHR_RADIUS_ANGSTROM : Double = 0.529177210903

/// One Hartree per unit positive charge in eV/e.
pub const HARTREE_EV : Double = 27.211386245988

/// Common electron-density isovalue for quantum-chemistry MESP surfaces.
///
/// The 0.001 a.u. isodensity surface is a standard molecular surface used in
/// electrostatic-potential surface maps. 0.002 a.u. is also common.
pub const STANDARD_MESP_SURFACE_DENSITY_AU : Double = 0.001

pub const ALTERNATE_MESP_SURFACE_DENSITY_AU : Double = 0.002

const EPSILON : Double = 0.000000000001
const PI : Double = 3.141592653589793

pub(all) struct Vec3 {
  x : Double
  y : Double
  z : Double
} derive(Debug)

pub(all) struct Atom {
  element : String
  position : Vec3
  charge : Double
} derive(Debug)

/// A nucleus for the quantum-chemistry electrostatic-potential expression.
///
/// `atomic_number` is the nuclear charge Z_A, not an assigned partial charge.
pub(all) struct Nucleus {
  element : String
  position : Vec3
  atomic_number : Int
} derive(Debug)

/// Uniform orthogonal electron-density quadrature grid.
///
/// Densities are positive electron number densities in e/Angstrom^3. The
/// samples are interpreted as quadrature points with weight
/// `spacing.x * spacing.y * spacing.z`.
pub(all) struct ElectronDensityGrid {
  origin : Vec3
  spacing : Vec3
  nx : Int
  ny : Int
  nz : Int
  densities_e_per_angstrom3 : FixedArray[Double]
} derive(Debug)

pub(all) enum Axis {
  X
  Y
  Z
} derive(Debug, Eq)

pub(all) struct Plane {
  axis : Axis
  position : Double
  min_a : Double
  max_a : Double
  min_b : Double
  max_b : Double
  width : Int
  height : Int
  minimum_distance : Double
} derive(Debug)

pub(all) struct Grid2D {
  width : Int
  height : Int
  min_value : Double
  max_value : Double
  values : FixedArray[Double]
} derive(Debug)

pub(all) struct Rgb {
  r : Int
  g : Int
  b : Int
} derive(Debug, Eq)

pub(all) struct PotentialColorScale {
  negative_limit : Double
  positive_limit : Double
} derive(Debug)

pub(all) suberror ElectrostaticError {
  EmptyMolecule
  InvalidChemicalData(String)
  InvalidGrid(String)
  InvalidMinimumDistance(Double)
  SingularPoint(String)
} derive(Debug)

pub fn make_vec3(x : Double, y : Double, z : Double) -> Vec3 {
  { x, y, z }
}

pub fn make_atom(
  element : String,
  x : Double,
  y : Double,
  z : Double,
  charge : Double
) -> Atom {
  { element, position: { x, y, z }, charge }
}

pub fn make_nucleus(
  element : String,
  x : Double,
  y : Double,
  z : Double,
  atomic_number : Int
) -> Nucleus {
  { element, position: { x, y, z }, atomic_number }
}

/// Atomic number for canonical element symbols.
///
/// Returns 0 for unsupported or non-canonical symbols. MESP nuclei must use a
/// symbol whose atomic number matches `Nucleus.atomic_number`.
pub fn atomic_number_for_element(element : String) -> Int {
  if element == "H" {
    1
  } else if element == "He" {
    2
  } else if element == "Li" {
    3
  } else if element == "Be" {
    4
  } else if element == "B" {
    5
  } else if element == "C" {
    6
  } else if element == "N" {
    7
  } else if element == "O" {
    8
  } else if element == "F" {
    9
  } else if element == "Ne" {
    10
  } else if element == "Na" {
    11
  } else if element == "Mg" {
    12
  } else if element == "Al" {
    13
  } else if element == "Si" {
    14
  } else if element == "P" {
    15
  } else if element == "S" {
    16
  } else if element == "Cl" {
    17
  } else if element == "Ar" {
    18
  } else if element == "K" {
    19
  } else if element == "Ca" {
    20
  } else if element == "Sc" {
    21
  } else if element == "Ti" {
    22
  } else if element == "V" {
    23
  } else if element == "Cr" {
    24
  } else if element == "Mn" {
    25
  } else if element == "Fe" {
    26
  } else if element == "Co" {
    27
  } else if element == "Ni" {
    28
  } else if element == "Cu" {
    29
  } else if element == "Zn" {
    30
  } else if element == "Ga" {
    31
  } else if element == "Ge" {
    32
  } else if element == "As" {
    33
  } else if element == "Se" {
    34
  } else if element == "Br" {
    35
  } else if element == "Kr" {
    36
  } else if element == "Rb" {
    37
  } else if element == "Sr" {
    38
  } else if element == "Y" {
    39
  } else if element == "Zr" {
    40
  } else if element == "Nb" {
    41
  } else if element == "Mo" {
    42
  } else if element == "Tc" {
    43
  } else if element == "Ru" {
    44
  } else if element == "Rh" {
    45
  } else if element == "Pd" {
    46
  } else if element == "Ag" {
    47
  } else if element == "Cd" {
    48
  } else if element == "In" {
    49
  } else if element == "Sn" {
    50
  } else if element == "Sb" {
    51
  } else if element == "Te" {
    52
  } else if element == "I" {
    53
  } else if element == "Xe" {
    54
  } else if element == "Cs" {
    55
  } else if element == "Ba" {
    56
  } else if element == "La" {
    57
  } else if element == "Ce" {
    58
  } else if element == "Pr" {
    59
  } else if element == "Nd" {
    60
  } else if element == "Pm" {
    61
  } else if element == "Sm" {
    62
  } else if element == "Eu" {
    63
  } else if element == "Gd" {
    64
  } else if element == "Tb" {
    65
  } else if element == "Dy" {
    66
  } else if element == "Ho" {
    67
  } else if element == "Er" {
    68
  } else if element == "Tm" {
    69
  } else if element == "Yb" {
    70
  } else if element == "Lu" {
    71
  } else if element == "Hf" {
    72
  } else if element == "Ta" {
    73
  } else if element == "W" {
    74
  } else if element == "Re" {
    75
  } else if element == "Os" {
    76
  } else if element == "Ir" {
    77
  } else if element == "Pt" {
    78
  } else if element == "Au" {
    79
  } else if element == "Hg" {
    80
  } else if element == "Tl" {
    81
  } else if element == "Pb" {
    82
  } else if element == "Bi" {
    83
  } else if element == "Po" {
    84
  } else if element == "At" {
    85
  } else if element == "Rn" {
    86
  } else if element == "Fr" {
    87
  } else if element == "Ra" {
    88
  } else if element == "Ac" {
    89
  } else if element == "Th" {
    90
  } else if element == "Pa" {
    91
  } else if element == "U" {
    92
  } else if element == "Np" {
    93
  } else if element == "Pu" {
    94
  } else if element == "Am" {
    95
  } else if element == "Cm" {
    96
  } else if element == "Bk" {
    97
  } else if element == "Cf" {
    98
  } else if element == "Es" {
    99
  } else if element == "Fm" {
    100
  } else if element == "Md" {
    101
  } else if element == "No" {
    102
  } else if element == "Lr" {
    103
  } else if element == "Rf" {
    104
  } else if element == "Db" {
    105
  } else if element == "Sg" {
    106
  } else if element == "Bh" {
    107
  } else if element == "Hs" {
    108
  } else if element == "Mt" {
    109
  } else if element == "Ds" {
    110
  } else if element == "Rg" {
    111
  } else if element == "Cn" {
    112
  } else if element == "Nh" {
    113
  } else if element == "Fl" {
    114
  } else if element == "Mc" {
    115
  } else if element == "Lv" {
    116
  } else if element == "Ts" {
    117
  } else if element == "Og" {
    118
  } else {
    0
  }
}

/// A compact water molecule with approximate partial charges.
pub fn sample_water() -> Array[Atom] {
  [
    make_atom("O", 0.0000, 0.0000, 0.0000, -0.8340),
    make_atom("H", 0.9572, 0.0000, 0.0000, 0.4170),
    make_atom("H", -0.2400, 0.9266, 0.0000, 0.4170),
  ]
}

/// Default xy slice for the water demo.
pub fn standard_water_plane() -> Plane {
  {
    axis: Z,
    position: 1.4,
    min_a: -2.0,
    max_a: 2.0,
    min_b: -2.0,
    max_b: 2.0,
    width: 80,
    height: 80,
    minimum_distance: 0.08,
  }
}

pub fn total_charge(atoms : Array[Atom]) -> Double {
  let mut sum = 0.0
  for atom in atoms {
    sum += atom.charge
  }
  sum
}

pub fn is_nearly_neutral(
  atoms : Array[Atom],
  tolerance? : Double = 0.000001
) -> Bool {
  abs_double(total_charge(atoms)) <= tolerance
}

/// Strictly audit assigned-charge input data before point-charge ESP use.
///
/// This checks chemical element symbols, finite Angstrom coordinates, and finite
/// assigned charges. It does not require molecular neutrality because ions are
/// valid electrostatic-potential inputs.
pub fn audit_assigned_charge_atoms(
  atoms : Array[Atom]
) -> Unit raise ElectrostaticError {
  guard atoms.length() > 0 else { raise EmptyMolecule }
  for atom in atoms {
    validate_element_symbol(atom.element)
    validate_vec3(atom.position, "atom position")
    guard is_finite_double(atom.charge) else {
      raise InvalidChemicalData("assigned atom charge must be finite")
    }
  }
}

/// Strictly audit nuclei for quantum-chemistry MESP input.
///
/// Each nucleus must use a real element symbol and the matching integer nuclear
/// charge Z. For example, oxygen must be `O` with `atomic_number = 8`.
pub fn audit_nuclei(nuclei : Array[Nucleus]) -> Unit raise ElectrostaticError {
  guard nuclei.length() > 0 else { raise EmptyMolecule }
  for nucleus in nuclei {
    validate_vec3(nucleus.position, "nucleus position")
    let expected = atomic_number_for_element(nucleus.element)
    guard expected > 0 else {
      raise InvalidChemicalData("unsupported element symbol: \{nucleus.element}")
    }
    guard nucleus.atomic_number == expected else {
      raise InvalidChemicalData(
        "nucleus \{nucleus.element} has atomic_number \{nucleus.atomic_number}, expected \{expected}",
      )
    }
  }
}

pub fn audit_density_grid(grid : ElectronDensityGrid) -> Unit raise ElectrostaticError {
  validate_density_grid(grid)
}

pub fn audit_mesp_inputs(
  nuclei : Array[Nucleus],
  density_grid : ElectronDensityGrid
) -> Unit raise ElectrostaticError {
  audit_nuclei(nuclei)
  validate_density_grid(density_grid)
}

pub fn total_nuclear_charge(nuclei : Array[Nucleus]) -> Int raise ElectrostaticError {
  audit_nuclei(nuclei)
  let mut sum = 0
  for nucleus in nuclei {
    sum += nucleus.atomic_number
  }
  sum
}

pub fn net_charge_from_density(
  nuclei : Array[Nucleus],
  density_grid : ElectronDensityGrid
) -> Double raise ElectrostaticError {
  total_nuclear_charge(nuclei).to_double() - total_electrons(density_grid)
}

pub fn is_density_nearly_neutral(
  nuclei : Array[Nucleus],
  density_grid : ElectronDensityGrid,
  tolerance? : Double = 0.000001
) -> Bool raise ElectrostaticError {
  abs_double(net_charge_from_density(nuclei, density_grid)) <= tolerance
}

pub fn density_au_to_e_per_angstrom3(density_au : Double) -> Double {
  density_au / bohr_volume_angstrom3()
}

pub fn density_e_per_angstrom3_to_au(density_e_per_angstrom3 : Double) -> Double {
  density_e_per_angstrom3 * bohr_volume_angstrom3()
}

pub fn standard_mesp_surface_density_e_per_angstrom3() -> Double {
  density_au_to_e_per_angstrom3(STANDARD_MESP_SURFACE_DENSITY_AU)
}

/// Quantum-chemistry molecular electrostatic potential from nuclei and density.
///
/// Evaluates, in eV/e,
///
///   V(r) = k [ sum_A Z_A / |r - R_A|
///              - integral rho(r') / |r - r'| dr' ]
///
/// using direct quadrature over the supplied density samples. Coordinates are
/// Angstrom, `rho` is e/Angstrom^3, and `Z_A` is the integer nuclear charge.
pub fn mesp_at(
  nuclei : Array[Nucleus],
  density_grid : ElectronDensityGrid,
  point : Vec3,
  minimum_nuclear_distance? : Double = 0.000001
) -> Double raise ElectrostaticError {
  audit_mesp_inputs(nuclei, density_grid)
  validate_vec3(point, "sample point")
  guard minimum_nuclear_distance >= 0.0 && is_finite_double(minimum_nuclear_distance) else {
    raise InvalidMinimumDistance(minimum_nuclear_distance)
  }
  nuclear_potential_at_unchecked(nuclei, point, minimum_nuclear_distance) -
  electronic_potential_from_density_grid_at_unchecked(density_grid, point)
}

pub fn nuclear_potential_at(
  nuclei : Array[Nucleus],
  point : Vec3,
  minimum_distance? : Double = 0.000001
) -> Double raise ElectrostaticError {
  audit_nuclei(nuclei)
  validate_vec3(point, "sample point")
  guard minimum_distance >= 0.0 && is_finite_double(minimum_distance) else {
    raise InvalidMinimumDistance(minimum_distance)
  }
  nuclear_potential_at_unchecked(nuclei, point, minimum_distance)
}

pub fn electronic_potential_from_density_grid_at(
  grid : ElectronDensityGrid,
  point : Vec3
) -> Double raise ElectrostaticError {
  validate_density_grid(grid)
  validate_vec3(point, "sample point")
  electronic_potential_from_density_grid_at_unchecked(grid, point)
}

fn electronic_potential_from_density_grid_at_unchecked(
  grid : ElectronDensityGrid,
  point : Vec3
) -> Double raise ElectrostaticError {
  let cell_volume = grid.cell_volume()
  let mut potential = 0.0
  for iz in 0..<grid.nz {
    for iy in 0..<grid.ny {
      for ix in 0..<grid.nx {
        let density = grid.densities_e_per_angstrom3[grid.density_index(ix, iy, iz)]
        if density > EPSILON {
          let sample_point = grid.sample_position(ix, iy, iz)
          let r = distance(point, sample_point)
          let kernel = if r <= EPSILON {
            finite_self_cell_kernel(cell_volume)
          } else {
            1.0 / r
          }
          potential += COULOMB_EV_ANGSTROM * density * cell_volume * kernel
        }
      }
    }
  }
  potential
}

pub fn total_electrons(grid : ElectronDensityGrid) -> Double raise ElectrostaticError {
  validate_density_grid(grid)
  let cell_volume = grid.cell_volume()
  let mut sum = 0.0
  for i in 0..<grid.densities_e_per_angstrom3.length() {
    sum += grid.densities_e_per_angstrom3[i] * cell_volume
  }
  sum
}

pub fn ElectronDensityGrid::density_index(
  self : ElectronDensityGrid,
  ix : Int,
  iy : Int,
  iz : Int
) -> Int raise ElectrostaticError {
  guard ix >= 0 && ix < self.nx && iy >= 0 && iy < self.ny && iz >= 0 && iz < self.nz else {
    raise InvalidGrid("density-grid coordinate is out of bounds")
  }
  (iz * self.ny + iy) * self.nx + ix
}

pub fn ElectronDensityGrid::cell_volume(self : ElectronDensityGrid) -> Double {
  self.spacing.x * self.spacing.y * self.spacing.z
}

pub fn ElectronDensityGrid::sample_position(
  self : ElectronDensityGrid,
  ix : Int,
  iy : Int,
  iz : Int
) -> Vec3 {
  {
    x: self.origin.x + ix.to_double() * self.spacing.x,
    y: self.origin.y + iy.to_double() * self.spacing.y,
    z: self.origin.z + iz.to_double() * self.spacing.z,
  }
}

pub fn potential_at(
  atoms : Array[Atom],
  point : Vec3,
  minimum_distance? : Double = 0.000001
) -> Double raise ElectrostaticError {
  audit_assigned_charge_atoms(atoms)
  validate_vec3(point, "sample point")
  guard minimum_distance >= 0.0 && is_finite_double(minimum_distance) else {
    raise InvalidMinimumDistance(minimum_distance)
  }
  point_charge_potential_at_unchecked(atoms, point, minimum_distance)
}

pub fn compute_plane(
  atoms : Array[Atom],
  plane : Plane
) -> Grid2D raise ElectrostaticError {
  audit_assigned_charge_atoms(atoms)
  validate_plane(plane)
  let size = plane.width * plane.height
  let values = FixedArray::make(size, 0.0)
  let mut min_value = 1.0e300
  let mut max_value = -1.0e300
  for iy in 0..<plane.height {
    for ix in 0..<plane.width {
      let point = plane_point(plane, ix, iy)
      let value = point_charge_potential_at_unchecked(atoms, point, plane.minimum_distance)
      values[iy * plane.width + ix] = value
      if value < min_value {
        min_value = value
      }
      if value > max_value {
        max_value = value
      }
    }
  }
  { width: plane.width, height: plane.height, min_value, max_value, values }
}

pub fn compute_mesp_plane(
  nuclei : Array[Nucleus],
  density_grid : ElectronDensityGrid,
  plane : Plane
) -> Grid2D raise ElectrostaticError {
  audit_mesp_inputs(nuclei, density_grid)
  validate_plane(plane)
  let size = plane.width * plane.height
  let values = FixedArray::make(size, 0.0)
  let mut min_value = 1.0e300
  let mut max_value = -1.0e300
  for iy in 0..<plane.height {
    for ix in 0..<plane.width {
      let point = plane_point(plane, ix, iy)
      let value = nuclear_potential_at_unchecked(nuclei, point, plane.minimum_distance) -
        electronic_potential_from_density_grid_at_unchecked(density_grid, point)
      values[iy * plane.width + ix] = value
      if value < min_value {
        min_value = value
      }
      if value > max_value {
        max_value = value
      }
    }
  }
  { width: plane.width, height: plane.height, min_value, max_value, values }
}

pub fn Grid2D::index(self : Grid2D, x : Int, y : Int) -> Int raise ElectrostaticError {
  guard x >= 0 && x < self.width && y >= 0 && y < self.height else {
    raise InvalidGrid("grid coordinate is out of bounds")
  }
  y * self.width + x
}

pub fn Grid2D::get(self : Grid2D, x : Int, y : Int) -> Double raise ElectrostaticError {
  self.values[self.index(x, y)]
}

pub fn to_csv(grid : Grid2D) -> String {
  let builder = StringBuilder::new()
  builder.write_string("ix,iy,potential\n")
  for y in 0..<grid.height {
    for x in 0..<grid.width {
      builder.write_object(x)
      builder.write_string(",")
      builder.write_object(y)
      builder.write_string(",")
      builder.write_object(grid.values[y * grid.width + x])
      builder.write_string("\n")
    }
  }
  builder.to_string()
}

pub fn to_ppm(grid : Grid2D) -> String {
  let builder = StringBuilder::new()
  builder.write_string("P3\n")
  builder.write_string("# generated by noahzhao/espviz\n")
  builder.write_object(grid.width)
  builder.write_string(" ")
  builder.write_object(grid.height)
  builder.write_string("\n255\n")
  for y in 0..<grid.height {
    let source_y = grid.height - 1 - y
    for x in 0..<grid.width {
      let color = color_for(grid.values[source_y * grid.width + x], grid.min_value, grid.max_value)
      builder.write_object(color.r)
      builder.write_string(" ")
      builder.write_object(color.g)
      builder.write_string(" ")
      builder.write_object(color.b)
      builder.write_string(" ")
    }
    builder.write_string("\n")
  }
  builder.to_string()
}

pub fn to_svg(grid : Grid2D) -> String {
  let builder = StringBuilder::new()
  builder.write_string("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 ")
  builder.write_object(grid.width)
  builder.write_string(" ")
  builder.write_object(grid.height)
  builder.write_string("\" shape-rendering=\"crispEdges\">\n")
  builder.write_string("<title>Point-charge electrostatic potential slice</title>\n")
  builder.write_string("<desc>Assigned atom-centered charges: red is negative potential, white is neutral, blue is positive potential.</desc>\n")
  for y in 0..<grid.height {
    let source_y = grid.height - 1 - y
    for x in 0..<grid.width {
      let color = color_for(grid.values[source_y * grid.width + x], grid.min_value, grid.max_value)
      builder.write_string("<rect x=\"")
      builder.write_object(x)
      builder.write_string("\" y=\"")
      builder.write_object(y)
      builder.write_string("\" width=\"1\" height=\"1\" fill=\"rgb(")
      builder.write_object(color.r)
      builder.write_string(",")
      builder.write_object(color.g)
      builder.write_string(",")
      builder.write_object(color.b)
      builder.write_string(")\"/>\n")
    }
  }
  builder.write_string("</svg>\n")
  builder.to_string()
}

pub fn to_visual_svg(grid : Grid2D, plane : Plane, atoms : Array[Atom]) -> String {
  let cell_size = 5.0
  let margin_left = 76.0
  let margin_top = 54.0
  let plot_width = grid.width.to_double() * cell_size
  let plot_height = grid.height.to_double() * cell_size
  let legend_gap = 28.0
  let legend_width = 18.0
  let legend_x = margin_left + plot_width + legend_gap
  let legend_steps = 96
  let total_width = legend_x + legend_width + 92.0
  let total_height = margin_top + plot_height + 70.0
  let builder = StringBuilder::new()

  builder.write_string("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 ")
  builder.write_object(total_width)
  builder.write_string(" ")
  builder.write_object(total_height)
  builder.write_string("\" role=\"img\">\n")
  builder.write_string("<title>Point-charge electrostatic potential</title>\n")
  builder.write_string(
    "<desc>Potential from assigned atom-centered point charges. Red is negative, white is near zero, blue is positive. Circles mark atom projections on the sampled plane.</desc>\n",
  )
  builder.write_string("<rect width=\"100%\" height=\"100%\" fill=\"#f8fafc\"/>\n")
  builder.write_string("<text x=\"")
  builder.write_object(margin_left)
  builder.write_string("\" y=\"28\" font-family=\"Arial, sans-serif\" font-size=\"20\" font-weight=\"700\" fill=\"#111827\">Point-charge ESP slice</text>\n")
  builder.write_string("<text x=\"")
  builder.write_object(margin_left)
  builder.write_string("\" y=\"46\" font-family=\"Arial, sans-serif\" font-size=\"12\" fill=\"#4b5563\">")
  builder.write_string(axis_name(plane.axis))
  builder.write_string(" = ")
  builder.write_object(plane.position)
  builder.write_string(" A, grid ")
  builder.write_object(grid.width)
  builder.write_string(" x ")
  builder.write_object(grid.height)
  builder.write_string(", excluded radius ")
  builder.write_object(plane.minimum_distance)
  builder.write_string(" A</text>\n")

  builder.write_string("<g id=\"potential-heatmap\" shape-rendering=\"crispEdges\">\n")
  for y in 0..<grid.height {
    for x in 0..<grid.width {
      let source_y = grid.height - 1 - y
      let color = color_for(grid.values[source_y * grid.width + x], grid.min_value, grid.max_value)
      builder.write_string("<rect x=\"")
      builder.write_object(margin_left + x.to_double() * cell_size)
      builder.write_string("\" y=\"")
      builder.write_object(margin_top + y.to_double() * cell_size)
      builder.write_string("\" width=\"")
      builder.write_object(cell_size)
      builder.write_string("\" height=\"")
      builder.write_object(cell_size)
      builder.write_string("\" fill=\"")
      builder.write_string(rgb_string(color))
      builder.write_string("\"/>\n")
    }
  }
  builder.write_string("</g>\n")

  builder.write_string("<rect x=\"")
  builder.write_object(margin_left)
  builder.write_string("\" y=\"")
  builder.write_object(margin_top)
  builder.write_string("\" width=\"")
  builder.write_object(plot_width)
  builder.write_string("\" height=\"")
  builder.write_object(plot_height)
  builder.write_string("\" fill=\"none\" stroke=\"#111827\" stroke-width=\"1\"/>\n")

  builder.write_string("<g id=\"atom-projections\" font-family=\"Arial, sans-serif\">\n")
  for atom in atoms {
    let (a, b, distance) = project_atom(plane, atom)
    if in_range(a, plane.min_a, plane.max_a) && in_range(b, plane.min_b, plane.max_b) {
      let cx = margin_left + ratio(a, plane.min_a, plane.max_a) * (plot_width - cell_size)
      let cy = margin_top + (1.0 - ratio(b, plane.min_b, plane.max_b)) * (plot_height - cell_size)
      let radius = 4.0 + abs_double(atom.charge) * 5.0
      let stroke = charge_rgb_string(atom.charge)
      let opacity = if abs_double(distance) <= plane.minimum_distance * 3.0 { 0.95 } else { 0.35 }
      builder.write_string("<circle cx=\"")
      builder.write_object(cx)
      builder.write_string("\" cy=\"")
      builder.write_object(cy)
      builder.write_string("\" r=\"")
      builder.write_object(radius)
      builder.write_string("\" fill=\"#ffffff\" fill-opacity=\"")
      builder.write_object(opacity)
      builder.write_string("\" stroke=\"")
      builder.write_string(stroke)
      builder.write_string("\" stroke-width=\"2\"/>\n")
      builder.write_string("<text x=\"")
      builder.write_object(cx + radius + 2.0)
      builder.write_string("\" y=\"")
      builder.write_object(cy + 4.0)
      builder.write_string("\" font-size=\"11\" font-weight=\"700\" fill=\"#111827\">")
      builder.write_string(atom.element)
      builder.write_string("</text>\n")
    }
  }
  builder.write_string("</g>\n")

  builder.write_string("<g id=\"colorbar\" font-family=\"Arial, sans-serif\" font-size=\"11\" fill=\"#374151\">\n")
  for step in 0..<legend_steps {
    let t = step.to_double() / (legend_steps - 1).to_double()
    let value = grid.max_value - t * (grid.max_value - grid.min_value)
    let color = color_for(value, grid.min_value, grid.max_value)
    let y = margin_top + t * plot_height
    builder.write_string("<rect x=\"")
    builder.write_object(legend_x)
    builder.write_string("\" y=\"")
    builder.write_object(y)
    builder.write_string("\" width=\"")
    builder.write_object(legend_width)
    builder.write_string("\" height=\"")
    builder.write_object(plot_height / legend_steps.to_double() + 0.8)
    builder.write_string("\" fill=\"")
    builder.write_string(rgb_string(color))
    builder.write_string("\"/>\n")
  }
  builder.write_string("<rect x=\"")
  builder.write_object(legend_x)
  builder.write_string("\" y=\"")
  builder.write_object(margin_top)
  builder.write_string("\" width=\"")
  builder.write_object(legend_width)
  builder.write_string("\" height=\"")
  builder.write_object(plot_height)
  builder.write_string("\" fill=\"none\" stroke=\"#111827\" stroke-width=\"1\"/>\n")
  builder.write_string("<text x=\"")
  builder.write_object(legend_x + legend_width + 8.0)
  builder.write_string("\" y=\"")
  builder.write_object(margin_top + 4.0)
  builder.write_string("\">")
  builder.write_object(grid.max_value)
  builder.write_string("</text>\n")
  builder.write_string("<text x=\"")
  builder.write_object(legend_x + legend_width + 8.0)
  builder.write_string("\" y=\"")
  builder.write_object(margin_top + plot_height)
  builder.write_string("\">")
  builder.write_object(grid.min_value)
  builder.write_string("</text>\n")
  builder.write_string("<text x=\"")
  builder.write_object(legend_x)
  builder.write_string("\" y=\"")
  builder.write_object(margin_top + plot_height + 20.0)
  builder.write_string("\" font-weight=\"700\">Potential</text>\n")
  builder.write_string("</g>\n")

  builder.write_string("</svg>\n")
  builder.to_string()
}

pub fn grid_summary(grid : Grid2D) -> String {
  "Grid2D(width=\{grid.width}, height=\{grid.height}, min=\{grid.min_value}, max=\{grid.max_value})"
}

pub fn color_for(value : Double, min_value : Double, max_value : Double) -> Rgb {
  color_for_scale(value, symmetric_color_scale(min_value, max_value))
}

pub fn symmetric_color_scale(min_value : Double, max_value : Double) -> PotentialColorScale {
  let scale = max_double(abs_double(min_value), abs_double(max_value))
  { negative_limit: -scale, positive_limit: scale }
}

pub fn fixed_symmetric_color_scale(limit : Double) -> PotentialColorScale raise ElectrostaticError {
  guard limit > 0.0 && is_finite_double(limit) else {
    raise InvalidGrid("fixed color-scale limit must be positive and finite")
  }
  { negative_limit: -limit, positive_limit: limit }
}

pub fn color_for_scale(value : Double, scale : PotentialColorScale) -> Rgb {
  let negative_limit = abs_double(scale.negative_limit)
  let positive_limit = abs_double(scale.positive_limit)
  if negative_limit <= EPSILON && positive_limit <= EPSILON {
    { r: 255, g: 255, b: 255 }
  } else if value < -EPSILON {
    let c = channel(1.0 - abs_double(value) / max_double(negative_limit, EPSILON))
    { r: 255, g: c, b: c }
  } else {
    let c = channel(1.0 - value / max_double(positive_limit, EPSILON))
    { r: c, g: c, b: 255 }
  }
}

fn validate_plane(plane : Plane) -> Unit raise ElectrostaticError {
  guard plane.width > 0 && plane.height > 0 else {
    raise InvalidGrid("plane width and height must be positive")
  }
  guard is_finite_double(plane.position) && is_finite_double(plane.min_a) &&
    is_finite_double(plane.max_a) && is_finite_double(plane.min_b) &&
    is_finite_double(plane.max_b) else {
    raise InvalidGrid("plane coordinates must be finite Angstrom values")
  }
  guard plane.max_a > plane.min_a && plane.max_b > plane.min_b else {
    raise InvalidGrid("plane ranges must be increasing")
  }
  guard plane.minimum_distance >= 0.0 && is_finite_double(plane.minimum_distance) else {
    raise InvalidMinimumDistance(plane.minimum_distance)
  }
}

fn validate_density_grid(grid : ElectronDensityGrid) -> Unit raise ElectrostaticError {
  validate_vec3(grid.origin, "density-grid origin")
  guard grid.nx > 0 && grid.ny > 0 && grid.nz > 0 else {
    raise InvalidGrid("density-grid dimensions must be positive")
  }
  guard grid.spacing.x > 0.0 && grid.spacing.y > 0.0 && grid.spacing.z > 0.0 &&
    is_finite_double(grid.spacing.x) && is_finite_double(grid.spacing.y) &&
    is_finite_double(grid.spacing.z) else {
    raise InvalidGrid("density-grid spacing must be positive Angstrom values")
  }
  guard grid.densities_e_per_angstrom3.length() == grid.nx * grid.ny * grid.nz else {
    raise InvalidGrid("density-grid data length does not match dimensions")
  }
  for i in 0..<grid.densities_e_per_angstrom3.length() {
    let density = grid.densities_e_per_angstrom3[i]
    guard density >= 0.0 && is_finite_double(density) else {
      raise InvalidGrid("electron density must be finite and non-negative")
    }
  }
}

fn validate_element_symbol(element : String) -> Unit raise ElectrostaticError {
  guard atomic_number_for_element(element) > 0 else {
    raise InvalidChemicalData("unsupported element symbol: \{element}")
  }
}

fn validate_vec3(vec : Vec3, label : String) -> Unit raise ElectrostaticError {
  guard is_finite_double(vec.x) && is_finite_double(vec.y) && is_finite_double(vec.z) else {
    raise InvalidChemicalData("\{label} must contain finite Angstrom coordinates")
  }
}

fn nuclear_potential_at_unchecked(
  nuclei : Array[Nucleus],
  point : Vec3,
  minimum_distance : Double
) -> Double raise ElectrostaticError {
  let mut potential = 0.0
  for nucleus in nuclei {
    let r = distance(point, nucleus.position)
    guard r >= minimum_distance && r > 0.0 else {
      raise SingularPoint("sample point is on or too close to a nucleus")
    }
    potential += COULOMB_EV_ANGSTROM * nucleus.atomic_number.to_double() / r
  }
  potential
}

fn point_charge_potential_at_unchecked(
  atoms : Array[Atom],
  point : Vec3,
  minimum_distance : Double
) -> Double raise ElectrostaticError {
  let mut potential = 0.0
  for atom in atoms {
    let r = distance(point, atom.position)
    guard r >= minimum_distance && r > 0.0 else {
      raise SingularPoint("sample point is on or too close to an atom; move the plane or increase minimum_distance")
    }
    potential += COULOMB_EV_ANGSTROM * atom.charge / r
  }
  potential
}

fn bohr_volume_angstrom3() -> Double {
  BOHR_RADIUS_ANGSTROM * BOHR_RADIUS_ANGSTROM * BOHR_RADIUS_ANGSTROM
}

fn finite_self_cell_kernel(cell_volume : Double) -> Double {
  let radius = cube_root(3.0 * cell_volume / (4.0 * PI))
  2.0 * PI * radius * radius / cell_volume
}

fn cube_root(value : Double) -> Double {
  if value <= 0.0 {
    0.0
  } else {
    let mut low = 0.0
    let mut high = if value > 1.0 { value } else { 1.0 }
    for _ in 0..<80 {
      let mid = (low + high) * 0.5
      if mid * mid * mid <= value {
        low = mid
      } else {
        high = mid
      }
    }
    (low + high) * 0.5
  }
}

fn distance(a : Vec3, b : Vec3) -> Double {
  let dx = a.x - b.x
  let dy = a.y - b.y
  let dz = a.z - b.z
  (dx * dx + dy * dy + dz * dz).sqrt()
}

fn plane_point(plane : Plane, ix : Int, iy : Int) -> Vec3 {
  let a = coordinate(plane.min_a, plane.max_a, ix, plane.width)
  let b = coordinate(plane.min_b, plane.max_b, iy, plane.height)
  match plane.axis {
    X => { x: plane.position, y: a, z: b }
    Y => { x: a, y: plane.position, z: b }
    Z => { x: a, y: b, z: plane.position }
  }
}

fn project_atom(plane : Plane, atom : Atom) -> (Double, Double, Double) {
  match plane.axis {
    X => (atom.position.y, atom.position.z, atom.position.x - plane.position)
    Y => (atom.position.x, atom.position.z, atom.position.y - plane.position)
    Z => (atom.position.x, atom.position.y, atom.position.z - plane.position)
  }
}

fn axis_name(axis : Axis) -> String {
  match axis {
    X => "x"
    Y => "y"
    Z => "z"
  }
}

fn ratio(value : Double, min_value : Double, max_value : Double) -> Double {
  clamp((value - min_value) / (max_value - min_value), 0.0, 1.0)
}

fn in_range(value : Double, min_value : Double, max_value : Double) -> Bool {
  value >= min_value && value <= max_value
}

fn rgb_string(color : Rgb) -> String {
  "rgb(\{color.r},\{color.g},\{color.b})"
}

fn charge_rgb_string(charge : Double) -> String {
  if charge < -EPSILON {
    "#dc2626"
  } else if charge > EPSILON {
    "#2563eb"
  } else {
    "#475569"
  }
}

fn coordinate(min_value : Double, max_value : Double, index : Int, count : Int) -> Double {
  if count <= 1 {
    (min_value + max_value) * 0.5
  } else {
    let t = index.to_double() / (count - 1).to_double()
    min_value + (max_value - min_value) * t
  }
}

fn channel(value : Double) -> Int {
  (clamp(value, 0.0, 1.0) * 255.0).to_int()
}

fn max_double(a : Double, b : Double) -> Double {
  if a > b { a } else { b }
}

fn clamp(value : Double, low : Double, high : Double) -> Double {
  if value < low {
    low
  } else if value > high {
    high
  } else {
    value
  }
}

fn abs_double(value : Double) -> Double {
  if value < 0.0 {
    -value
  } else {
    value
  }
}

fn is_finite_double(value : Double) -> Bool {
  value == value && value < 1.0e300 && value > -1.0e300
}
