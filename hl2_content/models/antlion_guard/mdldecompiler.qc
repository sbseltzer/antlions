$cd "C:\Documents and Settings\Sam\Desktop\antlion_content\models\antlion_guard"
$modelname "antlion_guard.mdl"
$model "studio" "Antlion_guard_reference.smd"

$lod 18
 {
  replacemodel "Antlion_guard_reference" "lod1_Antlion_guard_reference"
}
$lod 30
 {
  replacemodel "Antlion_guard_reference" "lod2_Antlion_guard_reference"
}
$lod 48
 {
  replacemodel "Antlion_guard_reference" "lod3_Antlion_guard_reference"
}
$lod 108
 {
  replacemodel "Antlion_guard_reference" "lod4_Antlion_guard_reference"
}
$shadowlod
{
  replacemodel "Antlion_guard_reference" "lod5_Antlion_guard_reference"
}
$poseparameter move_yaw -180.00 180.00
$poseparameter throw -45.00 45.00
$poseparameter head_pitch -30.00 90.00
$poseparameter head_yaw -80.00 80.00
$cdmaterials "models\antlion_guard\"
$hboxset "default"
$hbox 0 "Antlion_Guard.body" -5.960  -10.230  -9.330  24.040  9.770  8.670
$hbox 0 "Antlion_Guard.spine1" -4.690  -17.000  -9.330  25.310  13.000  8.670
$hbox 0 "Antlion_Guard.spine2" -6.680  -9.000  -9.330  18.330  11.000  8.670
$hbox 0 "Antlion_Guard.spine3" -7.870  -11.480  -9.330  27.130  13.520  8.670
$hbox 0 "Antlion_Guard.head" -5.500  -12.000  -7.830  19.500  6.000  7.170
$hbox 0 "Antlion_Guard.claw1_L" -5.000  -3.000  -1.500  35.000  4.000  4.500
$hbox 0 "Antlion_Guard.claw2_L" -1.960  -3.000  -0.530  38.040  5.000  5.470
$hbox 0 "Antlion_Guard.claw3_L" -0.320  -3.500  -0.460  59.680  3.500  4.540
$hbox 0 "Antlion_Guard.claw1_R" -5.000  -3.500  -5.500  35.000  3.500  0.500
$hbox 0 "Antlion_Guard.claw2_R" -1.740  -3.720  -6.080  38.260  4.280  -0.080
$hbox 0 "Antlion_Guard.claw3_R" -0.130  -3.500  -5.150  59.870  3.500  -0.150
$hbox 0 "Antlion_Guard.arm1_L" -5.910  -2.800  -1.110  19.090  5.200  2.890
$hbox 0 "Antlion_Guard.pelvis" -4.960  -13.270  -8.330  13.040  4.730  7.670
$hbox 0 "Antlion_Guard.leg1_L" -6.410  -6.270  -3.810  31.590  3.730  6.190
$hbox 0 "Antlion_Guard.leg2_L" -4.500  -10.000  -1.500  52.500  2.000  5.500
$hbox 0 "Antlion_Guard.leg1_R" -6.230  -6.070  -5.590  31.770  3.930  4.410
$hbox 0 "Antlion_Guard.leg2_R" -4.500  -10.000  -5.500  52.500  2.000  1.500
$hbox 0 "Antlion_Guard.arm1_R" -5.850  -2.930  -3.540  19.150  5.070  0.460
$hbox 0 "Antlion_Guard.finger1_R" -5.690  -8.010  -6.540  9.310  -0.010  18.460
$hbox 0 "Antlion_Guard.finger1_L" -5.550  -0.620  -6.680  9.450  7.380  18.320
$attachment "0" "Antlion_Guard.finger1_L" 0.00 0.00 0.00 rotate 0.00 -0.00 -0.00
$attachment "1" "Antlion_Guard.finger1_R" -0.00 -0.00 0.00 rotate -0.00 0.00 0.00
$attachment "leftfront" "Antlion_Guard.claw3_L" 60.00 0.00 -0.00 rotate 0.00 0.00 -0.00
$attachment "rightfront" "Antlion_Guard.claw3_R" 60.00 0.00 0.00 rotate -0.00 0.00 -0.00
$surfaceprop "antlion"
$eyeposition -0.000 0.000 90.000
$illumposition 13.143 4.846 69.282
$sequence idle "idle" loop ACT_IDLE 1 fps 30.00
$sequence alertidle "alertidle" loop ACT_IDLE 1 fps 30.00
$sequence cover_enter "cover_enter" ACT_ANTLIONGUARD_COVER_ENTER 1 fps 30.00 {
  { event AE_ANTLIONGUARD_VOICE_BARK 0 }
}

