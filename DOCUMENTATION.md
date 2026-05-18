# Godot_SpriteBasedSmoothMenuButton2D API Reference
Generated: 2026-05-18

A different way of handling menu buttons, rather than using control nodes. This can be useful for animations among others

## Class: SmoothButton
**Inherits:** [SmoothUI](git@github.com:ChillCube/SmoothUI/blob/main/DOCUMENTATION.md)

Used for having smoother UI animations

### ⚙️ Inspector Variables (Exported)
| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| **button_text** | `String` | `"Button"` | The string displayed on the button's label. |
| **text_position** | `TextPosition` | `TextPosition.CENTER` | Where the text label is placed relative to the button texture. |
| **text_offset** | `float` | `10.0` | The distance (in pixels) the text sits away from the button texture edges. |
| **text_unpressed_height_offset** | `float` | `0` | This value is used for when the height of the text needs to be different for whether or not the button is pressed or not |
| **label_settings** | `LabelSettings:` | `-` | Custom LabelSettings resource for controlling font, size, and shadow. |
| **spr_button_not_pressed** | `NinePatchRect:` | `-` | The default texture used when the button is idle or hovered. |
| **spr_button_pressed** | `NinePatchRect:` | `-` | The texture used when the button is pressed. |
| **adapt_size_to_text** | `bool` | `false` | When enabled, the button resizes to fit its text, subject to min/max constraints. |
| **margin_left** | `float` | `20` | Left margin between text and button edge when adapt_size_to_text is enabled. |
| **margin_right** | `float` | `20` | Right margin between text and button edge when adapt_size_to_text is enabled. |
| **margin_top** | `float` | `10` | Top margin between text and button edge when adapt_size_to_text is enabled. |
| **margin_bottom** | `float` | `10` | Bottom margin between text and button edge when adapt_size_to_text is enabled. |
| **min_size** | `Vector2` | `Vector2(0, 0)` | Minimum button size when adapting to text. Zero means no minimum on that axis. |
| **max_size** | `Vector2` | `Vector2(0, 0)` | Maximum button size when adapting to text. Zero means no maximum on that axis. Text is truncated with ... if it exceeds max x. |
| **is_selected** | `bool` | `false` | Whether this button is currently highlighted/selected by the user. |
| **selected_scale** | `float` | `1.1` | The scale multiplier applied to the button when it is selected (e.g., 1.1 for 110%). |
| **selected_color** | `Color` | `Color(1.2, 1.2, 1.2, 1.0)` | The color tint applied to the button when it is selected. |
| **lerp_time** | `float` | `0.15` | The duration (in seconds) for the selection scale and color transitions. |

### 💾 Class Variables (Standard)
| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| **focused_button** | `SmoothButton` | `null` | Keeps track of which button currently has controller/keyboard focus globally. |

---

