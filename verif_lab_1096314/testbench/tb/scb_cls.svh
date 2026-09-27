`ifndef __SCB_CLS__
`define __SCB_CLS__

`include "dat_cls.svh"

class scb_cls;

    // Mailboxes for receiving packets from the Monitor
    mailbox mbox_scb_wr;
    mailbox mbox_scb_rd;

    // Golden reference model: a simple SystemVerilog queue
    logic [7:0] ref_fifo[$];

    // Counters for evaluation
    int matched;
    int mismatched;
    
    // File descriptor for the log file
    int log_file;

    // Constructor
    function new(mailbox mbox_scb_wr, mailbox mbox_scb_rd);
        this.mbox_scb_wr = mbox_scb_wr;
        this.mbox_scb_rd = mbox_scb_rd;
        this.matched = 0;
        this.mismatched = 0;
        
        // Open the log file in write mode
        this.log_file = $fopen("scoreboard.log", "w");
        if (!this.log_file) begin
            $display("[SCB] Error: Could not open scoreboard.log");
        end
    endfunction : new

    // Main task
    task main();
        fork
            // Thread 1: Handle Writes
            forever begin
                dat_cls pkt_wr;
                mbox_scb_wr.get(pkt_wr);
                
                // Push data to the reference FIFO and log it
                ref_fifo.push_back(pkt_wr.data);
                $fdisplay(log_file, "[%0t] WRITE     : Pushed 0x%0h to reference FIFO", $time, pkt_wr.data);
            end

            // Thread 2: Handle Reads
            forever begin
                dat_cls pkt_rd;
                logic [7:0] expected_data;
                
                mbox_scb_rd.get(pkt_rd);
                
                if (ref_fifo.size() > 0) begin
                    // Pop expected data from the reference FIFO
                    expected_data = ref_fifo.pop_front();
                    
                    // Compare expected data with actual read data
                    if (pkt_rd.data == expected_data) begin
                        $fdisplay(log_file, "[%0t] READ MATCH: Expected = 0x%0h, Actual = 0x%0h", $time, expected_data, pkt_rd.data);
                        matched++;
                    end else begin
                        $fdisplay(log_file, "[%0t] READ MISMATCH: Expected = 0x%0h, Actual = 0x%0h", $time, expected_data, pkt_rd.data);
                        mismatched++;
                    end
                end else begin
                    // Attempted to read when the reference FIFO thinks it's empty
                    $fdisplay(log_file, "[%0t] READ ERROR: Read attempted on empty reference FIFO! Actual = 0x%0h", $time, pkt_rd.data);
                    mismatched++;
                end
            end
        join_none
    endtask : main

    // Report function called at the end of the simulation
    function void report();
        $fdisplay(log_file, "--------------------------------");
        $fdisplay(log_file, "       SCOREBOARD RESULTS       ");
        $fdisplay(log_file, "--------------------------------");
        $fdisplay(log_file, "Matches    : %0d", matched);
        $fdisplay(log_file, "Mismatches : %0d", mismatched);
        
        // Final evaluation and console print
        if (mismatched == 0 && matched > 0) begin
            $display("\n=======================================");
            $display("          SIMULATION PASSED            ");
            $display("=======================================\n");
            $fdisplay(log_file, "STATUS: PASS");
        end else begin
            $display("\n=======================================");
            $display("          SIMULATION FAILED            ");
            $display("=======================================\n");
            $fdisplay(log_file, "STATUS: FAIL");
        end
        
        // Close the log file safely
        $fclose(log_file);
    endfunction : report

endclass : scb_cls

`endif
