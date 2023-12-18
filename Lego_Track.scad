/* [Type of track ] */
// What type of Track should this be? For type-specific options, see the "Straight," "Curve" tabs.
Type = "straight"; // [straight:"Straight", curve:"Curve", crossing:"Crossing", test:"Test"]
NormalNarrow = "normal"; // [normal:"Normal", narrow:"Narrow"]
IncludeWallSplines = "no"; // [yes:"Yes",no:"No"]
BottomOpen = "yes"; // [yes:"Yes",no:"No"]
// Number of ties.  No checking is done so overlaps can occur
ties = 1; // [0:1:10]
TieCenterHole  = "yes"; // [yes:"Yes",no:"No"]
CenterHoleRadius = 1.6; // [0:-01:3] One LU
  
/* [Straight] */
StraightLength =8;  // [2:1:16]
/* [Curve] */
// Angle in degrees
CurveAngle = 45; // [0:0.001:180]
// Radius in 1x1 units (4mm)
CurveRadius = 20;
/* [Crossing] */
CrossingLength = 15;
SideBlockWidth = 2;     // [1,2]
SideBlockLength = 3;    // [1,2,3,4]
//

/* [Printer-Specific] */
// Change Stud on top size based on printer
StudRescale = 1.05;  // [1.0:0.001:2.0]
// Change large Post size based on printer
PostRescale = 1.05;  // [1.0:0.001:2.0]
// Change pin in 1xX areas based on printer
PinRescale=   1.10; // [1.0:0.001:2.0]
endSupports = "no"; // [yes:"Yes", no:"No"]
module __Customizer_Limit__ () {}  // End of customizer values

LU = 1.6;   // Lego design unit
BlockHeight     = 6*LU; // 9.6 MM
RailHeight      = 6*LU; // 9.6 MM
BlockWidth      = 5*LU; // 8.0 MM
TieHeight       = LU*2; // 3.2 MM
RoofThickness   = 1;    // 1.0 MM
Wall            = 1.45;   // 1.45 MM
WidthTolerance  = 0.2;  // 0.2 MM so an 8MM block would be 7.8
StudDiameter    = LU*3; // 4.8 MM
StudHeight      = LU;   // 1.6 MM Some like 1.8
StudSpacing     = LU*5; // 8.0 MM
PostDiameter = LU*4.07*PostRescale;  // 5*sqrt(2)-3 * LU
PinDiameter = 3*PinRescale;
TrackGuage      = LU*5*5; // 40 MM
NarrowTrackGuage = LU*5*3; // 24 MM
FPOffset        = 0.1;      // value to add to difference to 
                            // account for floating point math
Guage = (NormalNarrow == "normal" ? TrackGuage : NarrowTrackGuage);


SplineLength = 0.25;
SplineThickness = 0.7;
 
bottom_open = BottomOpen == "yes";
railProfile = (bottom_open) ? 
    [[0,0],[0,1.6], [TieHeight-RoofThickness,1.6], [TieHeight-RoofThickness, 6.4], [0, 6.4], [0,8],[3,8],[3,7],[4,7],[5.25,5.25],[RailHeight,5.25],[RailHeight,2.75],[5.25,2.75],[4,1],[3,1],[3,0]]
    :[[0,0], [0, 6.4], [0,8],[3,8],[3,7],[4,7],[5.25,5.25],[RailHeight,5.25],[RailHeight,2.75],[5.25,2.75],[4,1],[3,1],[3,0]];



module railCut(length) {
    difference () { polygon( [[0,0], [0,BlockWidth], [RailHeight, BlockWidth] , [RailHeight,0]]);
                    polygon (railProfile);
    };
}

module rail_straight(length) {
    rotate([90,-90,180]) linear_extrude(length) polygon(railProfile);
}

module rail_curved(angle, radius) {
    function angle_4mm(angle,radius) = 
        (360*4)/(3.14159*radius*2);
    sa = angle_4mm(angle,radius);  // small angle
    