$sequence cover_loop "cover_loop" loop ACT_ANTLIONGUARD_COVER_LOOP 1 fps 1.00
$sequence cover_exit "cover_exit" ACT_ANTLIONGUARD_COVER_EXIT 1 fps 30.00 {
  { event AE_ANTLIONGUARD_VOICE_BARK 0 }
}

$sequence cover_creep1 "cover_creep1" loop ACT_ANTLIONGUARD_COVER_ADVANCE 1 fps 30.00
$sequence cover_creep2 "cover_creep2" loop ACT_ANTLIONGUARD_COVER_ADVANCE 1 fps 30.00 {
  { event AE_ANTLIONGUARD_VOICE_GRUNT 0 }
}

$sequence cover_flinch "cover_flinch" ACT_ANTLIONGUARD_COVER_FLINCH 1 fps 30.00
$sequence peek_flinch "peek_flinch" ACT_ANTLIONGUARD_PEEK_FLINCH 1 fps 30.00 {
  { event AE_ANTLIONGUARD_VOICE_BARK 0 }
}

$sequence peek_enter "peek_enter" ACT_ANTLIONGUARD_PEEK_ENTER 1 fps 30.00
$sequence peek_left "peek_left" ACT_ANTLIONGUARD_PEEK1 5 fps 30.00
$sequence peek_right "peek_right" ACT_ANTLIONGUARD_PEEK1 5 fps 30.00
$sequence peek_sniff "peek_sniff" ACT_ANTLIONGUARD_PEEK1 4 fps 30.00
$sequence peek_exit "peek_exit" ACT_ANTLIONGUARD_PEEK_EXIT 1 fps 30.00
$sequence peek_squeeze "peek_squeeze" ACT_ANTLIONGUARD_PEEK_SIGHTED 1 fps 30.00 {
  { event 19 0 }
  { event AE_ANTLIONGUARD_VOICE_SQUEEZE 0 }
  { event AE_ANTLIONGUARD_VOICE_BARK 124 }
  { event AE_ANTLIONGUARD_VOICE_BARK 172 }
}

$sequence pain "pain" ACT_ANTLIONGUARD_PAIN 1 fps 30.00 {
  { event AE_ANTLIONGUARD_VOICE_PAIN 0 }
}

