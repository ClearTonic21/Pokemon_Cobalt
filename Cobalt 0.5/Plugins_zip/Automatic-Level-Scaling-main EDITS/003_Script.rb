#===============================================================================
# Automatic Level Scaling
# By Benitex
#===============================================================================

class AutomaticLevelScaling
  #-#{
  @@mapScalers = {
    precip:     {var:LevelScalingSettings::PRECIP_VAR,     scaler: pbGet(LevelScalingSettings::PRECIP_VAR),     reset: LevelScalingSettings::PRECIP_SHOULD_RESET,     isSet: LevelScalingSettings::PRECIP_IS_SET},
    riverside:  {var:LevelScalingSettings::RIVERSIDE_VAR,  scaler: pbGet(LevelScalingSettings::RIVERSIDE_VAR),  reset: LevelScalingSettings::RIVERSIDE_SHOULD_RESET,  isSet: LevelScalingSettings::RIVERSIDE_IS_SET},
    northridge: {var:LevelScalingSettings::NORTHRIDGE_VAR, scaler: pbGet(LevelScalingSettings::NORTHRIDGE_VAR), reset: LevelScalingSettings::NORTHRIDGE_SHOULD_RESET, isSet: LevelScalingSettings::NORTHRIDGE_IS_SET},
    grasslands: {var:LevelScalingSettings::GRASSLANDS_VAR, scaler: pbGet(LevelScalingSettings::GRASSLANDS_VAR), reset: LevelScalingSettings::GRASSLANDS_SHOULD_RESET, isSet: LevelScalingSettings::GRASSLANDS_IS_SET},
    odawa:      {var:LevelScalingSettings::ODAWA_VAR,      scaler: pbGet(LevelScalingSettings::ODAWA_VAR),      reset: LevelScalingSettings::ODAWA_SHOULD_RESET,      isSet: LevelScalingSettings::ODAWA_IS_SET},
    rootcavern: {var:LevelScalingSettings::ROOTCAVERN_VAR, scaler: pbGet(LevelScalingSettings::ROOTCAVERN_VAR), reset: LevelScalingSettings::ROOTCAVERN_SHOULD_RESET, isSet: LevelScalingSettings::ROOTCAVERN_IS_SET}
  }
  #-#}

  @@selectedDifficulty = Difficulty.new(id: 0)
  @@settings = {
    temporary: false,
    update_moves: true,
    automatic_evolutions: LevelScalingSettings::AUTOMATIC_EVOLUTIONS,
    include_previous_stages: LevelScalingSettings::INCLUDE_PREVIOUS_STAGES,
    first_evolution_level: LevelScalingSettings::DEFAULT_FIRST_EVOLUTION_LEVEL,
    second_evolution_level: LevelScalingSettings::DEFAULT_SECOND_EVOLUTION_LEVEL,
    proportional_scaling: LevelScalingSettings::PROPORTIONAL_SCALING,
    only_scale_if_higher: LevelScalingSettings::ONLY_SCALE_IF_HIGHER,
    only_scale_if_lower: LevelScalingSettings::ONLY_SCALE_IF_LOWER,
    max_scale_level: LevelScalingSettings::MAX_SCALE_LEVEL #-#
  }

  def self.setDifficulty(id)
    for difficulty in LevelScalingSettings::DIFICULTIES do
      @@selectedDifficulty = difficulty if difficulty.id == id
    end
  end

  def self.getScaledLevel
  	#-# {
    puts "$Trainer is #{defined?($Trainer) ? 'defined' : 'nil'}"
    return LevelScalingSettings::DEFAULT_MAP_SCALER unless $Trainer && $PokemonStorage

    unless AutomaticLevelScaling.isScalerSet
      pc = Array.new(6)
      highest = [1, 1, 1, 1, 1, 1]

      $PokemonStorage.maxBoxes.times do |numBoxes|
        $PokemonStorage.maxPokemon(numBoxes).times do |numSlots|
          pkmn = $PokemonStorage[numBoxes][numSlots]
          next unless pkmn
          pc.length.times do |numHighSlots|
            if pkmn.level > highest[numHighSlots]
              highest[numHighSlots] = pkmn.level
              pc[numHighSlots] = pkmn
              break
            end
          end
        end
      end

      trulen = pc.count { |p| !p.nil? }

      inparty = $Trainer.party.dup
      pcANDparty = inparty + pc.compact
      newlvl = pbBalancedLevel(pcANDparty) - 2 # pbBalancedLevel increses level by 2 to challenge the player
      AutomaticLevelScaling.setMapScaler(newlvl)
    else
      newlvl = AutomaticLevelScaling.getMapScalerLvl
    end

    level = newlvl
    #-# }

    level += @@selectedDifficulty.fixed_increase
    level += rand(@@selectedDifficulty.random_increase..0) if @@selectedDifficulty.random_increase < 0
    level += rand(@@selectedDifficulty.random_increase) if @@selectedDifficulty.random_increase > 0

    level = level.clamp(1, @@settings[:max_scale_level] || LevelScalingSettings::MAX_SCALE_LEVEL)
    return level
  end

  def self.setNewLevel(pokemon, difference_from_average = 0)
    # Checks for only_scale_if_higher and only_scale_if_lower
    unless $Trainer
      pokemon.level = LevelScalingSettings::DEFAULT_MAP_SCALER
      pokemon.calc_stats
      pokemon.reset_moves if @@settings[:update_moves]
      return
    end

    puts "$Trainer is #{defined?($Trainer) ? 'defined' : 'nil'}"
    higher_level_block = @@settings[:only_scale_if_higher] && pokemon.level > pbBalancedLevel($Trainer.party)
    lower_level_block = @@settings[:only_scale_if_lower] && pokemon.level < pbBalancedLevel($Trainer.party)
    unless higher_level_block || lower_level_block
      pokemon.level = AutomaticLevelScaling.getScaledLevel

      # Proportional scaling
      if @@settings[:proportional_scaling]
        level = pokemon.level + difference_from_average

        r = Random.new
        randnum = rand(1..3)
        randstr = r.to_s
        randnum = randstr.to_i
        if @@settings[:max_scale_level]
          pokemon.level = level.clamp(1, @@settings[:max_scale_level] - randnum)
        else
          pokemon.level = level.clamp(1, LevelScalingSettings::MAX_SCALE_LEVEL - randnum)
        end
      end

      # Evolution part
      #-# {
      r = Random.new
      r.rand(1...100)
      randstr = r.to_s
      randnum = randstr.to_i
      # evolution scarcity value, to make evolved Pokemon more rare
      scarcity = 60
      #-# }
      AutomaticLevelScaling.setNewStage(pokemon) if (@@settings[:automatic_evolutions] && randnum > scarcity) #-# there was no && before

      pokemon.calc_stats
      pokemon.reset_moves if @@settings[:update_moves]
    end

    pokemon.calc_stats
    pokemon.reset_moves if @@settings[:update_moves]

    # Settings reset
    if @@settings[:temporary]
      @@settings = {
        temporary: false,
        update_moves: true,
        automatic_evolutions: LevelScalingSettings::AUTOMATIC_EVOLUTIONS,
        include_previous_stages: LevelScalingSettings::INCLUDE_PREVIOUS_STAGES,
        first_evolution_level: LevelScalingSettings::DEFAULT_FIRST_EVOLUTION_LEVEL,
        second_evolution_level: LevelScalingSettings::DEFAULT_SECOND_EVOLUTION_LEVEL,
        proportional_scaling: LevelScalingSettings::PROPORTIONAL_SCALING,
        only_scale_if_higher: LevelScalingSettings::ONLY_SCALE_IF_HIGHER,
        only_scale_if_lower: LevelScalingSettings::ONLY_SCALE_IF_LOWER,
        max_scale_level: LevelScalingSettings::MAX_SCALE_LEVEL
      }
    end
  end

  def self.setNewStage(pokemon)
    form = pokemon.form   # regional form
    stage = 0             # evolution stage

    if @@settings[:include_previous_stages]
      pokemon.species = GameData::Species.get(pokemon.species).get_baby_species # revert to the first stage
    else
      # Checks if the pokemon has evolved
      if pokemon.species != GameData::Species.get(pokemon.species).get_baby_species
        stage = 1
      end
    end

    regionalForm = false
    for species in LevelScalingSettings::POKEMON_WITH_REGIONAL_FORMS do
      regionalForm = true if pokemon.isSpecies?(species)
    end

    (2 - stage).times do |_|
      evolutions = GameData::Species.get(pokemon.species).get_evolutions

      # Checks if the species only evolve by level up
      other_evolving_method = false
      evolutions.length.times { |i|
        if evolutions[i][1] != :Level
          other_evolving_method = true
        end
      }

      unless other_evolving_method || regionalForm  # Species that evolve by level up
        if pokemon.check_evolution_on_level_up != nil
          pokemon.species = pokemon.check_evolution_on_level_up
        end

      else  # For species with other evolving methods
        # Checks if the pokemon is in it's midform and defines the level to evolve
        level = stage == 0 ? @@settings[:first_evolution_level] : @@settings[:second_evolution_level]

        if pokemon.level >= level
          if evolutions.length == 1         # Species with only one possible evolution
            pokemon.species = evolutions[0][0]
            pokemon.setForm(form) if regionalForm

          elsif evolutions.length > 1
            if regionalForm
              if !pokemon.isSpecies?(:MEOWTH)
                if form >= evolutions.length  # regional form
                  pokemon.species = evolutions[0][0]
                  pokemon.setForm(form)
                else                          # regional evolution
                  pokemon.species = evolutions[form][0]
                end

              else  # Meowth has two possible evolutions and a regional form depending on its origin region
                if form == 0 || form == 1
                  pokemon.species = evolutions[0][0]
                  pokemon.setForm(form)
                else
                  pokemon.species = evolutions[1][0]
                end
              end

            else                            # Species with multiple possible evolutions
              pokemon.species = evolutions[rand(0, evolutions.length - 1)][0]
            end
          end
        end
      end

      stage += 1
    end
  end

  def self.setTemporarySetting(setting, value)
    # Parameters validation
    case setting
      when "firstEvolutionLevel", "secondEvolutionLevel", "maxScaleLevel"
        if !value.is_a?(Integer)
          raise _INTL("\"{1}\" requires an integer value, but {2} was provided.",setting,value)
        end
      when "updateMoves", "automaticEvolutions", "includePreviousStages", "proportionalScaling", "onlyScaleIfHigher", "onlyScaleIfLower"
        if !(value.is_a?(FalseClass) || value.is_a?(TrueClass))
          raise _INTL("\"{1}\" requires a boolean value, but {2} was provided.",setting,value)
        end
    else
      raise _INTL("\"{1}\" is not a defined setting name.",setting)
    end

    @@settings[:temporary] = true
    case setting
      when "updateMoves"
        @@settings[:update_moves] = value
      when "automaticEvolutions"
        @@settings[:automatic_evolutions] = value
      when "includePreviousStages"
        @@settings[:include_previous_stages] = value
      when "proportionalScaling"
        @@settings[:proportional_scaling] = value
      when "firstEvolutionLevel"
        @@settings[:first_evolution_level] = value
      when "secondEvolutionLevel"
        @@settings[:second_evolution_level] = value
      when "onlyScaleIfHigher"
        @@settings[:only_scale_if_higher] = value
      when "onlyScaleIfLower"
        @@settings[:only_scale_if_lower] = value
      when "maxScaleLevel"
        @@settings[:max_scale_level] = value  #-#
      end

      # example calls
      # AutomaticLevelScaling.setTemporarySetting("updateMoves", true)
      # AutomaticLevelScaling.setTemporarySetting("automaticEvolutions", true)
      # AutomaticLevelScaling.setTemporarySetting("includePreviousStages", true)
      # AutomaticLevelScaling.setTemporarySetting("proportionalScaling", true)
      # AutomaticLevelScaling.setTemporarySetting("firstEvolutionLevel", 20)
      # AutomaticLevelScaling.setTemporarySetting("secondEvolutionLevel", 40)
      # AutomaticLevelScaling.setTemporarySetting("onlyScaleIfHigher", true)
      # AutomaticLevelScaling.setTemporarySetting("onlyScaleIfLower", true)
      # AutomaticLevelScaling.setTemporarySetting("maxScaleLevel", 64)
  end

  def self.setSettings(
    temporary: false,                                                             #bool
    update_moves: true,                                                           #bool
    automatic_evolutions: LevelScalingSettings::AUTOMATIC_EVOLUTIONS,             #bool
    include_previous_stages: LevelScalingSettings::INCLUDE_PREVIOUS_STAGES,       #bool
    proportional_scaling: LevelScalingSettings::PROPORTIONAL_SCALING,             #bool
    first_evolution_level: LevelScalingSettings::DEFAULT_FIRST_EVOLUTION_LEVEL,   #number
    second_evolution_level: LevelScalingSettings::DEFAULT_SECOND_EVOLUTION_LEVEL, #number
    only_scale_if_higher: LevelScalingSettings::ONLY_SCALE_IF_HIGHER,             #bool
    only_scale_if_lower: LevelScalingSettings::ONLY_SCALE_IF_LOWER,               #bool
    max_scale_level: LevelScalingSettings::MAX_SCALE_LEVEL                        #-#number
    )

    @@settings[:temporary] = temporary
    @@settings[:update_moves] = update_moves
    @@settings[:first_evolution_level] = first_evolution_level
    @@settings[:second_evolution_level] = second_evolution_level
    @@settings[:proportional_scaling] = proportional_scaling
    @@settings[:automatic_evolutions] = automatic_evolutions
    @@settings[:include_previous_stages] = include_previous_stages
    @@settings[:only_scale_if_higher] = only_scale_if_higher
    @@settings[:only_scale_if_lower] = only_scale_if_lower
    @@settings[:max_scale_level] = max_scale_level  #-#
  end

  #===============================================================================
  # Returns (true) if the Player's location(map id) has a Set Scale or (false) if
  # the scale has not been set
  #===============================================================================
  def self.isScalerSet() #-# {
    map = $game_map.map_id
    refreshScalerVars()

    case map
      when *LevelScalingSettings::PRECIP_MAP_IDS
        return LevelScalingSettings::PRECIP_IS_SET

      when *LevelScalingSettings::RIVERSIDE_MAP_IDS
        return LevelScalingSettings::RIVERSIDE_IS_SET

      when *LevelScalingSettings::NORTHRIDGE_MAP_IDS
        return LevelScalingSettings::NORTHRIDGE_IS_SET

      when *LevelScalingSettings::GRASSLANDS_MAP_IDS
        return LevelScalingSettings::GRASSLANDS_IS_SET

      when *LevelScalingSettings::ODAWA_MAP_IDS
        return LevelScalingSettings::ODAWA_IS_SET

      when *LevelScalingSettings::ROOTCAVERN_MAP_IDS
        return LevelScalingSettings::ROOTCAVERN_IS_SET

      else
        puts"No Map Scaler found for the map with the id: #{map}."
        return false
    end
  end

  #===============================================================================
  # Returns the Current Scaler based upon the Player's location(map id)
  #===============================================================================
  def self.getMapScalerLvl()
      map = $game_map.map_id
      refreshScalerVars()

    case map
      when *LevelScalingSettings::PRECIP_MAP_IDS
        return @@mapScalers[:precip][:scaler].to_i

      when *LevelScalingSettings::RIVERSIDE_MAP_IDS
        return @@mapScalers[:riverside][:scaler].to_i

      when *LevelScalingSettings::NORTHRIDGE_MAP_IDS
        return @@mapScalers[:northridge][:scaler].to_i

      when *LevelScalingSettings::GRASSLANDS_MAP_IDS
        return @@mapScalers[:grasslands][:scaler].to_i

      when *LevelScalingSettings::ODAWA_MAP_IDS
        return @@mapScalers[:odawa][:scaler].to_i

      when *LevelScalingSettings::ROOTCAVERN_MAP_IDS
        return @@mapScalers[:rootcavern][:scaler].to_i

      else
        puts"No Map Scaler found for the map with the id: #{map}. returning default 5"
        return LevelScalingSettings::DEFAULT_MAP_SCALER
    end
  end

  #===============================================================================
  # Uses the Player's location(map id) and sets the Scaler based on the current
  # Automatic Level Scaling By Benitex (with a few edits by BigE21)
  #===============================================================================
  def self.setMapScaler(newScale)
    map = $game_map.map_id

    refreshScalerVars()

    mapToScale = case map
      when *LevelScalingSettings::PRECIP_MAP_IDS then @@mapScalers[:precip]
      when *LevelScalingSettings::RIVERSIDE_MAP_IDS then @@mapScalers[:riverside]
      when *LevelScalingSettings::NORTHRIDGE_MAP_IDS then @@mapScalers[:northridge]
      when *LevelScalingSettings::GRASSLANDS_MAP_IDS then @@mapScalers[:grasslands]
      when *LevelScalingSettings::ODAWA_MAP_IDS then @@mapScalers[:odawa]
      when *LevelScalingSettings::ROOTCAVERN_MAP_IDS then @@mapScalers[:rootcavern]
      else puts"No Map Scaler created for the map with the id: #{map}."
    end

      if((mapToScale[:scaler] == 0 || mapToScale[:reset]) && !mapToScale[:isSet])
        mapToScale[:isSet] = true
        puts"Setting #{mapToScale}[:scaler] >>> #{newScale.to_i}, reset = #{mapToScale[:reset]}, isSet = #{mapToScale[:isSet]}"
        mapToScale[:scaler] = newScale.to_i
        pbSet(mapToScale[:var], newScale.to_i)
      end
    end

  #===============================================================================
  # As the Variables used to store the Map Scalers are updated by other methods,
  # this method ensures the the @@mapScalers array is up to date based on what is
  # stored in the variables.
  #===============================================================================
  def self.refreshScalerVars()
    @@mapScalers = {
      precip:     {var:LevelScalingSettings::PRECIP_VAR,     scaler: pbGet(LevelScalingSettings::PRECIP_VAR),     reset: LevelScalingSettings::PRECIP_SHOULD_RESET,     isSet: LevelScalingSettings::PRECIP_IS_SET},
      riverside:  {var:LevelScalingSettings::RIVERSIDE_VAR,  scaler: pbGet(LevelScalingSettings::RIVERSIDE_VAR),  reset: LevelScalingSettings::RIVERSIDE_SHOULD_RESET,  isSet: LevelScalingSettings::RIVERSIDE_IS_SET},
      northridge: {var:LevelScalingSettings::NORTHRIDGE_VAR, scaler: pbGet(LevelScalingSettings::NORTHRIDGE_VAR), reset: LevelScalingSettings::NORTHRIDGE_SHOULD_RESET, isSet: LevelScalingSettings::NORTHRIDGE_IS_SET},
      grasslands: {var:LevelScalingSettings::GRASSLANDS_VAR, scaler: pbGet(LevelScalingSettings::GRASSLANDS_VAR), reset: LevelScalingSettings::GRASSLANDS_SHOULD_RESET, isSet: LevelScalingSettings::GRASSLANDS_IS_SET},
      odawa:      {var:LevelScalingSettings::ODAWA_VAR,      scaler: pbGet(LevelScalingSettings::ODAWA_VAR),      reset: LevelScalingSettings::ODAWA_SHOULD_RESET,      isSet: LevelScalingSettings::ODAWA_IS_SET},
      rootcavern: {var:LevelScalingSettings::ROOTCAVERN_VAR, scaler: pbGet(LevelScalingSettings::ROOTCAVERN_VAR), reset: LevelScalingSettings::ROOTCAVERN_SHOULD_RESET, isSet: LevelScalingSettings::ROOTCAVERN_IS_SET}
    }
  end
  #-# }
end