    translate([-radius,0,0])
    rotate([0,0,sa])
    rotate_extrude(angle = angle-sa*2, $fn = 300)
    translate([radius+8,0,0])
    rotate([0,0,90]) 
    polygon(railProfile);
}
module rail_endpoint_right() {
    off_l = 0.5;
    off_h=0.1;
    poly = [[2.2,1], [2.2,7], [4,7], [7.6,5.25], [RailHeight,5.25], [RailHeight,4], [3.2,4], [3.2,1]];
    //    poly = [[0,2],[0,6],[3+off_h,6],[3+off_h,4],[9,4],[9,2.75],[7,2.75],[4,2],[3+off_h,2]];
    translate([8,8+off_l,0]) rotate([-90,-90,180]) linear_extrude(8-off_l) polygon(poly);
}

module rail_endpoint_left() {
    off_l = 0.5;
    off_h=0.0;
    off_w = 0.1;
    
    poly = [[3.2+off_h,4+off_w], [3.2+off_h,7],[4,7], [7.6,5.35], [RailHeight,5.25], [RailHeight,4+off_w]];
    translate([8,8+off_l,0]) rotate([-90,-90,180]) linear_extrude(8-off_w) polygon(poly);
    // support
    if(endSupports == "yes")
        translate([-1.5,off_l,0]) cube([8,1,3.2+off_h], false);
}

module attach_poly(h) {
 
    linear_extrude(h) polygon([[0-FPOffset,0],[2-FPOffset,1.9],[6+FPOffset,1.9],[8+FPOffset,0]]);
}

module narrow_rail_endpoint_right() {
    poly = [[3.2,6],[3.2,4],[RailHeight,4],[RailHeight,2.75],[7,2.75],[4,2],[3.2,2]];
    rotate([90,-90,180]) linear_extrude(8) polygon(poly);
}

module narrow_rail_endpoint_left() {
    poly = [[3.2,8],[3.2,4],[RailHeight,4],[RailHeight,2.75],[7,2.75],[4,1],[3.2,1]];
    rotate([90,-90,180]) linear_extrude(8) polygon(poly);
}

function need_stud(index) = (NormalNarrow == "normal") ?
        [true,false,true,true,true, true,false,true][index] :  // normal
        [true,false,true,true,false,true,false,false][index];  // narrow

module stud() {
    studDiameter = 4.85;
    studHeight = 1.8;

    realStudDiameter = studDiameter * StudRescale;
    cylinder(d=realStudDiameter, h=studHeight,false, $fn = 80);
}

module attach() {
    off=0.1;
    union() {
        difference() {
            union() {
                
                // Area to remove from tie
                difference () {
                    translate ([8-Wall,-4,0]) cube([35.2,8,TieHeight], false);
                    // Small notch at left end
                    tieNotchSlot = .1; // extra clearance 
                    translate ([6.4,-4-1,1.6-tieNotchSlot]) cube([1.6+tieNotchSlot,4+1,1.6+tieNotchSlot+FPOffset]);
                    if (bottom_open) {
                        difference() {
                            translate ([9.6,-2.4,-FPOffset]) cube ([32-TieHeight, 4.8, TieHeight-RoofThickness+FPOffset], false);
                            translate ([12,-3.3,-0.5]) attach_poly(4);
                            translate ([32,-4,-0.5]) cylinder(4,3-off,3+off,false, $fn = 80);
                        }
                    }
                    translate ([12,-4.11,-0.5]) attach_poly(4);
                }
                
                // Round connection point
                difference() {
                    union() {
                        translate ([16,-2.2,0]) cylinder(3.2,1,1,false, $fn = 80);
                        translate ([16,-4,0]) cylinder(3.2,1.95,1.95,false, $fn = 80);
                    }
                    translate ([16,-4,-0.5]) cylinder(4,.8,.8,false, $fn = 80);
                }
                
                // hole connection point additional material
                translate ([28,-3.4,0]) mirror([0,1,0]) attach_poly(3.2);
            }
            // hole in the hole connection point
            translate ([32,-4,-0.5]) cylinder(4,2-off,2+off,false, $fn = 80);
        }
        // end of tie left
        difference() {
            translate ([-8,-4,0]) cube([BlockWidth+Wall,BlockWidth,TieHeight], false);
            if (bottom_open)
                translate ([-8+Wall,-4+Wall,-FPOffset])
                    cube([BlockWidth -(2*Wall),BlockWidth -(2*Wall),TieHeight-RoofThickness+FPOffset],false);
        }
        
