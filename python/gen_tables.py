#!/usr/bin/env python3
"""
AES-128 Test Vector Generator - Simple Random Version
"""

from Crypto.Cipher import AES
import random

def aes128_encrypt(plaintext_hex, key_hex):
    """Encrypt plaintext using AES-128 ECB"""
    plaintext = bytes.fromhex(plaintext_hex)
    key = bytes.fromhex(key_hex)
    
    cipher = AES.new(key, AES.MODE_ECB)
    ciphertext = cipher.encrypt(plaintext)
    
    return ciphertext.hex()

def generate_random_hex(length=32):
    """Generate random hex string of specified length"""
    return ''.join(random.choice('0123456789ABCDEF') for _ in range(length))

def main():
    """Generate 1024 random test vectors"""
    
    num_tests = 1024
    
    # Standard AES-128 key
    key = "2b7e151628aed2a6abf7158809cf4f3c"
    
    print(f"Generating {num_tests} RANDOM test vectors...")
    
    # Generate random test vectors
    test_vectors = []
    plaintext_vectors = []
    
    for i in range(num_tests):
        # Generate random plaintext
        plaintext = generate_random_hex(32)  # 128 bits = 32 hex chars
        
        # Encrypt it
        ciphertext = aes128_encrypt(plaintext, key)
        
        test_vectors.append((plaintext, ciphertext))
        plaintext_vectors.append(plaintext)
        
        if i < 5:  # Show first 5 generations
            print(f"Test {i+1}: {plaintext} -> {ciphertext}")
    
    # Generate ciphertext.txt
    with open("python/tb_tables/ciphertext.txt", "w") as f:
        for plaintext, ciphertext in test_vectors:
            f.write(ciphertext.lower() + "\n")
    
    # Generate plaintext.txt  
    with open("python/tb_tables/plaintext.txt", "w") as f:
        for plaintext in plaintext_vectors:
            f.write(plaintext.upper() + "\n")
    
    print(f"\nFiles generated successfully!")
    print(f"python/tb_tables/ciphertext.txt - {num_tests} ciphertext results")
    print(f"python/tb_tables/plaintext.txt - {num_tests} plaintext results")
    print(f"... and {num_tests - 5} more tests")

if __name__ == "__main__":
    main()