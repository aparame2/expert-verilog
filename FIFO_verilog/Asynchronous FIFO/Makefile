################################################################################
################ Makefile Definitions
################################################################################

# this line enables a local Makefile to override values of the main makefile
-include Makefile.local

# Machine Name
M_HOST := $(shell hostname)
DESIGN_HOME ?= $(dir $(lastword $(MAKEFILE_LIST)))
$(warning WARNING DESIGN_HOME set to $(DESIGN_HOME)) 


# Must have a pointer to design compiler
ifndef SYNOPSYS
  $(error ERROR SYNOPSYS environment variable is undefined )
endif


############# For Genesis2 ##############
#########################################
# tile is the top of the pre-processed hierarchy

# Title of the desired top synthesis module
MODULE_NAME ?= dff
MOD_VER_SRC ?= $(MODULE_NAME).v

# The top module for simulation and generatin is top_$MOD
TOP_MODULE := top_$(MODULE_NAME)

# list src folders and include folders
GENESIS_SRC := 	-srcpath ./			   \
		-srcpath $(DESIGN_HOME)/primitives \
		-srcpath $(DESIGN_HOME)/rtl        \
		-srcpath $(DESIGN_HOME)/verif

GENESIS_INC := 	-incpath ./			   \
		-incpath $(DESIGN_HOME)/rtl        \
		-incpath $(DESIGN_HOME)/verif

# vpath directive tells where to search for *.vp and *.vph files
vpath 	%.vp $(DESIGN_HOME)/rtl $(DESIGN_HOME)/verif $(DESIGN_HOME)/primitives
vpath 	%.vph $(DESIGN_HOME)/rtl $(DESIGN_HOME)/verif $(DESIGN_HOME)/primitives

