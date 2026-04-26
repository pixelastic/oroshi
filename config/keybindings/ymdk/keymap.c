// Custom keymap for YMDK YMD09
// Source of truth for keyboard configuration

#include QMK_KEYBOARD_H

// LAYER ENUM
enum layers {
    _LAYER_NORMAL = 0,
    _LAYER_INSERT,
    _LAYER_CONFIG,
    _LAYER_SOUND
};

// QMK KEYCODE ALIASES {{{
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
// }}}

// COLOR DEFINITIONS {{{
typedef struct {
    uint8_t r;
    uint8_t g;
    uint8_t b;
} Color;

// Blue-Green
#define BLUE  ((Color){0, 60, 200})
#define SKY   ((Color){0, 140, 200})
#define CYAN  ((Color){0, 180, 180})
#define MINT  ((Color){0, 200, 100})
#define GREEN ((Color){0, 180, 0})

// Red-Yellow
#define RED    ((Color){200, 0, 0})
#define CORAL  ((Color){200, 40, 0})
#define ORANGE ((Color){200, 70, 0})
#define AMBER  ((Color){200, 150, 0})
#define YELLOW ((Color){200, 200, 0})

// Violet-Pink
#define VIOLET  ((Color){50, 0, 200})
#define PURPLE  ((Color){110, 0, 180})
#define MAGENTA ((Color){180, 0, 180})
#define FUCHSIA ((Color){200, 0, 120})
#define PINK    ((Color){200, 0, 100})

// Black-White
#define BLACK     ((Color){12, 15, 21})
#define GREY      ((Color){107, 114, 128})
#define WHITE     ((Color){255, 255, 255})
#define NEUTRAL   ((Color){82, 82, 82})
#define COLOR_OFF ((Color){0, 0, 0})
// }}}

// KEY CODE DEFINITIONS {{{
#define MODE_NORMAL    TO(_LAYER_NORMAL)
#define MODE_INSERT    TO(_LAYER_INSERT)
#define MODE_CONFIG    TO(_LAYER_CONFIG)
#define MODE_SOUND    TO(_LAYER_SOUND)

#define SPEECH_TO_TEXT      C(KC_XF86LAUNCH5)
#define EMPTY_KEY           KC_NO

#define COPY_OUTPUT   C(S(KC_Y))
#define COPY_PATH     C(KC_Y)
#define FULLSCREEN    LALT(KC_ENT)
#define PASTE         C(S(KC_V))
#define TAB_NEXT      LALT(KC_L)
#define TAB_PREV      LALT(KC_H)
#define WINDOW_NEXT   C(S(KC_RIGHT))

#define MESSAGE_START LALT(KC_K) /* Go to start of message */
#define CHAT_BOTTOM KC_END /* Go to end of conversation */
#define CHOICE_NEXT KC_DOWN /* Next choice in list */
#define OK KC_ENT /* Validate choice*/
#define CANCEL C(KC_C) /* Cancel / go back */
#define MODE_NEXT S(KC_TAB) /* Normal -> Auto-Accept -> Plan */

#define CONFIG_SOUND_MODE C(G(KC_F8))
#define CONFIG_AUTOSEND C(G(KC_F9))
#define CONFIG_TRANSLATE C(G(KC_F10))
#define CONFIG_SLACK C(G(KC_F11))
#define CONFIG_MODEL C(G(KC_F12))

#define RP_GREEN A(G(KC_F2))
#define RP_YELLOW A(G(KC_F3))
#define RP_RED A(G(KC_F4))
#define RP_BLUE A(G(KC_F5))
#define RP_GREY A(G(KC_F6))
#define RP_PURPLE A(G(KC_F7))
// }}}

// VISUAL GRID {{{
#define LAYER_NORMAL_KEYS \
    MODE_INSERT,      TAB_PREV, TAB_NEXT, \
    MESSAGE_START, SPEECH_TO_TEXT, CHOICE_NEXT, \
    CHAT_BOTTOM,   CANCEL,      OK

#define LAYER_INSERT_KEYS \
    MODE_NORMAL,     FULLSCREEN, MODE_CONFIG,    \
    COPY_OUTPUT,    SPEECH_TO_TEXT,    WINDOW_NEXT, \
    COPY_PATH, MODE_NEXT, PASTE

#define LAYER_CONFIG_KEYS \
    CONFIG_SOUND_MODE, CONFIG_AUTOSEND, MODE_INSERT, \
    CONFIG_TRANSLATE,  CONFIG_SLACK,    CONFIG_MODEL, \
    EMPTY_KEY, EMPTY_KEY, MODE_SOUND

// Layer 3 - Placeholder
#define LAYER_SOUND_KEYS \
    RP_GREEN, RP_YELLOW, RP_RED, \
    RP_PURPLE, RP_BLUE, RP_GREY, \
    EMPTY_KEY, EMPTY_KEY, MODE_CONFIG
// }}}

// COLOR MAPPING {{{
Color get_color_for_key(uint16_t keycode, uint8_t layer) {
    // Normal
    if (keycode == MODE_INSERT) return WHITE;
    if (keycode == TAB_PREV) return BLUE;
    if (keycode == TAB_NEXT) return BLUE;

    if (keycode == MESSAGE_START) return BLUE;
    if (keycode == SPEECH_TO_TEXT) return YELLOW;
    if (keycode == CHOICE_NEXT) return MINT;

    if (keycode == CHAT_BOTTOM) return BLUE;
    if (keycode == CANCEL) return RED;
    if (keycode == OK) return GREEN;

    // Insert
    if (keycode == MODE_NORMAL) return WHITE;
    if (keycode == FULLSCREEN) return CORAL;
    if (keycode == MODE_CONFIG) return WHITE;

    if (keycode == COPY_OUTPUT) return ORANGE;
    if (keycode == SPEECH_TO_TEXT) return YELLOW;
    if (keycode == WINDOW_NEXT) return MINT;

    if (keycode == COPY_PATH) return ORANGE;
    if (keycode == MODE_NEXT) return MAGENTA;
    if (keycode == PASTE) return GREEN;

    // Config
    if (keycode == CONFIG_SOUND_MODE) return PURPLE;
    if (keycode == CONFIG_AUTOSEND) return PURPLE;
    if (keycode == MODE_INSERT) return WHITE;

    if (keycode == CONFIG_TRANSLATE) return MAGENTA;
    if (keycode == CONFIG_SLACK) return MAGENTA;
    if (keycode == CONFIG_MODEL) return MAGENTA;

    if (keycode == MODE_SOUND) return WHITE;

    // Sound
    if (keycode == RP_GREEN) return GREEN;
    if (keycode == RP_YELLOW) return YELLOW;
    if (keycode == RP_RED) return RED;
    if (keycode == RP_PURPLE) return PURPLE;
    if (keycode == RP_GREY) return GREY;
    if (keycode == RP_BLUE) return BLUE;

    return COLOR_OFF;
}
// }}}

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
    [_LAYER_NORMAL] = LAYOUT_WRAPPER(LAYER_NORMAL_KEYS),
    [_LAYER_INSERT] = LAYOUT_WRAPPER(LAYER_INSERT_KEYS),
    [_LAYER_CONFIG] = LAYOUT_WRAPPER(LAYER_CONFIG_KEYS),
    [_LAYER_SOUND] = LAYOUT_WRAPPER(LAYER_SOUND_KEYS)
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
