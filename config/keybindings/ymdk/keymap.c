// Custom keymap for YMDK YMD09
// Source of truth for keyboard configuration
//
// Kitty
// Next/Previous Tab
// Toggle Fullscreen
// Up, Right, Down, Left in windows
// Toggle AI
//
// Claude
// Up/Down
// Ok (Enter)
// Cancel (Ctrl-C)
// Enable/Disable thinking
// Switch mode (auto-accept, normal, plan)
//
// Speech to text
// Start/Stop
// Toggle Slack
// Toggle English
// Toggle Autosend
//
// Misc
// Toggle sound mode

#include QMK_KEYBOARD_H

// Layer definitions
enum layers {
    _BASE = 0,  // Layer 0: Numbers 1-9 with rainbow colors
    _LAYER1,    // Layer 1: All A keys with red color
    _LAYER2,    // Layer 2: All B keys with green color
    _LAYER3     // Layer 3: All C keys with blue color
};

// Keymap configuration
const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    /* Layer 0 - BASE
     * ┌───┬───┬───┐
     * │TO1│ 8 │ 9 │  <- TO1 = Go to layer 1
     * ├───┼───┼───┤
     * │ 4 │ 5 │ 6 │
     * ├───┼───┼───┤
     * │ 1 │ 2 │ 3 │
     * └───┴───┴───┘
     */
    [_BASE] = LAYOUT(
        TO(_LAYER1), KC_8,  KC_9,
        KC_4,        KC_5,  KC_6,
        KC_1,        KC_2,  KC_3
    ),

    /* Layer 1 - All A, Red
     * TO2 = Go to layer 2
     */
    [_LAYER1] = LAYOUT(
        TO(_LAYER2), KC_A,  KC_A,
        KC_A,        KC_A,  KC_A,
        KC_A,        KC_A,  KC_A
    ),

    /* Layer 2 - All B, Green
     * TO3 = Go to layer 3
     */
    [_LAYER2] = LAYOUT(
        TO(_LAYER3), KC_B,  KC_B,
        KC_B,        KC_B,  KC_B,
        KC_B,        KC_B,  KC_B
    ),

    /* Layer 3 - All C, Blue
     * TO0 = Go back to layer 0
     */
    [_LAYER3] = LAYOUT(
        TO(_BASE),   KC_C,  KC_C,
        KC_C,        KC_C,  KC_C,
        KC_C,        KC_C,  KC_C
    )
};

// RGB Matrix: Set individual colors per key and per layer
bool rgb_matrix_indicators_advanced_user(uint8_t led_min, uint8_t led_max) {
    uint8_t layer = get_highest_layer(layer_state);

    switch(layer) {
        case _BASE:
            // Layer 0: Rainbow colors (each key different)
            // LED mapping: [0]=top-right, [1]=top-center, [2]=top-left
            //              [3]=mid-right, [4]=mid-center, [5]=mid-left
            //              [6]=bot-right, [7]=bot-center, [8]=bot-left
            rgb_matrix_set_color(0, 255, 0, 0);     // 9: Red
            rgb_matrix_set_color(1, 255, 127, 0);   // 8: Orange
            rgb_matrix_set_color(2, 255, 255, 0);   // TO: Yellow
            rgb_matrix_set_color(3, 0, 255, 0);     // 6: Green
            rgb_matrix_set_color(4, 0, 255, 255);   // 5: Cyan
            rgb_matrix_set_color(5, 0, 0, 255);     // 4: Blue
            rgb_matrix_set_color(6, 127, 0, 255);   // 3: Purple
            rgb_matrix_set_color(7, 255, 0, 255);   // 2: Magenta
            rgb_matrix_set_color(8, 255, 255, 255); // 1: White
            break;

        case _LAYER1:
            // Layer 1: All red
            for (uint8_t i = led_min; i < led_max; i++) {
                rgb_matrix_set_color(i, 255, 0, 0);
            }
            break;

        case _LAYER2:
            // Layer 2: All green
            for (uint8_t i = led_min; i < led_max; i++) {
                rgb_matrix_set_color(i, 0, 255, 0);
            }
            break;

        case _LAYER3:
            // Layer 3: All blue
            for (uint8_t i = led_min; i < led_max; i++) {
                rgb_matrix_set_color(i, 0, 0, 255);
            }
            break;
    }

    return false;
}
