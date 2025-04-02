// Code your testbench here
// or browse Examples
/*module tb_s3_system;

    // Testbench signals
    reg clk;                    // Clock signal
    reg reset;                  // Reset signal
    reg [3:0] a, b;             // ALU operands
    reg [1:0] opcode;           // ALU operation code
    reg s3_state;               // S3 power state signal
    wire [3:0] result;          // ALU result
    wire clk_gate;              // Clock gating signal
    wire pg_down;               // Power down signal
    wire reset_assert;          // Reset assertion signal
    wire iso_clampn_deassert;   // Isolation clamp signal
    wire [3:0] ram_data_out;    // Output data from RAM

    // Instantiate the system
    s3_system dut (
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .opcode(opcode),
        .s3_state(s3_state),
        .result(result),
        .clk_gate(clk_gate),
        .pg_down(pg_down),
        .reset_assert(reset_assert),
        .iso_clampn_deassert(iso_clampn_deassert),
        .ram_data_out(ram_data_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period: 10 time units
    end

    // Testbench scenarios
    initial begin
        $monitor("Time: %0d | Reset: %b | S3 State: %b | A: %b | B: %b | Opcode: %b | Result: %b | RAM Data Out: %b | Clk Gate: %b | PG Down: %b | Reset Assert: %b | Iso Clamp: %b",
                 $time, reset, s3_state, a, b, opcode, result, ram_data_out, clk_gate, pg_down, reset_assert, iso_clampn_deassert);

        // SCENARIO 1: System Initialization
        reset = 1; a = 0; b = 0; opcode = 2'b00; s3_state = 0; #10;
        reset = 0; #10; // Release reset

        // SCENARIO 2: ALU Operations
        a = 4; b = 5; opcode = 2'b00; #20; // ADD operation
        a = 8; b = 3; opcode = 2'b01; #20; // SUB operation
        a = 2; b = 6; opcode = 2'b10; #20; // AND operation
        a = 9; b = 4; opcode = 2'b11; #20; // OR operation

        // SCENARIO 3: Idle Detection
        a = 0; b = 0; opcode = 2'b00; #50; // Idle state triggers clock gating
        #50; // Idle persists, observe multi-level power-down

        // SCENARIO 4: Recovery from Idle
        a = 7; b = 2; opcode = 2'b00; #20; // Exit idle with ADD operation

        // SCENARIO 5: S3 Mode Entry
        s3_state = 1; #30; // Enter S3 mode, ALU operations saved to RAM

        // SCENARIO 6: S3 Mode Exit
        s3_state = 0; #20; // Exit S3 mode, operations restored from RAM

        // SCENARIO 7: Edge Cases
        // Test edge cases like max values for A, B
        a = 4'b1111; b = 4'b1111; opcode = 2'b00; #20; // ADD max values
        a = 4'b1111; b = 4'b0000; opcode = 2'b10; #20; // AND edge case

        // SCENARIO 8: Re-Enter Idle and Power Down
        a = 0; b = 0; opcode = 2'b00; #50; // Re-enter idle state
        #50; // Observe deep power-down state

        // SCENARIO 9: Exit Power Down and Continue Operations
        a = 6; b = 3; opcode = 2'b01; #20; // Perform SUB operation after power-up

        // End simulation
        $finish;
    end

    initial begin
    $dumpvars();
    $dumpfile("dump.vcd");
    #1000 $finish();
  end
endmodule*/


