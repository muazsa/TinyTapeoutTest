/*
 * VGA text display: "ITI Luebeck" with animation
 * ui_in[0] = color mode (0=white, 1=rainbow)
 * ui_in[1] = movement mode (0=scroll horizontal, 1=bounce vertical)
 *
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_vga_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // VGA signals from sync generator
    wire hsync, vsync, display_on;
    wire [9:0] hpos, vpos;

    // Instantiate the sync generator
    hvsync_generator hvsync_gen (
        .clk(clk),
        .reset(~rst_n),
        .hsync(hsync),
        .vsync(vsync),
        .display_on(display_on),
        .hpos(hpos),
        .vpos(vpos)
    );

    // Frame counter for animation
    reg [9:0] frame;

    // Control inputs
    wire color_mode = ui_in[0];     // 0=white, 1=rainbow
    wire move_mode = ui_in[1];      // 0=scroll horizontal, 1=bounce

    // Character size: 16x24 pixels per character
    wire [5:0] char_col = hpos[9:4]; // Which character column (0-39)
    wire [4:0] char_row = vpos[9:4]; // Which character row (0-29)
    wire [3:0] pixel_x = hpos[3:0];  // Pixel within character (0-15)
    wire [3:0] pixel_y = vpos[3:0];  // Pixel within character (0-15)

    // Text animation: horizontal scrolling or vertical bounce
    wire [5:0] text_x_pos = move_mode ? 
                            (6'd14) : // bounce mode: fixed horizontal
                            (6'd39 - frame[8:3]); // scroll mode: right to left
    
    wire [4:0] text_y_pos = move_mode ?
                            (5'd10 + {1'b0, frame[6:4]}) : // bounce mode: moves vertically
                            (5'd14); // scroll mode: fixed vertical
    
    // Text position: "ITI Luebeck" 
    wire in_text_row = (char_row == text_y_pos);
    wire [5:0] adjusted_col = char_col + 6'd40 - text_x_pos; // Handle wrapping
    wire [3:0] text_pos = adjusted_col[3:0]; // Position in text string (0-10)
    wire in_text_col = (adjusted_col >= 6'd0) && (adjusted_col <= 6'd10);
    
    // Character to display (ASCII-like encoding)
    reg [7:0] char_code;
    always @(*) begin
        case (text_pos)
            4'd0:  char_code = 8'd73;  // I
            4'd1:  char_code = 8'd84;  // T
            4'd2:  char_code = 8'd73;  // I
            4'd3:  char_code = 8'd32;  // space
            4'd4:  char_code = 8'd76;  // L
            4'd5:  char_code = 8'd117; // u
            4'd6:  char_code = 8'd101; // e
            4'd7:  char_code = 8'd98;  // b
            4'd8:  char_code = 8'd101; // e
            4'd9:  char_code = 8'd99;  // c
            4'd10: char_code = 8'd107; // k
            default: char_code = 8'd32; // space
        endcase
    end

    // Character ROM lookup (8x16 font, using upper 8x12 portion)
    reg char_pixel;
    always @(*) begin
        char_pixel = 1'b0;
        if (pixel_y < 4'd12 && pixel_x < 4'd8) begin
            case (char_code)
                8'd73: begin // 'I'
                    case (pixel_y)
                        4'd0:  char_pixel = (pixel_x >= 4'd2 && pixel_x <= 4'd5);
                        4'd1:  char_pixel = (pixel_x >= 4'd2 && pixel_x <= 4'd5);
                        4'd2:  char_pixel = (pixel_x == 4'd3 || pixel_x == 4'd4);
                        4'd3:  char_pixel = (pixel_x == 4'd3 || pixel_x == 4'd4);
                        4'd4:  char_pixel = (pixel_x == 4'd3 || pixel_x == 4'd4);
                        4'd5:  char_pixel = (pixel_x == 4'd3 || pixel_x == 4'd4);
                        4'd6:  char_pixel = (pixel_x == 4'd3 || pixel_x == 4'd4);
                        4'd7:  char_pixel = (pixel_x == 4'd3 || pixel_x == 4'd4);
                        4'd8:  char_pixel = (pixel_x == 4'd3 || pixel_x == 4'd4);
                        4'd9:  char_pixel = (pixel_x == 4'd3 || pixel_x == 4'd4);
                        4'd10: char_pixel = (pixel_x >= 4'd2 && pixel_x <= 4'd5);
                        4'd11: char_pixel = (pixel_x >= 4'd2 && pixel_x <= 4'd5);
                    endcase
                end
                8'd84: begin // 'T'
                    case (pixel_y)
                        4'd0:  char_pixel = (pixel_x >= 4'd1 && pixel_x <= 4'd6);
                        4'd1:  char_pixel = (pixel_x >= 4'd1 && pixel_x <= 4'd6);
                        4'd2:  char_pixel = (pixel_x == 4'd3 || pixel_x == 4'd4);
                        4'd3:  char_pixel = (pixel_x == 4'd3 || pixel_x == 4'd4);
                        4'd4:  char_pixel = (pixel_x == 4'd3 || pixel_x == 4'd4);
                        4'd5:  char_pixel = (pixel_x == 4'd3 || pixel_x == 4'd4);
                        4'd6:  char_pixel = (pixel_x == 4'd3 || pixel_x == 4'd4);
                        4'd7:  char_pixel = (pixel_x == 4'd3 || pixel_x == 4'd4);
                        4'd8:  char_pixel = (pixel_x == 4'd3 || pixel_x == 4'd4);
                        4'd9:  char_pixel = (pixel_x == 4'd3 || pixel_x == 4'd4);
                        4'd10: char_pixel = (pixel_x == 4'd3 || pixel_x == 4'd4);
                        4'd11: char_pixel = (pixel_x == 4'd3 || pixel_x == 4'd4);
                    endcase
                end
                8'd76: begin // 'L'
                    case (pixel_y)
                        4'd0:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3);
                        4'd1:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3);
                        4'd2:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3);
                        4'd3:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3);
                        4'd4:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3);
                        4'd5:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3);
                        4'd6:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3);
                        4'd7:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3);
                        4'd8:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3);
                        4'd9:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3);
                        4'd10: char_pixel = (pixel_x >= 4'd2 && pixel_x <= 4'd6);
                        4'd11: char_pixel = (pixel_x >= 4'd2 && pixel_x <= 4'd6);
                    endcase
                end
                8'd117: begin // 'u'
                    case (pixel_y)
                        4'd3:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3 || pixel_x == 4'd5 || pixel_x == 4'd6);
                        4'd4:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3 || pixel_x == 4'd5 || pixel_x == 4'd6);
                        4'd5:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3 || pixel_x == 4'd5 || pixel_x == 4'd6);
                        4'd6:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3 || pixel_x == 4'd5 || pixel_x == 4'd6);
                        4'd7:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3 || pixel_x == 4'd5 || pixel_x == 4'd6);
                        4'd8:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3 || pixel_x == 4'd5 || pixel_x == 4'd6);
                        4'd9:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3 || pixel_x == 4'd5 || pixel_x == 4'd6);
                        4'd10: char_pixel = (pixel_x >= 4'd2 && pixel_x <= 4'd6);
                        4'd11: char_pixel = (pixel_x >= 4'd3 && pixel_x <= 4'd6);
                    endcase
                end
                8'd101: begin // 'e'
                    case (pixel_y)
                        4'd3:  char_pixel = (pixel_x >= 4'd2 && pixel_x <= 4'd5);
                        4'd4:  char_pixel = (pixel_x >= 4'd2 && pixel_x <= 4'd6);
                        4'd5:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3 || pixel_x == 4'd6);
                        4'd6:  char_pixel = (pixel_x >= 4'd2 && pixel_x <= 4'd6);
                        4'd7:  char_pixel = (pixel_x >= 4'd2 && pixel_x <= 4'd5);
                        4'd8:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3);
                        4'd9:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3 || pixel_x == 4'd6);
                        4'd10: char_pixel = (pixel_x >= 4'd2 && pixel_x <= 4'd6);
                        4'd11: char_pixel = (pixel_x >= 4'd3 && pixel_x <= 4'd5);
                    endcase
                end
                8'd98: begin // 'b'
                    case (pixel_y)
                        4'd0:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3);
                        4'd1:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3);
                        4'd2:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3);
                        4'd3:  char_pixel = (pixel_x >= 4'd2 && pixel_x <= 4'd5);
                        4'd4:  char_pixel = (pixel_x >= 4'd2 && pixel_x <= 4'd6);
                        4'd5:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3 || pixel_x == 4'd6);
                        4'd6:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3 || pixel_x == 4'd6);
                        4'd7:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3 || pixel_x == 4'd6);
                        4'd8:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3 || pixel_x == 4'd6);
                        4'd9:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3 || pixel_x == 4'd6);
                        4'd10: char_pixel = (pixel_x >= 4'd2 && pixel_x <= 4'd6);
                        4'd11: char_pixel = (pixel_x >= 4'd3 && pixel_x <= 4'd5);
                    endcase
                end
                8'd99: begin // 'c'
                    case (pixel_y)
                        4'd3:  char_pixel = (pixel_x >= 4'd3 && pixel_x <= 4'd5);
                        4'd4:  char_pixel = (pixel_x >= 4'd2 && pixel_x <= 4'd6);
                        4'd5:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3);
                        4'd6:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3);
                        4'd7:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3);
                        4'd8:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3);
                        4'd9:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3 || pixel_x == 4'd6);
                        4'd10: char_pixel = (pixel_x >= 4'd2 && pixel_x <= 4'd6);
                        4'd11: char_pixel = (pixel_x >= 4'd3 && pixel_x <= 4'd5);
                    endcase
                end
                8'd107: begin // 'k'
                    case (pixel_y)
                        4'd0:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3);
                        4'd1:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3);
                        4'd2:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3);
                        4'd3:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3 || pixel_x == 4'd5 || pixel_x == 4'd6);
                        4'd4:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3 || pixel_x == 4'd5);
                        4'd5:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3 || pixel_x == 4'd4);
                        4'd6:  char_pixel = (pixel_x >= 4'd2 && pixel_x <= 4'd4);
                        4'd7:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3 || pixel_x == 4'd4);
                        4'd8:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3 || pixel_x == 4'd5);
                        4'd9:  char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3 || pixel_x == 4'd5);
                        4'd10: char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3 || pixel_x == 4'd6);
                        4'd11: char_pixel = (pixel_x == 4'd2 || pixel_x == 4'd3 || pixel_x == 4'd6);
                    endcase
                end
                default: char_pixel = 1'b0; // space or unknown
            endcase
        end
    end

    // Text display logic
    wire show_text = in_text_row && in_text_col && char_pixel;
    
    // Background animation (always animated for visual effect)
    wire [7:0] bg_offset = frame[7:0];
    wire [7:0] bg_pattern = (hpos[7:0] ^ vpos[7:0]) ^ bg_offset;
    
    // Color selection
    wire [7:0] color_val = color_mode ? (hpos[7:0] + vpos[7:0] + frame[7:0]) : 8'hFF;
    
    // Final color outputs
    wire [1:0] r_out = (show_text ? color_val[7:6] : bg_pattern[7:6]) & {2{display_on}};
    wire [1:0] g_out = (show_text ? color_val[5:4] : bg_pattern[5:4]) & {2{display_on}};
    wire [1:0] b_out = (show_text ? color_val[3:2] : bg_pattern[3:2]) & {2{display_on}};

    // VGA output mapping (RGB222 on Tiny VGA PMOD)
    assign uo_out[0] = r_out[1];  // R1
    assign uo_out[4] = r_out[0];  // R0
    assign uo_out[1] = g_out[1];  // G1
    assign uo_out[5] = g_out[0];  // G0
    assign uo_out[2] = b_out[1];  // B1
    assign uo_out[6] = b_out[0];  // B0
    assign uo_out[3] = vsync;    // VSYNC
    assign uo_out[7] = hsync;    // HSYNC

    // Bidirectional pins unused
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // Frame counter for animation with variable speed
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            frame <= 0;
        end else begin
            if (hpos == 0 && vpos == 0)
                frame <= frame + 10'd1;
        end
    end

    // Unused inputs
    wire _unused = &{ena, uio_in, ui_in[7:2], frame[9:8], char_row[4:0], pixel_x[3], pixel_y[3], 
                     text_pos[3], char_code[7:0], color_val[1:0], bg_pattern[1:0], adjusted_col[5:4], 1'b0};

endmodule
