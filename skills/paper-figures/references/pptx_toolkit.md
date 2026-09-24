# python-pptx figure toolkit

Recipes proven on the GlanceWAM ICLR figures. Full working code: `~/projects/starVLA/tools/build_iclr_method_v2.py`.

## Run / export / inspect

```bash
uv run --no-project --with python-pptx --with numpy --with pillow python tools/build_fig.py
soffice --headless --convert-to pdf --outdir <tmp> fig.pptx      # LibreOffice render
pdfcrop --margins 2 fig.pdf fig_crop.pdf                          # what the paper includes
pdftoppm -r 220 -png fig_crop.pdf /tmp/view                       # look at it
pdftoppm -f <page> -l <page> -r 130 -png main.pdf /tmp/page       # look at it IN the paper
```

- Set the slide size to the figure size (`prs.slide_width/height`), one slide, blank layout 6.
- Double-blind: `prs.core_properties.author = "<Method> authors"` (the PDF metadata inherits it).

## Gotchas

- **Drop the theme style** from every autoshape/connector (`shape._element.remove(shape._element.find(qn("p:style")))`).
  Otherwise LibreOffice draws drop shadows.
- Text boxes: `tf.auto_size = MSO_AUTO_SIZE.NONE`, all margins 0, `word_wrap=True`. Autofit shifts text.
- Z-order is insertion order, so draw background panels **first**.
- Arrowheads: append `<a:tailEnd type="triangle"/>` to the line's `a:ln`. Use `w="sm" len="sm"` when many arrows
  converge on one point.
- Dashes: `line.dash_style = MSO_LINE_DASH_STYLE.DASH`.

## LaTeX symbols (IguanaTeX-style)

Each snippet goes into a standalone doc using the paper's fonts:
`\documentclass[10pt,border=0.6pt]{standalone}\usepackage{times}\usepackage[scaled=0.92]{helvet}\usepackage{amsmath,amssymb,bm}\usepackage{xcolor}`, colored with `\definecolor{c}{HTML}{...}\color{c}`.
Then run `pdflatex` → `pdftocairo -png -transp -singlefile -r 1200`. Place with `add_picture`, scaled
`px * pt / 10 / 1200` in; cache by md5(src|color); anchor by ha/va. Use `\textsf{}` for any word inside a math label.

## Shapes

- **3D latent / layer slab:** `MSO_SHAPE.CUBE`, `adjustments[0]` = depth (0.3 for cubes, 0.45 for thin slabs).
  A transformer is n thin cubes side by side.
- **Noisy latent:** `fill.patterned(); fill.pattern = MSO_PATTERN.WIDE_UPWARD_DIAGONAL` (fore = stroke color,
  back = pale fill).
- **Encoder trapezoid:** `MSO_SHAPE.TRAPEZOID` created with w/h swapped, then `rotation = 90`, so the narrow edge
  faces right.
- **Curved arrow:** `shapes.build_freeform(...)` + `add_line_segments(pts, close=False)` over a sampled half-sine,
  with no fill and a tailEnd arrow.
- **Rounded panels:** `ROUNDED_RECTANGLE`, `adjustments[0]` ≈ 0.04–0.08, a pale fill with a slightly darker 0.6–0.8 pt
  border.
- **Icons:** render an emoji with PIL,
  `ImageFont.truetype("/System/Library/Fonts/Apple Color Emoji.ttc", 160)` and `draw.text(..., embedded_color=True)`,
  crop to its bbox, and insert as a PNG (on Linux use Noto Color Emoji).
- **Noised frame:** `keep*img + (1-keep)*N(0.5, σ)` with a fixed seed, so every build is identical.

## Lint

`uvx black -l 121` + `uvx ruff check` on the generator (the repo config).
