# SwiftCAD

A collection of 3D models built with [Cadova](https://github.com/tomasf/Cadova) — a Swift DSL for declarative, code-driven 3D CAD modeling. All models are defined entirely in Swift and output to 3MF format.

## Models

### Easter Egg Ornament

A decorative Easter egg ornament with sinusoidal stripe patterns and dot accents, topped with a hanging ring. Designed as a companion to the Ornament Hook below.

<img src="/src/screenshots/egg_ornament.jpg" alt="Easter Egg Ornament">

---

### Ornament Hook

A two-part hook system for hanging ornaments from tree branches. The branch hook and ornament hook are printed in place as a single piece, with a rotated variant available for different branch angles.

<p>
  <img src="/src/screenshots/ornament_hook.jpg" alt="Ornament Hook" width="49%">
  <img src="/src/screenshots/ornament_hook_rotated.jpg" alt="Rotated Ornament Hook" width="49%">
</p>

---

### Street Sign

A customizable 3D-printed street sign. Takes any text string and optional suffix (`St`, `Ave`, `Blvd`, `Rd`, `Way`, `Ln`, `Dr`) and produces a green sign with white text and a rounded inner border.

<img src="/src/screenshots/street_sign.jpg" alt="Street Sign">

---

### Ferris Sweep Keyboard (WIP)

A keyboard plate for a Ferris Sweep-style split keyboard. Features a 3×5 column-staggered layout with configurable per-column vertical offsets to match your hand's natural curl, plus two thumb key cutouts. Designed for Cherry MX-compatible switches.

<!-- TODO: - Add Ferris Sweep screenshot -->

---

### Hailey60 Keyboard (Frame + Case)

A custom 60 key keyboard in a 6×5 column layout. Outputs two pieces:

- **Frame** — the switch plate with cutouts for Cherry MX switches, a microcontroller (RP2040-zero, Pro Micro, or similar), and a TR(R)S connector. Includes retention latches for snap-fitting into the case.
- **Case** — a wedge-angled bottom case with a filleted outer wall, internal support grid, and cutouts for the USB and TRRS ports. Snaps onto the frame via the integrated latch system.

Microcontroller and TR(R)S dimensions are fully parameterized.

<p>
  <img src="/src/screenshots/hailey60_frame.jpg" alt="Hailey60 Keyboard Frame" width="49%">
  <img src="/src/screenshots/hailey60_case.jpg" alt="Hailey60 Keyboard Case" width="49%">
</p>

---

### Modified Keycap

A Cherry MX keycap with a modified circular stem to fit any dust guards.

<p>
  <img src="/src/screenshots/modified_keycap_front.jpg" alt="Modified Keycap Front" width="49%">
  <img src="/src/screenshots/modified_keycap_back.jpg" alt="Modified Keycap Back" width="49%">
</p>

Based on the [Complete Cherry MX Stem Keycap Set](https://www.printables.com/model/399607-complete-cherry-mx-stem-keycap-set-optimized-for-3) by [@Riskable](https://www.printables.com/@Riskable) on Printables. Licensed under a remix-permitted, non-commercial, attribution-required license — see the original model page for details.

---

## Requirements

- macOS 14+
- Swift 6.1+
- [Cadova](https://github.com/tomasf/Cadova) `0.6.x`

[Cadova Viewer](https://github.com/tomasf/CadovaViewer) is optional, but highly recommended to preview 3mf files as it automatically reflects changes when they are made.

Output models are written to `$(BUILD_DIR)/output/`. (Folder is opened automatically.)
