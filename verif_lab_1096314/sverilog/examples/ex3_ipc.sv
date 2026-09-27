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
// Declare Data Packet Class
//      idx: index of packet
//      data: random data whith constraints
class packet;
    int idx;
    rand bit [7:0] data;
    constraint c0 { data >= 250 || data < 15; }

    // Set index value
    function set_idx(int index);
    begin
        this.idx = index;
    end
    endfunction

    // Print to screen packet contains
    function print;
    begin
        $display("[%t][idx]: %0d, [data]: 0x%0h ...",$time, idx, data);
    end
    endfunction
endclass
//------------------------------------------------------------------------------
// Declare Base class that contains producer/consumer methods
class base;
    // name of class
    string id;
    // input mailbox
    mailbox mbox_i;
    // output mailbox
    mailbox mbox_o;

    // constructor connect to extrernal mailboxes, get class ID
    function new(string name, mailbox mbox_i, mailbox mbox_o);
    begin
        this.id = name;
        this.mbox_i = mbox_i;
        this.mbox_o = mbox_o;
    end
    endfunction

    // producer
    //----------------------------------------------
    task producer(int cnt);
    packet seq_h;
    begin
        $display("[%t][%0s] producer enabled ...",$time, this.id);
        for ( int i = 0; i < cnt ; i++ ) begin
            seq_h = new();
            # 3;
            // Set index
            seq_h.set_idx(.index(i));
            // Randomize data field
            if( seq_h.randomize() == 1) begin
                // Print data content
                $write("[%t][%0s][prod] ",$time,this.id);
                seq_h.print();
                // Send to output mailbox
                this.mbox_o.put(seq_h);
            end
        end
    end
    endtask
    //----------------------------------------------

    // consumer
    //----------------------------------------------
    task consumer;
    packet seq;
    begin
        $display("[%t][%0s] consumer enabled ...",$time, this.id);
        while(1) begin
            if(this.mbox_i.num() > 0 ) begin
                $display("[%t][%0s][cons] num: %0d",$time, this.id, this.mbox_i.num());
                mbox_i.get(seq);
                $write("[%t][%0s][cons] ",$time, this.id);
                seq.print();
                # 1;
            end else begin
                // $display("[%t][%0s][cons] no data available,go to sleep ...",$time, this.id);
                # 5;
            end
        end
    end
    endtask
    //----------------------------------------------

    // Run operation - enable consumer
    task run;
    begin
        fork
            begin this.consumer(); end
        join_none
    end
    endtask;

endclass

mailbox mbox_AtoB = new();
mailbox mbox_BtoA = new();
//------------------------------------------------------------------------------
base endpoint_a;
base endpoint_b;
int cntA, cntB;
//------------------------------------------------------------------------------
initial begin
    // delays the execution of initial block
    #0;
    // Initialize endpoints, connect mailboxes
    endpoint_a = new(.name("epnt-A"), .mbox_i(mbox_BtoA), .mbox_o(mbox_AtoB));
    endpoint_b = new(.name("epnt-B"), .mbox_i(mbox_AtoB), .mbox_o(mbox_BtoA));
    // Enable consumer of endpoints
    fork
        begin endpoint_a.run(); end
        begin endpoint_b.run(); end
    join_none
    # 10;
    // Start test execution
    //-----------------------------
    // Send messages A -> B
    $display("Messaging A -> B");
    endpoint_a.producer(.cnt(3));
    # 10;
    // Send messages B -> A
    $display("Messaging B -> A");
    endpoint_b.producer(.cnt(4));
    # 10;
    // Endpoints messaging ...
    cntA = $unsigned($random())%10;
    cntB = $unsigned($random())%10;
    $display("Messaging A (%0d) <-> B (%0d)", cntA, cntB);
    fork
        begin endpoint_a.producer(.cnt(cntA)); end
        begin endpoint_b.producer(.cnt(cntB)); end
    join
    # 10;
    //-----------------------------
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
