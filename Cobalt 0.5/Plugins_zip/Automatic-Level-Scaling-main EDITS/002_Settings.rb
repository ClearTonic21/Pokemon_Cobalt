#===============================================================================
# Automatic Level Scaling Settings
# By Benitex
#===============================================================================

module LevelScalingSettings
  # These two below are the variables that control difficulty
  # (You can set both of them to be the same)
  TRAINER_VARIABLE = 99
  WILD_VARIABLE = 100

  AUTOMATIC_EVOLUTIONS = true
  INCLUDE_PREVIOUS_STAGES = true # Reverts pokemon to previous evolution stages if they did not reach the evolution level

  # Trainer and wild pokemon that do not evolve by level automatically evolve in these levels instead
  DEFAULT_FIRST_EVOLUTION_LEVEL = 21
  DEFAULT_SECOND_EVOLUTION_LEVEL = 57

  # Scales levels but takes original level differences into consideration
  # Don't forget to set random_increase values to 0 when using this setting
  PROPORTIONAL_SCALING = true

  # You can use the following to disable level scaling in any condition other then the selected below
  ONLY_SCALE_IF_HIGHER = true   # The script will only scale levels if the player is overleveled
  ONLY_SCALE_IF_LOWER = false    # The script will only scale levels if the player is underleveled

  # The maximum you would like Pokemon to be scaled to (most useful for temporary settings)
  MAX_SCALE_LEVEL = GameData::GrowthRate.max_level - 8 #-#

  # You can add your own difficulties here, using the function "Difficulty.new(id, fixed_increase, random_increase)"
  #   "id" is the value stored in TRAINER_VARIABLE or WILD_VARIABLE, defines the active difficulty
  #   "fixed_increase" is a pre defined value that increases the level (optional)
  #   "random_increase" is a randomly selected value between 0 and the value provided (optional)
  # (These variables can also store negative values)
  DIFICULTIES = [
    Difficulty.new(id: 0, fixed_increase: -2, random_increase: 2),  # Easy
    Difficulty.new(id: 1),                                          # Avarage
    Difficulty.new(id: 2, random_increase: 2),                      # Medium
    Difficulty.new(id: 3, fixed_increase: 3, random_increase: 3),   # Hard
    Difficulty.new(id: 10, fixed_increase: 8, random_increase: 3),  # MidLevel
    Difficulty.new(id: 20, fixed_increase: 17, random_increase: 5), # UpperLevel
    Difficulty.new(id: 30, fixed_increase: 5, random_increase: 20), # OpenSea
  ]

  # You can insert the first stage of a custom regional form here
  # Pokemon not included in this array will have their evolution selected randomly among all their possible forms
  POKEMON_WITH_REGIONAL_FORMS = [
    :RATTATA, :SANDSHREW, :VULPIX, :DIGLETT, :MEOWTH, :GEODUDE,
    :GRIMER, :PONYTA, :FARFETCHD, :CORSOLA, :ZIGZAGOON,
    :DARUMAKA, :YAMASK, :STUNFISK, :SLOWPOKE, :ARTICUNO, :ZAPDOS,
    :MOLTRES, :PIKACHU, :EXEGGCUTE, :CUBONE, :KOFFING, :MIMEJR,
    :BURMY, :DEERLING, :ROCKRUFF, :MINIOR, :PUMPKABOO, :TAILLOW,
    :FLABEBE
  ]

  #-# {
  # Default Scaler to be returned for Maps without a Map Scaler listed bellow
  DEFAULT_MAP_SCALER = 5

  #Maps (IDs) with Encounters
  PRECIP_MAP_IDS      = [22]
  RIVERSIDE_MAP_IDS   = [81, 95, 96]
  NORTHRIDGE_MAP_IDS  = [48, 97]
  GRASSLANDS_MAP_IDS  = [90, 91]
  ODAWA_MAP_IDS       = [84, 85, 86]
  ROOTCAVERN_MAP_IDS  = [88, 119, 120, 121]

  # Variables to be used by Script.rb in the @@mapScalers array
  #Map Scalers associated Variable
  PRECIP_VAR      = 101
  RIVERSIDE_VAR   = 102
  NORTHRIDGE_VAR  = 103
  GRASSLANDS_VAR  = 104
  ODAWA_VAR       = 105
  ROOTCAVERN_VAR  = 106

  # Always Reset implies that these maps should always scale,
  # rather than only scaling the first time you enter the route
  # Think Sw/Sh's Wild Area's.
  PRECIP_SHOULD_RESET      = false
  RIVERSIDE_SHOULD_RESET   = false
  NORTHRIDGE_SHOULD_RESET  = false
  GRASSLANDS_SHOULD_RESET  = true
  ODAWA_SHOULD_RESET       = false
  ROOTCAVERN_SHOULD_RESET  = false

  # If Is Set is true it means that these maps should never attempt to scale,
  # or they have been scaled already, and should not scale again
  PRECIP_IS_SET      = false
  RIVERSIDE_IS_SET   = false
  NORTHRIDGE_IS_SET  = false
  GRASSLANDS_IS_SET  = false
  ODAWA_IS_SET       = false
  ROOTCAVERN_IS_SET  = false
  #-# }
end
