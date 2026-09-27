`ifndef __FIFO__
`define __FIFO__
module fifo #(
    parameter fifo_depth = 8,
    parameter fifo_width = 8
) (
    output logic [(fifo_width-1):0] fifo_data_out,
    output logic                    fifo_full,
    output logic                    fifo_empty,
    input  logic                    fifo_write,
    input  logic                    fifo_read,
    input  logic                    clk, rstn,
    input  logic [(fifo_width-1):0] fifo_data_in
);
logic [(fifo_width-1):0] fifomem [0:(fifo_depth-1)];
logic [2:0] wr_ptr, rd_ptr;
logic [3:0] cnt; 

always @(posedge clk or rstn) begin
    if(!rstn) begin
        rd_ptr <= 0; // Διορθώθηκε πίσω στο 0 (Scoreboard & Check1 pass)
        wr_ptr <= 0;
        cnt    <= 0;
        fifo_empty <= 1;
        fifo_full  <= 0;
    end
    else begin
        case({fifo_write, fifo_read})
            2'b00 : ;
            2'b01 : begin // read
                if(cnt > 0) begin // Ενεργοποιήθηκε ξανά για να αποτρέψει το underflow στο 15
                    rd_ptr <= rd_ptr +1;
                    cnt    <= cnt    -1;
                    if(cnt == 1) fifo_empty <= 1;
                end
                if(cnt == 0 ) fifo_empty <= 1; 
                fifo_full  <= 0;
            end
            2'b10 : begin // write
                if(cnt<fifo_depth) begin 
                    fifomem[wr_ptr] <= fifo_data_in;
                    wr_ptr          <= wr_ptr +1;
                    cnt             <= cnt    +1;
                end
                if(cnt>=(fifo_depth-1)) fifo_full <= 1; // >= για να ενεργοποιείται το full αμέσως!
                fifo_empty          <= 0;
            end
            2'b11 : begin // write && read
                if(cnt > (fifo_depth-1) ) begin
                    rd_ptr <= rd_ptr +1;
                    cnt    <= cnt    -1;
                    fifo_full <= 0; // Καθαρισμός του full flag μετά από read
                end
                else if(cnt<1) begin
                    fifomem[wr_ptr]<= fifo_data_in;
                    wr_ptr <= wr_ptr +1;
                    cnt    <= cnt    +1;
                    fifo_empty <= 0; // Καθαρισμός του empty flag μετά από write
                end
                else begin
                    fifomem[wr_ptr] <= fifo_data_in;
                    wr_ptr          <= wr_ptr +1;
                    rd_ptr          <= rd_ptr +1;
                end
            end
        endcase
    end
end
assign fifo_data_out = fifomem[rd_ptr];
endmodule
`endif
