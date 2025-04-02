// Code your design here
module alu (
    input wire [3:0] a,        // Operand 1
    input wire [3:0] b,        // Operand 2
    input wire [1:0] opcode,   // Operation code (00: ADD, 01: SUB, 10: AND, 11: OR)
    input wire clk,            // Clock signal
    input wire reset,          // Reset signal
    input wire s3_state,       // S3 mode signal
    output reg [3:0] result,   // Result of operation
    output reg [3:0] saved_a,  // Saved Operand 1
    output reg [3:0] saved_b,  // Saved Operand 2
    output reg [1:0] saved_opcode, // Saved Opcode
    output reg idle,           // Idle signal
    output reg interrupt       // Interrupt signal for idleness
);

    reg [10:0] idle_counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            result <= 4'b0000;
            saved_a <= 4'b0000;
            saved_b <= 4'b0000;
            saved_opcode <= 2'b00;
            idle <= 1;
            interrupt <= 0;
            idle_counter <= 0;
        end else begin
            if (s3_state) begin
                // Save operation details into saved variables during S3
                saved_a <= a;
                saved_b <= b;
                saved_opcode <= opcode;
            end else begin
                // Perform the operation
                case (opcode)
                    2'b00: result <= a + b;  // ADD
                    2'b01: result <= a - b;  // SUB
                    2'b10: result <= a & b;  // AND
                    2'b11: result <= a | b;  // OR
                    default: result <= 4'b0000;
                endcase

                // Idle detection
                if (a == 0 && b == 0 && opcode == 2'b00) begin
                    idle <= 1;
                    idle_counter <= idle_counter + 1;
                end else begin
                    idle <= 0;
                    idle_counter <= 0;
                end

                // Set interrupt if idle for more than 10 ns
                if (idle_counter > 10) interrupt <= 1;
                else interrupt <= 0;
            end
        end
    end

endmodule

module ram (
    input wire [3:0] alu_result,   // ALU result
    input wire [3:0] operand_a,    // ALU Operand A
    input wire [3:0] operand_b,    // ALU Operand B
    input wire [1:0] operation,    // ALU Opcode
    input wire write_enable,       // Write enable signal
    input wire clk,                // Clock signal
    input wire reset,              // Reset signal
    input wire s3_state,           // S3 power state signal
    output reg [3:0] result_out,   // Retrieved ALU result
    output reg [3:0] operand_a_out, // Retrieved Operand A
    output reg [3:0] operand_b_out, // Retrieved Operand B
    output reg [1:0] operation_out // Retrieved Opcode
);

    reg [3:0] memory_result;       // Stores ALU result
    reg [3:0] memory_a;            // Stores Operand A
    reg [3:0] memory_b;            // Stores Operand B
    reg [1:0] memory_opcode;       // Stores Opcode

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            memory_result <= 4'b0000;
            memory_a <= 4'b0000;
            memory_b <= 4'b0000;
            memory_opcode <= 2'b00;
            result_out <= 4'b0000;
            operand_a_out <= 4'b0000;
            operand_b_out <= 4'b0000;
            operation_out <= 2'b00;
        end else if (write_enable) begin
            if (s3_state) begin
                // Store ALU operation and result details
                memory_result <= alu_result;
                memory_a <= operand_a;
                memory_b <= operand_b;
                memory_opcode <= operation;
            end else begin
                // Retrieve stored data from memory
                result_out <= memory_result;
                operand_a_out <= memory_a;
                operand_b_out <= memory_b;
                operation_out <= memory_opcode;
            end
        end
    end

endmodule

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
module s3_system (
    input wire clk,                   // Clock signal
    input wire reset,                 // Reset signal
    input wire [3:0] a,               // Operand A for ALU
    input wire [3:0] b,               // Operand B for ALU
    input wire [1:0] opcode,          // ALU operation code
    input wire s3_state,              // S3 power state signal
    output wire [3:0] result,         // Output result from ALU
    output wire [3:0] ram_data_out,   // Output data retrieved from RAM
    output wire clk_gate,             // Clock gating signal
    output wire pg_down,              // Power down signal
    output wire reset_assert,         // Reset assertion signal
    output wire iso_clampn_deassert   // Isolation clamp deassertion signal
);

    // Internal wires for communication between modules
    wire idle;                        // ALU idle signal
    wire interrupt;                   // Interrupt signal for power management

    // Instantiate ALU Module
    alu alu_inst (
        .a(a), 
        .b(b), 
        .opcode(opcode), 
        .clk(clk), 
        .reset(reset), 
        .s3_state(s3_state), 
        .result(result), 
        .saved_a(), 
        .saved_b(), 
        .saved_opcode(), 
        .idle(idle), 
        .interrupt(interrupt)
    );

    // Instantiate RAM Module
    ram ram_inst (
        .alu_result(result), 
        .operand_a(a), 
        .operand_b(b), 
        .operation(opcode), 
        .write_enable(!idle), 
        .clk(clk), 
        .reset(reset), 
        .s3_state(s3_state), 
        .result_out(ram_data_out), 
        .operand_a_out(), 
        .operand_b_out(), 
        .operation_out()
    );

    // Instantiate Power Management Module
    power_management pm_inst (
        .clk(clk), 
        .reset(reset), 
        .idle(idle), 
        .interrupt(interrupt), 
        .clk_gate(clk_gate), 
        .pg_down(pg_down), 
        .reset_assert(reset_assert), 
        .iso_clampn_deassert(iso_clampn_deassert)
    );

endmodule
