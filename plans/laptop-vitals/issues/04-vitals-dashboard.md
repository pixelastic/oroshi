## TLDR

Create `vitals` autoload function that calls all `sys-*` helpers and prints a color-coded dashboard.

## What to build

A `vitals` autoload function in `system/` that:

1. Loads colors via `colors-load-definitions`
2. Calls each `sys-*` helper with `--reply`, splitting REPLY on `▮`
3. Formats output as aligned columns:

```
CPU     27%
RAM     34%  8.2G / 30G
Swap     2%  128M / 2G
Temp    52°C (CPU)  48°C (GPU)  38°C (NVMe)
Fans    4039 avg  5293 / 4786
Battery 87%
```

4. Color-codes values by threshold using `$COLORS`:
   - CPU: green <50%, yellow 50-80%, red >80%
   - RAM: green <60%, yellow 60-85%, red >85%
   - Swap: green 0%, yellow 1-50%, red >50%
   - Temperature: green <60°C, yellow 60-80°C, red >80°C
   - Fans: green <3000, yellow 3000-5000, red >5000
   - Battery: green >30%, yellow 10-30%, red <10%

No `--reply` support — this is a display-only function.

## Acceptance criteria

- [ ] Calls all six `sys-*` helpers via `--reply`
- [ ] Output fits a single screenful
- [ ] Values color-coded green/yellow/red by threshold
- [ ] Uses `colors-load-definitions` for color values
- [ ] Labels aligned in a readable column layout
- [ ] Gracefully handles `?` values from missing sensors (display as-is, no color)
