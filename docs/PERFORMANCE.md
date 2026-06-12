# Performance Notes

The current solver is direct and intentionally simple:

```text
O(width * height * atom_count)
```

For the default water demo, the grid is `80 x 80` with three atoms, so it performs 19,200 atom contributions. This is suitable for small molecules and documentation examples.

## Accuracy Controls

- `minimum_distance`: excluded radius around point charges. Samples inside this radius are rejected because the point-charge potential is singular.
- `width` and `height`: increase spatial resolution linearly in each direction.

## Benchmark Plan

After the local MoonBit toolchain is available, run:

```bash
moon test
moon run cmd/main summary
```

For future benchmark expansion, add a `moon bench` test that evaluates:

- 64 x 64 water grid
- 128 x 128 water grid
- 128 x 128 grid with 100 point charges

The likely next algorithmic improvement is a tiled evaluator for direct mode, followed by an optional FFT-backed package when a stable MoonBit FFT dependency is available.
