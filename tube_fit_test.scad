// Tube fit test for rack_foot_guard.scad
// A row of thin rings, each with a different clearance. A flat tab on the
// side of each ring carries the clearance value.
// The rings lie on their side, so the bore prints horizontally like in the
// real part (horizontal holes print slightly differently from upright ones).
// Bores are teardrop-shaped like the real socket, so no supports are needed.
//
// Slide each one onto the tube and pick the clearance that feels right,
// then set that as `clearance` in rack_foot_guard.scad.

/* [Tube] */
// Measured outer diameter of the tube (mm)
tube_d = 16.0;
// Clearances to test (added to tube_d)
clearances = [0, 0.1, 0.2, 0.3, 0.4, 0.5];

/* [Test piece] */
// Length of each ring along the tube (mm)
ring_len = 6;
// Ring wall thickness (mm)
wall = 1.6;
// Width of the flat strip the ring stands on (mm)
foot_w = 8;
// Height of the flat foot (mm)
foot_h = 1;
// Label tab size sticking out from the ring's side (mm)
tab_w = 10;
// Label tab thickness (mm)
tab_h = 1.2;
// Depth of the engraved label (mm)
label_depth = 0.6;
// Label text size (mm)
label_size = 3.5;
// Space between pieces on the bed (mm)
spacing = 3;

/* [Hidden] */
$fn = 96;
eps = 0.01;

// Teardrop: a circle with a 45-degree point on top (+y in 2D), so a sideways
// hole prints without supports. The tube still rests on the round part.
module teardrop2d(d) {
    r = d / 2;
    hull() {
        circle(d = d);
        translate([0, r * sqrt(2)]) square(0.01, center = true);
    }
}

// Extrudes a 2D shape along +x, with the shape's +y pointing up (+z)
module along_x(h) {
    rotate([0, 90, 0]) linear_extrude(h) rotate(90) children();
}

module piece(c) {
    bore = tube_d + c;
    od = bore + 2 * wall;
    axis_z = foot_h + od / 2 - 0.5;   // ring sinks slightly into the foot so it bonds
    difference() {
        union() {
            // Ring with a flat foot underneath
            hull() {
                translate([0, 0, axis_z]) along_x(ring_len) teardrop2d(od);
                translate([0, -foot_w / 2, 0]) cube([ring_len, foot_w, foot_h]);
            }
            // Label tab on the side, flat on the bed
            // (starts under the ring's centre so it joins the foot)
            cube([ring_len, od / 2 + tab_w, tab_h]);
        }
        translate([-eps, 0, axis_z]) along_x(ring_len + 2 * eps) teardrop2d(bore);
        // Clearance value engraved in the tab
        translate([ring_len / 2, od / 2 + tab_w / 2, tab_h - label_depth])
            linear_extrude(label_depth + eps)
                rotate(90) text(str(c), size = label_size, halign = "center", valign = "center");
    }
}

for (i = [0 : len(clearances) - 1])
    translate([i * (ring_len + spacing), 0, 0]) piece(clearances[i]);
