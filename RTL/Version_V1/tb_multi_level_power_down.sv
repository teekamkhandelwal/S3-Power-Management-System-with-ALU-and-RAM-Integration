
module tb_multi_level_power_down;

    // Testbench signals
    reg clk;                     // Clock signal
    reg reset;                   // Reset signal
    reg idle;                    // Idle signal
    reg interrupt;               // Interrupt signal for prolonged idle
    wire clk_gate;               // Clock gating signal
    wire pg_down;                // Power down signal
    wire reset_assert;           // Reset assertion signal
    wire isolation;              // Isolation signal (1 = asserted, 0 = deasserted)

    // Instantiate the power management module
    power_management dut (
        .clk(clk),
        .reset(reset),
        .idle(idle),
        .interrupt(interrupt),
        .clk_gate(clk_gate),
        .pg_down(pg_down),
        .reset_assert(reset_assert),
        .isolation(isolation)
    );

    // Generate clock signal
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period: 10 time units
    end

    // Test scenarios
    initial begin
        $monitor("Time: %0d | Reset: %b | Idle: %b | Interrupt: %b | Clk Gate: %b | PG Down: %b | Reset Assert: %b | Isolation: %b",
                 $time, reset, idle, interrupt, clk_gate, pg_down, reset_assert, isolation);

        // **Scenario 1: Reset System**
        reset = 1; idle = 0; interrupt = 0; #10; // Reset all signals
        reset = 0; #10;

        // **Scenario 2: Active State**
        idle = 0; interrupt = 0; #50; // Normal operation, no power down

        // **Scenario 3: Idle State Detected**
        idle = 1; interrupt = 0; #50; // Idle triggers clock gating

        // **Scenario 4: Multi-Level Power Down**
        interrupt = 1; #20; // Prolonged idle triggers power down

        // **Scenario 5: Wait for 20 ns and Print Final Values**
        #20;
        $display("\nFinal Signal Values:");
        $display("Time: %0d | Reset: %b | Idle: %b | Interrupt: %b | Clk Gate: %b | PG Down: %b | Reset Assert: %b | Isolation: %b",
                 $time, reset, idle, interrupt, clk_gate, pg_down, reset_assert, isolation);

        // End simulation
        $finish;
    end
initial begin
    $dumpvars();
    $dumpfile("dump.vcd");
    #500 $finish();
  end


endmodule
   
