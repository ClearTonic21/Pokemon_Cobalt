# =========== Instructions ===========
# 1. Define any custom event indicators in EVENT_INDICATORS below. (See Defining Indicators)
# 2. Open the event page that you want to show an indicator when active
# 3. In that event page, add a new Comment command.
# 4. Add text to the Comment in the format noted below. The first line must be
#    "Event Indicator" without quotes. The second line follows the format
#    <indicator id> <x adjustment> <y adjustment>
#    - Replace <indicator ID> with the ID of the indicator you want to use. For example, 
#      you could replace it with the word quest for the "quest" indicator.
#    - (Optional) Replace <x adjustment> with the value of x that you want to
#      adjust the placement of the indicator by. For example, you could replace it 
#      with 2 if you want it to be 2 pixels to the right.
#    - (Optional) Replace <y adjustment> with the value of y that you want to
#      adjust the placement of the indicator by. For example, you could replace it 
#      with -6 if you want it to be 6 pixels up.
#   
#    Format:
#      Event Indicator
#      <indicator id> <x adjustment> <y adjustment>
#
#    Example 1:
#      Event Indicator
#      quest
#
#    Example 2:
#      Event Indicator
#      question 2 -6
#
# 5. You're all set! Now when that event page is active, it should show your indicator.
#
# =========== Defining Indicators ===========
# Define each indicator for your game in EVENT_INDICATORS in the Settings module below.
# Each indicator definition is a hash, where the key is the ID of the indicator, as a string, 
# that you'll use when adding Comments to event pages. There are two values/parameters you 
# can define for your indicator:
#   - :graphic => String - The filepath of the graphic you want to use for the indicator
#   - :x_adjustment => (Optional) Integer - Adjust the indicator's x position by this value. 
#                      Can be positive or negative.
#   - :y_adjustment => (Optional) Integer - Adjust the indicator's y position by this value. 
#                      Can be positive or negative.
#   - :always_visible => (Optional) Boolean - If true, the indicator will be visible even when 
#                        you run/interact with the event. If not set or set to false, the
#                        indicator will disappear when you run/interact with the event.
#  Example:
#        "question" => {
#            :graphic => "Graphics/UI/Event Indicators/event_question",
#            :always_visible => true,
#            :x_adjustment => 2,
#            :y_adjustment => -6,
#            :ignore_time_shading => true
#        }
#
# =========== Use Cases ===========
# The use case that spawned this plugin is to show an indicator when the event
# can give you a quest. After defining a "quest" indicator in EVENT_INDICATORS,
# You would add the appropriate Comment to the event, in the appropriate page.
# After you run/interact with the event, which gives you the quest, you'll
# likely set a Self Switch or some other condition to make a new page become
# active for the event. Don't include an indicator Comment to that page,
# and it will no longer show an indicator. If wanted, the new page can show
# a new indicator by adding a Comment to that page as well.


module Settings

    #------------------------------------------------------------------------------------
    # Define your Event Indicators
    #------------------------------------------------------------------------------------
    EVENT_INDICATORS = {
        # "quest" => {
        #     :graphic => "Graphics/UI/Event Indicators/quest_available"
        # },
        # "questsimple" => {
        #     :graphic => "Graphics/UI/Event Indicators/quest_available_simple"
        # },
        # "questshortnpc" => {
        #     :graphic => "Graphics/UI/Event Indicators/quest_available",
        #     :y_adjustment => 4
        # },
        # "question" => {
        #     :graphic => "Graphics/UI/Event Indicators/event_question",
        #     :always_visible => true,
        #     :ignore_time_shading => true,
        # },
        "battle" => {
            :graphic => "Graphics/UI/Event Indicators/battle",
            :ignore_time_shading => true,
            :toggle_sprite => true
        },
        "battle_1" => {
            :graphic => "Graphics/UI/Event Indicators/battle_1",
            :ignore_time_shading => true,
            :toggle_sprite => true
        },
        "battle_gold" => {
            :graphic => "Graphics/UI/Event Indicators/battle_gold",
            :ignore_time_shading => true,
            :toggle_sprite => true
        },
        "battle_gold_1" => {
            :graphic => "Graphics/UI/Event Indicators/battle_gold_1",
            :ignore_time_shading => true,
            :toggle_sprite => true
        },
        "dots" => {
            :graphic => "Graphics/UI/Event Indicators/dots",
            :ignore_time_shading => true,
            :toggle_sprite => true
        },
        "dots_1" => {
            :graphic => "Graphics/UI/Event Indicators/dots_1",
            :ignore_time_shading => true,
            :toggle_sprite => true
        },
        "dots_gold" => {
            :graphic => "Graphics/UI/Event Indicators/dots_gold",
            :ignore_time_shading => true,
            :toggle_sprite => true
        },
        "dots_gold_1" => {
            :graphic => "Graphics/UI/Event Indicators/dots_gold_1",
            :ignore_time_shading => true,
            :toggle_sprite => true
        },
    }

    #------------------------------------------------------------------------------------
    # Set x and y adjustments that will apply to all event indicators. Can be positive
    # or negative.
    #------------------------------------------------------------------------------------
    EVENT_INDICATOR_X_ADJ = 0
    EVENT_INDICATOR_Y_ADJ = -4

end