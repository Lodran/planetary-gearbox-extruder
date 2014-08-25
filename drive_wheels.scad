//
// RepRap Mendel Akimbo
//
// A Mendel variant, which improves the frame's clearance and stability
//  by increasing its triangulation.
//
// Copyright 2012 by Ron Aldrich.
//
// Licensed under GNU GPL v2
//
// drive_wheels.scad
//
// Size and shape definitions for various extruder drive wheels, for direct drive extruders.
//

drive_wheel_length = 0;
drive_wheel_radius = 1;
drive_wheel_hob_radius = 2;
drive_wheel_hob_center = 3;

makerbot_mk7 = [
	11,
	12.5/2,
	10.65/2,
	7.45
];

arcol_11x5 = [
	13,
	11/2,
	9.1/2,
	13-5
];

arcol_8x5 = [
	13,
	8/2,
	6.1/2,
	13-5
];

module drive_wheel(drive_bolt_spec)
{
	translate([0, 0, -drive_bolt_spec[drive_wheel_length]/2])
	difference()
	{
		translate([0, 0, drive_bolt_spec[drive_wheel_length]/2])
		cylinder(h=drive_bolt_spec[drive_wheel_length],
		         r=drive_bolt_spec[drive_wheel_radius],
		         $fn=30,
		         center=true);

		translate([0, 0, drive_bolt_spec[drive_wheel_hob_center]])
		rotate_extrude(convexity=4, $fn=30)
			translate([drive_bolt_spec[drive_wheel_radius]+1, 0])
			circle(r=drive_bolt_spec[drive_wheel_radius]-drive_bolt_spec[drive_wheel_hob_radius]+1, $fn=12);
	}
}
