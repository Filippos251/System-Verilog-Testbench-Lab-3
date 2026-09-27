/**
 * String handling example
 */
//-----------------------------------------------------------------------------
program example();
/**
 * Declaration of variables
 */
string info_text  = "SystemVerilog sTrinG eXaMPle";
/**
 * Initial blocks are executed at the initial phase of simulation
 */
initial begin
    // Start of Simulation message
    $display(">>> start of simulation");
    $display("----------------------------------------------");
end
//------------------------------------------------------------------------------
mailbox prod2cons = new();
//------------------------------------------------------------------------------
task producer;
logic [7:0] rdat;
begin
    $display("[%t] producer enabled ...",$time);
    for ( int i = 0; i < 6 ; i++ ) begin
        # 3;
        rdat = $random();
        $display("[%t][prod] pushing 0x%0h ...",$time,rdat);
        prod2cons.put(rdat);
    end
end
endtask
//-------
task consumer;
logic [7:0] dat;
begin
    $display("[%t] consumer enabled ...",$time);
    while(1) begin
        if(prod2cons.num() != 0 ) begin
            prod2cons.get(dat);
            $display("[%t][cons] got 0x%0h !!!",$time, dat);
            # 1;
        end else begin
            $display("[%t][cons] no data available,go to sleep ...",$time);
            # 5;
        end
    end
end
endtask

//------------------------------------------------------------------------------
initial begin
    // delays the execution of initial block
    #0;
    fork
        begin producer(); end
        begin consumer(); end
    join_any
    $finish;
end
/**
 * Final block
 */
final begin
    $display("----------------------------------------------");
    $display("end of simulation >>>");
end
//-----------------------------------------------------------------------------
endprogram
//-----------------------------------------------------------------------------
