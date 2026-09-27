`ifndef __ENV_CLS__
`define __ENV_CLS__
//------------------------------------------------------------------------------
`include "gen_cls.svh"
`include "drv_cls.svh"
`include "mon_cls.svh"
`include "scb_cls.svh"
`include "dat_cls.svh"
//------------------------------------------------------------------------------
class env_cls;
//------------------------------------------------------------------------------

    // Virtual Interfaces
    //-------------------------------
    virtual clkrstn_if clkrstn_vif;
    virtual fifo_if.wm fifo_wr_vif;
    virtual fifo_if.rm fifo_rd_vif;
    //-------------------------------

    // Declare Components
    //-------------------------------
    gen_cls    fifo_gen;
    drv_cls    fifo_drv;
    mon_cls    fifo_mon;
    scb_cls    fifo_scb;

    // Declare Mailboxes
    //-------------------------------
    mailbox    mbox;
    mailbox    mbox_scb_wr;
    mailbox    mbox_scb_rd;

    // Constructor
    //-----------------------------------------------
    function new(   virtual clkrstn_if clkrstn_vif,
                    virtual fifo_if.wm fifo_wr_vif,
                    virtual fifo_if.rm fifo_rd_vif);
    //-----------------------------------------------
    begin
        this.clkrstn_vif = clkrstn_vif;
        this.fifo_wr_vif = fifo_wr_vif;
        this.fifo_rd_vif = fifo_rd_vif;

        // Create mailboxes
        //-------------------------------
        mbox        = new();
        mbox_scb_wr = new();
        mbox_scb_rd = new();

        // Create components
        //-------------------------------
        fifo_gen = new( this.mbox, 40);
        
        fifo_drv = new( this.mbox,
                        this.clkrstn_vif,
                        this.fifo_rd_vif,
                        this.fifo_wr_vif);
                        
        fifo_mon = new( this.clkrstn_vif,
                        this.fifo_wr_vif,
                        this.fifo_rd_vif,
                        this.mbox_scb_wr,
                        this.mbox_scb_rd);
                        
        fifo_scb = new( this.mbox_scb_wr,
                        this.mbox_scb_rd);
    end
    //-----------------------------------------------
    endfunction

    task run;
    //-----------------------------------------------
    begin
        fork
            begin : fork_generator
                fifo_gen.main();
            end
            begin : fork_driver
                fifo_drv.main();
            end
            begin : fork_monitor
                fifo_mon.main();
            end
            begin : fork_scoreboard
                fifo_scb.main();
            end
        join
    end
    //-----------------------------------------------
    endtask

//------------------------------------------------------------------------------
endclass : env_cls
//------------------------------------------------------------------------------
`endif
