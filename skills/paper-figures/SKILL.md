---
name: paper-figures
description: Draw or revise research-paper figures (teaser, method/architecture/pipeline diagrams) so they look hand-made rather than AI-made — symbol-first, shaped, LaTeX-typeset, caption-explained — via an editable python-pptx generator. Use when asked to draw, redesign, polish or critique a paper figure, teaser, framework or method diagram, or when a figure "looks AI-generated", "too wordy", or "not pretty".
---

# Paper Figures (hand-drawn style)

The user's own hand-drawn figures (DC-Gaussian, Drive-JEPA, SCCNet, SemiETPicker on linhanwang.github.io; arXiv
2405.17705, 2601.22032, 2309.05840, 2510.22454) are the reference. AI-drawn figures look AI-made for three reasons:
too many words, only rectangles, and fake math. Fix all three.

## Principles

1. **Names and symbols only; the caption explains.** A figure holds module names (Video DiT, Action head) and
   symbols ($\mathbf{o}_{\le t}$, $\hat{\mathbf{z}}_\text{la}$, $\Delta$). It has no gray sub-captions, no phrases
   like "future-stream supervision", and no numbered section headers. Every explanation goes in the caption, and the
   caption plus the figure should summarize the whole method on their own. When you strip words from a figure, rewrite
   the caption in the same change.
2. **Draw things as their shape.** Frames are real images, a history is stacked frames, and a noised target is a
   noised copy of the image. Latents are 3D cubes (hatched = noisy). A transformer is a stack of thin 3D layer slabs,
   with tapped layers highlighted. An encoder is a trapezoid narrowing toward the output. Actions are a token strip.
   Operators are circled symbols. Mark trainable/frozen with a flame or snowflake icon, not with text.
3. **Real LaTeX for every symbol and loss.** Typeset with the paper's own fonts and write losses as the actual formula
   ($\mathcal{L}_\text{video}=\|\mathbf{v}_\theta-(\boldsymbol\epsilon-\mathbf{z})\|^2$), never as
   Unicode or Cambria approximations.
4. **Pale tints group only the major units.** The background shouldn't be all white. Tint one panel per big unit:
   trainable modules in a method figure, method families in a teaser. Inputs, losses and timelines stay on white.
   Tinting every section ("切太细", too fine-grained) makes the tints meaningless.
5. **One visual grammar across all figures.** A stream or role keeps the same color everywhere. Dashed = asynchronous
   or off the main loop; solid = in the main loop. Module shapes repeat between the teaser and the method figure.
6. **Correctness before beauty.** Check every depicted fact (the mask, data flow, timing and refresh schedules, which
   frame a latent depicts) against the method text *and* the code. If the text and code disagree, raise it with the
   user instead of picking one silently. Timelines are especially error-prone: make sure each arrow's start and end
   times mean something.
7. **Check at print size.** Printed scale = included width ÷ canvas width (a 10 in canvas at `\textwidth` ≈ 0.55×).
   Keep printed text ≥ ~6 pt. Inspect the figure on the compiled paper page, not only the standalone render. Don't
   make a figure taller when the paper is over its page limit.

## Workflow

1. Read the method section and the relevant code. Note the facts the figure must preserve.
2. If the user has an existing figure (pptx or PDF), reverse-engineer it into a generator first, then change that.
3. Write a **python-pptx generator** (see `references/pptx_toolkit.md`). The script is the source of truth; the pptx
   stays editable for humans. Keep a module docstring with the figure's structure and its rules.
4. Render, look at the PNG, and iterate. Then rebuild the paper and look at the figure on its page at print size.
5. Update the caption so it carries all the explanation removed from the figure.
6. Report what changed, any correctness issues found, and open decisions. Commit only when asked.

## Anti-patterns (the "AI look")

- A gray explanatory subtitle under every box, or a long sentence inside a box.
- Rectangles only; loss boxes containing prose instead of formulas.
- Numbered "1 / 2 / 3" stage headers with divider lines, like a slide template.
- Fake math: Unicode subscripts, Cambria italics, "L_video" typed as text.
- Tinting every section, or else leaving everything white.
- Assuming a timing or schedule diagram is correct because it looks plausible.

## Reference implementations

- `~/projects/starVLA/tools/build_iclr_method_v2.py` covers LaTeX via `Tex`, `cube`, the trapezoid `encoder`,
  freeform `arc`, emoji icons, tinted module panels, and the timeline.
- `~/projects/starVLA/tools/build_iclr_teaser.py` is the teaser: `stack` / `chunk` glyphs and one tint per method
  family.