$animation a_walkS "a_walkS" loop fps 30.000000
$animation a_walkSE "a_walkSE" loop fps 30.000000
$animation a_walkE "a_walkE" loop fps 30.000000
$animation a_walkNE "a_walkNE" loop fps 30.000000
$animation a_walk1 "a_walk1" loop fps 30.000000
$animation a_walkNW "a_walkNW" loop fps 30.000000
$animation a_walkW "a_walkW" loop fps 30.000000
$animation a_walkSW "a_walkSW" loop fps 30.000000
$animation a_walkS "a_walkS" loop fps 30.000000
$sequence walk1 "a_walkS" loop ACT_WALK 1 fps 30.00 {
  { event AE_ANTLIONGUARD_FOOTSTEP_LIGHT 19 }
  { event AE_ANTLIONGUARD_FOOTSTEP_LIGHT 10 }
  { event AE_ANTLIONGUARD_FOOTSTEP_HEAVY 12 }
  { event AE_ANTLIONGUARD_FOOTSTEP_HEAVY 1 }
  blendwidth 9
  blend move_yaw -180.000000 180.000000
  blend move_yaw -180.000000 180.000000
 a_walkS a_walkSE a_walkE a_walkNE a_walk1 a_walkNW a_walkW a_walkSW a_walkS
}
$animation a_walkS "a_walkS" loop fps 30.000000
$animation a_walkSE "a_walkSE" loop fps 30.000000
$animation a_walkE "a_walkE" loop fps 30.000000
$animation a_walkNE "a_walkNE" loop fps 30.000000
$animation a_sneak1 "a_sneak1" loop fps 30.000000
$animation a_walkNW "a_walkNW" loop fps 30.000000
$animation a_walkW "a_walkW" loop fps 30.000000
$animation a_walkSW "a_walkSW" loop fps 30.000000
$animation a_walkS "a_walkS" loop fps 30.000000
$sequence sneak1 "a_walkS" loop ACT_ANTLIONGUARD_SNEAK 1 fps 30.00 {
  blendwidth 9
  blend move_yaw -180.000000 180.000000
  blend move_yaw -180.000000 180.000000
 a_walkS a_walkSE a_walkE a_walkNE a_sneak1 a_walkNW a_walkW a_walkSW a_walkS
}
$sequence hurtrun1 "hurtrun1" loop ACT_ANTLIONGUARD_RUN_HURT 1 fps 30.00
$sequence run1 "run1" loop ACT_ANTLIONGUARD_RUN_FULL 1 fps 30.00 {
  { event AE_ANTLIONGUARD_FOOTSTEP_LIGHT 0 }
  { event AE_ANTLIONGUARD_FOOTSTEP_LIGHT 3 }
  { event AE_ANTLIONGUARD_FOOTSTEP_HEAVY 6 }
  { event AE_ANTLIONGUARD_FOOTSTEP_HEAVY 9 }
}

$animation a_walkS "a_walkS" loop fps 30.000000
$animation a_walkSE "a_walkSE" loop fps 30.000000
$animation a_walkE "a_walkE" loop fps 30.000000
$animation a_walkNE "a_walkNE" loop fps 30.000000
$animation a_uprun1 "a_uprun1" loop fps 30.000000
$animation a_walkNW "a_walkNW" loop fps 30.000000
$animation a_walkW "a_walkW" loop fps 30.000000
$animation a_walkSW "a_walkSW" loop fps 30.000000
$animation a_walkS "a_walkS" loop fps 30.000000
$sequence uprun1 "a_walkS" loop ACT_RUN 1 fps 30.00 {
  { event AE_ANTLIONGUARD_FOOTSTEP_HEAVY 8 }
  { event AE_ANTLIONGUARD_FOOTSTEP_HEAVY 10 }
  { event AE_ANTLIONGUARD_FOOTSTEP_LIGHT 10 }
  { event AE_ANTLIONGUARD_FOOTSTEP_LIGHT 12 }
  blendwidth 9
  blend move_yaw -180.000000 180.000000
  blend move_yaw -180.000000 180.000000
 a_walkS a_walkSE a_walkE a_walkNE a_uprun1 a_walkNW a_walkW a_walkSW a_walkS
}
$sequence turn_right "turn_right" loop ACT_TURN_RIGHT 1 fps 30.00 {
  { event AE_ANTLIONGUARD_FOOTSTEP_LIGHT 20 }
  { event AE_ANTLIONGUARD_FOOTSTEP_LIGHT 10 }
  { event AE_ANTLIONGUARD_FOOTSTEP_HEAVY 12 }
  { event AE_ANTLIONGUARD_FOOTSTEP_HEAVY 1 }
}