/*module tb_s3_power_management;

    // Testbench signals
    reg clk;                     // Clock signal
    reg reset;                   // Reset signal
    reg [3:0] a, b;              // ALU operands
    reg [1:0] opcode;            // ALU operation code
    reg s3_state;                // S3 power state signal
    wire [3:0] result;           // ALU operation result
    wire clk_gate;               // Clock gating signal
    wire pg_down;                // Power down signal
    wire reset_assert;           // Reset assertion signal
    wire iso_clampn_deassert;    // Isolation clamp deassertion signal
    wire [3:0] ram_data_out;     // Data retrieved from RAM after S3

    // Instantiate the system
    s3_system dut (
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .opcode(opcode),
        .s3_state(s3_state),
        .result(result),
        .ram_data_out(ram_data_out),
        .clk_gate(clk_gate),
        .pg_down(pg_down),
        .reset_assert(reset_assert),
        .iso_clampn_deassert(iso_clampn_deassert)
    );

    // Generate clock signal
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period: 10 time units
    end

    // Testbench scenarios
    initial begin
        $monitor("Time: %0d | Reset: %b | S3 State: %b | A: %b | B: %b | Opcode: %b | Result: %b | RAM Data Out: %b | Clk Gate: %b | PG Down: %b | Reset Assert: %b | Iso Clamp: %b",
                 $time, reset, s3_state, a, b, opcode, result, ram_data_out, clk_gate, pg_down, reset_assert, iso_clampn_deassert);

        // **Scenario 1: System Initialization**
        reset = 1; a = 0; b = 0; opcode = 2'b00; s3_state = 0; #10; // Reset the system
        reset = 0; #10;

        // **Scenario 2: Normal ALU Operations**
        a = 4; b = 5; opcode = 2'b00; #20; // ADD operation
        a = 8; b = 3; opcode = 2'b01; #20; // SUB operation
        a = 6; b = 2; opcode = 2'b10; #20; // AND operation

        // **Scenario 3: Idle State Detection**
        a = 0; b = 0; opcode = 2'b00; #50; // Idle triggers clock gating
        #50; // Idle persists, enter multi-level power-down flow

        // **Scenario 4: Recovery from Idle**
        a = 7; b = 3; opcode = 2'b00; #20; // Exit idle and perform ADD operation

        // **Scenario 5: Enter S3 Mode**
        s3_state = 1; #30; // Save ALU operations and results into RAM

        // **Scenario 6: Exit S3 Mode**
        s3_state = 0; #20; // Restore ALU operations and results from RAM

        // **Scenario 7: Power Down and Resume**
        a = 0; b = 0; opcode = 2'b00; #50; // Enter prolonged idle state
        #50; // Multi-level power-down flow
        a = 5; b = 2; opcode = 2'b00; #20; // Exit power-down and resume ADD operation
#100;
        // End simulation
        $finish;
      
    end
  
    initial begin
    $dumpvars();
    $dumpfile("dump.vcd");
    #1000 $finish();
  end

endmodule*/

/*module tb_power_down;

    // Testbench signals
    reg clk;                     // Clock signal
    reg reset;                   // Reset signal
    reg idle;                    // Idle signal
    reg interrupt;               // Interrupt signal for prolonged idle state
    wire clk_gate;               // Clock gating signal
    wire pg_down;                // Power down signal
    wire reset_assert;           // Reset assertion signal
    wire iso_clampn_deassert;    // Isolation clamp deassertion signal

    // Instantiate the power management module
    power_management dut (
        .clk(clk),
        .reset(reset),
        .idle(idle),
        .interrupt(interrupt),
        .clk_gate(clk_gate),
        .pg_down(pg_down),
        .reset_assert(reset_assert),
        .iso_clampn_deassert(iso_clampn_deassert)
    );

    // Generate clock signal
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period: 10 time units
    end

    // Test scenarios
    initial begin
        $monitor("Time: %0d | Reset: %b | Idle: %b | Interrupt: %b | Clk Gate: %b | PG Down: %b | Reset Assert: %b | Iso Clampn Deassert: %b",
                 $time, reset, idle, interrupt, clk_gate, pg_down, reset_assert, iso_clampn_deassert);

        // **Scenario 1: Reset System**
        reset = 1; idle = 0; interrupt = 0; #10; // Reset all signals
        reset = 0; #10;

        // **Scenario 2: Normal Operation**
        idle = 0; interrupt = 0; #50; // Active system, no power down
        $display("\n[Scenario 2] Normal operation: No power down\n");

        // **Scenario 3: Idle State Detected**
        idle = 1; interrupt = 0; #50; // System enters idle, check clock gating
        $display("\n[Scenario 3] Idle detected: Check clock gating\n");

        // **Scenario 4: Multi-Level Power Down**
        interrupt = 1; #20; // Prolonged idle triggers power down
        $display("\n[Scenario 4] Enter power down: Reset, clamp isolation, power down enabled\n");

        // **Scenario 5: Recovery from Power Down**
        idle = 0; interrupt = 0; #20; // System exits power down
        $display("\n[Scenario 5] Exit power down: Restore normal operation\n");

        // End simulation
 #120       $finish;
    end

    initial begin
    $dumpvars();
    $dumpfile("dump.vcd");
    #1500 $finish();
  end


endmodule*/

