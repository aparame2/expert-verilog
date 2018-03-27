module hazard_unit(
input logic [4:0] dst_ex,dst_mem,dst_wb,src_zero_addr,src_one_addr,
input logic [31:0]src_zero_id,src_one_id,
input logic regwrite_ex,regwrite_mem,regwrite_wb,
input logic [31:0] alu_out_ex,mem_data,wb_out,
output logic [31:0] src_zero_frm_funit,src_one_frm_funit
);

logic [1:0]forward_ctrl_srczero,forward_ctrl_srcone;
/////////////////////////////////////mux_src0////////////////
always_comb
	begin
		case(forward_ctrl_srczero)

					
		2'b01:src_zero_frm_funit=alu_out_ex;
				
		2'b10:src_zero_frm_funit=mem_data;
				
		2'b11:src_zero_frm_funit=wb_out;
          
        default:src_zero_frm_funit=src_zero_id;
				
		endcase
	end
//////////////////////////////////mux_src1////////////////
  always_comb
	begin
		case(forward_ctrl_srcone)
						
		2'b01:src_one_frm_funit=alu_out_ex;
				
		2'b10:src_one_frm_funit=mem_data;
				
		2'b11:src_one_frm_funit=wb_out;
        default:src_one_frm_funit=src_one_id;
				
		endcase
	end
////////////////////////hazard_unit/////////////////////

always_comb
begin
	if((src_zero_addr!=0)&&(src_zero_addr == dst_ex)&&(regwrite_ex))
	forward_ctrl_srczero=2'b01;
	else if ((src_zero_addr!=0)&&(src_zero_addr == dst_mem)&&(regwrite_mem))
	forward_ctrl_srczero=2'b10;
	else if ((src_zero_addr!=0)&&(src_zero_addr == dst_wb)&&(regwrite_wb))
	forward_ctrl_srczero=2'b11;
	else
	forward_ctrl_srczero=2'b00;
end

always_comb
begin
	if((src_one_addr!=0)&&(src_one_addr == dst_ex)&&(regwrite_ex))
	forward_ctrl_srcone=2'b01;
	else if ((src_one_addr!=0)&&(src_one_addr == dst_mem)&&(regwrite_mem))
	forward_ctrl_srcone=2'b10;
	else if ((src_one_addr!=0)&&(src_one_addr == dst_wb)&&(regwrite_wb))
	forward_ctrl_srcone=2'b11;
	else
	forward_ctrl_srcone=2'b00;
end

endmodule
