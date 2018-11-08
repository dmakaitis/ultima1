;-------------------------------------------------------------------------------
;
; data.s
;
; Data provided in the MI module.
;
;-------------------------------------------------------------------------------

.export mi_attribute_table
.export mi_class_name_table
.export mi_race_name_table

.export armor_table
.export command_table
.export gem_table
.export spell_table
.export transport_table
.export weapon_table

.export death_image

.data

death_image:

        .incbin "skull.bin"


mi_race_name_table:
        .byte   "lizar",$E4
        .byte   "huma",$EE
        .byte   "el",$E6
        .byte   "dwar",$E6
        .byte   "bobbi",$F4

weapon_table:
        .byte   "hand",$F3
        .byte   "dagge",$F2
        .byte   "mac",$E5
        .byte   "ax",$E5
        .byte   "rope & spike",$F3
        .byte   "swor",$E4
        .byte   "great swor",$E4
        .byte   "bow & arrow",$F3
        .byte   "amule",$F4
        .byte   "wan",$E4
        .byte   "staf",$E6
        .byte   "triangl",$E5
        .byte   "pisto",$EC
        .byte   "light swor",$E4
        .byte   "phazo",$F2
        .byte   "blaste",$F2

        .byte   "hand",$F3
        .byte   "dagge",$F2
        .byte   "mac",$E5
        .byte   "ax",$E5
        .byte   "rop",$E5
        .byte   "swor",$E4
        .byte   "g swor",$E4
        .byte   "bo",$F7
        .byte   "amule",$F4
        .byte   "wan",$E4
        .byte   "staf",$E6
        .byte   "triangl",$E5
        .byte   "pisto",$EC
        .byte   "l swor",$E4
        .byte   "phazo",$F2
        .byte   "blaste",$F2

mi_attribute_table:
        .byte   "Hit point",$F3
        .byte   "Strengt",$E8
        .byte   "Agilit",$F9
        .byte   "Stamin",$E1
        .byte   "Charism",$E1
        .byte   "Wisdo",$ED
        .byte   "Intelligenc",$E5


        .byte   "Gol",$E4
        .byte   "Rac",$E5

        .byte   "Typ",$E5

spell_table:
        .byte   "Praye",$F2
        .byte   "Ope",$EE
        .byte   "Unloc",$EB
        .byte   "Magic Missil",$E5

        .byte   "Stea",$EC
        .byte   "Ladder Dow",$EE
        .byte   "Ladder U",$F0
        .byte   "Blin",$EB
        .byte   "Creat",$E5
        .byte   "Destro",$F9
        .byte   "Kil",$EC

armor_table:
        .byte   "ski",$EE
        .byte   "leather armou",$F2
        .byte   "chain mai",$EC
        .byte   "plate mai",$EC
        .byte   "vacuum sui",$F4
        .byte   "reflect sui",$F4

mi_class_name_table:
        .byte   "peasan",$F4
        .byte   "fighte",$F2
        .byte   "cleri",$E3
        .byte   "wizar",$E4
        .byte   "thie",$E6

transport_table:
        .byte   "foo",$F4
        .byte   "hors",$E5
        .byte   "car",$F4
        .byte   "raf",$F4
        .byte   "frigat",$E5
        .byte   "airca",$F2
        .byte   "shuttl",$E5
        .byte   "phanto",$ED
        .byte   "star cruise",$F2
        .byte   "battle bas",$E5
        .byte   "time machin",$E5

command_table:
        .byte   "Nort",$E8
        .byte   "Sout",$E8
        .byte   "Eas",$F4
        .byte   "Wes",$F4
        .byte   "Pas",$F3
        .byte   "Attack",$A0
        .byte   "Board",$A0
        .byte   "Cast",$A0
        .byte   "Dro",$F0
        .byte   "Ente",$F2
        .byte   "Fire",$A0
        .byte   "Ge",$F4
        .byte   "HyperJum",$F0
        .byte   "Inform and searc",$E8
        .byte   "K-lim",$E2
        .byte   "Nois",$E5
        .byte   "Ope",$EE
        .byte   "Quit- saving game..",$AE
        .byte   "Ready Weapon,Armour,Spell:",$A0
        .byte   "Stea",$EC
        .byte   "Transac",$F4
        .byte   "Unloc",$EB
        .byte   "Vie",$F7
        .byte   "X-i",$F4
        .byte   "Ztat",$F3

