`ifndef __MON_CLS__
`define __MON_CLS__
//------------------------------------------------------------------------------
`include "dat_cls.svh"
//------------------------------------------------------------------------------
class mon_cls;

    virtual clkrstn_if   clkrstn_vif;
    fifo_r_vif_i         fifor_vif_i;
    fifo_w_vif_o         fifow_vif_o;

    mailbox mbox_scb_wr;
    mailbox mbox_scb_rd;

    function new(virtual clkrstn_if clkrstn_vif, 
                 fifo_w_vif_o       fifow_vif_o, 
                 fifo_r_vif_i       fifor_vif_i, 
                 mailbox            mbox_scb_wr, 
                 mailbox            mbox_scb_rd);
        this.clkrstn_vif = clkrstn_vif;
        this.fifow_vif_o = fifow_vif_o;
        this.fifor_vif_i = fifor_vif_i;
        this.mbox_scb_wr = mbox_scb_wr;
        this.mbox_scb_rd = mbox_scb_rd;
    endfunction : new

    task main();
        fork
            monitor_write();
            monitor_read();
        join
    endtask : main

    task monitor_write();
        dat_cls wr_pkt;
        forever begin
            @(negedge clkrstn_vif.clk); // Fix: negedge to prevent race conditions
            if (clkrstn_vif.rstn && fifow_vif_o.req === 1'b1 && fifow_vif_o.ack === 1'b0) begin
                wr_pkt = new();
                wr_pkt.data = fifow_vif_o.data;
                mbox_scb_wr.put(wr_pkt);
            end
        end
    endtask : monitor_write

    task monitor_read();
        dat_cls rd_pkt;
        forever begin
            @(negedge clkrstn_vif.clk); // Fix: negedge to prevent race conditions
            if (clkrstn_vif.rstn && fifor_vif_i.ack === 1'b1 && fifor_vif_i.req === 1'b0) begin
                rd_pkt = new();
                rd_pkt.data = fifor_vif_i.data;
                mbox_scb_rd.put(rd_pkt);
            end
        end
    endtask : monitor_read

endclass : mon_cls
`endif
