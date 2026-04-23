// Custom keymap for YMDK YMD09
// Source of truth for keyboard configuration
//
// Deux modes, comme vim
//
// Move (Blue)
// Blue/Orange PrevTab NextTab
// ToggleFullscreen UpWindow ToggleAi
// LeftWindow BottomWindow RightWindow
//
// AI (orange) pour Claude
// Blue/Orange SpeechToText Orange/Green
// Cancel Up Ok
// ToggleMode Down ToggleThink
//
// Config (green)
// ToggleSound ToggleSend Orange/Green
// ToggleEnglish ToggleSlack ToggleModel
// CopyPath CopyOutput Paste
//
//
// - Ctrl-Y to copy path?
// - Ctrl-Maj-Y to copy output?
// Maybe ToggleMode and ToggleThink are in Green?
// And in Orange bottom row I have copy path or copy error?
//

#include QMK_KEYBOARD_H

// Note: The keyboard mapping of F keys above 13 is clunky. Below is a set of
// clearer names and documentation
#define KC_XF86LAUNCH5     KC_F14
#define KC_XF86LAUNCH6     KC_F15
#define KC_XF86LAUNCH7     KC_F16
#define KC_XF86LAUNCH8     KC_F17
#define KC_XF86LAUNCH9     KC_F18
// KC_F13 → Opens Help in Ubuntu
// KC_F19 → NoSymbol (keycode 197)
// KC_F20 → XF86AudioMicMute
// KC_F21 → XF86TouchpadToggle
// KC_F22 → XF86TouchpadOn
// KC_F23 → XF86TouchpadOff
// KC_F24 → NoSymbol (keycode 202)
// ========================================================================

// Layer 0 - Blue / Kitty
// Gnome binding: <Ctrl>XF86Launch5 → mic2txt
#define LAYER0_KEYS \
    TO(_LAYER1), C(KC_XF86LAUNCH5), LALT(KC_ENT), \
    LALT(KC_H),  C(S(KC_RIGHT)),    LALT(KC_L), \
    C(KC_Y),     C(S(KC_Y)),        C(S(KC_V))

#define LAYER0_COLORS \
    ORANGE, YELLOW, BLUE, \
    BLUE,   BLUE,   BLUE, \
    BLUE,   BLUE,   BLUE

// Layer 1 - Orange / Claude
#define LAYER1_KEYS \
    TO(_LAYER0), KC_NO, TO(_LAYER2), \
    KC_NO,       KC_NO, KC_NO, \
    KC_NO,       KC_NO, KC_NO

#define LAYER1_COLORS \
    BLUE,   ORANGE, GREEN, \
    ORANGE, ORANGE, ORANGE, \
    ORANGE, ORANGE, ORANGE

// Layer 2 - Green / Config
#define LAYER2_KEYS \
    KC_NO, KC_NO, TO(_LAYER1), \
    KC_NO, KC_NO, KC_NO, \
    KC_NO, KC_NO, TO(_LAYER0)

#define LAYER2_COLORS \
    GREEN, GREEN, ORANGE, \
    GREEN, GREEN, GREEN, \
    GREEN, GREEN, BLUE

// Layer 3 - Placeholder
#define LAYER3_KEYS \
    KC_NO, KC_NO, KC_NO, \
    KC_NO, KC_NO, KC_NO, \
    KC_NO, KC_NO, KC_NO

#define LAYER3_COLORS \
    BLUE, BLUE, BLUE, \
    BLUE, BLUE, BLUE, \
    BLUE, BLUE, BLUE

// Color definitions
typedef struct {
    uint8_t r;
    uint8_t g;
    uint8_t b;
} Color;

#define BLUE   ((Color){0, 0, 255})
#define ORANGE ((Color){255, 50, 0})
#define GREEN  ((Color){0, 255, 0})
#define YELLOW ((Color){255, 255, 0})

// Layer definitions
enum layers {
    _LAYER0 = 0,  // Layer 0: Blue (Move mode)
    _LAYER1,      // Layer 1: Orange (AI mode)
    _LAYER2,      // Layer 2: Green (Config mode) - placeholder
    _LAYER3       // Layer 3: Placeholder
};


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

    // Color layout for current layer (defined in visual keyboard order)
    Color layout[9];

    // Load colors from configuration defines
    switch(layer) {
        case _LAYER0:
            {
                Color colors[] = {LAYER0_COLORS};
                for (uint8_t i = 0; i < 9; i++) {
                    layout[i] = colors[i];
                }
            }
            break;
        case _LAYER1:
            {
                Color colors[] = {LAYER1_COLORS};
                for (uint8_t i = 0; i < 9; i++) {
                    layout[i] = colors[i];
                }
            }
            break;
        case _LAYER2:
            {
                Color colors[] = {LAYER2_COLORS};
                for (uint8_t i = 0; i < 9; i++) {
                    layout[i] = colors[i];
                }
            }
            break;
        case _LAYER3:
            {
                Color colors[] = {LAYER3_COLORS};
                for (uint8_t i = 0; i < 9; i++) {
                    layout[i] = colors[i];
                }
            }
            break;
    }

    // Apply colors from visual layout to actual LED positions
    for (uint8_t i = 0; i < 9; i++) {
        rgb_matrix_set_color(visual_to_led[i], layout[i].r, layout[i].g, layout[i].b);
    }

    return false;
}
