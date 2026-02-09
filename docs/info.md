<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements a VGA text display that shows the animated text "ITI Luebeck" on a standard VGA monitor at 640×480 resolution @ 60Hz.

### VGA Signal Generation

### Hardware Setup

1. **Connect VGA PMOD**: Attach a Tiny VGA PMOD (or compatible VGA output board) to the output pins
   - The pinout follows the standard Tiny VGA PMOD configuration with RGB222 color depth
   - Outputs uo[7:0] map to: HSync, B0, G0, R0, VSync, B1, G1, R1

2. **Connect VGA Monitor**: Use a standard VGA cable to connect the PMOD to any VGA-compatible monitor or display

3. **Power On**: Enable the design with the clock running at 25.175 MHz (or 25 MHz as approximation)

### Testing Procedure

1. **Basic Display Test**:
   - After power-on, you should see "ITI Luebeck" text appear on the screen
   - With no inputs (ui_in = 0), the text will scroll horizontally in white color
   - An animated XOR pattern background should be visible

2. **Test Color Mode** (ui_in[0]):
   - Set ui_in[0] = 0: Text appears in white
   - Set ui_in[0] = 1: Text displays in rainbow colors that cycle continuously

3. **Test Movement Mode** (ui_in[1]):
   - Set ui_in[1] = 0: Text scrolls horizontally from right to left
   - Set ui_in[1] = 1: Text bounces vertically up and down

4. **Combination Test**:
   - Try different combinations of the two control inputs:
     - ui_in[1:0] = 00: White horizontal scroll
     - ui_in[1:0] = 01: Rainbow horizontal scroll
     - ui_in[1:0] = 10: White vertical bounce
     - ui_in[1:0] = 11: Rainbow vertical bounce

### Expected Results

- The text "ITI Luebeck" should be clearly readable
- Animations should run smoothly at 60 frames per second
- The background pattern should animate continuously
- Mode changes via input pins should take effect immediately
- No inputs ui_in[7:2] are used and can be left unconnectedsync generator module that produces the required horizontal and vertical sync signals (HSYNC and VSYNC) along with position counters. The VGA timing follows the standard 640×480 @ 60Hz specification:
- 25.175 MHz pixel clock
- Horizontal: 640 display + 16 front porch + 96 sync + 48 back porch = 800 total
- Vertical: 480 display + 10 front porch + 2 sync + 33 back porch = 525 total
- **Tiny VGA PMOD** (or compatible VGA output board): Required for converting the digital RGB signals to analog VGA output
  - Provides RGB222 color depth (6-bit total: 2 bits each for R, G, B)
  - Includes resistor DACs for analog conversion
  - Has a VGA connector for standard VGA cables

- **VGA Monitor or Display**: Any VGA-compatible monitor that supports 640×480 @ 60Hz resolution
  - Most modern monitors with VGA input will work
  - Older CRT monitors are also compatible
  - Some modern displays may require a VGA-to-HDMI adapter
### Text Display System

The text rendering system divides the screen into a character grid, where each character occupies a 16×16 pixel cell (using an 8×12 font within each cell):

1. **Character Grid**: The screen is divided into 40 columns × 30 rows of character cells
2. **Font ROM**: Character bitmaps for each letter (I, T, L, u, e, b, c, k) are stored in hardcoded lookup tables
3. **Text String**: The message "ITI Luebeck" (11 characters) is displayed

### Animation Modes

The design supports two animation modes controlled by input pins:

**Mode Selection (ui_in[1])**:
- Mode 0 (Horizontal Scroll): Text scrolls continuously from right to left across the screen
- Mode 1 (Vertical Bounce): Text moves up and down vertically while remaining horizontally centered

**Color Modes (ui_in[0])**:
- Mode 0 (White): Text displayed in white color
- Mode 1 (Rainbow): Text color cycles through the spectrum based on position and frame counter

### Background Animation

The background features an animated XOR pattern that creates a dynamic visual effect. The pattern is calculated using `(hpos ^ vpos) ^ frame_offset`, creating diagonal stripes that shift over time.

### Frame Counter

A 10-bit frame counter increments once per frame (every time the beam returns to position 0,0) to drive all animations. Different bits of this counter control animation speeds:
- Horizontal scroll uses bits [8:3] for slower movement
- Vertical bounce uses bits [6:4] for medium speed oscillation
- Rainbow colors use bits [7:0] for smooth color cycling

## How to test

Explain how to use your project

## External hardware

List external hardware used in your project (e.g. PMOD, LED display, etc), if any
