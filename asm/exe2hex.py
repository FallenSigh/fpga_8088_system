import os
import struct
import sys

# =================配置区域=================
# 这里写死 ROM 大小：16384 * 8bits = 16384 字节
ROM_SIZE_BYTES = 16384
# =========================================


def calculate_checksum(record_bytes):
    """计算 Intel HEX 校验和: 0x100 - (sum(bytes) & 0xFF)"""
    total = sum(record_bytes)
    return (-total) & 0xFF


def exe_to_bin_content(exe_data):
    """
    尝试解析 DOS MZ 头并提取代码段。
    """
    # 检查是否有 MZ 签名 (0x4D 0x5A)
    if len(exe_data) > 2 and exe_data[0:2] == b"MZ":
        print("检测到 DOS EXE 文件头，正在提取代码段...")
        # 解析 MZ 头, 0x08: Header size in paragraphs
        header_paragraphs = struct.unpack_from("<H", exe_data, 0x08)[0]
        header_size = header_paragraphs * 16

        # 提取实际代码
        code_data = exe_data[header_size:]
        print(f"头大小: {header_size} 字节, 代码净荷: {len(code_data)} 字节")
        return code_data
    else:
        print("未检测到 EXE 头，按纯二进制文件处理。")
        return exe_data


def bin_to_hex(bin_data, output_file):
    """将二进制数据转换为定长 Intel HEX 格式"""

    current_len = len(bin_data)

    # === 强制大小检查与填充逻辑 ===
    print(f"目标 ROM 大小: {ROM_SIZE_BYTES} 字节")

    if current_len > ROM_SIZE_BYTES:
        print(
            f"【错误】输入文件过大！({current_len} 字节) 超过了 ROM 上限 ({ROM_SIZE_BYTES} 字节)。"
        )
        sys.exit(1)
    elif current_len < ROM_SIZE_BYTES:
        pad_len = ROM_SIZE_BYTES - current_len
        print(f"输入数据 {current_len} 字节，正在填充 {pad_len} 字节的 0xFF...")
        # 填充 0xFF (通常代表空指令或无数据)
        bin_data = bytearray(bin_data) + (b"\xff" * pad_len)
    else:
        print("输入数据大小正好等于 ROM 大小，无需填充。")

    start_address = 0

    with open(output_file, "w") as f:
        print(f"正在生成 {output_file} ...")

        # 每次读取 16 字节
        for i in range(0, len(bin_data), 16):
            chunk = bin_data[i : i + 16]
            byte_count = len(chunk)
            address = start_address + i
            record_type = 0  # 00 = 数据记录

            # [Byte Count, Addr Hi, Addr Lo, Record Type, Data...]
            record_bytes = [
                byte_count,
                (address >> 8) & 0xFF,
                address & 0xFF,
                record_type,
            ]
            record_bytes.extend(chunk)

            # 计算校验和
            checksum = calculate_checksum(record_bytes)

            # 生成 HEX 行 :LLAAAATTDD...DDCC
            hex_line = ":{:02X}{:04X}{:02X}".format(byte_count, address, record_type)
            hex_line += "".join(["{:02X}".format(b) for b in chunk])
            hex_line += "{:02X}\n".format(checksum)

            f.write(hex_line)

        # 写入文件结束记录 :00000001FF
        f.write(":00000001FF\n")
        print("转换完成！")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("用法: python exe2hex.py <输入文件> <输出文件.hex>")
    else:
        input_path = sys.argv[1]
        output_path = sys.argv[2]

        try:
            with open(input_path, "rb") as f_in:
                raw_data = f_in.read()

            # 1. 提取有效数据
            clean_data = exe_to_bin_content(raw_data)

            # 2. 转换并填充到固定大小
            bin_to_hex(clean_data, output_path)

        except FileNotFoundError:
            print(f"错误: 找不到文件 {input_path}")
        except Exception as e:
            print(f"发生未知错误: {e}")
