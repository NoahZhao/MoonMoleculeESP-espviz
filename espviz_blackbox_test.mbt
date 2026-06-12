fn abs_for_test(value : Double) -> Double {
  if value < 0.0 {
    -value
  } else {
    value
  }
}

fn assert_close(actual : Double, expected : Double, tolerance : Double) -> Unit raise {
  guard abs_for_test(actual - expected) <= tolerance else {
    fail("expected \{actual} to be within \{tolerance} of \{expected}")
  }
}

fn distance_for_test(a : @espviz.Vec3, b : @espviz.Vec3) -> Double {
  let dx = a.x - b.x
  let dy = a.y - b.y
  let dz = a.z - b.z
  (dx * dx + dy * dy + dz * dz).sqrt()
}

fn dot_from_for_test(
  origin : @espviz.Vec3,
  a : @espviz.Vec3,
  b : @espviz.Vec3
) -> Double {
  let ax = a.x - origin.x
  let ay = a.y - origin.y
  let az = a.z - origin.z
  let bx = b.x - origin.x
  let by = b.y - origin.y
  let bz = b.z - origin.z
  ax * bx + ay * by + az * bz
}

test "point-charge Coulomb potential" {
  let atoms : Array[@espviz.Atom] = [@espviz.make_atom("Na", 0.0, 0.0, 0.0, 1.0)]
  let point = @espviz.make_vec3(1.0, 0.0, 0.0)
  let actual = @espviz.potential_at(atoms, point, minimum_distance=0.0)
  let expected = @espviz.COULOMB_EV_ANGSTROM
  assert_close(actual, expected, 0.000000001)
}

test "quantum nuclear potential uses atomic number not partial charge" {
  let nuclei : Array[@espviz.Nucleus] = [@espviz.make_nucleus("He", 0.0, 0.0, 0.0, 2)]
  let point = @espviz.make_vec3(2.0, 0.0, 0.0)
  let actual = @espviz.nuclear_potential_at(nuclei, point, minimum_distance=0.0)
  let expected = @espviz.COULOMB_EV_ANGSTROM
  assert_close(actual, expected, 0.000000001)
}

test "electron density contribution is subtracted from MESP" {
  let nuclei : Array[@espviz.Nucleus] = [@espviz.make_nucleus("H", 0.0, 0.0, 0.0, 1)]
  let densities = FixedArray::make(1, 1.0)
  let density_grid = @espviz.ElectronDensityGrid::{
    origin: @espviz.make_vec3(0.0, 0.0, 0.0),
    spacing: @espviz.make_vec3(1.0, 1.0, 1.0),
    nx: 1,
    ny: 1,
    nz: 1,
    densities_e_per_angstrom3: densities,
  }
  let point = @espviz.make_vec3(2.0, 0.0, 0.0)
  let nuclear = @espviz.nuclear_potential_at(nuclei, point, minimum_distance=0.0)
  let electronic = @espviz.electronic_potential_from_density_grid_at(density_grid, point)
  let mesp = @espviz.mesp_at(nuclei, density_grid, point, minimum_nuclear_distance=0.0)
  assert_close(@espviz.total_electrons(density_grid), 1.0, 0.000000001)
  assert_true(electronic > 0.0)
  assert_close(mesp, nuclear - electronic, 0.000000001)
  assert_close(mesp, 0.0, 0.000000001)
}

test "standard MESP density is converted from atomic units" {
  let density = @espviz.standard_mesp_surface_density_e_per_angstrom3()
  assert_close(@espviz.density_e_per_angstrom3_to_au(density), 0.001, 0.000000001)
}

test "water sample has physical gas-phase geometry" {
  let atoms = @espviz.sample_water()
  let oxygen = atoms[0].position
  let h1 = atoms[1].position
  let h2 = atoms[2].position
  let oh1 = distance_for_test(oxygen, h1)
  let oh2 = distance_for_test(oxygen, h2)
  let cos_hoh = dot_from_for_test(oxygen, h1, h2) / (oh1 * oh2)
  assert_close(oh1, 0.9572, 0.0001)
  assert_close(oh2, 0.9572, 0.0001)
  assert_close(cos_hoh, -0.2504, 0.0005)
}

test "neutral water sample" {
  let atoms = @espviz.sample_water()
  assert_true(@espviz.is_nearly_neutral(atoms, tolerance=0.000000001))
  assert_close(@espviz.total_charge(atoms), 0.0, 0.000000001)
}

test "opposite charges cancel at midpoint" {
  let atoms : Array[@espviz.Atom] = [
    @espviz.make_atom("A", -1.0, 0.0, 0.0, 1.0),
    @espviz.make_atom("B", 1.0, 0.0, 0.0, -1.0),
  ]
  let actual = @espviz.potential_at(atoms, @espviz.make_vec3(0.0, 0.0, 0.0), minimum_distance=0.0)
  assert_close(actual, 0.0, 0.000000001)
}

test "singular atom sample is rejected" {
  let atoms : Array[@espviz.Atom] = [@espviz.make_atom("Na", 0.0, 0.0, 0.0, 1.0)]
  let result : Result[Double, Error] = Ok(
    @espviz.potential_at(atoms, @espviz.make_vec3(0.0, 0.0, 0.0), minimum_distance=0.0),
  ) catch {
    err => Err(err)
  }
  guard result is Err(_) else { fail("expected exact atom sampling to fail") }
}

