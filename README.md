# Robot vacuum guard feet for a clothes drying rack

Replacement feet for a folding clothes drying rack. They stop a robot vacuum from getting stuck on the rack's legs.

They were designed for an older Sini drying rack whose legs are T-shaped, like the current Sini Ted: each leg stands on a horizontal steel tube with a plastic cap on each end. The model is parametric, so it can be adjusted for other racks with similar tube feet.

![Foot guard model](images/model.png)

<!-- Photo of the installed feet goes here -->

## The problem

Many folding drying racks stand on round steel tubes with a small plastic cap on each end. The tube is low enough that a robot vacuum treats it as a threshold and tries to climb over it. Partway over, the robot gets wedged and stuck.

On this rack the tube is 16 mm thick. The last 70 mm at each end is straight but angled. The tip touches the floor and the tube rises about 5 mm to the level middle section, so most of the tube sits a few millimetres off the floor.

## The solution

The foot is a 170 mm long, 35 mm tall block that replaces the plastic end cap. It's too tall for the robot to climb, so its bumper hits the block and the robot turns away like it would at a wall. The ends are sloped so the robot slides off instead of catching on a corner.

The block is long on purpose. With only a short block at each end of the tube, the robot could still drive up to the bare tube between them and try to climb it there. At 170 mm, the blocks cover most of the tube, and the bare stretch left in the middle is too short for the robot to get into.

The tube end slides into a closed socket at one end of the block. The socket is tilted to match the tube's angled end section. After the socket, the block has an open channel on top that follows the tube's rise. That way the tube sits in the block without needing to match its exact shape. The channel also widens slightly towards the open end, in case the leg doesn't line up exactly with the block.

![Closed socket end of the block](images/model-socket.png)

## Rail end caps

The rack's top rails are the same 16 mm tube, and the wire frames of the folding wings hook into the plastic caps on their ends. Those caps crack over time, so `rail_end_cap.scad` is a replacement.

The cap is a sleeve over the tube end, with a hole straight across it for the 4 mm wire to pivot in. The wire hole sits a little closer to the tube end than the wire does on the rack, so the tube stops about 2 mm short of the bottom of the socket and the hole can line up with the wire. The cap can be turned on the tube to point the hole whichever way the wire needs.

![Rail end cap model](images/rail-end-cap.png)

## Files

| File | What it is |
| --- | --- |
| `rack_foot_guard.scad` | The parametric model (OpenSCAD) |
| `rack_foot_guard.stl` | The full 170 mm foot, ready to print |
| `rack_foot_test_60mm.stl` | A 60 mm version for testing the socket fit and angle |
| `tube_fit_test.scad` / `.stl` | Six thin rings for finding the right hole size |
| `rail_end_cap.scad` / `.stl` | End cap for the top rails, where the wing wires hook in |

The STLs are made with the default settings, which match the rack these were designed for. If your rack is different, change the settings in the `.scad` file and make new STLs.

## Fitting it to your rack

1. **Measure the tube.** Take the old caps off. Measure the tube's diameter, the length of the angled end section, and how much higher the middle of the tube is than the tip.
2. **Find the clearance.** Set `tube_d` in `tube_fit_test.scad` and print it. Each ring is labelled with its clearance, which is how much bigger the hole is than the tube. Slide the rings onto the tube and pick the one that fits snugly.
3. **Check the fit and angle.** In `rack_foot_guard.scad`, set `tube_d`, `clearance`, `end_seg_len` and `end_rise`, then print a test piece with `length = 60`. Put it on the tube and stand the rack on it. The block should sit flat on the floor. If the open end lifts, increase `end_rise`; if the closed end lifts, decrease it.
4. **Print the full feet.** You need one per leg end, usually four. The block is the same on both sides, so one file works for every corner.

### Settings

Open the `.scad` file in [OpenSCAD](https://openscad.org/) and use **Window → Customizer** to change these:

| Setting | Default | Meaning |
| --- | --- | --- |
| `tube_d` | 16.0 | Tube diameter (mm) |
| `clearance` | 0.2 | How much bigger the hole is than the tube (mm) |
| `socket_len` | 35 | How far the tube goes into the closed socket (mm) |
| `end_seg_len` | 70 | Length of the tube's straight angled end section (mm) |
| `end_rise` | 5 | How much higher the tube's middle is than its tip (mm) |
| `gap_at_tip` | 3 | Plastic under the tube tip; raises the rack by this much (mm) |
| `channel_flare` | 1 | How much the open channel widens sideways towards the open end, per side (degrees); gives room if the leg sits at a slight sideways angle |
| `length` | 170 | Block length (mm); long enough that the robot can't reach the bare tube between the two feet |
| `height` | 35 | Block height (mm); keep it above ~30 so the robot's bumper hits it |
| `base_w` / `top_w` | 40 / 30 | Block width at the floor and at the top (mm) |

The rail end cap has its own settings:

| Setting | Default | Meaning |
| --- | --- | --- |
| `tube_d` / `clearance` | 16.0 / 0.2 | Same as for the foot (mm) |
| `socket_len` | 15 | How far the tube goes into the cap (mm) |
| `wire_d` / `wire_clearance` | 4.0 / 0.5 | Wire diameter and the extra room in its hole (mm) |
| `wire_offset` | 7 | From the bottom of the socket to the centre of the wire hole (mm); set it a little less than the tube end to wire distance on the rack (about 9 mm here) |
| `end_wall` | 4 | Plastic past the wire hole (mm) |

To make the STLs from the command line:

```bash
openscad -o rack_foot_guard.stl rack_foot_guard.scad
openscad -o rack_foot_test_60mm.stl -D length=60 rack_foot_guard.scad
openscad -o rail_end_cap.stl rail_end_cap.scad
```

## Printing

- **Material:** PETG is recommended. It's tougher than PLA and holds its shape better under the rack's constant weight.
- **Orientation:** flat side down. No supports are needed: the socket and the test rings are teardrop-shaped so their tops print without support.
- **Walls and infill:** 3–4 walls so the channel sides can take bumps from the robot. 15–20 % infill is plenty.
- **Bed size:** the 170 mm block fits a 180 × 180 mm bed (such as a Prusa Mini). Put the long side along X and skip the brim.
- **Rail end caps:** print them standing on the open end, so the layers wrap around the tube and the sleeve doesn't split. No supports are needed. Use 5 or more walls; the walls are thin enough that this makes the cap solid.

Felt pads stick fine to the flat bottom if you want to protect the floor.

## License

[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). You can share and modify these files for any purpose, as long as you give credit. See [LICENSE](LICENSE).
