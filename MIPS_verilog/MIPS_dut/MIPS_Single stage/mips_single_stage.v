//mipsCore.vp

module mipsCore 
(

//ICache Ifc
input logic [31:0] iCacheReadData,
output logic [31:0] iCacheReadAddr,

//DCache Ifc
input logic [31:0] dCacheReadData,
output logic [31:0] dCacheWriteData,
output logic [31:0] dCacheAddr,
output logic dCacheWriteEn,
output logic dCacheReadEn,
input logic [31:0] rfReadData_p0,rfReadData_p1,
output logic [4:0] rfReadAddr_p0,rfReadAddr_p1,
output logic rfReadEn_p0,rfReadEn_p1,
output logic [31:0] rfWriteData_p0,
output logic [4:0] rfWriteAddr_p0,
output logic rfWriteEn_p0,

// Globals
input logic clk,
input logic rst

);

  
wire logic [63:0] alu_out;
  
wire logic [31:0] pc_in_wire,pc_out_wire,pc8,imm_addr,alu_src1;
wire logic [31:0] ld_out,str_out,lowmul_out,highmul_out,wb_out;
  
wire logic [4:0] alu_control,regdst0_nz;
  
wire logic [27:0] j_imm;

wire logic divmul,regwrite,regread0,regread1,regdst1,regdst0,alusrc0;
wire logic memread,memtoreg2,memtoreg1,memtoreg0,memwrite;
wire logic beq,bne,blez,bgtz,bltz,bgez,j,jr,lw,sw;


//PC module
//; my $pcm = generate_base("pc","pcm");

`$pcm->instantiate()`  (.clk(clk),
                        .rst(rst),
       			.input_pc(pc_in_wire),
      			.output_pc(pc_out_wire)
    		  	);

assign imm_addr = {{16{iCacheReadData[15]}},{iCacheReadData[15:0]}};
assign j_imm = {2'b0,iCacheReadData[26:0]};
 
  
//pc-nxt module  
//; my $pcnm = generate_base("pcnxt","pcnm");

`$pcnm->instantiate()`  (.pc(pc_out_wire),
          .imm_extend(imm_addr),
          .src0(rfReadData_p0),
          .addr(j_imm),
          .B_sel(b),
          .JR_sel(jr),
          .J_sel(j),
          .pc_nxt(pc_in_wire),
          .pc8(pc8)
         );
 
  assign iCacheReadAddr=pc_out_wire;
  
  assign {rfReadAddr_p0,rfReadAddr_p1}={iCacheReadData[25:21],iCacheReadData[20:16]};

  
//	ID
//; my $idm = generate_base("decoder","idm");

`$idm->instantiate()`  (.instr(iCacheReadData),
            .alu_cntrl(alu_control),
            .divmul(divmul),
            .regwrite(regwrite),
            .regread0(regread0),
            .regread1(regread1),
            .regdst1(regdst1),
            .regdst0(regdst0),
            .alusrc0(alusrc0),
            .memread(memread),
            .memtoreg2(memtoreg2),
            .memtoreg1(memtoreg1),
            .memtoreg0(memtoreg0),
            .memwrite(memwrite),
            .beq(beq),.bne(bne),
            .blez(blez),
            .bgtz(bgtz),
            .bltz(bltz),
            .bgez(bgez),
            .j(j),
            .jr(jr),
            .lw(lw),
            .sw(sw)
           );

assign rfWriteEn_p0=regwrite;

assign dCacheWriteEn=memwrite;
assign dCacheReadEn=memread;
  
assign {rfReadEn_p0,rfReadEn_p1}={regread0,regread1};
  

// branch detetctor //
//; my $bcm = generate_base("Bdetect","bcm");
`$bcm->instantiate()` (.src0(rfReadData_p0),
            .src1(rfReadData_p1),
            .BEQ(beq),
            .BNE(bne),
            .BGTZ(bgtz),
            .BLTZ(bltz),
            .BLEZ(blez),
            .BGEZ(bgez),
            .B_sel(b)
           );

  assign alu_src1 = (alusrc0) ? imm_addr : rfReadData_p1;


//Execution Unit //
//; my $alum = generate_base("exec_unit","alum");

`$alum->instantiate()`  (.alusrc0(rfReadData_p0),
              .alusrc1(alu_src1),
              .shft_amt(iCacheReadData[10:6]),
              .alu_ctrl(alu_control),
              .alu_out(alu_out)
             );
  
  assign dCacheAddr = alu_out[31:0];


//Load_store Module  /
//; my $loadm = generate_base("ldstr","loadm");

`$loadm->instantiate()` (.lw(lw),
           .dch_dat(dCacheReadData),
           .RF_RD_dat(rfReadData_p1),
           .ld_out(ld_out),
           .sw(sw),
           .str_out(str_out)
          );

  assign dCacheWriteData = str_out;
  

//DIVMUL Module  //
//; my $multlatchm = generate_base("divmul","multlatchm");

`$multlatchm->instantiate()`(.alu_out(alu_out),
           .divmul(divmul),
           .wr_data(rfReadData_p0),
           .lowmul_out(lowmul_out),
           .highmul_out(highmul_out)
          );

  
//Write Back Stage  //
//; my $wb_muxm = generate_base("wb","wb_muxm");
  `$wb_muxm->instantiate()` (.pc8(pc8),
         .lowmul(lowmul_out),
         .highmul(highmul_out),
         .alu_out(alu_out[31:0]),
         .ld_out(ld_out),
         .memtoreg0(memtoreg0),
         .memtoreg1(memtoreg1),
         .memtoreg2(memtoreg2),
         .wb_out(wb_out)
        );

assign rfWriteData_p0 = wb_out;

assign regdst0_nz = (|iCacheReadData[15:11]) ? iCacheReadData[15:11] : 5'd31;
assign rfWriteAddr_p0 = ({regdst1,regdst0}==2'b01) ? iCacheReadData[15:11] : ((({regdst1,regdst0}==2'b00) ? iCacheReadData[20:16] : ({regdst1,regdst0}==2'b10) ? 5'd31 : regdst0_nz));

endmodule
