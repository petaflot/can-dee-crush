use <scadlib.scad>
/*
 * can-di-crush : quelle tuile!
 *
 * machine à faire des tuiles avec des canettes de bière
 *
 * les crushers ont des ressorts forts avec une petite course ; on veut
 * appuyer avec assez de force
 *
 * les crushers sont activés à l'aide de bielles ; d'abord on écrase le milieu
 * de la canette puis ensuite les extrémités, d'abord en bas puis en haut
 *
 * les tuiles à partir canettes standard seront probablement moins belles mais
 * on peut les jeter si on veut.. qui boit du coca de toute façon?
 *
 * à priori, on veut éviter les canettes slim
 *
 * dans l'idéal, le bas de la machine collecte les canettes de sorte à en faire 
 * une jolie pile avec les tuiles orientées toujours dans le même sens
 *
 * Notes:
 * - les ressorts sont les bielles et ne sont pas dessinés
 * - les canettes ne sont pas cachées quand elles devraient, parce qu'OpenSCAD
 *   c'est bien mais pas top
 * - si on met un gate, on peut avoir un machin qui tourne en permanence (par 
 *   par exemple avec une éolienne) ; c'est préférable même si on a un moteur
 *   activé par exemple avec un barrage optique
 * - l'alimentation se fait via un tube (qui fait aussi office de réservoir)
 *   et il faut un genre d'entonnoir à l'entrée de la machine
 * - la machine est légèrement inclinée pour que les canettes tombent pas par 
 *   la fenêtre de debug
 *
 */

fn=32;
g=9810; // mm/s²
x0=186;

crush_offset=53;
course=100;

//gate_offset=160;
//course2=150;	// course du gate

diam_vlb=180;	// diamètre du vilebrequin

/*
 * une canette 50cl
 */
module classic_long() {
	prism(fn,[66,66,186]);
}

cz=5;	// épaisseur des plaques du chassis
cy=110;	// largeur du chassis (intérieur)
vz=10;	// épaisseur des disques du vilebrequin
vj=.5;	// jeu entre les disques du vilebrequin et le chassis

segments=2;


function tval(t,min,max) = .5;	// should range from 0.0 to <1.0
function time(min, max) = ($t < min || $t > max) ? undef : tval($t,min,max);

module anim(min, max, squeeze) {
    //$a = time(segment / segments, (segment + 1) / segments, p);
    $a = time( min, max);
    if (!is_undef($a))
    	if (squeeze) {
        scale([$a,1,1])
            children();
	} else {
            children();
	}
}



// vilebrequin partiel
module vlbrq( phase, offset, h )
{
	translate([300,0,0])
	{
		rotate([0,0,($t*360)+phase+crush_offset+180])
		{
			// roue dentée du haut
			translate([0,0,-h/2+cz/2+vz/2+vj]) prism(fn*2, [diam_vlb, diam_vlb, vz], center=[true, true, true]);
			// axe de la bielle
			translate([offset, 0, 0]) prism(fn, [10,10,h-cz-2*vj], center=[true, true, true]);
			// roue dentée du bas
			translate([0,0,h/2-cz/2-vz/2-vj]) prism(fn*2, [diam_vlb, diam_vlb, vz], center=[true, true, true]);
		}
		// ça c'est pour répartir les forces (couple et pression) de sorte à pas casser la machine
		translate([diam_vlb*.75,0,0]) rotate([0,0,-$t*360*2])
		{
			// contre-roue dentée du haut
			translate([0,0,-h/2+cz/2+vz/2+vj]) prism(fn, [diam_vlb/2, diam_vlb/2, vz], center=[true, true, true]);
			// contre-roue dentée du bas
			translate([0,0,h/2-cz/2-vz/2-vj]) prism(fn, [diam_vlb/2, diam_vlb/2, vz], center=[true, true, true]);
		}
	}
}

rotate([-5,-5,0])
{
	// la canette qui sera la suivante à tomber (retenue par le gate)
	//translate([33,0,186*2]) color("green") classic_long();
	
	// la canette qui tombe dans le crusher
	anim( 0, .2, false )
	translate([33,0,-1/2*g*$t*$t+x0]) color("blue") classic_long();
	
	// la canette qui est dans le crusher
	anim( .2, .8, true )
	translate([33,0,0]) color("blue") classic_long();
	
	// la canette écrasée qui tombe hors de l'appareil
	t2=$t-.8;
	anim( .8, 1, false ) translate([0,0,-1/2*g*t2*t2]) color("blue")
	{
		 translate([2,0,0]) rotate([0,-90,0]) prism(fn, [66,103,2], center=[false,true,false], oblong=false);
		 translate([0,0,66/2]) prism(0,[2,103,186-66], center=[false,true,false]);
		 translate([2,0,186-66]) rotate([0,-90,0]) prism(fn, [66,103,2], center=[false,true,false], oblong=false);
	}
	
	// gate ; empêche les canettes d'entrer au mauvais moment
	//translate([course2/2+sin($t*360-gate_offset)*course2/2,0,186*2]) //color("#808080")
	//{
	//	difference()
	//	{
	//		translate([-25,0,1]) prism(0,[25,105,186-2], center=[false, true, false]);
	//		translate([0,0,0]) translate([-33,0,0]) classic_long();
	//	}
	//	prism(0,[100,105,186], center=[false, true, false]);
	//}
	//vlbrq( course2/2 );
	
	// crusher
	translate([course/2+sin($t*360-35+crush_offset)*course/2,0,186-35]) color("#c0c0c0") prism(0,[100,105,70-cz-2*vj], center=[false, true, true]);
	translate([0,0,35]) vlbrq( 35, course/2, 70 );
	translate([course/2+sin($t*360+crush_offset)*course/2,0,186/2]) color("#a0a0a0") prism(0,[100,105,186-140-cz-2*vj], center=[false, true, true]);
	translate([0,0,186/2]) vlbrq( 90, course/2, 186-140-2 );
	translate([course/2+sin($t*360-60+crush_offset)*course/2,0,35]) color("#707070") prism(0,[100,105,70-cz-2*vj], center=[false, true, true]);
	translate([0,0,186-35]) vlbrq( 60, course/2, 70 );
	
	dt=72;	// diamètre du trou de canette
	
	// chassis
	translate([5,0,0]) color("orange") prism(0, [500-5,cy,cz], center=[false, true, true]);
	translate([70,0,70]) color("orange") prism(0, [500-70,cy,cz], center=[false, true, true]);
	translate([70,0,186-70]) color("orange") prism(0, [500-70,cy,cz], center=[false, true, true]);
	translate([0,0,186]) color("orange")
	difference()
	{
		prism(0, [500,cy,cz], center=[false, true, true]);
		translate([-(dt-66)/2,0,0]) prism(fn, [dt,dt,cz+1], center=[false, true, true]);
	}
	// contre-sabot
	translate([-cz,0,-cz/2]) color("orange") prism(0, [cz,cy,186+cz], center=[false, true, false]);
	
	// guides latéraux ; un côté reste est laissé ouvert exprès
	translate([-cz,cy/2,-cz/2]) color("orange") prism(0, [200,cz,186+cz], center=[false, false, false]);
	translate([dt,-cy/2-cz,-cz/2]) color("orange") prism(0, [200-dt,cz,186+cz], center=[false, false, false]);
	
	
	// arbre d'entraînement
	translate([300+diam_vlb*.75,0,-50]) rotate([0,0,-$t*360]) color("yellow") prism($fn, [10,10,300]);
}
