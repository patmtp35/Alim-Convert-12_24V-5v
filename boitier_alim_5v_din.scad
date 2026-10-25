// Boîtier DIN 3 modules - alim 24V -> 5V + porte-fusible 5x20
// Unités : mm. Choisir la pièce avec 'piece' : "plaque" (tout imprimer d'un coup), "base", "couvercle", "clip", "assemble"
piece = "plaque";

// ---------- Boîtier ----------
W = 54;          // largeur (3 modules)
H = 90;          // hauteur (axe vertical sur le rail)
wall = 2;        // parois
floor_t = 3;     // fond
lid_t = 2;       // couvercle
clip_t = 4;      // épaisseur plaque du clip rail
D = 45 - clip_t; // face avant à 45 mm du plan des ailes du rail (à ajuster au SoyoSource)
Zb = D - lid_t;  // hauteur des parois depuis la face arrière du fond
tol = 0.3;

// ---------- Convertisseur ----------
cv_l = 63.15;  cv_w = 27.30;  cv_h = 12.80;
cv_x = -10.85;               // centre X (collé au côté gauche)
cv_y = 0;
stand = 3;                   // hauteur des plots sous le PCB

// ---------- Porte-fusible ----------
f_l = 26.5;  f_w = 9.15;     // capot transparent : longueur x largeur (passe pile dans la fenêtre)
cap_h = 10.80;               // hauteur du capot transparent
y_l = 23.33;  y_w = 10.0;  y_h = 6.30;  // corps jaune : longueur, largeur, hauteur
// le bloc complet s'insère PAR DESSOUS : fenêtre haute = cotes du capot, logement bas élargi pour le jaune
f_x = 17.3;  f_y = -24;      // position (côté entrée, bas)
f_wall = 1.6;
f_sink = 0.5;                // capot en retrait par rapport à la face avant

// ---------- Gravure du couvercle ----------
label_txt = "Convert 24/12 => 5V";
label_size = 3.6;     // hauteur des lettres (texte ~40 mm de large)
label_depth = 0.6;    // 3 couches à 0,2 mm
label_x = 0;  label_y = 25;   // zone libre, loin de la fenêtre du fusible (y de -37 à -10)

// ---------- Fixations ----------
screw_pos = [[-21,-39],[21,39]];   // vis couvercle (diagonale)
boss_z = 22;                       // début des bossages : au-dessus du convertisseur (haut à 18,8) et des câbles (19,5)
clip_screws = [[7,-4],[7,12]];     // vis du clip

// ---------- Clip rail 35 mm ----------
rail_edge = 17.5;  fl_t = 1.0;  cl = 0.4;
clip_x0 = -8;  clip_len = 30;

module ext_x(len) rotate([90,0,90]) linear_extrude(len) children();

module base() {
  difference() {
    union() {
      difference() {
        translate([-W/2,-H/2,0]) cube([W,H,Zb]);
        translate([-W/2+wall,-H/2+wall,floor_t]) cube([W-2*wall,H-2*wall,Zb]);
      }
      // plots PCB + butées convertisseur
      for (sx=[-1,1], sy=[-1,1]) {
        translate([cv_x+sx*(cv_w/2-2.5)-2.5, cv_y+sy*(cv_l/2-2.5)-2.5, floor_t]) cube([5,5,stand]);
        translate([cv_x+sx*(cv_w/2+tol+0.6)-0.6, cv_y+sy*(cv_l/2-3)-3, floor_t]) cube([1.2,6,stand+3]);
        translate([cv_x+sx*(cv_w/2-2)-2, cv_y+sy*(cv_l/2+tol+0.6)-0.6, floor_t]) cube([4,1.2,stand+3]);
      }
      // bossages vis couvercle
      // (démarrent au-dessus du convertisseur et de l'ouverture câbles, rattachés au coin des parois,
      //  dessous incliné pour s'imprimer sans support)
      for (p=screw_pos) {
        sx = p[0]>0 ? 1 : -1;  sy = p[1]>0 ? 1 : -1;
        hull() {
          translate([p[0],p[1],boss_z]) cylinder(d=1,h=0.01,$fn=16);
          translate([p[0],p[1],boss_z+3]) cylinder(d=7,h=Zb-boss_z-3,$fn=32);
          translate([sx>0 ? W/2-wall-1 : -W/2+wall-0.2, sy>0 ? H/2-wall-1 : -H/2+wall-0.2, boss_z+3])
            cube([1.2,1.2,Zb-boss_z-3]);
        }
      }
    }
    for (p=screw_pos) translate([p[0],p[1],Zb-12]) cylinder(d=2.6,h=13,$fn=24);
    // ouvertures câbles / connecteurs aux 2 extrémités
    for (s=[-1,1]) translate([cv_x-cv_w/2+1.5, s*(H/2-wall/2)-wall, floor_t+1.5]) cube([cv_w-3,wall*2,15]);
    // trous vis du clip (tête noyée côté intérieur)
    for (p=clip_screws) {
      translate([p[0],p[1],-1]) cylinder(d=3.4,h=floor_t+2,$fn=24);
      translate([p[0],p[1],floor_t-1.7]) cylinder(d1=3.4,d2=6.2,h=1.71,$fn=24);
    }
  }
}

