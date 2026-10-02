# UI direction

The production UI should follow the supplied simulator reference without copying its assets.

- Large rounded shapes and readable silhouettes.
- `FredokaOne` headings with white fill and a thick black `UIStroke`.
- Bright category colors, subtle vertical gradients, dark outer borders, and lighter inner highlights.
- Large square menu buttons on the left; persistent currencies below them.
- Level/XP bar centered at the top.
- Modal panels centered on screen with a dim or blurred game background.
- Green primary action, purple premium action, red close buttons.
- Small repeating background patterns may be added as replaceable image assets later.
- Buttons use hover/touch scale animation and strong pressed feedback.
- All important layouts use scale plus constraints so phone, tablet, and desktop remain readable.

Runtime controllers must find UI by stable instance names and only update values/visibility. They must not overwrite Studio-authored sizes, colors, fonts, or positions.
