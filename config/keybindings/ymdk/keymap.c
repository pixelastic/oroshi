// Custom keymap for YMDK YMD09
// Source of truth for keyboard configuration

#include QMK_KEYBOARD_H

// ========================================================================
// QMK KEYCODE ALIASES
// ========================================================================
// The keyboard mapping of F keys above 13 is clunky
// Below are clearer names and documentation
#define KC_XF86LAUNCH5  KC_F14  // → XF86Launch5
#define KC_XF86LAUNCH6  KC_F15  // → XF86Launch6
#define KC_XF86LAUNCH7  KC_F16  // → XF86Launch7
#define KC_XF86LAUNCH8  KC_F17  // → XF86Launch8
#define KC_XF86LAUNCH9  KC_F18  // → XF86Launch9
// KC_F13 → Opens Help in Ubuntu (avoid)
// KC_F19 → NoSymbol (keycode 197)
// KC_F20 → XF86AudioMicMute (system intercepts)
// KC_F21 → XF86TouchpadToggle (system intercepts)
// KC_F22 → XF86TouchpadOn (system intercepts)
// KC_F23 → XF86TouchpadOff (system intercepts)
// KC_F24 → NoSymbol (keycode 202)

// ========================================================================
// COLOR DEFINITIONS
// ========================================================================
typedef struct {
    uint8_t r;
    uint8_t g;
    uint8_t b;
} Color;

#define BLUE   ((Color){0, 0, 255})
#define ORANGE ((Color){255, 50, 0})
#define GREEN  ((Color){0, 255, 0})
#define YELLOW ((Color){255, 255, 0})
#define BLACK  ((Color){0, 0, 0})  // Off/disabled

// ========================================================================
// LAYER ENUM
// ========================================================================
enum layers {
    _LAYER0 = 0,
    _LAYER1,
    _LAYER2,
    _LAYER3
};

// ========================================================================
// ACTION DEFINITIONS
// ========================================================================
#define LAYER_KITTY    TO(_LAYER0)
#define LAYER_AI       TO(_LAYER1)
#define LAYER_CONFIG   TO(_LAYER2)

#define SPEECH_TO_TEXT      C(KC_XF86LAUNCH5)
#define EMPTY_KEY           KC_NO

#define KITTY_COPY_OUTPUT   C(S(KC_Y))
#define KITTY_COPY_PATH     C(KC_Y)
#define KITTY_FULLSCREEN    LALT(KC_ENT)
#define KITTY_PASTE         C(S(KC_V))
#define KITTY_TAB_NEXT      LALT(KC_L)
#define KITTY_TAB_PREV      LALT(KC_H)
#define KITTY_WINDOW_NEXT   C(S(KC_RIGHT))

#define AI_MESSAGE_START LALT(KC_K) /* Go to start of message */
#define AI_CHAT_BOTTOM KC_END /* Go to end of conversation */
#define AI_CHOICE_NEXT KC_DOWN /* Next choice in list */
#define AI_OK KC_ENT /* Validate choice*/
#define AI_CANCEL KC_ESC /* Cancel / go back */
#define AI_MODE_NEXT S(KC_TAB) /* Normal -> Auto-Accept -> Plan */

#define CONFIG_SOUND_MODE C(G(KC_F8)) /* Toggle sound mode */
#define CONFIG_AUTOSEND C(G(KC_F9)) /* Toggle autosend */
#define CONFIG_TRANSLATE C(G(KC_F10)) /* Toggle translate */
#define CONFIG_SLACK C(G(KC_F11)) /* Toggle slack rewrite */
#define CONFIG_MODEL C(G(KC_F12)) /* Toggle whisper/parakeet */


// Visual 3x3 grid matches the physical keyboard layout
// Layer 0 - Blue / Kitty Navigation
#define LAYER0_KEYS \
    LAYER_AI,          KITTY_TAB_PREV,    KITTY_TAB_NEXT, \
    KITTY_FULLSCREEN,  SPEECH_TO_TEXT,    KITTY_WINDOW_NEXT, \
    KITTY_COPY_PATH,   KITTY_COPY_OUTPUT, KITTY_PASTE

// Layer 1 - Orange / AI (Claude)
#define LAYER1_KEYS \
    LAYER_KITTY,      AI_CANCEL,      LAYER_CONFIG, \
    AI_MESSAGE_START, SPEECH_TO_TEXT, AI_CHOICE_NEXT, \
    AI_CHAT_BOTTOM,   AI_MODE_NEXT ,  AI_OK

