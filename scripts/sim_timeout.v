`timescale 1ns / 1ps

// Simulation-only helper. Some lab testbenches are written for interactive
// Vivado sessions and never call $finish; this second root module ends the
// run after LIMIT_NS so command-line simulation terminates. The Makefile sets
// LIMIT_NS from SIM_TIME_NS.
module sim_timeout;
    parameter integer LIMIT_NS = 50000;

    initial begin
        #(LIMIT_NS);
        $display("sim_timeout: stopping at %0d ns", $time);
        $finish;
    end
endmodule
