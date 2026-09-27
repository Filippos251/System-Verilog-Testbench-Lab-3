###############################################################################
.DEFAULT_GOAL:=help
###############################################################################
SHELL=/bin/bash
###############################################################################
help: ## This help message
	@echo -e ""
	@echo -e " SystemVerilog Lab 4  targets"
	@echo -e "-------------------------------------------------"
	@echo -e " Usage:"
	@echo -e "     make $(GREEN)<target>$(NC)"
	@echo -e ""
	@echo -e " Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS =":.*?##"}; \
	{printf "  $(GREEN)%-25s$(NC)%s\n", $$1, $$2}'
	@echo -e ""
	@echo -e " Variables:"
	@echo -e "     WAVES=1                dumps waveforms during simulation"
	@echo -e "     CVRG=1                 generates coverage data"
	@echo -e "     LINT=1                 linting check during compile"
	@echo -e "     DBG=1                  simulation run in gui"
	@echo -e ""
	@echo -e "  example:"
	@echo -e "     make all WAVES=1"
	@echo ""
###############################################################################
.PHONY: help
###############################################################################
DBG?=0
CVRG?=0

# Enables waves dumping
###############################################################################
ifeq ($(WAVES),1)
    VCSWAVES=-debug_all +vcs+vcdpluson
    VCSDUMP=+vpdfile+./Waves/waves.vpd
else
    VCSWAVES=
    VCSDUMP=
endif

# Enables Coverage Reporting
###############################################################################
ifeq ($(CVRG),1)
    VCSCVRG=-cm line+cond+tgl+fsm+branch+assert -cm_name test$(TEST)
else
    VCSCVRG=
endif

# Enables Linting/Races Reporting
###############################################################################
ifeq ($(LINT),1)
    VCSLINT=+lint=all -race=all
else
    VCSLINT=
endif

# Runs simulation in debug mode
###############################################################################
ifeq ($(DBG),1)
    VCSDBG=-debug_all -gui
else
    VCSDBG=
endif
###############################################################################
# VCS compile,run and system calls options
###############################################################################
VCSCOMP?=$(VCSSYS) $(VCSWAVES) $(VCSDBG) $(VCSLINT) $(VCSCVRG)
VCSRUN?=$(VCSDUMP) -l reports/simrun.log
###############################################################################
all: ## Compiles & runs examples
	@if [ ! -d Waves   ]; then mkdir Waves; fi
	@if [ ! -d reports ]; then mkdir reports; fi
	vcs -full64 $(VCSCOMP) -sverilog $(INCDIRS) $(INCFILES) -R $(VCSRUN)
###############################################################################
# Program files
###############################################################################
INCFILES=tb/fifo_tb.sv
###############################################################################
# Include directories
###############################################################################
INCDIRS=+incdir+rtl +incdir+tb
###############################################################################
# Top design
###############################################################################
TOP_DESIGN=fifo_tb
###############################################################################
compile: ## Compiles design
	vlogan -full64 $(INCDIRS) -sverilog $(INCFILES)
###############################################################################
.PHONY: compile
###############################################################################
run: ## Runs design
	vcs -full64 -R $(TOP_DESIGN)
###############################################################################
.PHONY: run
###############################################################################
viewWaves: ## Opens simulation waves
	dve -full64 -vpd Waves/waves.vpd
###############################################################################
cviewWaves: simv.vdb ## View Coverage metrics
	dve -full64 -logdir ./work_vcsmx -dir simv.vdb -cov
###############################################################################
.PHONY: dviewWaves
###############################################################################
clean: ## Cleans work directory
	$(RM) -r *.log *.key *.dump *.vpd *.vcd .vcs_lib_lock session.tcl
	$(RM) -r ./simv ./csrc ./simv.daidir ./simv.vdb ./inter.vpd
	$(RM) -r ./AN.DB ./DVEfiles .vlogansetup.args .vlogansetup.env
	$(RM) -r ./reports ./Waves
	$(RM) -r .restartSimSession.tcl.old .synopsys_dve_rebuild.tcl
###############################################################################
.PHONY: clean
###############################################################################
