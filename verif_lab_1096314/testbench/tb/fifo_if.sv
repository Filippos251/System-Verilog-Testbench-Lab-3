`ifndef __FIFO_IF__
`define __FIFO_IF__
//------------------------------------------------------------------------------
interface clkrstn_if;
//-----------------------------------------
  logic        clk;
  logic        rstn;
//-----------------------------------------
endinterface
//-----------------------------------------

interface fifo_if #(
//-----------------------------------------
    parameter dw = 8
//-----------------------------------------
  ) (input clk, rstn);
//-----------------------------------------

    logic [(dw-1):0] data;
    logic            req;
    logic            ack;

//-----------------------------------------
modport rm	( input data, req, output ack);
modport rs	(output data, req,  input ack);
//-----------------------------------------
modport wm	(output data, req,  input ack);
modport ws	( input data, req, output ack);
//-----------------------------------------
endinterface
//------------------------------------------------------------------------------
`endif