#===============================================================================
# Automatic Level Scaling Settings
# By Benitex
#===============================================================================

module LevelScalingSettings
  # These two below are the variables that control difficulty
  # (You can set both of them to be the same)
  WILD_VARIABLE = 99 #-# = 1
  TRAINER_VARIABLE = 100 #-# = 2

  # You can add your own difficulties in the following Hash, using the constructor "Difficulty.new(fixed_increase, random_increase)"
  #   "fixed_increase" is a pre defined value that is always added to the level avarage
  #   "random_increase" is a randomly selected value between 0 and the value provided
  # Each difficulty has an index in the Hash, which represents the difficulty
  # You can change the active difficulty by updating TRAINER_VARIABLE or WILD_VARIABLE according to these indexes
  DIFFICULTIES = {
    1 => Difficulty.new(fixed_increase: -2, random_increase: 2),  # Easy
    2 => Difficulty.new(fixed_increase: -2, random_increase: 5),  # Standard Essentials
    3 => Difficulty.new,                                          # Avarage
    4 => Difficulty.new(random_increase: 2),                      # Medium
    5 => Difficulty.new(fixed_increase: 3, random_increase: 3),   # Hard
    6 => Difficulty.new(fixed_increase: 8, random_increase: 3),   # MidLevel
    7 => Difficulty.new(fixed_increase: 17, random_increase: 5),  # UpperLevel
    8 => Difficulty.new(fixed_increase: 5, random_increase: 20),  # OpenSea
  }

  # Scales levels but takes original level differences between members of the trainer party into consideration
  PROPORTIONAL_SCALING = true

  # The maximum level a pokemon can be scaled to
  MAX_SCALE_LEVEL = 62

  # Trainer parties will keep the same pokemon and levels of the first battle
  SAVE_TRAINER_PARTIES = true

  # Defines a "Map Level" in which all wild pokemon in the map will be, based on the the party when the player first enters the map
  USE_MAP_LEVEL_FOR_WILD_POKEMON = true

  # You can use the following to disable level scaling in any condition other then the selected below
  ONLY_SCALE_IF_HIGHER = true   # The script will only scale levels if the player is overleveled
  ONLY_SCALE_IF_LOWER = false    # The script will only scale levels if the player is underleveled

  AUTOMATIC_EVOLUTIONS = true     # Updates the evolution stage of the pokemon
  INCLUDE_PREVIOUS_STAGES = false  # Reverts pokemon to previous evolution stages if they did not reach the evolution level
  INCLUDE_NEXT_STAGES = true      # If false, stops evolution at the species used in the function call (or defined in the PBS)

  INCLUDE_NON_NATURAL_EVOLUTIONS = true # Evolve all pokemon, even if it only evolves by a non natural method
  # If INCLUDE_NON_NATURAL_EVOLUTIONS is false, the script will only consider evolutions that use the methods in the NATURAL_EVOLUTION_METHODS array
  # (All conditions other than level for these evolutions are ignored)
  NATURAL_EVOLUTION_METHODS = [
    :Level,
    :LevelMale, :LevelFemale,
    :LevelDay, :LevelNight, :LevelMorning, :LevelAfternoon, :LevelEvening,
    :LevelNoWeather, :LevelSun, :LevelRain, :LevelSnow, :LevelSandstorm,
    :LevelCycling, :LevelSurfing, :LevelDiving, :LevelDarkness, :LevelDarkInParty,

    # Specific pokemon
    :AttackGreater, :AtkDefEqual, :DefenseGreater,
    :Silcoon, :Cascoon, :Ninjask,
  ]

  # The default evolution levels are used for all evolution methods that are not in the NATURAL_EVOLUTION_METHODS array
  DEFAULT_FIRST_EVOLUTION_LEVEL = 21
  DEFAULT_SECOND_EVOLUTION_LEVEL = 42

  #-# {
  # Default Scaler to be returned for Maps without a Map Scaler listed bellow
  DEFAULT_MAP_SCALER = 5

  # #Maps (IDs) with Encounters
  # PRECIP_MAP_IDS      = [22]
  # RIVERSIDE_MAP_IDS   = [81, 95, 96]
  # NORTHRIDGE_MAP_IDS  = [48, 97]
  # GRASSLANDS_MAP_IDS  = [90, 91]
  # ODAWA_MAP_IDS       = [84, 85, 86]
  # ROOTCAVERN_MAP_IDS  = [88, 119, 120, 121]

  # # Variables to be used by Script.rb in the @@mapScalers array
  # #Map Scalers associated Variable
  # PRECIP_VAR      = 101
  # RIVERSIDE_VAR   = 102
  # NORTHRIDGE_VAR  = 103
  # GRASSLANDS_VAR  = 104
  # ODAWA_VAR       = 105
  # ROOTCAVERN_VAR  = 106

  # # Always Reset implies that these maps should always scale,
  # # rather than only scaling the first time you enter the route
  # # Think Sw/Sh's Wild Area's.
  # PRECIP_SHOULD_RESET      = false
  # RIVERSIDE_SHOULD_RESET   = false
  # NORTHRIDGE_SHOULD_RESET  = false
  # GRASSLANDS_SHOULD_RESET  = true
  # ODAWA_SHOULD_RESET       = false
  # ROOTCAVERN_SHOULD_RESET  = false

  # # If Is Set is true it means that these maps should never attempt to scale,
  # # or they have been scaled already, and should not scale again
  # PRECIP_IS_SET      = false
  # RIVERSIDE_IS_SET   = false
  # NORTHRIDGE_IS_SET  = false
  # GRASSLANDS_IS_SET  = false
  # ODAWA_IS_SET       = false
  # ROOTCAVERN_IS_SET  = false
  #-# }
end
