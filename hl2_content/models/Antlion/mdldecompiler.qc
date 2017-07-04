$cd "C:\Documents and Settings\Sam\Desktop\antlion_content\models\AntLion"
$modelname "Antlion.mdl"
$model "studio" "AntLion_reference.smd"

$lod 15
 {
  replacemodel "AntLion_reference" "lod1_AntLion_reference"
}
$lod 30
 {
  replacemodel "AntLion_reference" "lod2_AntLion_reference"
}
$lod 55
 {
  replacemodel "AntLion_reference" "lod3_AntLion_reference"
}
$lod 85
 {
  replacemodel "AntLion_reference" "lod4_AntLion_reference"
}
$shadowlod
{
  replacemodel "AntLion_reference" "lod5_AntLion_reference"
}
$model "wings" "UnknownModelName.smd"

$lod 15
 {
  replacemodel "UnknownModelName" "lod1_UnknownModelName"
}
$lod 30
 {
  replacemodel "UnknownModelName" "lod2_UnknownModelName"
}
$lod 55
 {
  replacemodel "UnknownModelName" "lod3_UnknownModelName"
}
$lod 85
 {
  replacemodel "UnknownModelName" "lod4_UnknownModelName"
}
$shadowlod
{
  replacemodel "UnknownModelName" "lod5_UnknownModelName"
}
$model "wings" "wings_reference.smd"

$lod 15
 {
  replacemodel "wings_reference" "lod1_wings_reference"
}
$lod 30
 {
  replacemodel "wings_reference" "lod2_wings_reference"
}
$lod 55
 {
  replacemodel "wings_reference" "lod3_wings_reference"
}
$lod 85
 {
  replacemodel "wings_reference" "lod4_wings_reference"
}
$shadowlod
{
  replacemodel "wings_reference" "lod5_wings_reference"
}
$poseparameter move_yaw -180.00 180.00
$poseparameter head_pitch -40.00 40.00
$poseparameter head_yaw -40.00 40.00
$cdmaterials "models\antlion\"
$texturegroup skinfamilies
{
	{"antlionhigh_sheet.vmt"
 "antlionhigh_sheet2.vmt"
}
 	{"antlionhigh_sheet2.vmt"
 "antlionhigh_sheet2.vmt"
}
 	{"antlionhigh_sheet3.vmt"
 "antlionhigh_sheet2.vmt"
}
 	{"antlionhigh_sheet4.vmt"
 "antlionhigh_sheet2.vmt"
}
 }