test "empty molecule is rejected" {
  let atoms : Array[@espviz.Atom] = []
  let result : Result[Double, Error] = Ok(
    @espviz.potential_at(atoms, @espviz.make_vec3(1.0, 0.0, 0.0), minimum_distance=0.0),
  ) catch {
    err => Err(err)
  }
  guard result is Err(_) else { fail("expected empty molecule to fail") }
}

test "plane grid has expected shape and range" {
  let atoms = @espviz.sample_water()
  let plane = @espviz.Plane::{
    axis: @espviz.Axis::Z,
    position: 0.5,
    min_a: -1.0,
    max_a: 1.0,
    min_b: -1.0,
    max_b: 1.0,
    width: 5,
    height: 4,
    minimum_distance: 0.001,
  }
  let grid = @espviz.compute_plane(atoms, plane)
  assert_eq(grid.width, 5)
  assert_eq(grid.height, 4)
  assert_eq(grid.values.length(), 20)
  assert_true(grid.max_value > grid.min_value)
}

test "plane axes map to physical cartesian coordinates" {
  let atoms : Array[@espviz.Atom] = [@espviz.make_atom("Q", 0.0, 0.0, 0.0, 1.0)]
  let expected_point = @espviz.make_vec3(1.0, 2.0, 3.0)
  let expected = @espviz.potential_at(atoms, expected_point, minimum_distance=0.0)
  let x_plane = @espviz.Plane::{
    axis: @espviz.Axis::X,
    position: 1.0,
    min_a: 1.5,
    max_a: 2.5,
    min_b: 2.5,
    max_b: 3.5,
    width: 1,
    height: 1,
    minimum_distance: 0.0,
  }
  let y_plane = @espviz.Plane::{
    axis: @espviz.Axis::Y,
    position: 2.0,
    min_a: 0.5,
    max_a: 1.5,
    min_b: 2.5,
    max_b: 3.5,
    width: 1,
    height: 1,
    minimum_distance: 0.0,
  }
  let z_plane = @espviz.Plane::{
    axis: @espviz.Axis::Z,
    position: 3.0,
    min_a: 0.5,
    max_a: 1.5,
    min_b: 1.5,
    max_b: 2.5,
    width: 1,
    height: 1,
    minimum_distance: 0.0,
  }
  assert_close(@espviz.compute_plane(atoms, x_plane).get(0, 0), expected, 0.000000001)
  assert_close(@espviz.compute_plane(atoms, y_plane).get(0, 0), expected, 0.000000001)
  assert_close(@espviz.compute_plane(atoms, z_plane).get(0, 0), expected, 0.000000001)
}

test "grid accessor rejects out of bounds coordinates" {
  let grid = @espviz.compute_plane(@espviz.sample_water(), @espviz.standard_water_plane())
  let result : Result[Double, Error] = Ok(grid.get(-1, 0)) catch {
    err => Err(err)
  }
  guard result is Err(_) else { fail("expected out of bounds access to fail") }
}

test "renderers produce non-empty portable output" {
  let atoms = @espviz.sample_water()
  let plane = @espviz.Plane::{
    axis: @espviz.Axis::Z,
    position: 0.5,
    min_a: -0.5,
    max_a: 0.5,
    min_b: -0.5,
    max_b: 0.5,
    width: 3,
    height: 3,
    minimum_distance: 0.001,
  }
  let grid = @espviz.compute_plane(atoms, plane)
  assert_true(@espviz.to_csv(grid).length() > 20)
  assert_true(@espviz.to_ppm(grid).length() > 20)
  assert_true(@espviz.to_svg(grid).length() > 50)
  assert_true(@espviz.to_visual_svg(grid, plane, atoms).length() > 200)
}

test "zero potential maps to neutral white" {
  let color = @espviz.color_for(0.0, -2.0, 2.0)
  assert_eq(color.r, 255)
  assert_eq(color.g, 255)
  assert_eq(color.b, 255)
}

test "all-zero color scale maps to neutral white" {
  let color = @espviz.color_for(0.0, 0.0, 0.0)
  assert_eq(color.r, 255)
  assert_eq(color.g, 255)
  assert_eq(color.b, 255)
}

test "negative potential maps to red" {
  let color = @espviz.color_for(-2.0, -2.0, 2.0)
  assert_eq(color.r, 255)
  assert_eq(color.g, 0)
  assert_eq(color.b, 0)
}

test "positive potential maps to blue" {
  let color = @espviz.color_for(2.0, -2.0, 2.0)
  assert_eq(color.r, 0)
  assert_eq(color.g, 0)
  assert_eq(color.b, 255)
}

test "fixed color scale keeps zero centered independent of data extrema" {
  let scale = @espviz.fixed_symmetric_color_scale(4.0)
  let color = @espviz.color_for_scale(2.0, scale)
  assert_eq(color.r, 127)
  assert_eq(color.g, 127)
  assert_eq(color.b, 255)
}
