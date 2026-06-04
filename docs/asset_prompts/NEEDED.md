# Assets Needed for v2

## Sprites (generate via Claude or find on OpenGameArt)

Style brief: Bold outline Indonesian cartoon, vibrant 4–5 color palette, mobile-readable at 200px, transparent PNG.

| Asset | Size | Notes |
|---|---|---|
| `ui/star_empty.png` | 64×64 | Outline star, grey fill |
| `ui/star_half.png` | 64×64 | Half-filled gold star |
| `ui/star_full.png` | 64×64 | Fully filled gold star |
| `ui/combo_flame_1.png` | 128×128 | Small flame, frame 1 of 3 |
| `ui/combo_flame_2.png` | 128×128 | Medium flame, frame 2 of 3 |
| `ui/combo_flame_3.png` | 128×128 | Large flame, frame 3 of 3 |
| `objects/obstacle_cone.png` | 200×200 | Orange traffic cone |
| `objects/obstacle_car.png` | 300×200 | Parked car (side view) |
| `objects/spark_burst.png` | 256×256 | 12-frame sprite atlas (4×3 grid), white/yellow sparks |
| `objects/bonus_glow.png` | 100×100 | 4-frame gold ring pulse animation |
| `ui/tutorial_hand.png` | 120×200 | 2-frame tap gesture (finger down + up) |

## Claude Prompt Template for Sprites

```
Create a [ASSET_DESCRIPTION] sprite for a 2D Android mobile game called "Gas Gas Man: Delivery Rush".
Style: bold black outlines, flat cartoon shading, vibrant Indonesian neighborhood color palette
(warm oranges, greens, yellows, sky blue). Transparent background. Size: [WxH]px.
Mobile-readable — high contrast, simple shapes, no fine detail smaller than 8px.
The game features a delivery moped rider throwing packages to houses.
```

## OpenGameArt Search Queries

- Star rating icons: https://opengameart.org/content/star-button (CC0)
- Explosion particles: https://opengameart.org/content/explosion-set-1-m484-games (CC0)
- SFX combo hits: https://opengameart.org/content/8-bit-sound-effects-library (CC0)
- Cartoon impact sparks: https://opengameart.org/content/sparks-particle-effects (CC0)

## SFX Needed

| File | Description | Source |
|---|---|---|
| `sfx/combo_hit_2.wav` | Package hit, pitch +8% (combo x2) | Pitch-shift `package_hit.wav` |
| `sfx/combo_hit_3.wav` | Package hit, pitch +16% (combo x3) | Pitch-shift `package_hit.wav` |
| `sfx/combo_hit_4.wav` | Package hit, pitch +24% (combo x4) | Pitch-shift `package_hit.wav` |
| `sfx/combo_hit_5.wav` | Package hit, pitch +32% (combo x5) | Pitch-shift `package_hit.wav` |
| `sfx/combo_break.wav` | Descending whoosh, 300ms | OpenGameArt or generate |
| `sfx/level_complete.wav` | 3-note ascending fanfare, 0.8s | OpenGameArt |
| `sfx/obstacle_hit.wav` | Deflect thud impact | OpenGameArt |

Note: The AudioManager uses pitch_scale on play_combo_sfx() so combo hits 2–5
can be generated automatically from `package_hit.wav` without separate files.