gem_table:
        .byte   "Red Ge",$ED
        .byte   "Green Ge",$ED
        .byte   "Blue Ge",$ED
        .byte   "White Ge",$ED


        .byte   $0A,$05,$04,$03,$02,$01,$04,$06
        .byte   $08,$0A,$01,$02,$04,$06,$08,$02
        .byte   $04,$06,$08,$09,$0A,$02,$02,$03
        .byte   $03,$03,$04,$04,$04,$05,$05,$05
        .byte   $06,$06,$06,$07,$07,$07,$08,$08
        .byte   $08,$09,$09,$09,$0A,$0A,$A0,$A0
        .byte   $A0,$A0,$A0,$A0


        .byte   "Ness creatur",$E5
        .byte   "giant squi",$E4
        .byte   "dragon turtl",$E5
        .byte   "pirate shi",$F0
        .byte   "hoo",$E4
        .byte   "bea",$F2
        .byte   "hidden arche",$F2
        .byte   "dark knigh",$F4
        .byte   "evil tren",$F4
        .byte   "thie",$E6
        .byte   "or",$E3
        .byte   "knigh",$F4
        .byte   "necromance",$F2
        .byte   "evil range",$F2
        .byte   "wandering warloc",$EB
        .byte   "range",$F2
        .byte   "skeleto",$EE
        .byte   "thie",$E6
        .byte   "giant ra",$F4
        .byte   "ba",$F4
        .byte   "giant spide",$F2
        .byte   "vipe",$F2
        .byte   "or",$E3
        .byte   "cyclop",$F3
        .byte   "gelatinous cub",$E5
        .byte   "etti",$EE
        .byte   "mimi",$E3
        .byte   "lizard ma",$EE
        .byte   "minotau",$F2
        .byte   "carrion creepe",$F2
        .byte   "tangle",$F2
        .byte   "gremli",$EE
        .byte   "wandering eye",$F3
        .byte   "wrait",$E8
        .byte   "lic",$E8
        .byte   "invisible seeke",$F2
        .byte   "mind whippe",$F2
        .byte   "zor",$EE
        .byte   "daemo",$EE
        .byte   "balro",$EE

        .byte   "Lord Britis",$E8
        .byte   "the Feudal Lord",$F3
        .byte   "the Dark Unknow",$EE
        .byte   "Danger and Despai",$F2


        .byte   $1F,$14,$03,$02,$06,$24,$16,$35
        .byte   $1E,$04,$2A,$0F,$3D,$20,$22,$36
        .byte   $15,$38,$1B,$38,$0F,$5E,$56,$7B
        .byte   $5A,$48,$43,$5D,$71,$53,$66,$74
        .byte   $6B,$5C,$5D,$78,$4F,$64,$6A,$48
        .byte   $7C,$76,$A1,$A9,$84,$A5,$B7,$BC
        .byte   $8E,$A2,$AC,$99,$8B,$94,$A3,$A2
        .byte   $87,$B0,$9B,$95,$B7,$83,$89,$DF
        .byte   $D4,$C3,$C2,$C6,$E4,$D6,$F5,$DE
        .byte   $C4,$EA,$CF,$FD,$E0,$E2,$F6,$D5
        .byte   $F8,$DB,$F8,$CF,$1E,$16,$3B,$1A
        .byte   $08,$03,$31,$1D,$13,$26,$34,$2B
        .byte   $1C,$1D,$38,$0F,$24,$2A,$08,$3C
        .byte   $36,$1F,$14,$03,$02,$06,$24,$35
        .byte   $16,$1E,$04,$2A,$0F,$3D,$20,$22
        .byte   $36,$15,$38,$1B,$38,$0F,$1F,$14
        .byte   $03,$02,$06,$24,$16,$35,$1E,$04
        .byte   $2A,$0F,$3D,$20,$22,$36,$15,$38
        .byte   $1B,$38,$0F,$21,$29,$04,$25,$37
        .byte   $3C,$0E,$22,$2C,$19,$0B,$14,$23
        .byte   $22,$07,$30,$1B,$15,$37,$03,$09


        .byte   "The Castle of Lord Britis",$E8
        .byte   "The Castle of the Lost Kin",$E7
        .byte   "The Tower of Knowledg",$E5
        .byte   "The Pillars of Protectio",$EE
        .byte   "The Dungeon of Perini",$E1
        .byte   "The Lost Cavern",$F3
        .byte   "The Mines of Mt. Dras",$E8
        .byte   "The Mines of Mt. Drash I",$C9
        .byte   "Mondain's Gate to Hel",$EC
        .byte   "The Unholy Hol",$E5
        .byte   "The Dungeon of Doub",$F4
        .byte   "The Dungeon of Monto",$F2
        .byte   "Death's Awakenin",$E7

        .byte   "Britai",$EE
        .byte   "Moo",$EE
        .byte   "Faw",$EE
        .byte   "Paw",$F3
        .byte   "Monto",$F2
        .byte   "Ye",$F7
        .byte   "Tun",$E5
        .byte   "Gre",$F9

        .byte   "The Castle Baratari",$E1
        .byte   "The Castle Rondorli",$EE
        .byte   "The Pillar of Ozymandia",$F3
        .byte   "The Pillars of the Argonaut",$F3
        .byte   "Scorpion Hol",$E5
        .byte   "The Savage Plac",$E5
        .byte   "The Horror of the Harpie",$F3
        .byte   "The Horror of the Harpies I",$C9
        .byte   "Advari's Hol",$E5
        .byte   "The Labyrint",$E8
        .byte   "The Gorgon's Hol",$E5
        .byte   "Where Hercules Die",$E4
        .byte   "The Dead Warrior's Figh",$F4
        .byte   "Arnol",$E4
        .byte   "Lind",$E1
        .byte   "Hele",$EE
        .byte   "Owe",$EE
        .byte   "Joh",$EE
        .byte   "Gerr",$F9
        .byte   "Wol",$E6
        .byte   "The Snak",$E5
        .byte   "The Castle of Olympu",$F3
        .byte   "The Black Dragon's Castl",$E5
        .byte   "The Sign Pos",$F4
        .byte   "The Southern Sign Pos",$F4
        .byte   "The Metal Twiste",$F2
        .byte   "The Troll's Hol",$E5
        .byte   "The Viper's Pi",$F4
        .byte   "The Viper's Pit I",$C9
        .byte   "The Guild of Deat",$E8
        .byte   "The End..",$AE
        .byte   "The Tramp of Doo",$ED
        .byte   "The Long Deat",$E8
        .byte   "The Slow Deat",$E8
        .byte   "Nassa",$F5
        .byte   "Clear Lagoo",$EE
        .byte   "Stou",$F4
        .byte   "Gauntle",$F4
        .byte   "Imaginatio",$EE
        .byte   "Ponde",$F2
        .byte   "Wealt",$E8
        .byte   "Poo",$F2
        .byte   "The White Dragon's Castl",$E5
        .byte   "The Castle of Shamin",$EF
        .byte   "The Grave of the Lost Sou",$EC
        .byte   "Eastern Sign Pos",$F4
        .byte   "Spine Breake",$F2
        .byte   "Free Death Hol",$E5
        .byte   "The Dead Cat's Lif",$E5
        .byte   "The Dead Cat's Life I",$C9
        .byte   "The Morbid Adventur",$E5
        .byte   "The Skull Smashe",$F2
        .byte   "Dead Man's Wal",$EB
        .byte   "The Dungeon of Doo",$ED
        .byte   "Hole to Hade",$F3
        .byte   "Gorla",$E2
        .byte   "Dextro",$EE
        .byte   "Magi",$E3
        .byte   "Wheele",$F2
        .byte   "Bulldoze",$F2
        .byte   "The Brothe",$F2
        .byte   "The Turtl",$E5
        .byte   "Lost Friend",$F3