$sequence turn_left "turn_left" loop ACT_TURN_LEFT 1 fps 30.00 {
  { event AE_ANTLIONGUARD_FOOTSTEP_LIGHT 20 }
  { event AE_ANTLIONGUARD_FOOTSTEP_LIGHT 10 }
  { event AE_ANTLIONGUARD_FOOTSTEP_HEAVY 12 }
  { event AE_ANTLIONGUARD_FOOTSTEP_HEAVY 1 }
}

$animation a_walkS "a_walkS" loop fps 30.000000
$sequence walkS "a_walkS" loop fps 30.00
$animation a_walkSE "a_walkSE" loop fps 30.000000
$sequence walkSE "a_walkSE" loop fps 30.00
$animation a_walkE "a_walkE" loop fps 30.000000
$sequence walkE "a_walkE" loop fps 30.00
$animation a_walkNE "a_walkNE" loop fps 30.000000
$sequence walkNE "a_walkNE" loop fps 30.00
$animation a_walkN "a_walkN" loop fps 30.000000
$sequence walkN "a_walkN" loop fps 30.00
$animation a_walkNW "a_walkNW" loop fps 30.000000
$sequence walkNW "a_walkNW" loop fps 30.00
$animation a_walkW "a_walkW" loop fps 30.000000
$sequence walkW "a_walkW" loop fps 30.00
$animation a_walkSW "a_walkSW" loop fps 30.000000
$sequence walkSW "a_walkSW" loop fps 30.00
$sequence search "search" ACT_ANTLIONGUARD_SEARCH 1 fps 30.00
$sequence shove "shove" ACT_MELEE_ATTACK1 1 fps 20.00 {
  { event AE_ANTLIONGUARD_VOICE_GROWL 0 }
  { event AE_ANTLIONGUARD_SHOVE 10 }
}

$sequence fireattack "fireattack" ACT_RANGE_ATTACK1 1 fps 30.00 {
  { event AE_ANTLIONGUARD_VOICE_GROWL 0 }
  { event AE_ANTLIONGUARD_CHARGE_HIT 24 }
  { event AE_ANTLIONGUARD_SHOVE_PHYSOBJECT 29 }
  { event AE_ANTLIONGUARD_CHARGE_HIT 31 }
  { event AE_ANTLIONGUARD_SHOVE_PHYSOBJECT 36 }
  { event AE_ANTLIONGUARD_CHARGE_HIT 38 }
  { event AE_ANTLIONGUARD_SHOVE_PHYSOBJECT 44 }
  { event AE_ANTLIONGUARD_CHARGE_HIT 46 }
}

$sequence bark "bark" ACT_ANTLIONGUARD_BARK 1 fps 30.00 {
  { event AE_ANTLIONGUARD_VOICE_BARK 15 }
  { event AE_ANTLIONGUARD_VOICE_BARK 30 }
  { event AE_ANTLIONGUARD_VOICE_BARK 45 }
}

$sequence charge_startfast "charge_startfast" ACT_ANTLIONGUARD_CHARGE_START 1 fps 30.00 {
  { event AE_ANTLIONGUARD_VOICE_GROWL 0 }
  { event AE_ANTLIONGUARD_CHARGE_EARLYOUT 23 }
  { event AE_ANTLIONGUARD_FOOTSTEP_HEAVY 35 }
  { event AE_ANTLIONGUARD_FOOTSTEP_LIGHT 23 }
  { event AE_ANTLIONGUARD_FOOTSTEP_HEAVY 35 }
  { event AE_ANTLIONGUARD_FOOTSTEP_LIGHT 36 }
}

$sequence charge_cancel "charge_cancel" ACT_ANTLIONGUARD_CHARGE_CANCEL 1 fps 30.00
$sequence charge_loop "charge_loop" loop ACT_ANTLIONGUARD_CHARGE_RUN 1 fps 24.00 {
  { event AE_ANTLIONGUARD_FOOTSTEP_LIGHT 8 }
  { event AE_ANTLIONGUARD_FOOTSTEP_LIGHT 0 }
  { event AE_ANTLIONGUARD_FOOTSTEP_HEAVY 10 }
  { event AE_ANTLIONGUARD_FOOTSTEP_HEAVY 2 }
}

