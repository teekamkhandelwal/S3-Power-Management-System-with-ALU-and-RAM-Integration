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