$hboxset "default"
$hbox 0 "Antlion.Body_Bone" -8.560  -8.140  -9.910  3.880  7.860  10.060
$hbox 0 "Antlion.Head_Bone" -19.010  -7.770  -8.940  0.990  9.230  9.060
$hbox 0 "Antlion.LegMidL1_Bone" -0.960  -2.450  -2.320  11.040  2.550  0.680
$hbox 0 "Antlion.LegMidL2_Bone" 0.000  -1.540  -1.470  24.900  2.750  1.530
$hbox 0 "Antlion.LegMidL3_Bone" -1.290  -3.990  -1.050  28.710  1.010  1.950
$hbox 0 "Antlion.LegMidR1_Bone" 0.260  -3.030  -2.290  12.260  1.980  0.710
$hbox 0 "Antlion.LegMidR2_Bone" 0.000  -2.500  -2.570  26.000  2.500  0.430
$hbox 0 "Antlion.LegMidR3_Bone" 0.000  -1.860  -1.420  30.000  3.860  1.580
$hbox 0 "Antlion.Back_Bone" -3.340  -9.000  -13.560  33.440  13.000  13.440
$hbox 0 "Antlion.LegL1_Bone" -4.150  -2.540  -3.120  24.940  4.150  2.900
$hbox 0 "Antlion.LegL2_Bone" -3.930  -2.560  -2.890  30.470  4.070  2.220
$hbox 0 "Antlion.LegL3_Bone" -2.030  -4.060  -2.600  46.210  1.500  3.170
$hbox 0 "Antlion.LegR1_Bone" -4.460  -2.220  -2.460  24.460  5.690  3.510
$hbox 0 "Antlion.LegR2_Bone" -6.210  -2.370  -2.070  28.200  4.180  3.200
$hbox 0 "Antlion.LegR3_Bone" -1.920  -4.250  -3.040  46.320  1.310  2.730
$attachment "leftfront" "Antlion.LegR3_Bone" 46.00 -0.00 -0.00 rotate 0.00 -0.00 0.00
$attachment "rightfront" "Antlion.LegL3_Bone" 46.00 0.00 0.00 rotate 0.00 0.00 -0.00
$attachment "leftrear" "Antlion.LegMidL3_Bone" 30.00 0.00 -0.00 rotate 0.00 0.00 0.00
$attachment "rightrear" "Antlion.LegMidR3_Bone" 30.00 0.00 -0.00 rotate 0.00 -0.00 -0.00
$surfaceprop "antlion"
$eyeposition -0.000 0.000 24.000
$illumposition 4.591 -0.140 31.068
$sequence Idle "Idle" loop ACT_IDLE 1 fps 30.00
$sequence DistractIdle2 "DistractIdle2" loop ACT_IDLE 1 fps 30.00
$sequence DistractIdle3 "DistractIdle3" loop ACT_IDLE 1 fps 30.00
$sequence DistractIdle4 "DistractIdle4" loop ACT_IDLE 1 fps 30.00
$animation a_WalkS "a_WalkS" loop fps 30.000000
$animation a_WalkSE "a_WalkSE" loop fps 30.000000
$animation a_WalkE "a_WalkE" loop fps 30.000000
$animation a_WalkNE "a_WalkNE" loop fps 30.000000
$animation a_WalkN "a_WalkN" loop fps 30.000000
$animation a_WalkNW "a_WalkNW" loop fps 30.000000
$animation a_WalkW "a_WalkW" loop fps 30.000000
$animation a_WalkSW "a_WalkSW" loop fps 30.000000
$animation a_WalkS "a_WalkS" loop fps 30.000000
$sequence walk_all "a_WalkS" loop ACT_WALK 1 fps 30.00 node walking {
  { event AE_ANTLION_WALK_FOOTSTEP 1 }
  { event AE_ANTLION_FOOTSTEP_SOFT 9 }
  { event AE_ANTLION_WALK_FOOTSTEP 11 }
  { event AE_ANTLION_FOOTSTEP_SOFT 19 }
  blendwidth 9
  blend move_yaw -180.000000 180.000000
  blend move_yaw -180.000000 180.000000
 a_WalkS a_WalkSE a_WalkE a_WalkNE a_WalkN a_WalkNW a_WalkW a_WalkSW a_WalkS
}
$animation a_WalkS "a_WalkS" loop fps 30.000000
$animation a_WalkSE "a_WalkSE" loop fps 30.000000
$animation a_ScuttleRt "a_ScuttleRt" loop fps 30.000000
$animation a_WalkNEfast "a_WalkNEfast" loop fps 45.000000
$animation a_RunN "a_RunN" loop fps 30.000000
$animation a_WalkNWfast "a_WalkNWfast" loop fps 45.000000
$animation a_ScuttleLeft "a_ScuttleLeft" loop fps 30.000000
$animation a_WalkSW "a_WalkSW" loop fps 30.000000
$animation a_WalkS "a_WalkS" loop fps 30.000000
$sequence run_all "a_WalkS" loop ACT_RUN 1 fps 30.00 node walking {
  { event AE_ANTLION_WALK_FOOTSTEP 1 }
  { event AE_ANTLION_FOOTSTEP_SOFT 9 }
  { event AE_ANTLION_WALK_FOOTSTEP 11 }
  { event AE_ANTLION_FOOTSTEP_SOFT 19 }
  blendwidth 9
  blend move_yaw -180.000000 180.000000
  blend move_yaw -180.000000 180.000000
 a_WalkS a_WalkSE a_ScuttleRt a_WalkNEfast a_RunN a_WalkNWfast a_ScuttleLeft a_WalkSW a_WalkS
}
$animation a_ScuttleRt "a_ScuttleRt" loop fps 30.000000
$sequence ScuttleRt "a_ScuttleRt" loop ACT_ANTLION_SIDESTEP_RIGHT 1 fps 30.00 {
  { event AE_ANTLION_WALK_FOOTSTEP 5 }
  { event AE_ANTLION_FOOTSTEP_SOFT 7 }
  { event AE_ANTLION_WALK_FOOTSTEP 12 }
  { event AE_ANTLION_FOOTSTEP_SOFT 14 }
}