        // end of tie right
        difference() {
            translate ([Guage+8-Wall, -4, 0]) cube([BlockWidth+Wall,BlockWidth,TieHeight], false);
            if (bottom_open)
                translate ([Guage+8+Wall,-4+Wall,-FPOffset])
                    cube([BlockWidth -(2*Wall),BlockWidth -(2*Wall),TieHeight-RoofThickness+FPOffset],false);
        }           
        if (bottom_open) {
            translate([-8,-4, 0]) fill_bottom(1,1,TieHeight-RoofThickness);
            translate([Guage+8,-4, 0]) fill_bottom(1,1,TieHeight-RoofThickness);
        }
        // brace
        translate ([-BlockWidth,BlockWidth/2-Wall,0]) cube([Guage+3*BlockWidth, Wall, TieHeight]);
        
        // Studs
        for(index = [0:1:7]) {
            if(need_stud(index))
                translate ([-4+BlockWidth*index,0,3]) stud();
        }
    }
}

module narrow_attach(l) {
    union() {
        difference() {
            union() {
                difference() {
                    translate ([0,-4,0]) cube([48,8,TieHeight], false);
                    translate ([12,-4.11,-0.5]) attach_poly(4);
                    if (bottom_open) {
                        translate([Wall, -4+Wall, -FPOffset]) cube([BlockWidth-2*Wall, BlockWidth-2*Wall, TieHeight-RoofThickness+FPOffset]);
                        translate([BlockWidth*5+Wall, -4+Wall, -FPOffset]) cube([BlockWidth-2*Wall, BlockWidth-2*Wall, TieHeight-RoofThickness]);
                    }
                    if (bottom_open) {
                        translate([0,-4, 0]) fill_bottom(1,1,TieHeight-RoofThickness);
                        translate([BlockWidth*5,-4, 0]) fill_bottom(1,1,TieHeight-RoofThickness);
                    }
                }
                // Left Round connection point
                difference() {
                    union() {
                        translate ([16,-4,0]) cylinder(3.2,1.95,1.95,false, $fn = 80);
                        translate ([16,-2.2,0]) cylinder(3.2,1,1,false, $fn = 80);
                    }
                    translate ([16,-4,-0.5]) cylinder(4,.8,.8,false, $fn = 80);
                }
                // Right side connector area
                translate ([28,-3.4,0]) mirror([0,1,0]) attach_poly(3.2);        
            }
            // Hole in right side connector
            translate ([32,-4,-0.5]) cylinder(4,2.05,2.05,false, $fn = 80);
        }
        
        // Studs
        for(index = [0:1:7]) {
            if(need_stud(index))
                translate ([4+BlockWidth*index,0,3]) stud();
        }
    }
}

module normal_full_endpoint() {
    translate([0,-8,0]) rail_endpoint_left();
    translate([Guage,-8,0]) rail_endpoint_right();
    attach();
}

module narrow_full_endpoint() {
    difference() {
        union() {
            translate([0,-8,0]) narrow_rail_endpoint_left();
            translate([24,-8,0]) narrow_rail_endpoint_right();            
        }
        //support avoidance 1
        translate([-8,0,0.8]) rotate([-30,0,0]) translate([-5,-10,-5]) cube([60,20,5],false);
        //support avoidance 2
        translate([-6,-9,1.1]) rotate([0,-30,0]) cube([5,9,2],false);
    }
    difference() {
        translate([-8,0,0]) narrow_attach(0);
        translate([1.5,-12+4,-0.005]) cube([4.5,8,3.22],false);
    }
}

module full_endpoint() {
    if (NormalNarrow == "normal") normal_full_endpoint(); else narrow_full_endpoint();
}


