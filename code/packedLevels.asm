        module  PACKED

map_size:       equ     200
; каждый world_map_NN занимает 200 байт, каждые 2 байта это смещение уровня от world_01
world_map_01:           incbin  "levels/world_1_100_levels_memoryMap.bin"
world_map_02:           incbin  "levels/world_2_100_levels_memoryMap.bin"
world_map_03:           incbin  "levels/world_3_100_levels_memoryMap.bin"
world_map_04:           incbin  "levels/world_4_100_levels_memoryMap.bin"
world_map_05:           incbin  "levels/world_5_100_levels_memoryMap.bin"
world_map_06:           incbin  "levels/world_6_100_levels_memoryMap.bin"
world_map_07:           incbin  "levels/world_7_100_levels_memoryMap.bin"
world_map_08:           incbin  "levels/world_8_100_levels_memoryMap.bin"
world_map_09:           incbin  "levels/world_9_100_levels_memoryMap.bin"
world_map_10:           incbin  "levels/world_10_100_levels_memoryMap.bin"
; в каждом world_NN находятся 100 уровней.
world_01:               incbin  "levels/world_1_100_levels_worldBinary.bin"
world_02:               incbin  "levels/world_2_100_levels_worldBinary.bin"
world_03:               incbin  "levels/world_3_100_levels_worldBinary.bin"
world_04:               incbin  "levels/world_4_100_levels_worldBinary.bin"
world_05:               incbin  "levels/world_5_100_levels_worldBinary.bin"
world_06:               incbin  "levels/world_6_100_levels_worldBinary.bin"
world_07:               incbin  "levels/world_7_100_levels_worldBinary.bin"
world_08:               incbin  "levels/world_8_100_levels_worldBinary.bin"
world_09:               incbin  "levels/world_9_100_levels_worldBinary.bin"
world_10:               incbin  "levels/world_10_100_levels_worldBinary.bin"

        endmodule

        ; display "Packed levels size: ",/A, $ - PACKED.worlds