GENESIS_PRIMITIVES :=	$(notdir $(wildcard $(DESIGN_HOME)/primitives/*.vp))
GENESIS_ENV :=		$(notdir $(wildcard $(DESIGN_HOME)/verif/*.vp))
GENESIS_DESIGN := 	$(notdir $(wildcard $(DESIGN_HOME)/rtl/*.vp))

# 
GENESIS_INPUTS := $(GENESIS_DESIGN) $(GENESIS_PRIMITIVES) $(GENESIS_ENV)
$(warning WARNING GENESIS_INPUTS set to $(GENESIS_INPUTS))



# Header Files
GENESIS_INCLUDES := 	$(wildcard $(DESIGN_HOME)/rtl/*.vph)        \
			$(wildcard $(DESIGN_HOME)/primitives/*.vph) \
			$(wildcard $(DESIGN_HOME)/verif/*.vph)

# debug level
GENESIS_DBG_LEVEL := 3

# List of generated verilog files
GENESIS_VLOG_LIST := genesis_vlog.vf

# Input xml configuration
GENESIS_CFG_XML ?= config.xml

# xml hierarchy file
GENESIS_HIERARCHY := $(MODULE_NAME).xml

# For more Genesis parsing options, type 'Genesis2 -help'
#        [-parse]                    ---   should we parse input file to generate perl modules?
#        [-sources|srcpath dir]      ---   Where to find source files
#        [-includes|incpath dir]     ---   Where to find included files
#        [-input file1 .. filen]     ---   List of top level files
#                                    ---   The default is STDIN, but some functions
#                                    ---   (such as "for" or "while")
#                                    ---   may not work properly.
#        [-perl_modules modulename]  ---   Additional perl modules to load
GENESIS_PARSE_FLAGS := 	-parse \
			$(GENESIS_SRC) \
			$(GENESIS_INC) \
			-input $(GENESIS_INPUTS)

# For more Genesis parsing options, type 'Genesis2 -help'
#        [-generate]                 ---   should we generate a verilog hierarchy?
#        [-top topmodule]            ---   Name of top module to start generation from
#        [-depend filename]          ---   Should Genesis2 generate a dependency file list? (list of input files)
#        [-product filename]         ---   Should Genesis2 generate a product file list? (list of output files)
#        [-hierarchy filename]       ---   Should Genesis2 generate a hierarchy representation tree?
#        [-xml filename]             ---   Input XML representation of definitions
GENESIS_GEN_FLAGS :=	-generate  						\
			-top $(TOP_MODULE)					\
			-synthtop $(TOP_MODULE).my_$(MODULE_NAME) \
			-depend depend.list					\
			-product $(GENESIS_VLOG_LIST)				\
			-hierarchy $(GENESIS_HIERARCHY)                		\
			-xml $(GENESIS_CFG_XML)

ifneq ($(strip $(GENESIS_PARAMS)),)
  GENESIS_GEN_FLAGS	:= $(GENESIS_GEN_FLAGS) -parameter $(GENESIS_PARAMS)
  $(warning WARNING: GENESIS_PARAMS set to $(GENESIS_PARAMS))
endif


############### For Verilo (VCS) ################
#################################################


VCS_CC ?= gcc

COMPILER := vcs

EXECUTABLE := ./simv

EXECUTABLE_GATE := ./simv_gate

VERILOG_ENV :=		 

VERILOG_DESIGN :=	

VERILOG_FILES :=				

VERILOG_LIBS :=	

VERILOG_DC_ROOT :=  $(SYNOPSYS)

VERILOG_DW_SIM_DIR := $(VERILOG_DC_ROOT)/dw/sim_ver/

VERILOG_GT_SIM_DIR := $(VERILOG_DC_ROOT)/packages/gtech/src_ver/

#GATE_VER := /cad/synopsys_cell_lib/SAED32_EDK/lib/stdcell_hvt/verilog/saed32nm_hvt.tv
GATE_VER := /afs/asu.edu/class/e/e/e/eee333/2016_01_SPR-Brun/saed32nm_hvt.tv


# "-sverilog" enables system verilog
# "+lint=PCWM" enables linting error messages
# "+libext+.v" specifies that library files (imported by the "-y" directive) ends with ".v"
# "-notice" used to get details when ports are coerced to inout
# "-full64" for 64 bit compilation and simulation
# "+v2k" for verilog 2001 constructs such as generate
# "-timescale=1ns/1ns" sets the time unit and time precision for the entire design
# "+noportcoerce" compile-time option to shut off the port coercion for the entire design
# "-top topModuleName" specifies the top module
# "-f verilogFiles.list" specifies a file that contains list of verilog files to compile


SIM_CLK_PERIOD ?= 2
VCS_SAIF_FILE ?= $(MODULE_NAME)_act.saif

VERILOG_LINT_FLAGS :=   +lint=PCWM		\
			+lint=UV		\
			+lint=IRIMW		\
			+lint=FIAAS		\
			+lint=CAWM-L		\
			+lint=ERASM-L		\
			+lint=TFIPC-L           \
			+lint=all		\
			-ova_lint		\
			-ova_lint_magellan	\
			-notice			\
			+warn=all

VERILOG_COMPILE_FLAGS := 	$(VERILOG_LINT_FLAGS)                           \
				-sverilog 					\
				+cli 						\
				+memcbk 					\
				+libext+.v					\
				+libext+.inc					\
				-full64						\
				+v2k						\
				-debug_pp					\
				-timescale=1ns/1ns				\
				+noportcoerce         				\
				-diag timescale                                 \
				-lca						\
				-ld $(VCS_CC) 					\
				-debug_pp					\
				-top $(TOP_MODULE)				\
				-parallel+saif=1				\
				+vcs+saif_libcell

VERILOG_SRCS :=	-f $(GENESIS_VLOG_LIST) 			\
				 $(VERILOG_FILES) $(VERILOG_LIBS)

VERILOG_GATE_SRCS := genesis_verif/*.v $(GATE_VER) phys_$(MODULE_NAME)/$(MODULE_NAME).v


# "+vpdbufsize+100" limit the internal buffer to 100MB (forces flushing to disk)
# "+vpdports" Record information about ports (signal/in/out)
# "+vpdfileswitchsize+1000" limits the wave file to 1G (then switch to next file)
VERILOG_SIMULATION_FLAGS := 	$(VERILOG_SIMULATION_FLAGS) 			\
				-l $(EXECUTABLE).log				\
				+vpdbufsize+100					\
				+vcs+lic+wait					\
				+vpdfileswitchsize+100				\
				+VCS_SAIF_FILE=$(VCS_SAIF_FILE)                 \
				+clk_period=$(SIM_CLK_PERIOD)

##### END OF FLAGS FOR SYNOPSYS COMPILATION ####




############################################                                                               
# Synthesis Compiler Flags                                                                                 
############################################                                                               

SYN := dc_shell-xg-t -64bit

CLK_PERIOD ?= 1.0
COMB_MODE ?= 0



################################################################################
################ Makefile Rules
################################################################################
#default rule: 
all: $(EXECUTABLE)

# Genesis2 rules:
#####################
# This is the rule to activate Genesis2 generator to generate verilog 
# files (_unqN.v) from the genesis (.vp) program.
# Use "make GEN=<genesis2_gen_flags>" to add elaboration time flags
$(GENESIS_VLOG_LIST): $(GENESIS_INPUTS) $(GENESIS_CFG_XML)
	@echo ""
	@echo Making $@ because of $?
	@echo ==================================================
	Genesis2 $(GENESIS_PARSE_FLAGS) $(GENESIS_GEN_FLAGS)

# phony rules for verilog generation process
.PHONY: gen genesis_clean
gen: $(GENESIS_VLOG_LIST)

genesis_clean:
	@echo ""
	@echo Cleanning previous runs of Genesis
	@echo ===================================
	if test -f "genesis_clean.cmd"; then 	\
		$(DESIGN_HOME)/genesis_clean.cmd;	\
	fi
	\rm -f genesis_vlog.vf

# VCS rules:
#####################
# compile rules:
# use "make COMP=+define+<compile_time_flag[=value]>" to add compile time flags
.PHONY: comp
comp: $(EXECUTABLE)

$(EXECUTABLE):	$(VERILOG_FILES) $(GENESIS_VLOG_LIST)
	@echo ""
	@echo Making $@ because of $?
	@echo ==================================================
	$(COMPILER)  $(VERILOG_COMPILE_FLAGS) $(VERILOG_SRCS) $(COMP) | tee comp.log


# Simulation rules:
#####################
# use "make run RUN=+<runtime_flag[=value]>" to add runtime flags
.PHONY: run run_wave
run_wave: vcdplus.vpd
vcdplus.vpd: $(EXECUTABLE)
	@echo ""
	@echo Now Running $(EXECUTABLE) with wave
	@echo ==================================================
	$(EXECUTABLE) +wave $(VERILOG_SIMULATION_FLAGS) $(RUN)

viz: vcdplus.vpd
	dve -full64 -vpd vcdplus.vpd

simLog.txt: $(EXECUTABLE)
	@echo ""
	@echo Now Running $(EXECUTABLE)
	@echo ==================================================
	$(EXECUTABLE) $(VERILOG_SIMULATION_FLAGS) $(RUN) | tee simLog.txt

run: simLog.txt

# Synthesis Rules:
#####################
synLog.txt: simLog.txt
	mkdir phys_$(MODULE_NAME)
	cd phys_$(MODULE_NAME); $(SYN) -x " set DESIGN {$(MODULE_NAME)} ; set SYN_TOP_NAME $(TOP_MODULE) ; set SYN_INST_NAME my_$(MODULE_NAME) ; set VERILOG [glob ../genesis_synth/*.v] ; set CLK_PERIOD $(CLK_PERIOD) ; set COMB $(COMB_MODE) ; source -echo -verbose ../syn.tcl " | tee ../syn_$(MODULE_NAME).log
#	dc_shell-xg-t -64bit -topo -x "define_design_lib MULT -path \"MULT\" ; set synthetic_library [list  dw_foundation.sldb]  ; set search_path [list ./ ./genesis_synth ./genesis_verif] ; analyze -library MULT -format sverilog {CSA_unq1.v  CSA_unq2.v  wallace_unq1.v}; elaborate wallace_unq1 -architecture verilog -library MULT ; exit " | tee synLog.txt 

syn: synLog.txt



# VCS Gate rules:
#####################
# compile rules:
# use "make COMP=+define+<compile_time_flag[=value]>" to add compile time flags
.PHONY: comp_gate
comp_gate: $(EXECUTABLE_GATE)

$(EXECUTABLE_GATE): synLog.txt
	@echo ""
	@echo Making $@ because of $?
	@echo ==================================================
	-mv simv.daidir simv.daidir_tmp
	-mv $(EXECUTABLE)  tmpExecutable
	$(COMPILER)  $(VERILOG_COMPILE_FLAGS) $(VERILOG_GATE_SRCS) $(COMP) | tee comp_gate.log
	-mv $(EXECUTABLE) $(EXECUTABLE_GATE)
	-mv simv.daidir simv_gate.daidir
	-mv tmpExecutable $(EXECUTABLE) 
	-mv simv.daidir_tmp simv.daidir 

# Gate Simulation rules:
#####################
# use "make run RUN=+<runtime_flag[=value]>" to add runtime flags
.PHONY: run_gate run_gate_wave
run_gate_wave: vcdplus_gate.vpd
vcdplus_gate.vpd: $(EXECUTABLE_GATE)
	@echo ""
	@echo Now Running $(EXECUTABLE_GATE) with wave
	@echo ==================================================
	-mv vcdplus.vpd tmpvcd
	$(EXECUTABLE_GATE) +wave $(VERILOG_SIMULATION_FLAGS) $(RUN)
	-mv vcdplus.vpd vcdplus_gate.vpd
	-mv tmpvcd vcdplus.vpd 

viz_gate: vcdplus_gate.vpd
	dve -full64 -vpd vcdplus_gate.vpd

simLogGate.txt: $(EXECUTABLE_GATE)
	@echo ""
	@echo Now Running $(EXECUTABLE_GATE)
	@echo ==================================================
	$(EXECUTABLE_GATE) $(VERILOG_SIMULATION_FLAGS) $(RUN) | tee simLogGate.txt

run_gate: simLogGate.txt



# Cleanup rules:
#####################
.PHONY: clean cleanall 
clean: genesis_clean
	@echo ""
	@echo Cleanning old files, objects, logs and garbage
	@echo ==================================================
	\rm -rf $(EXECUTABLE) ./simv_iv
	\rm -rf $(EXECUTABLE_GATE)
	\rm -rf DVEfiles
	\rm -rf default.svf
	\rm -rf csrc
	\rm -rf *.daidir
	\rm -rf *.log
	\rm -rf *.pvl
	\rm -rf *.syn
	\rm -rf *.mr
	\rm -rf *.pvk
	\rm -rf *.flc
	\rm -rf ucli.key
	\rm -rf simLog*
	\rm -rf synLog*
	\rm -rf *~ top.saif
	\rm -rf MULT
	\rm -rf test.vcd
	\rm -rf $(EXECUTABLE).*
	\rm -rf phys_*

cleanall: clean
	\rm -rf DVE*
	\rm -rf vcdplus.vpd
