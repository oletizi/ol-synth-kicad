SHELL := zsh
#PCBS := $(wildcard ol-synth-teensy-board/*.kicad_pcb)
PCBS := $(shell echo src/**/*.kicad_pcb)
GERBERS_FRONT := $(addprefix build/,$(addsuffix -F_Cu.gbr,$(basename $(PCBS))))
GERBERS_BACK := $(addprefix build/,$(addsuffix -B_Cu.gbr,$(basename $(PCBS))))
GERBERS_EDGE_CUTS := $(addprefix build/,$(addsuffix -Edge_Cuts.gbr,$(basename $(PCBS))))
GERBERS_ALL := $(GERBERS_FRONT) $(GERBERS_BACK) $(GERBERS_EDGE_CUTS)
GCODE := $(addsuffix _front.ngc,$(basename $(GERBERS_FRONT)))

LAYERS := F.Cu,B.Cu,F.Silkscreen,B.Silkscreen,Edge.Cuts

kicad := /Applications/KiCad/KiCad.app/Contents/MacOS/kicad-cli
pcb2gcode := pcb2gcode

MILL_DIAMETERS := .1
MILLDRILL_DIAMETER := 1
ISOLATION_WIDTH := 1
ZWORK := -0.1
MILL_FEED := 200
MILL_VERTFEED := 200
MILL_SPEED := 5600
ZSAFE := 10
ZCHANGE := 10
ZDRILL := 1.1
DRILL_FEED := 50
DRILL_SPEED := 5600

.PHONY := clean pcbs gcode

all: xgcode

gcode: SHELL:=zsh
gcode: gerbers
	for gbr in build/**/*F_Cu.gbr; do \
  		base=$${gbr/-F_Cu.gbr}; \
  		echo "base $$base"; \
		$(pcb2gcode) \
			--metric 1\
			--basename $$base:t:r \
			--output-dir $$gbr:h \
			--front $$gbr \
			--back $${base}-B_Cu.gbr \
			--mill-diameters=$(MILL_DIAMETERS) \
			--isolation-width=$(ISOLATION_WIDTH) \
			--zwork $(ZWORK) \
			--mill-feed $(MILL_FEED) \
			--mill-vertfeed $(MILL_VERTFEED) \
			--mill-speed $(MILL_SPEED) \
			--outline $$base-Edge_Cuts.gbr \
			--drill $${base}.drl \
			--milldrill-output $${base}-milldrill.ngc \
			--milldrill-diameter ${MILLDRILL_DIAMETER} \
			--zsafe $(ZSAFE) \
			--zchange $(ZCHANGE) \
			--zdrill $(ZDRILL) \
			--zmilldrill $(ZDRILL) \
			--drill-feed $(DRILL_FEED) \
			--drill-speed $(DRILL_SPEED); \
  	done

xgcode: SHELL=zsh
xgcode: gerbers $(GCODE)

%_front.ngc:%.gbr
	echo "Render gcode: $@ $^"; \
	gbr=$^; \
	base=$${gbr/-F_Cu.gbr}; \
	echo "base $$base"; \
	$(pcb2gcode) \
		--metric 1\
		--basename $$gbr:t:r \
		--output-dir $$gbr:h \
		--front $$gbr \
		--back $${base}-B_Cu.gbr \
		--mill-diameters=$(MILL_DIAMETERS) \
		--isolation-width=$(ISOLATION_WIDTH) \
		--zwork $(ZWORK) \
		--mill-feed $(MILL_FEED) \
		--mill-vertfeed $(MILL_VERTFEED) \
		--mill-speed $(MILL_SPEED) \
		--drill $${base}.drl \
		--milldrill-output $${base}-milldrill.ngc \
		--milldrill-diameter ${MILLDRILL_DIAMETER} \
		--zsafe $(ZSAFE) \
		--zchange $(ZCHANGE) \
		--zdrill $(ZDRILL) \
		--zmilldrill $(ZDRILL) \
		--drill-feed $(DRILL_FEED) \
		--drill-speed $(DRILL_SPEED);

gcode-post: xgcode
	prune = "^G04.*"
	for gc in build/**/*.ngc; do \
  		for pat in $$prine; do \
			cmd="sed -i -e s/$$pat/DELETE_ME/g $$gc"; \
			echo $$cmd; \
			$$cmd; \
  		done; \
	done; \

gerbers: $(GERBERS_ALL)

build/%-F_Cu.gbr: %.kicad_pcb
	echo "Generate gerbers: $@ from $^ with $(kicad)"
	mkdir -p $(dir $@)
	$(kicad) pcb export gerbers --output $(dir $@) --layers $(LAYERS) --no-protel-ext $^
	$(kicad) pcb export drill --output $(dir $@) $^

pcbs: $(PCBS)
	echo "PCBS: $(PCBS)"

clean:
	rm -rf build/*