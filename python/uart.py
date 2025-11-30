import serial
import time
import sys

class AES128Controller:
    # Адреса регистров согласно карте
    AXI_ADDR_TEST_REG   = 0x80000000
    AXI_ADDR_DATA_0     = 0x80000004
    AXI_ADDR_DATA_1     = 0x80000008  
    AXI_ADDR_DATA_2     = 0x8000000C
    AXI_ADDR_DATA_3     = 0x8000000F
    AXI_START_AES       = 0x800000F0
    AXI_STOP_AES        = 0x800000F4
    AXI_RESULT_AES      = 0x800000F8
    
    def __init__(self, port='/dev/ttyACM0', baudrate=115200):
        self.port = port
        self.baudrate = baudrate
        self.ser = None
        
    def connect(self):
        """Подключение к UART"""
        try:
            self.ser = serial.Serial(
                self.port,
                baudrate=self.baudrate,
                timeout=0.1,
                write_timeout=1.0,
                bytesize=serial.EIGHTBITS,
                parity=serial.PARITY_NONE,
                stopbits=serial.STOPBITS_ONE
            )
            time.sleep(2)
            print(f"✅ Успешное подключение к {self.port}")
            return True
        except serial.SerialException as e:
            print(f"❌ Ошибка подключения: {e}")
            return False
    
    def disconnect(self):
        """Отключение от UART"""
        if self.ser and self.ser.is_open:
            self.ser.close()
            print("📴 Отключено от UART")
    
    def build_frame(self, header, address, data, wr_rd):
        """Построение кадра для отправки"""
        address_hex = f"{address:08x}"
        data_hex = f"{data:08x}"
        frame = f"{header:02x}{address_hex}{data_hex}{wr_rd:02x}"
        return frame
    
    def send_frame(self, frame, byte_delay=0.001):
        """Отправка кадра с задержками между байтами"""
        try:
            data_bytes = bytes.fromhex(frame)
            
            # Очистка буферов перед отправкой
            self.ser.reset_input_buffer()
            self.ser.reset_output_buffer()
            
            # Отправка с задержками между байтами
            for i, byte in enumerate(data_bytes):
                self.ser.write(bytes([byte]))
                self.ser.flush()
                if i < len(data_bytes) - 1:
                    time.sleep(byte_delay)
            
            # Задержка перед чтением ответа
            time.sleep(0.01)
            
            # Чтение ответа
            start_time = time.time()
            response = b''
            
            while time.time() - start_time < 0.1:
                if self.ser.in_waiting > 0:
                    bytes_to_read = self.ser.in_waiting
                    chunk = self.ser.read(bytes_to_read)
                    response += chunk
                    
                    if len(response) >= 11:
                        break
                time.sleep(0.001)
            
            return response.hex() if response else None
            
        except Exception as e:
            print(f"❌ Ошибка отправки: {e}")
            return None
    
    def decode_frame(self, data_hex):
        """Декодирование кадра"""
        try:
            if len(data_hex) == 22:  # RX frame
                header = data_hex[0:2]
                address = data_hex[2:10]
                data_field = data_hex[10:18]
                response_byte = data_hex[18:20]
                wr_rd_byte = data_hex[20:22]
                
                # Декодирование ответа
                response_int = int(response_byte, 16)
                response_bits = response_int & 0b00000011
                
                if response_bits == 0b00:
                    response = "OKAY"
                elif response_bits == 0b11:
                    response = "DECERR"
                else:
                    response = "ERROR"
                    
                return header, address, data_field, wr_rd_byte, response
            else:
                return "ERROR", "ERROR", "ERROR", "ERROR", "ERROR"
                
        except Exception as e:
            return "ERROR", "ERROR", "ERROR", "ERROR", "ERROR"
    
    def write_register(self, address, data):
        """Запись в регистр"""
        frame = self.build_frame(0xF0, address, data, 0xA1)
        response = self.send_frame(frame)
        
        if response:
            header, addr, data_field, wr_rd, resp = self.decode_frame(response)
            return resp == "OKAY"
        else:
            return False
    
    def read_register(self, address):
        """Чтение регистра"""
        frame = self.build_frame(0xF0, address, 0x00000000, 0xA2)
        response = self.send_frame(frame)
        
        if response:
            header, addr, data_field, wr_rd, resp = self.decode_frame(response)
            
            if resp == "OKAY" and data_field != "ERROR":
                try:
                    value = int(data_field, 16)
                    return value
                except ValueError:
                    return None
            else:
                return None
        else:
            return None
    
    def test_connection(self):
        """Тест подключения - запись и чтение тестового регистра"""
        print("🔍 Тестирование подключения к плате...")
        
        time.sleep(0.5)
        
        # Тестовое значение
        test_value = 0x12345678
        
        # Запись тестового значения
        if not self.write_register(self.AXI_ADDR_TEST_REG, test_value):
            print("❌ Ошибка записи тестового регистра")
            return False
        
        time.sleep(0.1)
        
        # Чтение тестового значения
        read_value = self.read_register(self.AXI_ADDR_TEST_REG)
        
        if read_value is None:
            print("❌ Ошибка чтения тестового регистра")
            return False
        
        if read_value == test_value:
            print("✅ Плата успешно инициализирована!")
            return True
        else:
            print("❌ Ошибка: записанное и считанное значение не совпадают")
            print(f"   Записали: 0x{test_value:08x}, Прочитали: 0x{read_value:08x}")
            return False

    def write_data_block(self, data_128bit):
        """Запись 128-битного блока данных по 4 регистрам"""
        if len(data_128bit) != 32:  # 32 hex chars = 128 bits
            print("❌ Неверная длина данных (должно быть 32 hex символа)")
            return False
        
        # Разбиваем на 4 части по 32 бита
        data_parts = [
            int(data_128bit[0:8], 16),    # bits 127:96
            int(data_128bit[8:16], 16),   # bits 95:64  
            int(data_128bit[16:24], 16),  # bits 63:32
            int(data_128bit[24:32], 16)   # bits 31:0
        ]
        
        addresses = [
            self.AXI_ADDR_DATA_0,
            self.AXI_ADDR_DATA_1, 
            self.AXI_ADDR_DATA_2,
            self.AXI_ADDR_DATA_3
        ]
        
        # Записываем все 4 части
        for i, (addr, data) in enumerate(zip(addresses, data_parts)):
            if not self.write_register(addr, data):
                print(f"❌ Ошибка записи в регистр DATA_{i}")
                return False
            time.sleep(0.01)
        
        print("✅ Данные успешно записаны")
        return True

    def read_data_block(self):
        """Чтение 128-битного блока данных из 4 регистров"""
        data_parts = []
        addresses = [
            self.AXI_ADDR_DATA_0,
            self.AXI_ADDR_DATA_1,
            self.AXI_ADDR_DATA_2, 
            self.AXI_ADDR_DATA_3
        ]
        
        # Читаем все 4 части
        for i, addr in enumerate(addresses):
            data = self.read_register(addr)
            if data is None:
                print(f"❌ Ошибка чтения из регистра DATA_{i}")
                return None
            data_parts.append(data)
            time.sleep(0.01)
        
        # Собираем в 128-битное значение
        result = (data_parts[0] << 96) | (data_parts[1] << 64) | (data_parts[2] << 32) | data_parts[3]
        return f"{result:032x}"

    def start_aes(self):
        """Запуск AES операции"""
        return self.write_register(self.AXI_START_AES, 0x1)

    def stop_aes(self):
        """Остановка AES операции"""  
        return self.write_register(self.AXI_STOP_AES, 0x1)

    def reset_aes(self):
        """Сброс AES (запись в RESULT)"""
        return self.write_register(self.AXI_RESULT_AES, 0x1)

    def test_aes_encryption(self, plaintext_hex, expected_ciphertext_hex=None):
        """Тест одного AES шифрования"""
        print(f"\n🔐 Тест AES шифрования")
        print(f"   Plaintext:  {plaintext_hex}")
        
        # Записываем входные данные
        if not self.write_data_block(plaintext_hex):
            return False
        
        # Запускаем AES
        if not self.start_aes():
            print("❌ Ошибка запуска AES")
            return False
        time.sleep(0.1)
        
        # Останавливаем AES
        if not self.stop_aes():
            print("❌ Ошибка остановки AES") 
            return False
        time.sleep(0.1)
        
        # Читаем результат
        ciphertext = self.read_data_block()
        if ciphertext is None:
            print("❌ Ошибка чтения результата")
            return False
        
        print(f"   Ciphertext: {ciphertext}")
        
        # Проверяем ожидаемый результат если предоставлен
        if expected_ciphertext_hex:
            if ciphertext == expected_ciphertext_hex:
                print("✅ Результат совпадает с ожидаемым!")
                success = True
            else:
                print(f"❌ Ошибка: ожидалось {expected_ciphertext_hex}")
                success = False
        else:
            success = True
        
        # Сброс для следующей операции
        self.reset_aes()
        time.sleep(0.1)
        
        return success

    def run_performance_test(self, num_tests=100):
        """Тест производительности с множеством операций"""
        print(f"\n🚀 Запуск теста производительности ({num_tests} операций)")
        
        start_time = time.time()
        successful_ops = 0
        
        # Тестовые векторы
        test_vectors = [
            ("00000000000000000000000000000000", "3ad77bb40d7a3660a89ecaf32466ef97"),
            ("6bc1bee22e409f96e93d7e117393172a", "f5d3d58503b9699de785895a96fdbaaf"),
        ]
        
        for i in range(num_tests):
            # Циклически используем тестовые векторы
            plaintext, expected = test_vectors[i % len(test_vectors)]
            
            if self.test_aes_encryption(plaintext, expected):
                successful_ops += 1
            
            # Прогресс каждые 10%
            if (i + 1) % (num_tests // 10) == 0:
                progress = (i + 1) / num_tests * 100
                print(f"   Прогресс: {progress:.0f}%")
        
        end_time = time.time()
        total_time = end_time - start_time
        
        print(f"\n📊 Результаты производительности:")
        print(f"   Успешных операций: {successful_ops}/{num_tests}")
        print(f"   Общее время: {total_time:.2f} сек")
        print(f"   Операций в секунду: {num_tests/total_time:.1f}")
        print(f"   Время на операцию: {total_time/num_tests*1000:.1f} мс")

def main():
    print("=" * 65)
    print("               AES128 CONTROLLER")
    print("=" * 65)
    
    # Создание контроллера
    controller = AES128Controller()
    
    # Подключение
    if not controller.connect():
        return
    
    try:
        # Тест подключения
        if not controller.test_connection():
            print("❌ Не удалось инициализировать плату")
            return
        
        while True:
            print("\n🎮 Выберите действие:")
            print("1. Тест одного AES шифрования")
            print("2. Тест производительности") 
            print("3. Ручной ввод данных")
            print("4. Выход")
            
            choice = input("Ваш выбор (1-4): ").strip()
            
            if choice == '1':
                # Одиночный тест
                plaintext = input("Введите plaintext (32 hex символа): ").strip()
                if len(plaintext) != 32:
                    print("❌ Должно быть 32 hex символа!")
                    continue
                    
                expected = input("Введите ожидаемый ciphertext (32 hex символа, Enter для пропуска): ").strip()
                expected = expected if len(expected) == 32 else None
                
                controller.test_aes_encryption(plaintext, expected)
                
            elif choice == '2':
                # Тест производительности
                try:
                    num_tests = int(input("Количество операций для теста: "))
                    if num_tests <= 0:
                        print("❌ Число должно быть положительным")
                        continue
                    controller.run_performance_test(num_tests)
                except ValueError:
                    print("❌ Неверный формат числа")
                    
            elif choice == '3':
                # Ручной режим
                print("\n🔧 Ручной режим:")
                print("   Запись данных -> START -> STOP -> Чтение результата -> RESET")
                
                plaintext = input("Введите plaintext (32 hex символа): ").strip()
                if len(plaintext) != 32:
                    print("❌ Должно быть 32 hex символа!")
                    continue
                
                # Полный цикл операции
                controller.write_data_block(plaintext)
                controller.start_aes()
                time.sleep(0.2)
                controller.stop_aes() 
                time.sleep(0.2)
                result = controller.read_data_block()
                if result:
                    print(f"📤 Результат: {result}")
                controller.reset_aes()
                
            elif choice == '4':
                print("👋 Выход")
                break
            else:
                print("❌ Неверный выбор")
                
    except KeyboardInterrupt:
        print("\n⏹️  Программа прервана пользователем")
    except Exception as e:
        print(f"❌ Ошибка: {e}")
    finally:
        controller.disconnect()

if __name__ == "__main__":
    main()