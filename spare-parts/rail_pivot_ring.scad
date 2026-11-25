// Rail pivot ring
// The ring at the end of the top rail that holds the rack to the far end of
// the stands. It turns freely on the 16 mm rail tube.
//
// Two 4 mm wires connect to it:
// - One wire end goes through the hole in the lobe, parallel to the tube.
// - The other wire runs through the slot between the ring's two rims. The
//   slot is open at the back, so the ring slides onto that wire sideways
//   before it goes on the tube; the tube then keeps the wire in the slot.
//
// Modelled with the tube along z and the lobe along +x. The STL is turned to
// print on one flat side of the lobe, so the slot stands upright and nothing
// needs supports; the round holes are teardrop-shaped for the same reason.
// Printed this way, the pull on the lobe runs along the layers, not across
// them.

/* [Ring] */
// Hole for the tube (mm); about 1 mm over the tube so it turns freely
bore_d = 17;
// Thickness along the tube (mm)
thickness = 15;
// Outer diameter of the round part (mm)
ring_d = 24;

/* [Lobe] */
// Distance from the ring's centre to the centre of the lobe hole (mm)
lobe_offset = 17;
// Wire diameter (mm)
wire_d = 4.0;
// Extra diameter for the lobe hole, so the wire can pivot freely
wire_clearance = 0.5;
// Wall around the lobe hole (mm)
lobe_wall = 4;

/* [Slot] */
// Slot width (mm); the wire is 4 mm
slot_w = 4.4;
// How far the slot goes in from the back of the ring (mm)
slot_depth = 24;

/* [Output] */
// Turn the part to its print orientation
print_orientation = true;

/* [Hidden] */
$fn = 96;
eps = 0.01;

R1 = ring_d / 2;
hole_d = wire_d + wire_clearance;
R2 = hole_d / 2 + lobe_wall;
slot_end = -R1 + slot_depth;

// Outward normal of the lobe's flat side on -y; the part prints on this side
nx = (R1 - R2) / lobe_offset;
n = [nx, -sqrt(1 - nx * nx)];
// "Up" in the print orientation, as an angle in the xy plane
up_angle = atan2(-n[1], -n[0]);

assert(R1 > R2, "The lobe must be smaller than the ring");
assert(ring_d > bore_d + 4, "Ring wall is too thin");
assert(thickness - slot_w >= 6, "Rims beside the slot are too thin");
assert(slot_end < lobe_offset - hole_d / 2 - 2, "Slot cuts too close to the lobe hole");

// Teardrop pointing at up_angle, so a horizontal hole prints without supports.
// The point is cut flat at `top` from the centre, leaving a short bridge.
module teardrop2d(d, top = 1e3) {
    r = d / 2;
    rotate(up_angle - 90) intersection() {
        hull() {
            circle(d = d);
            translate([0, r * sqrt(2)]) square(0.01, center = true);
        }
        translate([-d, -d]) square([2 * d, d + top]);
    }
}

module part() {
    difference() {
        translate([0, 0, -thickness / 2]) linear_extrude(thickness)
            difference() {
                hull() {
                    circle(r = R1);
                    translate([lobe_offset, 0]) circle(r = R2);
                }
                // Cut short of the ring's outer edge so the point doesn't break through
                teardrop2d(bore_d, R1 - 2);
                translate([lobe_offset, 0]) teardrop2d(hole_d);
            }
        // Slot for the second wire, open at the back
        // with a round end that the wire sits in
        translate([-R1 - 1, -ring_d, -slot_w / 2])
            cube([slot_end - slot_w / 2 + R1 + 1, 2 * ring_d, slot_w]);
        translate([slot_end - slot_w / 2, ring_d, 0]) rotate([90, 0, 0])
            cylinder(d = slot_w, h = 2 * ring_d);
    }
}

if (print_orientation) {
    // Flat lobe side down: turn the normal n to -y, then lay -y onto the bed
    translate([0, 0, R1]) rotate([90, 0, 0])
        rotate(-90 - atan2(n[1], n[0])) part();
} else {
    part();
}
