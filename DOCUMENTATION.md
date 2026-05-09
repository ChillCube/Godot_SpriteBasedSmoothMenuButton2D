# Godot_SpriteBasedSmoothMenuButton2D API Reference
Generated: 2026-05-09

A different way of handling menu buttons, rather than using control nodes. This can be useful for animations among others

## Class: SmoothButton
**Inherits:** [Sprite2D](https://docs.godotengine.org/en/stable/classes/class_sprite2d.html)

Used for having smoother UI animations

### ⚙️ Inspector Variables (Exported)
| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| **button_text** | `String` | `"Button"` | The string displayed on the button's label. |
| **text_position** | `TextPosition` | `TextPosition.CENTER` | Where the text label is placed relative to the button texture. |
| **text_offset** | `float` | `10.0` | The distance (in pixels) the text sits away from the button texture edges. |
| **text_unpressed_height_offset** | `float` | `0` | This value is used for when the height of the text needs to be different for wheter or not the button is pressed or not |
| **label_settings** | `LabelSettings:` | `-` | Custom LabelSettings resource for controlling font, size, and shadow. |
| **spr_button_not_pressed** | `NinePatchRect:` | `-` | The default texture used when the button is idle or hovered. |
| **spr_button_pressed** | `NinePatchRect:` | `-` | The default texture used when the button is idle or hovered. |
| **is_selected** | `bool` | `false` | Whether this button is currently highlighted/selected by the user. |
| **selected_scale** | `float` | `1.1` | The scale multiplier applied to the button when it is selected (e.g., 1.1 for 110%). |
| **selected_color** | `Color` | `Color(1.2, 1.2, 1.2, 1.0)` | The color tint applied to the button when it is selected. |
| **lerp_time** | `float` | `0.15` | The duration (in seconds) for the selection scale and color transitions. |
| **_position** | `Vector2` | `Vector2.ZERO` | The local offset relative to the anchor point when the button is visible. |
| **_off_screen_position** | `Vector2` | `Vector2(0.0, 0.6)` | The local offset relative to the anchor point when the button is hidden. |
| **button_hidden** | `bool` | `false` | If true, the button moves to its off-screen position and becomes unselectable. |
| **bounce** | `bool` | `false` | Enables an elastic bounce effect when the button reaches its target position. |
| **rotation_on** | `bool` | `false` | If enabled, the button will slightly tilt/rotate during movement. |
| **speed** | `float` | `10` | The speed multiplier for the smooth movement transition. |

### 💾 Class Variables (Standard)
| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| **focused_button** | `SmoothButton` | `null` | Keeps track of which button currently has controller/keyboard focus globally. |
| **anchor_point** | `Vector2` | `Vector2(0.5, 0.5)` | The normalized screen coordinate (0.0 to 1.0) used as the button's origin. |

---

