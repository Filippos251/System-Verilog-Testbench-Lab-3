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

initial begin
    // delays the execution of initial block
    #0;
    // Print Initial values
    $display("---> initial value of info_text variable: \"%s\"",info_text);
    // Convert to lower case letters
    $display("---> info_text length: %d",info_text.len());
    // if string larger than 5
    if ( info_text.len() >= 12) begin
        info_text = info_text.tolower();
    end
    else begin
        info_text = info_text.toupper();
    end
    $display("---> info_text status: \"%s\"",info_text);
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