// Layer 2 - Green / Config
#define LAYER2_KEYS \
    CONFIG_SOUND_MODE, CONFIG_AUTOSEND, LAYER_AI, \
    CONFIG_TRANSLATE,  CONFIG_SLACK,    CONFIG_MODEL, \
    EMPTY_KEY,         EMPTY_KEY,       EMPTY_KEY

// Layer 3 - Placeholder
#define LAYER3_KEYS \
    EMPTY_KEY, EMPTY_KEY, EMPTY_KEY, \
    EMPTY_KEY, EMPTY_KEY, EMPTY_KEY, \
    EMPTY_KEY, EMPTY_KEY, EMPTY_KEY

// ========================================================================
// COLOR MAPPING
// ========================================================================
Color get_color_for_key(uint16_t keycode, uint8_t layer) {
    if (keycode == LAYER_AI) return ORANGE;
    if (keycode == LAYER_KITTY) return BLUE;
    if (keycode == LAYER_CONFIG) return GREEN;

    if (keycode == SPEECH_TO_TEXT) return YELLOW;

    if (keycode == KITTY_FULLSCREEN) return BLUE;
    if (keycode == KITTY_TAB_PREV) return BLUE;
    if (keycode == KITTY_WINDOW_NEXT) return BLUE;
    if (keycode == KITTY_TAB_NEXT) return BLUE;
    if (keycode == KITTY_COPY_PATH) return BLUE;
    if (keycode == KITTY_COPY_OUTPUT) return BLUE;
    if (keycode == KITTY_PASTE) return BLUE;

    if (keycode == AI_MESSAGE_START) return ORANGE;
    if (keycode == AI_CHOICE_NEXT) return ORANGE;
    if (keycode == AI_CHAT_BOTTOM) return ORANGE;
    if (keycode == AI_CANCEL) return ORANGE;
    if (keycode == AI_OK) return ORANGE;
    if (keycode == AI_MODE_NEXT) return ORANGE;

    if (keycode == CONFIG_SOUND_MODE) return GREEN;
    if (keycode == CONFIG_AUTOSEND) return GREEN;
    if (keycode == CONFIG_TRANSLATE ) return GREEN;
    if (keycode == CONFIG_SLACK) return GREEN;
    if (keycode == CONFIG_MODEL) return GREEN;

    if (keycode == EMPTY_KEY) return BLACK;

    return BLACK;
}

// ========================================================================
// QMK INFRASTRUCTURE - DO NOT EDIT BELOW THIS LINE
// ========================================================================
// Helper macro to force expansion of defines before passing to LAYOUT
#define LAYOUT_WRAPPER(...) LAYOUT(__VA_ARGS__)

// Visual layout macro - maps visual positions to array
// Allows defining colors in the same visual order as keymaps
#define VISUAL_LAYOUT( \
    k00, k01, k02, \
    k10, k11, k12, \
    k20, k21, k22  \
) { k00, k01, k02, k10, k11, k12, k20, k21, k22 }

// Keymap configuration - Built from configuration defines above
const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [_LAYER0] = LAYOUT_WRAPPER(LAYER0_KEYS),
    [_LAYER1] = LAYOUT_WRAPPER(LAYER1_KEYS),
    [_LAYER2] = LAYOUT_WRAPPER(LAYER2_KEYS),
    [_LAYER3] = LAYOUT_WRAPPER(LAYER3_KEYS)
};

// RGB Matrix: Set individual colors per key and per layer
bool rgb_matrix_indicators_advanced_user(uint8_t led_min, uint8_t led_max) {
    uint8_t layer = get_highest_layer(layer_state);

    // Mapping from visual position (0-8) to LED index
    // Visual order: top-left, top-center, top-right, mid-left, mid-center, mid-right, bot-left, bot-center, bot-right
    // LED order: each row is reversed (right-to-left)
    const uint8_t visual_to_led[9] = {2, 1, 0, 5, 4, 3, 8, 7, 6};

    // For each key position, get its keycode and corresponding color
    for (uint8_t i = 0; i < 9; i++) {
        uint16_t keycode = pgm_read_word(&keymaps[layer][i / MATRIX_COLS][i % MATRIX_COLS]);
        Color color = get_color_for_key(keycode, layer);
        rgb_matrix_set_color(visual_to_led[i], color.r, color.g, color.b);
    }

    return false;
}
