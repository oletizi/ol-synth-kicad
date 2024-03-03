SHELL := zsh
#PCBS := $(wildcard ol-synth-teensy-board/*.kicad_pcb)
PCBS := $(shell echo src/**/*.kicad_pcb)
GERBERS_FRONT := $(addprefix build/,$(addsuffix -F_Cu.gbr,$(basename $(PCBS))))
GERBERS_BACK := $(addprefix build/,$(addsuffix -B_Cu.gbr,$(basename $(PCBS))))
GERBERS_EDGE_CUTS := $(addprefix build/,$(addsuffix -Edge_Cuts.gbr,$(basename $(PCBS))))
GERBERS_ALL := $(GERBERS_FRONT) $(GERBERS_BACK) $(GERBERS_EDGE_CUTS)
DXF := $(addprefix build/,$(addsuffix .dxf,$(basename $(PCBS))))
STEP := $(addprefix build/,$(addsuffix .step,$(basename $(PCBS))))
GCODE := $(addsuffix _front.ngc,$(basename $(GERBERS_FRONT)))

LAYERS := F.Cu,B.Cu,F.Silkscreen,B.Silkscreen,Edge.Cuts

kicad := /Applications/KiCad/KiCad.app/Contents/MacOS/kicad-cli
pcb2gcode := pcb2gcode

# ENGRAVING
MILL_DIAMETERS := .1
ISOLATION_WIDTH := .1
ZWORK := -0.2
MILL_FEED := 150
MILL_VERTFEED := 100
MILL_SPEED := 5600
ZSAFE := 5
ZCHANGE := 5
ZCUT := -1.1

# HOLES
ZDRILL := -1.1
DRILL_FEED := 100
DRILL_SPEED := 5600
MILLDRILL_DIAMETER := 1

# Edge Cuts
CUT_FEED := 150
CUT_INFEED := 100
CUT_SPEED := 5600
CUTTER_DIAMETER := 2

.PHONY := clean pcbs gcode

all: gcode-post dxf step

xgcode: SHELL=zsh
xgcode: gerbers $(GCODE)

%_front.ngc:%.gbr
	echo "Render gcode: $@ $^"; \
	gbr=$^; \
	base=$${gbr/-F_Cu.gbr}; \
	echo "base $$base"; \
	$(pcb2gcode) \
		--ignore-warnings \
		--zero-start \
		--metric=1 \
		--metricoutput=1 \
		--nom6=1 \
		--basename $$gbr:t:r \
		--output-dir $$gbr:h \
		--front $$gbr \
		--back $${base}-B_Cu.gbr \
		--mirror-yaxis 1 \
		--outline $${base}-Edge_Cuts.gbr \
		--mill-diameters=$(MILL_DIAMETERS) \
		--isolation-width=$(ISOLATION_WIDTH) \
		--zwork $(ZWORK) \
		--mill-feed $(MILL_FEED) \
		--mill-vertfeed $(MILL_VERTFEED) \
		--mill-speed $(MILL_SPEED) \
		--zsafe $(ZSAFE) \
		--zchange $(ZCHANGE) \
		--drill $${base}.drl \
		--drill-side front \
		--zdrill $(ZDRILL) \
		--zmilldrill $(ZDRILL) \
		--zcut $(ZCUT) \
		--min-milldrill-hole-diameter $(MILLDRILL_DIAMETER) \
		--milldrill-diameter $(MILLDRILL_DIAMETER) \
		--milldrill-output $${base}-milldrill.ngc \
		--drill-feed $(DRILL_FEED) \
		--drill-speed $(DRILL_SPEED) \
        --cut-feed $(CUT_FEED) \
        --cut-infeed $(CUT_INFEED) \
        --cut-speed $(CUT_SPEED) \
        --cutter-diameter $(CUTTER_DIAMETER) \
		;
drl:
	./drl2ngc ~/work/ol-synth-kicad/build/src/ol-synth-midi-board/ol-synth-midi-board.drl 0.0393 50 50 100 1 -0.0393 out.ngc;
gcode-post: xgcode
	for gc in build/**/*.ngc; do \
  		echo "Postprocessing: $$gc"; \
		sed -i -e "s/^\(G04.*\)/\(Suppressed: \1\)/g" $$gc; \
		sed -i -e "s/^\(G64.*\)/\(Suppressed: \1\)/g" $$gc; \
	done; \

gerbers: $(GERBERS_ALL)
build/%-F_Cu.gbr: %.kicad_pcb
	echo "Generate gerbers: $@ from $^ with $(kicad)"
	mkdir -p $(dir $@)
	$(kicad) pcb export gerbers --output $(dir $@) --layers $(LAYERS) --no-protel-ext --no-x2 $^
	$(kicad) pcb export drill --drill-origin plot -u mm --output $(dir $@) $^

dxf: $(DXF)
build/%.dxf: %.kicad_pcb
	echo "Generate dfx: $@ from $^ with $(kicad)"
	mkdir -p $(dir $@)
	$(kicad) pcb export dxf --layers $(LAYERS) --output $@ "$^"

step: $(STEP)
build/%.step: %.kicad_pcb
	echo "Generate step: $0 from $^ with $(kicad)"
	mkdir -p $(dir $@)
	$(kicad) pcb export step --output $@ --force --include-tracks --include-zones "$^"

pcbs: $(PCBS)
	echo "PCBS: $(PCBS)"

clean:
	rm -rf build/*