module fill_bottom(width, length, height) {
// width is Y length is X
    wall_play = 0.0;
    post_wall_thickness = 0.85;
    total_posts_width = (PostDiameter * (width - 1)) + ((width - 2) * (StudSpacing - PostDiameter));
    total_posts_length = (PostDiameter * (length - 1)) + ((length - 2) * (StudSpacing - PostDiameter));
    total_pins_width = (PinDiameter * (width - 1)) + max(0, ((width - 2) * (StudSpacing - PinDiameter)));
    total_pins_length = (PinDiameter * (length - 1)) + max(0, ((length - 2) * (StudSpacing - PinDiameter)));
    overall_length = (length * StudSpacing) - (2 * wall_play);
    overall_width = (width * StudSpacing) - (2 * wall_play);
    
    module post() {
        difference() {
            cylinder(r=PostDiameter/2, h=height,$fn=40);
            translate([0,0,-FPOffset]) cylinder(r=(PostDiameter/2)-post_wall_thickness, h=height+FPOffset,$fn=40);
        }
    }
    
    // Interior splines to catch the studs.
    if (IncludeWallSplines == "yes") {
        // X Walls
        translate([StudSpacing / 2 - wall_play - (SplineThickness/2), 0, 0]) for (xcount = [0:length-1]) {
            translate([0,Wall,0]) translate([xcount * StudSpacing, 0, 0]) cube([SplineThickness, SplineLength, height]);
            translate([xcount * StudSpacing, overall_width - Wall -  SplineLength, 0]) cube([SplineThickness, SplineLength, height]);
         }
        // W Walls
        translate([0, StudSpacing / 2 - wall_play - (SplineThickness/2), 0]) for (ycount = [0:width-1]) {
            translate([Wall,0,0]) translate([0, ycount * StudSpacing, 0]) cube([SplineLength, SplineThickness, height]);
            translate([overall_length - Wall -  SplineLength, ycount * StudSpacing, 0]) cube([SplineLength, SplineThickness, height]);
        }
    }

    if (width > 1 && length > 1 ) {
    // posts
        translate([PostDiameter / 2, PostDiameter / 2, 0]) {
            translate([(overall_length - total_posts_length)/2, (overall_width - total_posts_width)/2, 0]) {
                union() {
                    // Posts
                    for (ycount=[1:width-1]) {
                        for (xcount=[1:length-1]) {
                            translate([(xcount-1)*StudSpacing,(ycount-1)*StudSpacing,0]) post();
                        }
                    }
                }
            }
        }
    }
                    
    // insert pins if X by 1 block
    if ((width == 1 || length == 1) && width != length) {
        if (width == 1) {
            translate([(PinDiameter/2) + (overall_length - total_pins_length) / 2, overall_width/2, 0]) {
                for (xcount=[1:length-1]) {
                    translate([(xcount-1)*StudSpacing,0,0]) cylinder(r=PinDiameter/2,h=height,$fn=40);
                }
            }
        }
        else {
            translate([overall_length/2, (PinDiameter/2) + (overall_width - total_pins_width) / 2, 0]) {
                for (ycount=[1:width-1]) {
                    translate([0,(ycount-1)*StudSpacing,0]) cylinder(r=PinDiameter/2,h=height,$fn=40);
                }
            }
        }
    }

}

module tie() {

   // end of tie left
   difference() {
        translate ([-8,-8,0]) cube([BlockWidth+Wall,BlockWidth*2,TieHeight], false);
        if (bottom_open) 
            translate ([-BlockWidth+Wall,-BlockWidth+Wall,-FPOffset]) 
                cube ([BlockWidth-2*Wall,2*BlockWidth-2*Wall,TieHeight-RoofThickness+FPOffset],false);    
    }
    if (bottom_open) translate([-BlockWidth, -BlockWidth, 0]) fill_bottom(2,1,TieHeight-RoofThickness);
    
    // end of tie right
    difference() {
        translate ([Guage+8-Wall,-BlockWidth, 0]) cube([9.6,16,3.2], false);
        if (bottom_open) 
            translate ([Guage+8+Wall,-(BlockWidth-Wall),-FPOffset]) 
                cube ([BlockWidth-2*Wall,2*BlockWidth-2*Wall,TieHeight-RoofThickness+FPOffset],false);
    }
    if (bottom_open) 
        translate([(Guage+BlockWidth), -BlockWidth, 0]) fill_bottom(2,1,TieHeight-RoofThickness);
        
