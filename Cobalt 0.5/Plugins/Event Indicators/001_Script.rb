class EventIndicator
    attr_accessor :type
    attr_accessor :event
    attr_accessor :visible
    attr_accessor :frame_num

    def initialize(params, event, viewport, map)
        @type = params[0]
        @event = event
        @viewport = viewport
        @map = map
        @alwaysvisible = false
        @ignoretimeshade = false
        @toggle_sprite = false   #-#
        @x_adj = Settings::EVENT_INDICATOR_X_ADJ
        @y_adj = Settings::EVENT_INDICATOR_Y_ADJ
        @x_adj += params[1] if params[1] && params[1].is_a?(Integer)
        @y_adj += params[2] if params[2] && params[2].is_a?(Integer)
        @frame_num = 0     #-#

        data = Settings::EVENT_INDICATORS[@type]
        if !data
            @disposed = true
            return
        end
        @x_adj += data[:x_adjustment] if data[:x_adjustment]
        @y_adj += data[:y_adjustment] if data[:y_adjustment]

        @alwaysvisible = true if data[:always_visible]
        @ignoretimeshade = true if data[:ignore_time_shading]
        @toggle_sprite = true if data[:toggle_sprite]    #-#
        @indicator = IconSprite.new(0, 0, viewport)
        @indicator.setBitmap(data[:graphic])
        @indicator.z = 1000
        @indicator.ox = @indicator.bitmap.width / 2
        @indicator.oy = @indicator.bitmap.height
        @disposed = false
    end
  
    def disposed?
        @disposed
    end
  
    def dispose
        @indicator.dispose
        @disposed = true
    end
  
    def update
        data = Settings::EVENT_INDICATORS[@type]
        if !data
            @disposed = true
            return
        end
        if @alwaysvisible
            @visible = true
        elsif pbMapInterpreterRunning? && pbMapInterpreter.get_self && @event && pbMapInterpreter.get_self.id == @event.id
            @visible = false
        else
            @visible = true
        end
        @visible = @alwaysvisible || !(pbMapInterpreterRunning? && pbMapInterpreter&.get_self&.id == @event&.id)
        @indicator.update
        @indicator.visible = @visible
        #-# {
        if @toggle_sprite && @frame_num <= 8
            @indicator.setBitmap(data[:graphic] + "_1")
        end
        if @frame_num <= 16
            @frame_num = 0
            @indicator.setBitmap(data[:graphic])
        end
        #-# }
        pbDayNightTint(@indicator) unless @ignoretimeshade
        @indicator.x = @event.screen_x + @x_adj
        @indicator.y = @event.screen_y - Game_Map::TILE_HEIGHT + @y_adj
        @frame_num += 1     #-#
    end
end

class Scene_Map
    attr_reader :spritesets
end

class Spriteset_Map
    attr_accessor :event_indicator_sprites
            
    alias event_indicator_spriteset_init initialize 
    def initialize(map = nil)
        @event_indicator_sprites = []
        event_indicator_spriteset_init(map)
    end
    
    def addEventIndicator(new_sprite, forced = false)
        return false if !Settings::EVENT_INDICATORS[new_sprite.type]
        return false if !forced && @event_indicator_sprites[new_sprite.event.id] && !@event_indicator_sprites[new_sprite.event.id].disposed?
        @event_indicator_sprites[new_sprite.event.id].dispose if @event_indicator_sprites[new_sprite.event.id]
        @event_indicator_sprites[new_sprite.event.id] = new_sprite
        return true
    end

    def refreshEventIndicator(event)
        params = event.pbCheckForActiveIndicator
        if params
            ret = addEventIndicator(EventIndicator.new(params, event, @@viewport1, map), true)
            @event_indicator_sprites[event.id].dispose if @event_indicator_sprites[event.id] && !ret
        elsif @event_indicator_sprites[event.id] && map.map_id == event.map_id
            @event_indicator_sprites[event.id].dispose
        end
    end
    
    alias event_indicator_spriteset_dispose dispose
    def dispose
        event_indicator_spriteset_dispose
        @event_indicator_sprites.each do |sprite| 
            next if sprite.nil?
            sprite.dispose
        end
        @event_indicator_sprites.clear
    end
    
    alias event_indicator_spriteset_update update 
    def update
        event_indicator_spriteset_update
        @event_indicator_sprites.each do |sprite| 
            next if sprite.nil?
            sprite.update if !sprite.disposed?
        end
    end
end

class Game_Event < Game_Character
    attr_accessor :event_indicator_refresh

    def pbCheckForActiveIndicator
        ret = pbEventCommentInput(self, 1, "Event Indicator")
        if ret
            ret = ret[0].split.map { |x| x.match?(/^-?\d+$/) ? x.to_i : x }
        end
        return ret 
    end

    alias event_indicator_e_refresh refresh
    def refresh
        event_indicator_e_refresh
        if $scene.is_a?(Scene_Map) && $scene.spritesets
            $scene.spriteset.refreshEventIndicator(self)
        end
    end

end
  
EventHandlers.add(:on_new_spriteset_map, :add_event_indicators,
    proc do |spriteset, viewport|
        map = spriteset.map
        map.events.each_key do |i|
            event = map.events[i]
            params = event.pbCheckForActiveIndicator
            spriteset.addEventIndicator(EventIndicator.new(params, event, viewport, map)) if params
        end
    end
)