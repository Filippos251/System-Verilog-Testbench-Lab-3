`ifndef __DRV_CLS__
`define __DRV_CLS__
typedef virtual fifo_if.rm fifo_r_vif_i;
typedef virtual fifo_if.wm fifo_w_vif_o;

class drv_cls;
    virtual clkrstn_if   clkrstn_vif;
    fifo_r_vif_i         fifor_vif_i;
    fifo_w_vif_o         fifow_vif_o;
    dat_cls              data_pkt;
    mailbox              mbox;

    function new(         mailbox      mbox,
                  virtual clkrstn_if   clkrstn_vif,
                          fifo_r_vif_i fifor_vif_i,
                          fifo_w_vif_o fifow_vif_o );
        this.mbox        = mbox;
        this.clkrstn_vif = clkrstn_vif;
        this.fifor_vif_i = fifor_vif_i;
        this.fifow_vif_o = fifow_vif_o;
    endfunction : new

    task main;
        fork
            fifo_write();
            fifo_read();
        join
    endtask : main

    task fifo_write;
        int bad_write_cnt = 0;
        bit injected_x = 0;
    begin
        fifow_vif_o.data <= 'd0;
        fifow_vif_o.req  <= 1'b0;
        
        wait(clkrstn_vif.rstn == 1'b1);
        @(posedge clkrstn_vif.clk);
        fifow_vif_o.req <= 1'bx;
        @(posedge clkrstn_vif.clk);
        fifow_vif_o.req <= 1'b0;
        
        forever begin
            @(posedge clkrstn_vif.clk);
            if(!clkrstn_vif.rstn) begin
                fifow_vif_o.data <=  'd0;
                fifow_vif_o.req  <= 1'b0;
                bad_write_cnt = 0;
            end
            else begin
                if( !fifow_vif_o.req || ( fifow_vif_o.req && !fifow_vif_o.ack )) begin
                    if(mbox.num() > 'd0 ) begin
                        mbox.get(data_pkt);
                        data_pkt.show("drv");
                        
                        if (data_pkt.delay > 0) begin
                            repeat(data_pkt.delay) @(posedge clkrstn_vif.clk);
                        end
                        
                        for (int i = 0; i < data_pkt.iter; i++) begin
                            while (fifow_vif_o.ack == 1'b1) begin // FIFO is full
                                if (bad_write_cnt < 20) begin
                                    fifow_vif_o.req <= 1'b1; 
                                    fifow_vif_o.data <= data_pkt.data;
                                    bad_write_cnt++;
                                end else begin
                                    fifow_vif_o.req <= 1'b0;
                                end
                                @(posedge clkrstn_vif.clk);
                            end
                            
                            fifow_vif_o.data <= data_pkt.data;
                            fifow_vif_o.req  <= 1'b1;
                            @(posedge clkrstn_vif.clk);
                            
                            fifow_vif_o.req <= 1'b0;
                            @(posedge clkrstn_vif.clk); // Safety gap
                        end
                    end
                end
            end
        end
    end
    endtask : fifo_write
    
    task fifo_read;
        int bad_read_cnt = 0;
    begin
        fifor_vif_i.ack <= 1'b0;
        forever begin
            @(posedge clkrstn_vif.clk);
            if(!clkrstn_vif.rstn) begin
                fifor_vif_i.ack  <= 1'b0;
                bad_read_cnt = 0;
            end
            else begin
                if (fifor_vif_i.req == 1'b1) begin 
                    if (bad_read_cnt < 20) begin
                        fifor_vif_i.ack <= 1'b1; 
                        bad_read_cnt++;
                    end else begin
                        fifor_vif_i.ack <= 1'b0;
                    end
                end else begin
                    fifor_vif_i.ack <= ($urandom_range(0, 99) < 20) ? 1'b1 : 1'b0;
                end
                
                if(fifor_vif_i.ack && !fifor_vif_i.req) begin
                    $display("pop data: 0x%0h", fifor_vif_i.data);
                end
            end
        end
    end
    endtask : fifo_read

endclass: drv_cls
`endif