    // middle
    difference() {
        union () {
            difference() {
                translate([6.4,-8,0]) cube([Guage-8+(2*Wall),16,TieHeight], false);  // Guage -8 accounts 1/2 rail block for each rail block
                if (bottom_open)
                    translate ([BlockWidth+Wall,-(BlockWidth-Wall),-FPOffset]) 
                        cube ([Guage-8-2*Wall,2*BlockWidth-2*Wall,TieHeight-RoofThickness+FPOffset],false);
            }
            if (bottom_open)translate([BlockWidth, -BlockWidth, 0]) fill_bottom(2,(Guage-8)/BlockWidth,TieHeight-RoofThickness);
        }
        // hole in the middle
        if (TieCenterHole == "yes")
            translate([(Guage+8)/2,0,-.5]) cylinder(r=CenterHoleRadius, h=5, center=false, $fn=40);
    }
    
    for(a=[-4,4])
        for(index = [0:1:7]) {
            if(need_stud(index))
                translate ([-4+BlockWidth*index,a,3]) stud();
    }

}

module mainStraight(length=120, ties=1) {
    rail_straight(length);
    translate([Guage,0,0]) rail_straight(length);
    
    full_endpoint();

    translate([Guage+8,length,0]) rotate([180,180,0]) full_endpoint();

    for (index = [1:1:ties]) {
        translate([0,(length+8)*(index/(ties+1))-4,0]) tie();
        }
  }
 
  
 //
 // Center Radius in blocks
 module mainCurved(angle=CurveAngle,CenterRadius=20,ties=1) {
    real_center_radius = CenterRadius*BlockWidth;
    inner_tie_radius = real_center_radius - 
        (NormalNarrow == "normal" ? 3*BlockWidth : 2*BlockWidth);
    outer_tie_radius = inner_tie_radius + Guage;

    // Move so tie is at 0,0,0
    translate([8,0,0]) {
        rail_curved(angle, inner_tie_radius);
        translate([Guage,0,0]) rail_curved(angle, outer_tie_radius);
    }
    translate([8,4,0])
        full_endpoint();
    
    // endpoint after rotate 180.180 on minus side with 8 on plus
    // so guage plus 16 moves to positive side with rail 8 out.  
    translate([-(inner_tie_radius-8),0,0]) 
        rotate([0,0,angle]) 
            translate([Guage+16+inner_tie_radius-8,-4,0]) 
                rotate([180,180,0])
                    full_endpoint();

     for (index = [1:1:ties]) {
        translate([-inner_tie_radius+8,0,0]) 
        rotate([0,0,angle*(index/(ties+1))])
        translate([inner_tie_radius,0,0]) tie();
    }
}


module main_crossing(length=120) {
    rail_straight(length);
    translate([Guage,0,0]) rail_straight(length);

    full_endpoint();

    translate([Guage+8,length,0]) rotate([180,180,0]) full_endpoint();
}
  
module crossing(l=120) {
  
    off=8*2;
  
    // Rails
    translate([-BlockWidth/2,0,0])rotate([0,0,90]) main_crossing(l-BlockWidth);
 
    // Left slope
    translate([-off/2,0,0]) sloped_side(l-off);

    // Right slope
    translate([-l+off/2,Guage+BlockWidth*1,0])rotate([0,0,180]) sloped_side(l-off);

    // Center section
    difference() {
        translate([-l+off/2,8,0]) {
            difference () {
                cube([l-off,Guage-8,8]);
                if (bottom_open) translate([Wall,Wall,-FPOffset]) cube([l-off-2*Wall,(Guage-8)-2*Wall, TieHeight-RoofThickness+FPOffset]);
            } 
            if (bottom_open) fill_bottom((Guage-8)/BlockWidth,(l-off)/BlockWidth,TieHeight-RoofThickness);
        }

    }
}
 
// sloped side
module sloped_side(l=100) {

    difference() {
   
        hull() {
            translate([-l,-2,0])  cube([l,2,8]);
            translate([-l,-40,0]) cube([l,2,2]);
        }

        if (bottom_open) translate([-l+Wall,-40+Wall,-FPOffset]) cube([l-2*Wall, 40-2*Wall, TieHeight-RoofThickness+FPOffset]);
    }