$sequence charge_crash03 "charge_crash03" ACT_ANTLIONGUARD_CHARGE_CRASH 6 fps 30.00 {
  { event AE_ANTLIONGUARD_VOICE_PAIN 0 }
  { event AE_ANTLIONGUARD_CHARGE_HIT 0 }
  { event AE_ANTLIONGUARD_FOOTSTEP_HEAVY 39 }
  { event AE_ANTLIONGUARD_FOOTSTEP_HEAVY 45 }
}

$sequence charge_crash02 "charge_crash02" ACT_ANTLIONGUARD_CHARGE_CRASH 3 fps 30.00 {
  { event AE_ANTLIONGUARD_VOICE_PAIN 0 }
  { event AE_ANTLIONGUARD_CHARGE_HIT 0 }
  { event AE_ANTLIONGUARD_FOOTSTEP_HEAVY 26 }
  { event AE_ANTLIONGUARD_FOOTSTEP_HEAVY 64 }
  { event AE_ANTLIONGUARD_FOOTSTEP_LIGHT 70 }
  { event AE_ANTLIONGUARD_FOOTSTEP_LIGHT 82 }
  { event AE_ANTLIONGUARD_FOOTSTEP_LIGHT 72 }
}

$sequence charge_crash "charge_crash" ACT_ANTLIONGUARD_CHARGE_CRASH 1 fps 30.00 {
  { event AE_ANTLIONGUARD_VOICE_PAIN 0 }
  { event AE_ANTLIONGUARD_CHARGE_HIT 0 }
  { event AE_ANTLIONGUARD_FOOTSTEP_HEAVY 47 }
  { event AE_ANTLIONGUARD_FOOTSTEP_HEAVY 58 }
  { event AE_ANTLIONGUARD_FOOTSTEP_LIGHT 58 }
  { event AE_ANTLIONGUARD_FOOTSTEP_LIGHT 71 }
  { event AE_ANTLIONGUARD_FOOTSTEP_LIGHT 72 }
}

$sequence charge_crash2 "charge_crash2" fps 30.00
$sequence charge_crash3 "charge_crash3" fps 30.00
$sequence charge_stop "charge_stop" ACT_ANTLIONGUARD_CHARGE_STOP 1 fps 30.00 {
  { event AE_ANTLIONGUARD_VOICE_SQUEEZE 0 }
  { event AE_ANTLIONGUARD_FOOTSTEP_LIGHT 7 }
  { event AE_ANTLIONGUARD_FOOTSTEP_HEAVY 10 }
  { event AE_ANTLIONGUARD_FOOTSTEP_LIGHT 10 }
  { event AE_ANTLIONGUARD_FOOTSTEP_HEAVY 12 }
  { event AE_ANTLIONGUARD_FOOTSTEP_HEAVY 21 }
  { event AE_ANTLIONGUARD_FOOTSTEP_LIGHT 22 }
  { event AE_ANTLIONGUARD_FOOTSTEP_HEAVY 25 }
  { event AE_ANTLIONGUARD_FOOTSTEP_HEAVY 37 }
  { event AE_ANTLIONGUARD_FOOTSTEP_LIGHT 40 }
  { event AE_ANTLIONGUARD_FOOTSTEP_HEAVY 42 }
  { event AE_ANTLIONGUARD_FOOTSTEP_LIGHT 48 }
}

$sequence death01 "death01" ACT_DIESIMPLE 1 fps 30.00 {
  { event AE_NPC_RAGDOLL 85 }
}

