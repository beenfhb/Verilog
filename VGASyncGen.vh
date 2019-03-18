//////////////////////////////////////////////////////////////////////////////////
// Company: Ridotech
// Engineer: Juan Manuel Rico
// 
// Create Date:    25/03/2018
// Module Name:    VGASyncGen
// Description:    Basic control for 640x480@72Hz VGA signal.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created for Roland Coeurjoly (RCoeurjoly) in 640x480@85Hz.
// Revision 0.02 - Change for 640x480@60Hz.
// Revision 0.03 - Solved some mistakes.
// Revision 0.04 - Change for 640x480@72Hz and output signals 'activevideo' and 'px_clk'.
// Revision 0.05 - Eliminate 'color_px' and 'red_monitor', green_monitor', 'blue_monitor' (Sergio Cuenca).
// Revision 0.06 - Create 'FDivider' parameter for PLL.
//
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`ifndef VGASYNCGEN_VH
`define VGASYNCGEN_VH

module VGASyncGen
  #(
    // 640x480@60Hz (pixel clock 25.175MHz) - OK
    // parameter FDivider = 66, // 62         // Feedback divider 62 for 16Mhz (default) 83 for 12Mhz.
    // parameter QDivider = 5,  // 5 for 640x480
    // parameter activeHvideo = 640,               // Width of visible pixels.
    // parameter activeVvideo =  480,              // Height of visible lines.
    // parameter hfp = 16,                         // Horizontal front porch length.
    // parameter hpulse = 96,                      // Hsync pulse length.
    // parameter hbp = 48,                        // Horizontal back porch length.
    // parameter vfp = 10,                          // Vertical front porch length.
    // parameter vpulse = 2,                       // Vsync pulse length.n
    // parameter vbp = 33                         // Vertical back porch length.
    //
    // 640x480@73Hz (pixel clock 31.5MHz) - OK
    // parameter FDivider = 83, // 62         // Feedback divider 62 for 16Mhz (default) 83 for 12Mhz.
    // parameter QDivider = 5,  // 5 for 640x480
    // parameter activeHvideo = 640,               // Width of visible pixels.
    // parameter activeVvideo =  480,              // Height of visible lines.
    // parameter hfp = 24,                         // Horizontal front porch length.
    // parameter hpulse = 40,                      // Hsync pulse length.
    // parameter hbp = 128,                        // Horizontal back porch length.
    // parameter vfp = 9,                          // Vertical front porch length.
    // parameter vpulse = 3,                       // Vsync pulse length.n
    // parameter vbp = 28                         // Vertical back porch length.
    //
    // 800x600@56Hz (pixel clock 36MHz) - OK
    // parameter FDivider = 47, // 
    // parameter QDivider = 4,  //
    // parameter activeHvideo = 800,               // Width of visible pixels.
    // parameter activeVvideo =  600,              // Height of visible lines.
    // parameter hfp = 24,                         // Horizontal front porch length.
    // parameter hpulse = 72,                      // Hsync pulse length.
    // parameter hbp = 128,                        // Horizontal back porch length.
    // parameter vfp = 1,                          // Vertical front porch length.
    // parameter vpulse = 2,                       // Vsync pulse length.n
    // parameter vbp = 22                         // Vertical back porch length.
    //
    // // 800x600@60Hz (40MHz pixel clock) - NG
    // parameter FDivider = 50, // 
    // parameter QDivider = 4,  //
    // parameter activeHvideo = 800,               // Width of visible pixels.
    // parameter activeVvideo =  600,              // Height of visible lines.
    // parameter hfp = 40,                         // Horizontal front porch length.
    // parameter hpulse = 128,                      // Hsync pulse length.
    // parameter hbp = 88,                        // Horizontal back porch length.
    // parameter vfp = 1,                          // Vertical front porch length.
    // parameter vpulse = 4,                       // Vsync pulse length.n
    // parameter vbp = 23                         // Vertical back porch length.
    //
    // // 1024x600@63.59Hz (50MHz pixel clock)
    // parameter FDivider = 66, // 62         // Feedback divider 62 for 16Mhz (default) 83 for 12Mhz.
    // parameter QDivider = 4,  // 5 for 640x480
    // parameter activeHvideo = 1024,               // Width of visible pixels.
    // parameter activeVvideo =  600,              // Height of visible lines.
    // parameter hfp = 48,                         // Horizontal front porch length.
    // parameter hpulse = 32,                      // Hsync pulse length.
    // parameter hbp = 240,                        // Horizontal back porch length.
    // parameter vfp = 3,                          // Vertical front porch length.
    // parameter vpulse = 10,                       // Vsync pulse length.n
    // parameter vbp = 12                         // Vertical back porch length.
    // 1024x768@60Hz (65MHz pixel clock)
    parameter FDivider = 49, // 62         // Feedback divider 62 for 16Mhz (default) 83 for 12Mhz.
    parameter QDivider = 3,  // 5 for 640x480
    parameter activeHvideo = 1024,               // Width of visible pixels.
    parameter activeVvideo =  768,              // Height of visible lines.
    parameter hfp = 24,                         // Horizontal front porch length.
    parameter hpulse = 136,                      // Hsync pulse length.
    parameter hbp = 144,                        // Horizontal back porch length.
    parameter vfp = 3,                          // Vertical front porch length.
    parameter vpulse = 6,                       // Vsync pulse length.n
    parameter vbp = 29                         // Vertical back porch length.
    )
   (
    input wire 	      clk, // Input clock (12Mhz or 16Mhz)
    output wire       hsync, // Horizontal sync out
    output wire       vsync, // Vertical sync out
    output reg [10:0] x_px, // X position for actual pixel.
    output reg [10:0] y_px, // Y position for actual pixel.
    output wire       activevideo, // Video is actived.
    //            output wire      endframe,      // End for actual frame.
    output wire       px_clk         // Pixel clock.
    );

   // Generated values for pixel clock of 31.5Mhz and 72Hz frame frecuency (12Mhz - iceZum Alhambra).
   // # icepll -i12 -o31.5
   //
   // F_PLLIN:    12.000 MHz (given)
   // F_PLLOUT:   31.500 MHz (requested)
   // F_PLLOUT:   31.500 MHz (achieved)
   //
   // FEEDBACK: SIMPLE
   // F_PFD:   12.000 MHz
   // F_VCO: 1008.000 MHz
   //
   // DIVR:  0 (4'b0000)
   // DIVF: 83 (7'b1010011)
   // DIVQ:  5 (3'b101)
   //
   // FILTER_RANGE: 1 (3'b001)
   //

   // Generated values for pixel clock of 31.5Mhz and 72Hz frame frecuency (16Mhz - TinyFPGA-B2).
   // # icepll -i16 -o31.5
   //
   // F_PLLIN:    16.000 MHz (given)
   // F_PLLOUT:   31.500 MHz (requested)
   // F_PLLOUT:   31.500 MHz (achieved)
   //
   // FEEDBACK: SIMPLE
   // F_PFD:   16.000 MHz
   // F_VCO: 1008.000 MHz
   //
   // DIVR:  0 (4'b0000)
   // DIVF: 62 (7'b0111110)
   // DIVQ:  5 (3'b101)
   //
   // FILTER_RANGE: 1 (3'b001)
   //

   parameter blackH = hfp + hpulse + hbp;      // Hide pixels in one line.
   parameter blackV = vfp + vpulse + vbp;      // Hide lines in one frame.
   parameter hpixels = blackH + activeHvideo;  // Total horizontal pixels.
   parameter vlines = blackV + activeVvideo;   // Total lines.

   SB_PLL40_CORE #(.FEEDBACK_PATH("SIMPLE"),
                   .PLLOUT_SELECT("GENCLK"),
                   .DIVR(4'b0000),
                   .DIVF(FDivider),
                   .DIVQ(QDivider), // 3'b101),
                   .FILTER_RANGE(3'b001)
		   )
   uut
     (
      .REFERENCECLK(clk),
      .PLLOUTCORE(px_clk),
      .RESETB(1'b1),
      .BYPASS(1'b0)
      );

   /*
    http://www.epanorama.net/faq/vga2rgb/calc.html
    [*User-Defined_mode,(640X480)]
    PIXEL_CLK   =   31500
    H_DISP      =   640
    V_DISP      =   480
    H_FPORCH    =   24
    H_SYNC      =   40
    H_BPORCH    =   128
    V_FPORCH    =   9
    V_SYNC      =   3
    V_BPORCH    =   28
    */

   // Video structure constants.
   //
   //   Horizontal Dots          640 (activeHvideo)
   //   Horiz. Sync Polarity     NEG
   //   A (hpixels)              Scanline time
   //   B (hpulse)               Sync pulse lenght
   //   C (hbp)                  Back porch
   //   D (activeHvideo)         Active video time
   //   E (hfp)                  Front porch
   //              ______________________            ______________
   //   __________|        VIDEO         |__________| VIDEO (next line)
   //   |-E-| |-C-|----------D-----------|-E-|
   //   ____   ______________________________   ___________________
   //       |_|                              |_|
   //       |B|
   //       |---------------A----------------|
   //   
   // (Same structure for vertical signals).
   //

   // Registers for storing the horizontal & vertical counters.
   reg [10:0] 			    hc;
   reg [10:0] 			    vc;

   // Initial values.
   initial
     begin
	x_px <= 0;
	y_px <= 0;
	hc <= 0;
	vc <= 0;
     end

   // Counting pixels.
   always @(posedge px_clk)
     begin
        // Keep counting until the end of the line.
        if (hc < hpixels - 1)
          hc <= hc + 1;
        else
          // When we hit the end of the line, reset the horizontal
          // counter and increment the vertical counter.
          // If vertical counter is at the end of the frame, then
          // reset that one too.
          begin
             hc <= 0;
             if (vc < vlines - 1)
               vc <= vc + 1;
             else
               vc <= 0;
          end
     end

   // Generate horizontal and vertical sync pulses (active low) and active video.
   assign hsync = (hc >= hfp && hc < hfp + hpulse) ? 1'b0 : 1'b1;
   assign vsync = (vc >= vfp && vc < vfp + vpulse) ? 1'b0 : 1'b1;
   assign activevideo = (hc >= blackH) && (vc >= blackV) ? 1'b1 : 1'b0; //&& (hc < blackH + activeHvideo) && (vc < blackV + activeVvideo) ? 1'b1 : 1'b0;
   //    assign endframe = (hc == hpixels-1 && vc == vlines-1) ? 1'b1 : 1'b0 ;

   // Generate new pixel position.
   always @(*)
     begin
        // First check if we are within vertical active video range.
        if (activevideo)
          begin
             x_px <= hc - blackH;
             y_px <= vc - blackV;
          end
        // else
        //   // We are outside active video range so initial position it's ok.
        //   begin
        //     x_px <= 0;
        //     y_px <= 0;
        //   end
     end

endmodule

`endif
