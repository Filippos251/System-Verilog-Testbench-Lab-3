`ifndef __FIFO_TB__
`define __FIFO_TB__
//-----------------------------------------------------------------------------
`include "fifo.v"
`include "fifo_property.sv"
`include "fifo_test.sv"
`include "fifo_if.sv"
//-----------------------------------------------------------------------------
`define DUV  duv
//-----------------------------------------------------------------------------
module fifo_tb;
//-----------------------------------------------------------------------------
bit clk, rstn;
//-----------------------------------------------------------------------------
localparam  fifo_depth = 8;
localparam  fifo_width = 8;
//-----------------------------------------------------------------------------
clkrstn_if clkrstn();
fifo_if #(.dw(fifo_width)) fwrite_if (.clk(clk),.rstn(rstn));
fifo_if #(.dw(fifo_width)) fread_if  (.clk(clk),.rstn(rstn));
//-----------------------------------------------------------------------------
/**
 * Clock
 */
always #5 clk=!clk;
//-----------------------------------------------------------------------------
initial begin : reset
    rstn = 1'b0;
    repeat(2) begin @(posedge clk); end
    #2 rstn = 1'b1;
    
    // Επιβολή του rstn=0 πριν το τέλος της προσομοίωσης (που είναι 3000 κύκλοι)
    // για την κάλυψη της μετάβασης 1->0 στο Toggle Coverage.
    repeat(2990) begin @(posedge clk); end
    #1 rstn = 1'b0;
end
//-----------------------------------------------------------------------------
assign clkrstn.clk  = clk;
assign clkrstn.rstn = rstn;
//-----------------------------------------------------------------------------
fifo_test oop_tb (
//-----------------------------------------------------------------------------
    .clkrstn    ( clkrstn   ),
    .fifo_read  ( fread_if  ),
    .fifo_write ( fwrite_if )
);
//-----------------------------------------------------------------------------
/**
 * Device-Under-Verification
 */
//-----------------------------------------------------------------------------
fifo #(
//-----------------------------------------------------------------------------
    .fifo_depth     ( fifo_depth    ),
    .fifo_width     ( fifo_width    )
//-----------------------------------------------------------------------------
  ) duv (
//-----------------------------------------------------------------------------
    .clk            ( clk            ),
    .rstn           ( rstn           ),
    //---------------------------------
    .fifo_data_out  ( fread_if.data  ),
    .fifo_empty     ( fread_if.req   ),
    .fifo_read      ( fread_if.ack   ),
    //---------------------------------
    .fifo_data_in   ( fwrite_if.data ),
    .fifo_full      ( fwrite_if.ack  ),
    .fifo_write     ( fwrite_if.req  )
    //---------------------------------
);
//-----------------------------------------------------------------------------
/**
 * Bind checker
 */
//-----------------------------------------------------------------------------
bind `DUV fifo_property#(
//-----------------------------------------------------------------------------
    .fifo_depth(fifo_depth),
    .fifo_width(fifo_width)
//-----------------------------------------------------------------------------
  ) duv_bind (
//-----------------------------------------------------------------------------
    .clk            ( clk           ),
    .rstn           ( rstn          ),
    .fifo_data_out  ( fifo_data_out ),
    .fifo_full      ( fifo_full     ),
    .fifo_empty     ( fifo_empty    ),
    .fifo_write     ( fifo_write    ),
    .fifo_read      ( fifo_read     ),
    .fifo_data_in   ( fifo_data_in  )
);
//-----------------------------------------------------------------------------
// ---- ΠΡΟΣΩΡΙΝΟ DEBUG BLOCK — αφαίρεσέ το μετά ----
always @(posedge clk) begin
    if ($time >= 1850 && $time <= 1950) begin
        $display("[DBG %0t] rd_ptr=%0d wr_ptr=%0d cnt=%0d | fifo_read=%b fifo_write=%b | fifo_data_out=%h | fread.ack=%b fread.req=%b fread.data=%h",
                  $time, duv.rd_ptr, duv.wr_ptr, duv.cnt,
                  duv.fifo_read, duv.fifo_write, duv.fifo_data_out,
                  fread_if.ack, fread_if.req, fread_if.data);
    end
end
// ---- ΤΕΛΟΣ DEBUG BLOCK ----
endmodule
//-----------------------------------------------------------------------------
`endif