$sequence charge_hit "charge_hit" ACT_ANTLIONGUARD_CHARGE_HIT 1 fps 30.00 subtract mdldecompiler_delta.smd 0
$sequence charge_anticipate "charge_anticipate" ACT_ANTLIONGUARD_CHARGE_ANTICIPATION 1 fps 30.00 subtract mdldecompiler_delta.smd 0
$sequence roar "roar" ACT_ANTLIONGUARD_ROAR 1 fps 30.00 {
  { event AE_ANTLIONGUARD_VOICE_ROAR 30 }
}

$sequence physhit_fr "physhit_fr" ACT_ANTLIONGUARD_PHYSHIT_FR 1 fps 30.00 {
  { event AE_ANTLIONGUARD_VOICE_PAIN 0 }
}

$sequence physhit_fl "physhit_fl" ACT_ANTLIONGUARD_PHYSHIT_FL 1 fps 30.00 {
  { event AE_ANTLIONGUARD_VOICE_PAIN 0 }
}

$sequence physhit_rr "physhit_rr" ACT_ANTLIONGUARD_PHYSHIT_RR 1 fps 30.00 {
  { event AE_ANTLIONGUARD_VOICE_PAIN 0 }
}

$sequence physhit_rl "physhit_rl" ACT_ANTLIONGUARD_PHYSHIT_RL 1 fps 30.00 {
  { event AE_ANTLIONGUARD_VOICE_PAIN 0 }
}

$animation physthrow_right "physthrow_right" fps 30.000000
$animation physthrow_left "physthrow_left" fps 30.000000
$sequence physthrow "physthrow_right" ACT_ANTLIONGUARD_SHOVE_PHYSOBJECT 1 fps 30.00 {
  { event AE_ANTLIONGUARD_VOICE_GROWL 0 }
  { event AE_ANTLIONGUARD_SHOVE_PHYSOBJECT 15 }
  blendwidth 2
  blend throw -45.000000 45.000000
  blend throw -45.000000 45.000000
 physthrow_right physthrow_left
}
$sequence flinch1 "flinch1" ACT_ANTLIONGUARD_FLINCH_LIGHT 4 fps 30.00 subtract mdldecompiler_delta.smd 0
$sequence flinch2 "flinch2" ACT_ANTLIONGUARD_FLINCH_LIGHT 4 fps 30.00 subtract mdldecompiler_delta.smd 0
$sequence floor_break "floor_break" ACT_ANTLIONGUARD_UNBURROW 1 fps 30.00 {
  { event AE_ANTLIONGUARD_BURROW_OUT 1 }
}

$sequence inoutalert01 "inoutalert01" fps 30.00
$sequence bugbait "bugbait" fps 30.00
$sequence charge_start_stop "charge_start_stop" fps 30.00
$sequence headturn "headturn" fps 30.00
$animation head_up "head_up" fps 30.000000 subtract mdldecompiler_delta.smd 0

$animation head_down "head_down" fps 30.000000 subtract mdldecompiler_delta.smd 0

$sequence head_pitch "head_up" fps 30.00 {
  blendwidth 2
  blend head_pitch -30.000000 90.000000
  delta
  autoplay
 head_up head_down
}
$animation head_right "head_right" fps 30.000000 subtract mdldecompiler_delta.smd 0

$animation head_left "head_left" fps 30.000000 subtract mdldecompiler_delta.smd 0

$sequence head_yaw "head_right" fps 30.00 {
  blendwidth 2
  blend head_yaw -80.000000 80.000000
  delta
  autoplay
 head_right head_left
}
$sequence ragdoll "ragdoll" ACT_DIERAGDOLL 1 fps 30.00
$ikchain ltftfoot Antlion_Guard.claw3_L knee  0.000 0.000 0.000
$ikchain rtftfoot Antlion_Guard.claw3_R knee  0.922 0.386 0.000
$ikchain ltbkfoot Antlion_Guard.foot_L knee  0.682 -0.732 0.002
$ikchain rtbkfoot Antlion_Guard.foot_R knee  0.640 -0.768 -0.002