$animation a_ScuttleLeft "a_ScuttleLeft" loop fps 30.000000
$sequence ScuttleLeft "a_ScuttleLeft" loop ACT_ANTLION_SIDESTEP_LEFT 1 fps 30.00 {
  { event AE_ANTLION_WALK_FOOTSTEP 5 }
  { event AE_ANTLION_FOOTSTEP_SOFT 7 }
  { event AE_ANTLION_WALK_FOOTSTEP 12 }
  { event AE_ANTLION_FOOTSTEP_SOFT 14 }
}

$sequence RunAgitated "RunAgitated" loop ACT_ANTLION_RUN_AGITATED 1 fps 30.00
$sequence Flip1 "Flip1" ACT_ANTLION_FLIP 1 fps 30.00
$sequence attack1 "attack1" ACT_MELEE_ATTACK1 1 fps 30.00 {
  { event AE_ANTLION_MELEE1_SOUND 0 }
  { event AE_ANTLION_MELEE_HIT1 19 }
}

$sequence attack2 "attack2" ACT_MELEE_ATTACK1 1 fps 30.00 {
  { event AE_ANTLION_MELEE2_SOUND 0 }
  { event AE_ANTLION_MELEE_HIT1 17 }
}

$sequence attack3 "attack3" ACT_MELEE_ATTACK1 1 fps 30.00 {
  { event AE_ANTLION_MELEE1_SOUND 0 }
  { event AE_ANTLION_MELEE_HIT1 16 }
}

$sequence attack4 "attack4" ACT_MELEE_ATTACK1 1 fps 30.00 {
  { event AE_ANTLION_MELEE1_SOUND 0 }
  { event AE_ANTLION_MELEE_HIT1 16 }
}

$sequence attack5 "attack5" ACT_MELEE_ATTACK1 1 fps 30.00 {
  { event AE_ANTLION_MELEE1_SOUND 0 }
  { event AE_ANTLION_MELEE_HIT1 16 }
}

$sequence attack6 "attack6" ACT_MELEE_ATTACK1 1 fps 30.00 {
  { event AE_ANTLION_MELEE1_SOUND 0 }
  { event AE_ANTLION_MELEE_HIT1 16 }
}

$sequence charge_start "charge_start" ACT_ANTLION_CHARGE_IN 1 fps 30.00 {
  { event 26 0 }
  { event AE_ANTLION_FOOTSTEP_HEAVY 18 }
  { event AE_ANTLION_FOOTSTEP_HEAVY 20 }
}

$animation a_charge_run "a_charge_run" loop fps 30.000000
$sequence charge_run "a_charge_run" loop ACT_ANTLION_CHARGE_LOOP 1 fps 30.00 {
  { event AE_ANTLION_FOOTSTEP_HEAVY 1 }
  { event AE_ANTLION_FOOTSTEP_HEAVY 3 }
  { event AE_ANTLION_FOOTSTEP_HEAVY 7 }
  { event AE_ANTLION_FOOTSTEP_HEAVY 9 }
}

