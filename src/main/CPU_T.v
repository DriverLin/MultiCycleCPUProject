module CPU_T();
    reg     clk, rst;

    initial begin
        clk = 0;
        rst = 1;
        #12 rst = 0;
        // #20000 $stop;
    end
    always #10 clk = ~clk;
    CPU CPU(
        .clk(clk),
        .rst(rst)
    );
endmodule
