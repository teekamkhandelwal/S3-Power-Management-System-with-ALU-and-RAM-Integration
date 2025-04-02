

module power_management (
    input wire clk,                   // Clock signal
    input wire reset,                 // Reset signal
    input wire idle,                  // Idle signal from ALU
    input wire interrupt,             // Interrupt signal for long idle state
    output reg clk_gate,              // Clock gating signal
    output reg pg_down,               // Power down signal
    output reg reset_assert,          // Reset assertion signal
    output reg iso_clampn_deassert    // Isolation clamp deassertion signal
);

    reg [10:0] idle_time;             // Counter to track idle duration

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize all control signals on reset
            clk_gate <= 0;            // Disable clock gating
            pg_down <= 0;             // Power down off
            reset_assert <= 0;        // Reset deasserted
            iso_clampn_deassert <= 1; // Isolation deasserted (default active)
            idle_time <= 0;           // Reset idle time counter
        end else begin
            // Increment idle time if idle signal is high
            if (idle) 
                idle_time <= idle_time + 1;
            else 
                idle_time <= 0; // Reset idle counter if not idle

            // Clock gating: Enable after 10 time units of idle state
            if (idle_time == 10) 
                clk_gate <= 1;        // Enable clock gating
            else 
                clk_gate <= 0;        // Disable clock gating when active

            // Multi-level power-down entry flow
            if (interrupt) begin
                reset_assert <= 1;          // Assert reset
                iso_clampn_deassert <= 0;  // Assert isolation clamp (iso_clampn = 0)
                pg_down <= 1;              // Enable power down
            end

            // Power-down exit flow
            if (!idle) begin
                pg_down <= 0;              // Disable power down
                iso_clampn_deassert <= 1;  // Deassert isolation clamp (iso_clampn = 1)
                reset_assert <= 0;         // Deassert reset
            end
        end
    end

endmodule
