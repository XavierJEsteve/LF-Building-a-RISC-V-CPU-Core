\m4_TLV_version 1d: tl-x.org
\SV
   // This code can be found in: https://github.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/risc-v_shell.tlv
   
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/warp-v_includes/1d1023ccf8e7b0a8cf8e8fc4f0a823ebb61008e3/risc-v_defs.tlv'])
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/main/lib/risc-v_shell_lib.tlv'])



   //---------------------------------------------------------------------------------
   // /====================\
   // | Sum 1 to 9 Program |
   // \====================/
   //
   // Program to test RV32I
   // Add 1,2,3,...,9 (in that order).
   //
   // Regs:
   //  x12 (a2): 10
   //  x13 (a3): 1..10
   //  x14 (a4): Sum
   // 
	//m4_asm(ADDI, x0, x0, 1) 				 //tests that we cannot write to x0
   m4_test_prog()
   //m4_asm_end()
   //m4_define(['M4_MAX_CYC'], 50)
   //---------------------------------------------------------------------------------



\SV
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)
   /* verilator lint_on WIDTH */
\TLV
   // hello?
   $reset = *reset;
   
   
   // YOUR CODE HERE
   // ...
   // Program counter
   $next_pc[31:0] = $reset ? 32'b0 : 
                    $taken_br ? $br_tgt_pc[31:0] :
                    $is_jal   ? $br_tgt_pc  :
                    $is_jalr  ? $jal_tgt_pc :
                    (32'h4 + $pc[31:0]);
   $pc[31:0] = (>>1$next_pc);
   
   $br_tgt_pc[31:0] = $pc + $imm;
   $jal_tgt_pc[31:0] = $src1_value + $imm;
   
   `READONLY_MEM($pc, $$instr[31:0]);
   
   // Instr type decoding
   // R, I, S, B, U, J
   $is_r_instr = $instr[6:2] ==  5'b01011 ||
                 $instr[6:2] ==? 5'b011x0 ||
                 $instr[6:2] ==  5'b10100;

   $is_i_instr = $instr[6:2] ==? 5'b0000x ||
                 $instr[6:2] ==? 5'b001x0 ||
                 $instr[6:2] ==  5'b11001;

   $is_s_instr = $instr[6:2] ==? 5'b0100x;

   $is_b_instr = $instr[6:2] ==  5'b11000;

   $is_u_instr = $instr[6:2] ==? 5'b0x101;

   $is_j_instr = $instr[6:2] ==  5'b11011;
   
   // Instr field decoding
   $rs2[4:0]    = $instr[24:20];
   $rs1[4:0]    = $instr[19:15];
   $funct3[2:0] = $instr[14:12];
   $rd[4:0]     = $instr[11:7];
   $opcode[6:0] = $instr[6:0];
   
   // Pad with sign extension and then concatenate remaining bitfields
   $imm[31:0]   = $is_i_instr ? { {21{$instr[31]}}, $instr[30:20]} :
                  $is_s_instr ? { {21{$instr[31]}}, $instr[30:25], $instr[11:7] } :
                  $is_b_instr ? { {20{$instr[31]}}, $instr[7], $instr[30:25], $instr[11:8], 1'b0}    :
                  $is_u_instr ? { $instr[31:12] , 12'b0 } :
                  $is_j_instr ? { {12{$instr[31]}}, $instr[19:12], $instr[20], $instr[30:21], 1'b0 } :
                  32'b0; // default
   
   $rs2_valid    = $is_r_instr || $is_s_instr || $is_b_instr;
   $rs1_valid    = $is_r_instr || $is_i_instr || $is_s_instr || $is_b_instr;
   $funct3_valid = $is_r_instr || $is_i_instr || $is_s_instr || $is_b_instr;
   $rd_valid     = ($is_r_instr || $is_i_instr || $is_u_instr || $is_j_instr);
   $opcode_valid = 1; //always true
   $imm_valid    = $is_i_instr || $is_s_instr ||
                   $is_b_instr || $is_u_instr || $is_j_instr;
   
   `BOGUS_USE($rs2 $rs2_valid $rs1 $rs1_valid $funct3 $funct3_valid $rd $rd_valid $opcode $opcode_valid $imm_valid);
   
   //instruction decoding
   $dec_bits[10:0] = { $instr[30], $funct3[2:0], $opcode[6:0] };
   $is_lui  = $dec_bits ==? 11'bx_xxx_0110111;
   $is_auipc = $dec_bits ==? 11'bx_xxx_0010111;
   $is_jal  = $dec_bits ==? 11'bx_xxx_1101111;
   $is_jalr = $dec_bits ==? 11'bx_000_1100111;
   $is_beq  = $dec_bits ==? 11'bx_000_1100011;
   $is_bne  = $dec_bits ==? 11'bx_001_1100011;
   $is_blt  = $dec_bits ==? 11'bx_100_1100011;
   $is_bge  = $dec_bits ==? 11'bx_101_1100011;
   $is_bltu = $dec_bits ==? 11'bx_110_1100011;
   $is_bgeu = $dec_bits ==? 11'bx_111_1100011;
   $is_load = $dec_bits  ==? 11'bx_xxx_0000011; //generalized load by opcode
   $is_addi = $dec_bits  ==? 11'bx_000_0010011;
   $is_slti = $dec_bits  ==? 11'bx_010_0010011;
   $is_sltiu = $dec_bits ==? 11'bx_011_0010011;
   $is_xori = $dec_bits  ==? 11'bx_100_0010011;
   $is_ori = $dec_bits   ==? 11'bx_110_0010011;
   $is_andi = $dec_bits  ==? 11'bx_111_0010011;
   $is_slli = $dec_bits  ==  11'b0_001_0010011;
   $is_srli = $dec_bits  ==  11'b0_101_0010011;
   $is_srai = $dec_bits  ==  11'b1_101_0010011;
   $is_add  = $dec_bits  ==  11'b0_000_0110011;
   $is_sub  = $dec_bits  ==  11'b1_000_0110011;
   $is_sll  = $dec_bits  ==  11'b0_001_0110011;
   $is_slt  = $dec_bits  ==  11'b0_010_0110011;
   $is_sltu = $dec_bits  ==  11'b0_011_0110011;
   $is_xor  = $dec_bits  ==  11'b0_100_0110011;
   $is_srl  = $dec_bits  ==  11'b0_101_0110011;
   $is_sra  = $dec_bits  ==  11'b1_101_0110011;
   $is_or   = $dec_bits  ==  11'b0_110_0110011;
   $is_and  = $dec_bits  ==  11'b0_111_0110011;
   
   //branch taken logic
   $taken_br =
      $is_beq ? $src1_value == $src2_value :
      $is_bne ? $src1_value != $src2_value :
      $is_blt ? ($src1_value <  $src2_value)  ^ ($src1_value[31] != $src2_value[31]) :
      $is_bge ? ($src1_value >=  $src2_value) ^ ($src1_value[31] != $src2_value[31]) :
      $is_bltu ? $src1_value < $src2_value :
      $is_bgeu ? $src1_value >= $src2_value:
      1'b0;

   // set if less than results
   $sltu_result[31:0]  = {31'b0, $src1_value < $src2_value};
   $sltiu_result[31:0] = {31'b0, $src2_value < $imm};
   
   // Shift Right Arith.
   // sign-ext src1
   $sext_src1[63:0] = { {32{$src1_value[31]}}, $src1_value };
   //64-bit sign-extd results ready for truncation
   $sra_result[63:0] = $sext_src1 >> $src2_value[4:0];
   $srai_result[63:0] = $sext_src1 >> $imm[4:0];

   // ALU  -> result
   $result[31:0] =
   
      $is_lui   ? { $imm[31:12], 12'b0 } :
      $is_auipc ? $pc + $imm  :
      $is_jal   ? $pc + 32'd4 :
      $is_jalr  ? $pc + 32'd4 :
      //$is_beq   ? 
      //$is_bne  = $dec_bits ==? 11'bx_001_1100011;
      //$is_blt  = $dec_bits ==? 11'bx_100_1100011;
      //$is_bge  = $dec_bits ==? 11'bx_101_1100011;
      //$is_bltu = $dec_bits ==? 11'bx_110_1100011;
      //$is_bgeu = $dec_bits ==? 11'bx_111_1100011;
      $is_load  ? $src1_value + $imm : //generalized load by opcode
      $is_addi  ? $src1_value + $imm :
      $is_slti  ? ( ( $src1_value[31] == $imm[31]) ?
                     $sltu_result  : {31'b0, $src1_value[31]} ):
      $is_sltiu ? ( ( $src1_value[31] == $imm[31]) ?
                     $sltiu_result : {31'b0, $src1_value[31]} ):
      $is_xori  ? $src1_value ^ $imm :
      $is_ori   ? $src1_value | $imm :
      $is_andi  ? $src1_value & $imm :
      $is_slli  ? $src1_value << $imm[5:0] :
      $is_srli  ? $src1_value >> $imm[5:0] :
      $is_srai  ? $srai_result[31:0] :
      $is_add   ? $src1_value + $src2_value :
      $is_sub   ? $src1_value - $src2_value :
      $is_sll   ? $src1_value << $src2_value[4:0] :
      $is_slt   ? ( ( $src1_value[31] == $src2_value[31]) ?
                     $sltu_result : {31'b0, $src1_value[31]}):
      $is_sltu  ? $sltu_result[31:0]        :
      $is_xor   ? $src1_value ^ $src2_value :
      $is_srl   ? $src1_value >> $src2_value[4:0] :
      $is_sra   ? $sra_result[31:0]         :
      $is_or    ? $src1_value | $src2_value :
      $is_and   ? $src1_value & $src2_value :
      $is_s_instr ? $src1_value + $imm      :
      32'b0;

      
   // Assert these to end simulation (before Makerchip cycle limit).
   m4+tb()
   *failed = *cyc_cnt > M4_MAX_CYC;
   // replace wr_data with alu $result
   
   $rf_wr_en = $rd_valid && ( $rd[4:0] != 5'b0 );
   $rf_wr_data[31:0] = $is_load ? $dmem_rd_data : $result;
   $dmem_wr_en = $is_s_instr;
   $dmem_rd_en = $is_load;
   $dmem_wr_data[31:0] = $src2_value; // from alu-> is_s_inst
   $dmem_addr[4:0] = $result[6:2]; // calculated by alu
   $ld_data[31:0] = $dmem_rd_data[31:0];
   //$dmem_rd_data = // rd <= Dmem[add]
   m4+rf(32, 32, $reset, $rf_wr_en, $rd[4:0], $rf_wr_data[31:0], $rs1_valid, $rs1[4:0], $src1_value, $rs2_valid, $rs2[4:0], $src2_value)
   m4+dmem(32, 32, $reset, $dmem_addr[4:0], $dmem_wr_en, $dmem_wr_data[31:0], $dmem_rd_en, $dmem_rd_data)
   //m4+rf(32, 32, $reset, $wr_en, $wr_index[4:0], $wr_data[31:0], $rd1_en, $rd1_index[4:0], $rd1_data, $rd2_en, $rd2_index[4:0], $rd2_data)
   //m4+dmem(32, 32, $reset, $addr[4:0], $wr_en, $wr_data[31:0], $rd_en, $rd_data)
   m4+cpu_viz()
\SV
   endmodule