module tb;

    // Declare signals
    logic clk;
    logic rst_n;
    logic [3:0] input_signal;
    logic [1:0] output_signal;

    logic start;
    logic sample_ready;
    logic ready;
    logic sample; 

    // Instantiate the network module
    network #(
        .n_cycles(10),
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
        input_signal = 4'hF;
        sample_ready = 1;

        // Apply reset
        #10 
        rst_n = 1;
        @(posedge ready);
        start = 1;  

        // Wait for sample to go high
        @(posedge sample);
        input_signal = 4'hf;

        @(posedge sample);
        input_signal = 4'hf;

        @(posedge sample);
        input_signal = 4'hF;
        
        // Finish simulation
        #100 $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("At time %t, input_signal = %h, output_signal = %h, sample_ready = %h, ready = %h, sample = %h", $time, input_signal, output_signal, sample_ready, ready, sample);
    end

endmodule