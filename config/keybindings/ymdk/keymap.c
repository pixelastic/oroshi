// Custom keymap for YMDK YMD09
// Source of truth for keyboard configuration

#include QMK_KEYBOARD_H

// Layer definitions
enum layers {
    _BASE = 0,  // Layer 0: Numbers 1-9 with rainbow colors
    _ALT        // Layer 1: All Z keys with red color
};

// Keymap configuration
const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    /* Layer 0 - BASE
     * ┌───┬───┬───┐
     * │TG1│ 8 │ 9 │  <- TG1 = Toggle to layer 1
     * ├───┼───┼───┤
     * │ 4 │ 5 │ 6 │
     * ├───┼───┼───┤
     * │ 1 │ 2 │ 3 │
     * └───┴───┴───┘
     */
    [_BASE] = LAYOUT(
        TG(_ALT), KC_8,     KC_9,
        KC_4,     KC_5,     KC_6,
        KC_1,     KC_2,     KC_3
    ),

    /* Layer 1 - ALT
     * All keys output Z, all red color
     * TG1 on top-left toggles back to layer 0
     */
    [_ALT] = LAYOUT(
        TG(_ALT), KC_Z,     KC_Z,
        KC_Z,     KC_Z,     KC_Z,
        KC_Z,     KC_Z,     KC_Z
    )
};

// RGB Matrix: Set individual colors per key and per layer
bool rgb_matrix_indicators_advanced_user(uint8_t led_min, uint8_t led_max) {
    uint8_t layer = get_highest_layer(layer_state);

    switch(layer) {
        case _BASE:
            // Layer 0: Rainbow colors (each key different)
            // LED mapping matches matrix positions:
            // [0]=top-right, [1]=top-center, [2]=top-left
            // [3]=mid-right, [4]=mid-center, [5]=mid-left
            // [6]=bot-right, [7]=bot-center, [8]=bot-left

            rgb_matrix_set_color(0, 255, 0, 0);     // 9: Red
            rgb_matrix_set_color(1, 255, 127, 0);   // 8: Orange
            rgb_matrix_set_color(2, 255, 255, 0);   // 7: Yellow
            rgb_matrix_set_color(3, 0, 255, 0);     // 6: Green
            rgb_matrix_set_color(4, 0, 255, 255);   // 5: Cyan
            rgb_matrix_set_color(5, 0, 0, 255);     // 4: Blue
            rgb_matrix_set_color(6, 127, 0, 255);   // 3: Purple
            rgb_matrix_set_color(7, 255, 0, 255);   // 2: Magenta
            rgb_matrix_set_color(8, 255, 255, 255); // TG: White
            break;

        case _ALT:
            // Layer 1: All red
            for (uint8_t i = led_min; i < led_max; i++) {
                rgb_matrix_set_color(i, 255, 0, 0); // Red
            }
            break;
    }

    return false;
}
