<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements a VGA text display that shows "ITI Luebeck" with animated visual effects. The design generates standard VGA timing signals at 640x480 resolution using a 25.175 MHz clock.

### Core Components:

**VGA Sync Generator** (`hvsync_generator.v`):
- Generates horizontal and vertical sync signals (hsync, vsync) according to VGA 640x480 @ 60Hz timing specification
- Provides current pixel position (hpos, vpos) for the rendering logic
- Outputs a display_on signal to indicate when the beam is in the visible display area

**Text Rendering Engine** (`project.v`):
- Implements a custom character ROM for displaying the text "ITI Luebeck"
- Each character is rendered using a 16x16 pixel cell (with an 8x12 font bitmap inside)
- Supports both uppercase letters (I, T, L) and lowercase letters (u, e, b, c, k), plus spaces
- Positions characters at specific screen coordinates and renders them pixel-by-pixel

**Animation System**:
- Frame counter increments at the start of each video frame to drive animations
- Two animation modes controlled by input pin `ui_in[1]`:
  - **Horizontal Scroll** (mode 0): Text scrolls from right to left across the screen
  - **Vertical Bounce** (mode 1): Text moves up and down vertically

**Visual Effects**:
- Two color modes controlled by input pin `ui_in[0]`:
  - **White Mode** (mode 0): Text appears in white against an animated background
  - **Rainbow Mode** (mode 1): Text cycles through colors based on position and time
- Animated background pattern using XOR operations on pixel coordinates and frame counter

**Output Format**:
- Generates 6-bit RGB color (2 bits per channel: RGB222)
- Compatible with Tiny VGA PMOD interface
- Pin mapping: R1, G1, B1 for MSBs; R0, G0, B0 for LSBs; plus HSync and VSync signals

## How to test

### Hardware Setup:

1. **Connect a Tiny VGA PMOD** to the output pins according to this mapping:
   - `uo[0]` → R1 (Red MSB)
   - `uo[1]` → G1 (Green MSB)
   - `uo[2]` → B1 (Blue MSB)
   - `uo[3]` → VSync
   - `uo[4]` → R0 (Red LSB)
   - `uo[5]` → G0 (Green LSB)
   - `uo[6]` → B0 (Blue LSB)
   - `uo[7]` → HSync

2. **Connect the Tiny VGA PMOD to a VGA monitor** using a standard VGA cable

3. **Ensure the design is clocked at 25.175 MHz** for proper VGA timing (640x480 @ 60Hz)

### Testing Procedure:

1. **Default behavior**: After reset, you should see "ITI Luebeck" text scrolling horizontally from right to left on the screen with a white color and an animated background pattern.

2. **Test color modes** (toggle `ui_in[0]`):
   - Set `ui_in[0] = 0`: Text appears in white
   - Set `ui_in[0] = 1`: Text appears with rainbow color cycling effect

3. **Test movement modes** (toggle `ui_in[1]`):
   - Set `ui_in[1] = 0`: Text scrolls horizontally from right to left
   - Set `ui_in[1] = 1`: Text is horizontally centered and bounces vertically

4. **Combine modes**: Try all four combinations (00, 01, 10, 11) of the control inputs to see different animation and color effects.

5. **Visual verification**: The text should be clearly readable with smooth animation. The background should show an animated XOR pattern.

### Expected Results:
- Stable VGA output at 640x480 resolution
- Clear, readable "ITI Luebeck" text
- Smooth animation without flicker
- Responsive control input changes (movement and color modes)

## External hardware

- **Tiny VGA PMOD**: Required for converting the 6-bit RGB output signals to analog VGA signals
- **VGA Monitor**: Any standard VGA monitor supporting 640x480 @ 60Hz resolution
- **VGA Cable**: Standard 15-pin VGA cable to connect the PMOD to the monitor