$sequence charge_end "charge_end" ACT_ANTLION_CHARGE_OUT 1 fps 30.00 {
  { event AE_ANTLION_MELEE_POUNCE 9 }
  { event AE_ANTLION_FOOTSTEP_HEAVY 1 }
  { event AE_ANTLION_FOOTSTEP_HEAVY 3 }
  { event AE_ANTLION_FOOTSTEP_HEAVY 4 }
  { event AE_ANTLION_FOOTSTEP_HEAVY 19 }
}

$sequence pounce "pounce" ACT_ANTLION_POUNCE 1 fps 30.00 {
  { event AE_ANTLION_MELEE_POUNCE 18 }
}

$sequence pounce2 "pounce2" ACT_ANTLION_POUNCE_MOVING 1 fps 30.00 {
  { event AE_ANTLION_MELEE_POUNCE 9 }
}

$sequence distract "distract" ACT_ANTLION_DISTRACT 1 fps 30.00 {
  { event AE_ANTLION_OPEN_WINGS 40 }
  { event AE_ANTLION_CLOSE_WINGS 60 }
}

$sequence distract_arrived "distract_arrived" ACT_ANTLION_DISTRACT_ARRIVED 1 fps 30.00
$sequence jump_start "jump_start" ACT_JUMP 1 fps 30.00 {
  { event AE_ANTLION_OPEN_WINGS 0 }
}

$sequence jump_glide "jump_glide" loop ACT_GLIDE 1 fps 30.00
$sequence jump_stop "jump_stop" ACT_ANTLION_LAND 1 fps 30.00 {
  { event AE_ANTLION_CLOSE_WINGS 10 }
}

$sequence fly_in "fly_in" ACT_ANTLION_JUMP_START 1 fps 30.00 {
  { event AE_ANTLION_START_JUMP 17 }
  { event AE_ANTLION_OPEN_WINGS 17 }
}

$sequence turn_right "turn_right" loop ACT_TURN_RIGHT 1 fps 30.00
$sequence turn_left "turn_left" loop ACT_TURN_LEFT 1 fps 30.00
$sequence digin "digin" ACT_ANTLION_BURROW_IN 1 fps 60.00 {
  { event AE_ANTLION_BURROW_IN 22 }
  { event AE_ANTLION_VANISH 60 }
}

$sequence digout "digout" ACT_ANTLION_BURROW_OUT 1 fps 30.00 {
  { event AE_ANTLION_BURROW_OUT 1 }
}

$sequence drown "drown" loop ACT_ANTLION_DROWN 1 fps 30.00
$sequence digidle "digidle" loop ACT_ANTLION_BURROW_IDLE 1 fps 30.00
$sequence touchtest "touchtest" fps 30.00
$sequence frustration "frustration" ACT_ANTLION_FRUSTRATION1 1 fps 30.00
$sequence headturn "headturn" fps 30.00
$animation mdldecompiler_delta.smd "mdldecompiler_delta.smd" fps 30
$animation head_up "head_up" fps 30.000000 subtract mdldecompiler_delta.smd 0

$animation head_down "head_down" fps 30.000000 subtract mdldecompiler_delta.smd 0

$sequence head_pitch "head_up" fps 30.00 {
  blendwidth 2
  blend head_pitch -40.000000 40.000000
  delta
  autoplay
 head_up head_down
}
$animation head_right "head_right" fps 30.000000 subtract mdldecompiler_delta.smd 0

$animation head_left "head_left" fps 30.000000 subtract mdldecompiler_delta.smd 0

$sequence head_yaw "head_right" fps 30.00 {
  blendwidth 2
  blend head_yaw -40.000000 40.000000
  delta
  autoplay
 head_right head_left
}
$sequence ragdoll "ragdoll" ACT_DIERAGDOLL 1 fps 30.00