    if (bottom_open) translate([-l, Guage-BlockWidth+BlockWidth*2,0]) fill_bottom(5,l/BlockWidth, TieHeight-RoofThickness);
    x=10;
    // side 3x2 block
    translate([-0,-40,0]) {
        // Studs
        for (i=[0:8:(SideBlockWidth-1)*BlockWidth])
            for (j=[0:8:(SideBlockLength-1)*BlockWidth])
                translate ([4+i,4+j,3]) cylinder(d=StudDiameter,h=StudHeight, $fn = 50);
                
        difference () {
            cube([BlockWidth*SideBlockWidth, BlockWidth*SideBlockLength,TieHeight], false);
            if (bottom_open) translate([Wall, Wall, -FPOffset]) 
                cube([BlockWidth*SideBlockWidth-2*Wall, BlockWidth*SideBlockLength-2*Wall, TieHeight-RoofThickness+FPOffset]);
        }
        if (bottom_open) fill_bottom(SideBlockLength,SideBlockWidth,TieHeight-RoofThickness);
    }
    // side 3x2 block
    translate([-l-(BlockWidth*SideBlockWidth),-40,0]) {
        // Studs
        for (i=[0:8:(SideBlockWidth-1)*BlockWidth])
            for (j=[0:BlockWidth:(SideBlockLength-1)*BlockWidth])
                translate ([4+i,4+j,3]) cylinder(d=StudDiameter,h=StudHeight, $fn = 50);

          difference () {
            cube([BlockWidth*SideBlockWidth, BlockWidth*SideBlockLength,TieHeight], false);
            if (bottom_open) translate([Wall, Wall, -FPOffset]) cube([BlockWidth*SideBlockWidth-2*Wall, BlockWidth*SideBlockLength-2*Wall, TieHeight-RoofThickness+FPOffset]);
        }
        if (bottom_open) fill_bottom(SideBlockLength,SideBlockWidth,TieHeight-RoofThickness);
    }

}
 
/*
    MAIN CALL'S
*/

AdditionalLength = (StraightLength-1) * BlockWidth;
if (Type == "straight")
    mainStraight (AdditionalLength,ties=ties);
else if (Type == "curve") {
    %color("Lime")for(i=[0: 22.5: 90])rotate([0,0,i])
        translate([0,25,0])
            cube([1,400,1]);

    // Translate so angles show more easily
    translate([0,(CurveRadius*8-(NormalNarrow=="normal" ? 32: 24)),0])
    rotate([0,0,90]) mainCurved(angle=CurveAngle, CenterRadius=CurveRadius, ties=ties);
    }
else if (Type == "crossing")
    crossing(CrossingLength*8);
else if (Type =="test")
{
    tie();
    translate([0,-8,0]) rail_straight(16);
    translate([Guage,-8,0]) rail_straight(16);
}   
  
  

/*
module negative_bend(angle,diameter)
{
    rotate([0,90,0])
    translate([-diameter,0,+8])
    rotate([0,0,-angle])
    rotate_extrude(angle = angle, $fn = 300)
    translate([diameter,0,0])
    rotate([0,0,180]) 
    polygon(railProfile);

}
module rail_curved2(angle, diameter) {
    //rotate([0,-90,0])
    //translate([diameter,0,]) 
    //rotate (-angle)
    //translate ([-2*diameter,0,0])
    //translate([0,100.0])
    //
    translate([0,length-length/2*cos(angle1)-length/2,length/2])
    union () {
        rotate([0,-90,0])
        translate([-diameter,-8,-8])
 
        rotate_extrude(angle = angle, $fn = 300)
        translate([diameter,0,0])
        polygon(railProfile);
    }
   
}
angle1 = 30;
angle2 = 60;
length=100;
length2=50;
length3=75;

negative_bend(angle1,length);
echo(sin(angle1), cos(angle1));
translate([0,-length*sin(angle1),length-length*cos(angle1)])
rotate([-angle1,0,0])
translate([0,-length2+0,0])
rail_straight(length2);
rail_curved2(angle2,length2);
//translate([Guage,0,0]) rail_curved2(45,100);   
*/
