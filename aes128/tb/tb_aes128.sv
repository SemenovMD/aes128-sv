`timescale 1ns/1ps

module tb_aes128();

    // Тактовый сигнал и сброс
    logic aclk = 0;
    logic aresetn = 0;
    
    // AXI-Stream входные сигналы
    logic [127:0] s_axis_tdata;
    logic s_axis_tvalid = 0;
    logic s_axis_tready;
    
    // AXI-Stream выходные сигналы  
    logic [127:0] m_axis_tdata;
    logic m_axis_tvalid;
    logic m_axis_tready = 1;
    
    // Генерация тактового сигнала
    always #5 aclk = ~aclk;
    
    // DUT
    aes128 dut (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready)
    );
    
    // Тестовые векторы (пример)
    localparam [127:0] TEST_CIPHERTEXT = 128'hf5d3d58503b9699de785895a96fdbaaf;
    localparam [127:0] EXPECTED_PLAINTEXT = 128'h3243f6a8885a308d313198a2e0370734;
    
    initial begin
        // Логирование
        $display("=== AES128 Testbench Started ===");
        $monitor("Time: %0t | State: %s | Input: %h | Output: %h", 
                 $time, dut.state.name(), s_axis_tdata, m_axis_tdata);
        
        // Сброс
        #10 aresetn = 1;
        #20;
        
        @(posedge aclk)
        // Тест 1: Отправка одного блока
        $display("\n--- Test 1: Single Block Decryption ---");
        s_axis_tdata = TEST_CIPHERTEXT;
        s_axis_tvalid = 1;
        
        // Ждем готовности
        wait(s_axis_tready == 1);
        @(posedge aclk);
        s_axis_tvalid = 0;
        
        // Ждем результата
        wait(m_axis_tvalid == 1);
        @(posedge aclk);
        
        // Проверка результата
        if (m_axis_tdata === EXPECTED_PLAINTEXT) begin
            $display("✅ Test 1 PASSED: Correct decryption");
        end else begin
            $display("❌ Test 1 FAILED: Expected %h, Got %h", 
                     EXPECTED_PLAINTEXT, m_axis_tdata);
        end
        
        // Тест 2: Несколько блоков подряд
        $display("\n--- Test 2: Back-to-Back Blocks ---");
        fork
            begin
                // Отправка первого блока
                @(posedge aclk);
                s_axis_tdata = TEST_CIPHERTEXT;
                s_axis_tvalid = 1;
                wait(s_axis_tready == 1);
                @(posedge aclk);
                
                // Отправка второго блока сразу после первого
                s_axis_tdata = TEST_CIPHERTEXT ^ 128'h1; // Немного измененный
                wait(s_axis_tready == 1);
                @(posedge aclk);
                s_axis_tvalid = 0;
            end
            
            begin
                // Прием результатов
                repeat(2) begin
                    wait(m_axis_tvalid == 1);
                    @(posedge aclk);
                    $display("Received block: %h", m_axis_tdata);
                end
            end
        join
        
        // Тест 3: Backpressure тест
        $display("\n--- Test 3: Backpressure Test ---");
        m_axis_tready = 0; // Симулируем занятость приемника
        
        @(posedge aclk);
        s_axis_tdata = TEST_CIPHERTEXT;
        s_axis_tvalid = 1;
        wait(s_axis_tready == 1);
        @(posedge aclk);
        s_axis_tvalid = 0;
        
        // Ждем пока модуль попытается выдать данные
        wait(m_axis_tvalid == 1);
        #50; // Держим backpressure
        
        m_axis_tready = 1; // Снимаем backpressure
        @(posedge aclk);
        $display("Backpressure test completed");
        
        // Завершение
        #100;
        $display("\n=== AES128 Testbench Finished ===");
        $finish;
    end
    
    // Простая проверка таймаутов
    initial begin
        #10000;
        $display("❌ TIMEOUT: Simulation took too long");
        $finish;
    end
    
endmodule