#==============================================================================
#  Overworld Shadows
#     by Luka S.J.
#     based on the original script from Marin
#==============================================================================
class Game_Character
  # additional accessors for sprite shadow rendering
  attr_reader :jump_fraction
  attr_reader :jump_distance
  attr_reader :jump_peak
end

#  Main sprite class override to add shadow-rendering functionality.
#    Additional sprites rendered per event/character sprite.
class Sprite_Character < RPG::Sprite
  #----------------------------------------------------------------------------
  #  Class used to build the shadow sprite component.
  class ShadowSprite
    #  Path to the bitmap of your shadow graphic
    BITMAP = 'Graphics/Characters/shadow'

    #  List of event name inclusions that will not render a shadow
    #    underneath the event/character sprite.
    BLACKLIST = [
      "CutTree",
      "Door",
      "Stairs",
      "Fireplace",
      "HiddenItem",
      "Window"
    ].freeze

    #  List of event name inclusions that will always render a shadow
    #    underneath the event/character sprite
    WHITELIST = [
      "Trainer",
      "Pokemon"
    ].freeze

    #  Main class constructor
    def initialize(viewport, character, event)
      @viewport  = viewport
      @character = character
      @event     = event
      @sprite    = ::Sprites::Base.new(viewport)
      @sprite.set_bitmap(BITMAP)
      @sprite.center!

      self.visible = visible?
    end

    #  Sets shadow sprite visibility
    def visible=(value)
      return @sprite.visible = false unless value

      @sprite.visible = visible?
    end

    #  Disposes of the shadow sprite
    def dispose
      @sprite.dispose
    end

    #  Checks whether or not the shadow sprite is disposed
    def disposed?
      @sprite.disposed?
    end

    #  Checks whether or not the shadow sprite is visible.
    #  Shadows will not appear if:
    #     - event/character has no graphic
    #     - event is in a bush tile
    #     - player is diving or surfing
    #     - active event page has no graphic
    #     - names match anything from the blacklist/whitelist
    def visible?
      return false if @character.character_name.blank?
      return false if @character.character.bush_depth > 0
      return false if player_in_water?
      return true if @event.is_a?(Game_Player)

      WHITELIST.each do |str|
        return true if @event.name.downcase.include?(str.downcase)
      end

      BLACKLIST.each do |str|
        return false if @event.name.downcase.include?(str.downcase)
      end

      true
    end

    #  Updates shadow visibility and position
    def update
      @sprite.visible = visible?

      position
    end

    private

    #  Calculates shadow sprite position
    def position
      if @event.jumping?
        @sprite.y = @event.screen_y - 6 - jump_offset
        @sprite.zoom = 1 - (0.5 * jump_zoom)
      else
        @sprite.y = @event.screen_y - 6
        @sprite.zoom = 1
      end
      @sprite.x = @event.screen_x
      @sprite.z = @character.z - 1
    end

    #  Calculates position offset based on jumping
    def jump_offset
      jump_peak * ((4 * (jump_progress ** 2)) - 1)
    end

    #  Calculates current jump progress
    def jump_progress
      ((@character.character&.jump_fraction || 0) - 0.5).abs
    end

    #  Calculates maximum jump height
    def jump_peak
      @character.character&.jump_peak || 0
    end

    #  Calculates zoom components when jumping
    def jump_zoom
      (@sprite.y - @event.screen_y) / jump_peak
    end

    #  Checks if player is diving or surfing
    def player_in_water?
      return false unless @event == $game_player

      $PokemonGlobal.diving || $PokemonGlobal.surfing
    end
  end
  #----------------------------------------------------------------------------
  attr_reader :character
  attr_reader :character_name

  #  Override original constructor to add shadows
  alias with_shadows_initialize initialize
  def initialize(viewport, character = nil)
    @shadow = ShadowSprite.new(viewport, self, character)

    with_shadows_initialize(viewport, character)
  end

  #  Override original function for shadow visibility
  def visible=(value)
    super(value)
    @reflection.visible = value if @reflection
    @shadow.visible = value if @shadow
  end

  #  Override original function to dispose shadows
  alias with_shadows_dispose dispose
  def dispose
    @shadow&.dispose
    @shadow = nil
    with_shadows_dispose
  end

  #  Override original function to update shadows
  alias with_shadows_update update
  def update
    with_shadows_update
    @shadow&.update
  end
end
#==============================================================================
