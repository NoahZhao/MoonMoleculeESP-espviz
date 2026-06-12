fn usage() -> String {
  (
    #|espviz renders the built-in water electrostatic-potential slice.
    #|
    #|Usage:
    #|  moon run cmd/main            # SVG to stdout
    #|  moon run cmd/main svg        # SVG to stdout
    #|  moon run cmd/main ppm        # ASCII PPM to stdout
    #|  moon run cmd/main csv        # CSV samples to stdout
    #|  moon run cmd/main summary    # grid range summary
    #|
    #|Examples:
    #|  moon run cmd/main svg > examples/water.svg
    #|  moon run cmd/main ppm > examples/water.ppm
  )
}

fn main {
  let argv = @env.args()
  let mode = if argv.length() > 1 { argv[1] } else { "svg" }
  if mode == "--help" || mode == "-h" {
    println(usage())
  } else {
    let atoms = @espviz.sample_water()
    let plane = @espviz.standard_water_plane()
    try @espviz.compute_plane(atoms, plane) catch {
      _ => println("failed to compute electrostatic potential grid")
    } noraise {
      grid =>
        match mode {
          "svg" => println(@espviz.to_visual_svg(grid, plane, atoms))
          "ppm" => println(@espviz.to_ppm(grid))
          "csv" => println(@espviz.to_csv(grid))
          "summary" => println(@espviz.grid_summary(grid))
          _ => {
            println(usage())
            println("unknown output mode: \{mode}")
          }
        }
      }
  }
}
