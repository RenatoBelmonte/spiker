module tb;

    // Declare signals
    logic clk;
    logic rst_n;
    logic [7:0] input_signal;
    logic [1:0] output_signal;

    logic start;
    logic sample_ready;
    logic ready;
    logic sample; 

    // Instantiate the network module
    network #(
        .n_cylces(10),
        .cycles_cnt_bitwidth(5)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .sample_ready(sample_ready),
        .ready(ready),
        .sample(sample),
        .in_spikes(input_signal),
        .out_spikes(output_signal)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Stimulus generation
    initial begin
        // Initialize signals
        rst_n = 0;
        input_signal = 8'b10101111;
        sample_ready = 1;

        // Apply reset
        #10 
        rst_n = 1;

        // Wait for sample to go high
        @(posedge sample);
        input_signal = 8'hAA;

        @(posedge sample);
        input_signal = 8'h55;

        @(posedge sample);
        input_signal = 8'hFF;
        
        // Finish simulation
        #100 $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("At time %t, input_signal = %h, output_signal = %h, sample = %h, sample_ready = %h, ready = %h", $time, input_signal, output_signal, sample, sample_ready, ready);
    end

endmodule