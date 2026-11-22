# Simulation and elaboration entry points for the ECE 369A lab designs.
#
# Requires Icarus Verilog (iverilog/vvp). Vivado is used for synthesis and
# board programming; see README.md.
#
#   make check            Elaborate every processor core and unit testbench
#   make sim LAB=lab04    Compile and run a lab's toplevel_tb
#                         (SIM_TIME_NS bounds the run; default 50000)
#   make unit LAB=lab03   Compile and run a lab's unit testbenches
#   make board LAB=lab05  Elaborate a lab's FPGA wrapper (module top)
#   make clean            Remove build outputs

IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  ?= -g2012 -Wno-portbind -Wno-timescale
BUILD    ?= build
SIM_TIME_NS ?= 50000

lab01 := labs/lab01-instruction-fetch
lab03 := labs/lab03-vbsme-and-datapath
lab04 := labs/lab04-pipelined-datapath
lab05 := labs/lab05-fpga-pipelined-processor
lab06 := labs/lab06-hazard-detection-forwarding
lab07 := labs/lab07-vbsme-on-pipeline

# RTL sources per lab. "core" excludes the board wrapper (top.v).
rtl   = $(wildcard $($(1))/rtl/*.v)
core  = $(filter-out %/top.v,$(call rtl,$(1)))

# Lab 7 is an overlay on Lab 6: its rtl/ holds only the files it replaces.
lab07_overrides := $(notdir $(call rtl,lab07))
lab07_sources   := $(filter-out $(addprefix $(lab06)/rtl/,$(lab07_overrides)),$(call rtl,lab06)) $(call rtl,lab07)

sources = $(if $(filter lab07,$(1)),$(lab07_sources),$(call rtl,$(1)))
cores   = $(filter-out %/top.v,$(call sources,$(1)))
mems    = $(wildcard $($(1))/mem/*.mem)

PROCESSOR_LABS := lab04 lab05 lab06 lab07
UNIT_LABS      := lab01 lab03

LAB ?= lab04

.PHONY: check sim unit board clean

check:
	@status=0; \
	for lab in $(PROCESSOR_LABS); do \
	  $(MAKE) --no-print-directory elab-core-$$lab || status=1; \
	done; \
	for lab in $(UNIT_LABS); do \
	  $(MAKE) --no-print-directory elab-unit-$$lab || status=1; \
	done; \
	exit $$status

elab-core-%:
	@mkdir -p $(BUILD)/$*
	@printf '%-8s core (toplevel) ... ' $*
	@$(IVERILOG) $(IVFLAGS) -s toplevel -o $(BUILD)/$*/core.vvp $(call cores,$*) \
	  > $(BUILD)/$*/core.log 2>&1 && echo ok || { echo FAILED; grep -iE 'error' $(BUILD)/$*/core.log | head -5; exit 1; }

elab-unit-%:
	@mkdir -p $(BUILD)/$*
	@status=0; for tb in $(wildcard $($*)/tb/*_tb.v); do \
	  name=$$(basename $$tb .v); \
	  printf '%-8s %-22s ... ' $* $$name; \
	  if $(IVERILOG) $(IVFLAGS) -s $$name -s sim_timeout -Psim_timeout.LIMIT_NS=$(SIM_TIME_NS) \
	       -o $(BUILD)/$*/$$name.vvp $(call core,$*) $$tb scripts/sim_timeout.v \
	       > $(BUILD)/$*/$$name.log 2>&1; then echo ok; \
	  else echo FAILED; grep -iE 'error' $(BUILD)/$*/$$name.log | head -5; status=1; fi; \
	done; exit $$status

sim:
	@mkdir -p $(BUILD)/$(LAB)
	$(IVERILOG) $(IVFLAGS) -s toplevel_tb -s sim_timeout -Psim_timeout.LIMIT_NS=$(SIM_TIME_NS) \
	  -o $(BUILD)/$(LAB)/toplevel_tb.vvp \
	  $(call cores,$(LAB)) $($(LAB))/tb/toplevel_tb.v scripts/sim_timeout.v
	$(if $(call mems,$(LAB)),cp $(call mems,$(LAB)) $(BUILD)/$(LAB)/)
	cd $(BUILD)/$(LAB) && $(VVP) -n toplevel_tb.vvp

unit: elab-unit-$(LAB)
	@for vvp in $(BUILD)/$(LAB)/*_tb.vvp; do \
	  echo "== $$vvp"; (cd $(BUILD)/$(LAB) && $(VVP) -n $$(basename $$vvp)); \
	done

board:
	@mkdir -p $(BUILD)/$(LAB)
	$(IVERILOG) $(IVFLAGS) -s top -o $(BUILD)/$(LAB)/top.vvp $(call sources,$(LAB))

clean:
	rm -rf $(BUILD)