module couvercle() {
  top = Zb+lid_t;
  z_cap = top - f_sink - cap_h;          // bas du capot = plan d'appui du jaune (épaulement)
  z_low = z_cap - y_h - 0.5;             // bas du logement jaune (ouvert vers le dessous)
  ix = f_w+tol;  iy = f_l+tol;           // fenêtre haute : capot transparent
  lx = y_w+tol;  ly = iy;                // logement bas : élargi en X pour le jaune, même longueur pour laisser passer le capot
  difference() {
    union() {
      translate([-W/2,-H/2,Zb]) cube([W,H,lid_t]);
      // 4 ergots de centrage (pas dans les coins)
      for (sx=[-1,1]) translate([sx*(W/2-wall-0.2-0.6)-0.6,-12,Zb-4]) cube([1.2,24,4]);
      for (sy=[-1,1]) translate([-8,sy*(H/2-wall-0.2-0.6)-0.6,Zb-4]) cube([16,1.2,4]);
      // niche du porte-fusible, suspendue au couvercle
      translate([f_x-lx/2-f_wall, f_y-ly/2-f_wall, z_low])
        cube([lx+2*f_wall, ly+2*f_wall, Zb-z_low+0.01]);
    }
    // logement bas pour le corps jaune (ouvert vers le dessous)
    translate([f_x-lx/2, f_y-ly/2, z_low-1]) cube([lx, ly, z_cap-z_low+1]);
    // fenêtre haute : cotes du capot transparent, jusqu'à la face avant
    translate([f_x-ix/2, f_y-iy/2, z_cap-0.01]) cube([ix, iy, top-z_cap+1]);
    for (p=screw_pos) {
      translate([p[0],p[1],Zb-1]) cylinder(d=3.4,h=lid_t+2,$fn=24);
      translate([p[0],p[1],top-1.7]) cylinder(d1=3.4,d2=6.2,h=1.71,$fn=24);
    }
    // gravure sur la face avant (lisible une fois le boîtier monté sur le rail)
    translate([label_x,label_y,top-label_depth])
      linear_extrude(label_depth+1)
        text(label_txt, size=label_size, font="Liberation Sans:style=Bold", halign="center", valign="center");
  }
}

// Clip dans sa position de montage (z<0 = côté rail), avec les trous de fixation
// alignés sur ceux de la base (même variable clip_screws)
module clip_mount() {
  difference() {
    clip_body();
    // trous pour vis M3 autotaraudeuses (pré-trou 2,6 mm), traversent la plaque du clip
    for (p=clip_screws) translate([p[0],p[1],-clip_t-0.01]) cylinder(d=2.6,h=clip_t+0.02,$fn=24);
  }
}

module clip_body() {
  z0 = -clip_t;                  // plan de contact avec les ailes du rail
  zb = z0 - fl_t - 0.3;          // dessus de la lèvre (sous l'aile)
  zl = zb - 1.5;                 // bas de la lèvre
  hy = rail_edge + cl;           // face intérieure du crochet
  // plaque + crochet haut rigide
  translate([clip_x0,0,0]) ext_x(clip_len)
    polygon([[-16.4,z0],[hy,z0],[hy,zb],[hy-2.2,zb],[hy-0.7,zl],[hy+2,zl],[hy+2,0],[-16.4,0]]);
  // bas : lame flexible parallèle au rail (flexion en Y), lèvre à l'extrémité libre
  translate([clip_x0,0,0]) {
    translate([0,-19.5,-4]) cube([6,4.5,4]);                       // pied de la lame
    translate([5,-19.5,zl]) cube([clip_len-5,1.6,-0.4-zl]);        // lame
    translate([clip_len-8,0,0]) ext_x(8)                            // lèvre
      polygon([[-hy-0.2,zb],[-hy+2.2,zb],[-hy+0.7,zl],[-hy-0.2,zl]]);
    translate([clip_len-4,-24,zl]) cube([4,4.6,4]);                // poignée de déverrouillage
  }
}

// Clip orienté pour l'impression (plaque à plat, crochets vers le haut)
module clip() { rotate([180,0,0]) clip_mount(); }

// Couvercle retourné (face avant sur le plateau) pour l'impression
module couvercle_print() translate([0,0,Zb+lid_t]) rotate([180,0,0]) couvercle();

// Vue "plaque" : les 3 pièces à plat sur un plateau 220 x 220 (Ender 3 V3 KE)
module plaque() {
  translate([-32,0,0]) base();
  translate([ 32,0,0]) couvercle_print();
  translate([ -7,75,0]) clip();
}

if (piece=="plaque") plaque();
else if (piece=="base") base();
else if (piece=="couvercle") couvercle_print();
else if (piece=="clip") clip();
else { base(); couvercle(); color("orange") clip_mount(); }
