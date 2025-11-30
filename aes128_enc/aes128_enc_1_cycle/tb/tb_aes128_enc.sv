`timescale 1ns / 1ps

module tb_aes128_enc;

    parameter CLK_PERIOD = 10;
    parameter MAX_TESTS = 1024;
    
    logic           aclk;
    logic           aresetn;
    logic [127:0]   s_axis_tdata;
    logic           s_axis_tvalid;
    logic           s_axis_tready;
    logic [127:0]   m_axis_tdata;
    logic           m_axis_tvalid;
    logic           m_axis_tready;
    
    // Static key (the same as in decryption)
    localparam logic [127:0] STATIC_KEY = 128'h2B7E151628AED2A6ABF7158809CF4F3C;
    
    // Test vectors for ENCRYPTION: plaintext input and expected ciphertext output
    logic [127:0]   plaintext   [0:MAX_TESTS-1];
    logic [127:0]   ciphertext  [0:MAX_TESTS-1];

    int test_count = 0;
    int error_count = 0;
    int total_start_time;
    int total_end_time;
    longint total_processing_time;

    int tests_sent = 0;
    int tests_received = 0;

    initial begin
        // For ENCRYPTOR: plaintext as input, ciphertext as expected output
        $readmemh("python/tb_tables/plaintext.txt", plaintext);
        $readmemh("python/tb_tables/ciphertext.txt", ciphertext);
    end

    // AES-128 encryption core with static key
    aes128_enc_core_cluster dut (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready)
    );
    
    initial begin
        aclk = 0;
        forever #(CLK_PERIOD/2) aclk = ~aclk;
    end

    initial begin
        aresetn = 0;
        repeat (10) @(posedge aclk);
        aresetn = 1;
    end
    
    initial begin       
        s_axis_tvalid = '0;
        m_axis_tready = '0;
        s_axis_tdata  = '0;
    end
    
    initial begin
        wait(aresetn === 1'b1);
        $display("\nStarting AES-128 ENCRYPTION Testbench with Static Key");
        $display("Static Key: %032h", STATIC_KEY);
        $display("BURST Streaming Mode\n");
        
        repeat (5) @(posedge aclk);
        m_axis_tready = 1'b1;
        
        total_start_time = $time;
        
        fork
            send_all_tests_burst();
            receive_all_results();
        join
        
        total_end_time = $time;
        print_test_summary();
        
        #100;
        $finish;
    end
    
    task automatic send_all_tests_burst();
        int i = 0;
        
        $display("Sending %0d AES ENCRYPTION tests in BURST mode...", MAX_TESTS);
        
        @(posedge aclk);
        s_axis_tvalid = 1'b1;

        while (i < MAX_TESTS) begin
            s_axis_tdata = plaintext[i];
            
            @(posedge aclk);
            
            if (s_axis_tready) begin
                tests_sent++;
                i++;
                
                if (i % 100 == 0) begin
                    $display("[SENT: %0d/%0d]", i, MAX_TESTS);
                end
            end
        end
        
        s_axis_tvalid = 1'b0;
        $display("All AES encryption tests sent in burst mode");
    endtask
    
    task automatic receive_all_results();
        int current_test_id = 0;
        
        $display("Receiving AES ENCRYPTION results...");
        
        while (tests_received < MAX_TESTS) begin
            while (!m_axis_tvalid) begin
                @(posedge aclk);
            end
            
            if (current_test_id < MAX_TESTS) begin
                if (m_axis_tdata === ciphertext[current_test_id]) begin
                    if (tests_received < 5) begin
                        $display("PASS Test %0d", current_test_id+1);
                        $display("   Plaintext:  %032h", plaintext[current_test_id]);
                        $display("   Ciphertext: %032h", m_axis_tdata);
                    end
                end else begin
                    $display("FAIL Test %0d", current_test_id+1);
                    $display("   Plaintext:  %032h", plaintext[current_test_id]);
                    $display("   Key:        %032h", STATIC_KEY);
                    $display("   Expected:   %032h", ciphertext[current_test_id]);
                    $display("   Got:        %032h", m_axis_tdata);
                    error_count++;
                end
                
                test_count++;
                tests_received++;
                current_test_id++;
                
                if (tests_received % 100 == 0) begin
                    $display("[RECV: %0d/%0d]", tests_received, MAX_TESTS);
                end
            end
            
            @(posedge aclk);
        end
        
        $display("All AES encryption results received");
    endtask
    
    function automatic void print_test_summary();
        real total_time_ns;
        real total_time_us;
        real total_time_ms;
        real throughput;
        real data_rate;
        real speed_per_encryption;
        
        $display("\n====================================================================");
        $display("                    AES-128 ENCRYPTION TEST SUMMARY");
        $display("====================================================================");
        $display("Static Key:     %032h", STATIC_KEY);
        $display("Tests sent:     %0d", tests_sent);
        $display("Tests received: %0d", tests_received);
        $display("Errors:         %0d", error_count);
        
        if (test_count > 0) begin
            total_processing_time = total_end_time - total_start_time;
            total_time_ns = real'(total_processing_time);
            total_time_us = total_time_ns / 1000.0;
            total_time_ms = total_time_us / 1000.0;
            
            throughput = (real'(test_count) / total_time_ns) * 1e9;
            data_rate = (real'(test_count) * 128.0 / total_time_ns) * 1000.0;
            speed_per_encryption = total_time_ns / real'(test_count);
            
            $display("\nPROCESSING TIME:");
            $display("  Total time: %0.0f ns", total_time_ns);
            $display("              %0.2f us", total_time_us);
            $display("              %0.3f ms", total_time_ms);
            
            $display("\nPERFORMANCE METRICS:");
            $display("  Frequency:  %0d MHz", 1000 / CLK_PERIOD);
            $display("  Throughput: %0.2f encryptions/sec", throughput);
            $display("  Speed:      %0.2f ns/encryption", speed_per_encryption);
            $display("  Data rate:  %0.2f Mbps", data_rate);
            
            $display("\nSUCCESS RATE: %0.1f%%", (real'(test_count - error_count) / real'(test_count)) * 100.0);
            
        end else begin
            $display("No tests completed!");
        end
        
        if (error_count == 0 && tests_sent == tests_received) begin
            $display("\nALL AES ENCRYPTION TESTS PASSED SUCCESSFULLY!");
        end else begin
            $display("\nAES ENCRYPTION TEST FAILURES DETECTED!");
            if (tests_sent != tests_received) begin
                $display("   Mismatch: %0d sent vs %0d received", tests_sent, tests_received);
            end
        end
        $display("====================================================================");
    endfunction
    
    initial begin
        #5000000;
        $display("\nTIMEOUT: Simulation too long");
        $display("Sent: %0d, Received: %0d", tests_sent, tests_received);
        print_test_summary();
        $finish;
    end

endmodule