

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