module tb_s3_power_management_with_alu;

    // Testbench signals
    reg clk;                     // Clock signal
    reg reset;                   // Reset signal
    reg [3:0] a, b;              // ALU operands
    reg [1:0] opcode;            // ALU operation code
    reg idle_tb;                 // Idle signal (local to testbench)
    reg interrupt_tb;            // Interrupt signal (local to testbench)
    wire idle;                   // Idle signal (connected to ALU)
    wire interrupt;              // Interrupt signal (connected to ALU)
    wire [3:0] result;           // ALU operation result
    wire clk_gate;               // Clock gating signal
    wire pg_down;                // Power down signal
    wire reset_assert;           // Reset assertion signal
    wire iso_clampn_deassert;    // Isolation clamp deassertion signal

    // Instantiate the ALU module
    alu alu_inst (
        .a(a),
        .b(b),
        .opcode(opcode),
        .clk(clk),
        .reset(reset),
        .s3_state(0),   // No S3 state here, focused on power management
        .result(result),
        .saved_a(),
        .saved_b(),
        .saved_opcode(),
        .idle(idle),                // Connect ALU idle signal
        .interrupt(interrupt)       // Connect ALU interrupt signal
    );

    // Instantiate the power management module
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

    // Generate clock signal
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period: 10 time units
    end

    // Testbench control for idle and interrupt signals
    assign idle = idle_tb;             // Drive idle signal
    assign interrupt = interrupt_tb;   // Drive interrupt signal

    // Test scenarios
    initial begin
        $monitor("Time: %0d | Reset: %b | A: %b | B: %b | Opcode: %b | Result: %b | Idle: %b | Interrupt: %b | Clk Gate: %b | PG Down: %b | Reset Assert: %b | Iso Clampn Deassert: %b",
                 $time, reset, a, b, opcode, result, idle, interrupt, clk_gate, pg_down, reset_assert, iso_clampn_deassert);

        // **Scenario 1: Reset System**
        reset = 1; a = 0; b = 0; opcode = 2'b00; idle_tb = 0; interrupt_tb = 0; #10;
        reset = 0; #10;

        // **Scenario 2: Perform ALU Operations**
        $display("\n[Scenario 2] ALU operations\n");
        a = 4; b = 5; opcode = 2'b00; #20; // ADD operation
        a = 8; b = 3; opcode = 2'b01; #20; // SUB operation
        a = 2; b = 6; opcode = 2'b10; #20; // AND operation
        a = 9; b = 4; opcode = 2'b11; #20; // OR operation

        // **Scenario 3: Transition to Idle State**
        $display("\n[Scenario 3] Transition to idle state\n");
        idle_tb = 1; #50; // System enters idle state
        #50; // Idle persists, clock gating expected

        // **Scenario 4: Multi-Level Power Down**
        $display("\n[Scenario 4] Multi-level power down\n");
        interrupt_tb = 1; #20; // Prolonged idle triggers power down

        // **Scenario 5: Exit Idle State**
        $display("\n[Scenario 5] Exit idle state and recover\n");
        interrupt_tb = 0; idle_tb = 0; #20; // System exits power down and resumes operations

        // End simulation
    #20    $finish;
    end
 initial begin
    $dumpvars();
    $dumpfile("dump.vcd");
    #500 $finish();
  end

endmodule
   
