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
