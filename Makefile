PCBS := $(wildcard ol-synth-teensy-board/*.kicad_pcb)
GERBERS_FRONT := $(addprefix build/,$(addsuffix -F_Cu.gbr,$(basename $(PCBS))))
GERBERS_BACK := $(addprefix build/,$(addsuffix -B_Cu.gbr,$(basename $(PCBS))))
GERBERS_EDGE_CUTS := $(addprefix build/,$(addsuffix -Edge_Cuts.gbr,$(basename $(PCBS))))
GERBERS_ALL := $(GERBERS_FRONT) $(GERBERS_BACK) $(GERBERS_EDGE_CUTS)
GCODE := $(addsuffix .nc,$(basename $(GERBERS_FRONT)))

LAYERS := F.Cu,B.Cu,F.Silkscreen,B.Silkscreen,Edge.Cuts

kicad := /Applications/KiCad/KiCad.app/Contents/MacOS/kicad-cli
pcb2gcode := pcb2gcode

MILL_DIAMETERS := 1
ISOLATION_WIDTH := 1
ZWORK := -0.1
MILL_FEED := 200
MILL_VERTFEED := 50
MILL_SPEED := 5600
ZSAFE := 10
ZCHANGE := 10


.PHONY := clean pcbs gcode

all: gcode

thingy:
	echo "GCODE: $(GCODE)"

gcode: SHELL:=zsh
gcode: gerbers
	for gbr in build/**/*F_Cu.gbr; do \
  		echo "thingy 1 $$gbr:r"; \
  		base=$${gbr/-F_Cu.gbr}; \
  		echo "base $$base"; \
		$(pcb2gcode) \
			--metric \
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
			--zsafe $(ZSAFE) \
			--zchange $(ZCHANGE); \
  	done

#
#	for x in $(PCBS); do \
#  		echo "   Boardz: $$x" \
#	done


gerbers: $(GERBERS_ALL)

build/%-F_Cu.gbr: %.kicad_pcb
	echo "Generate gerbers: $@ from $^ with $(kicad)"
	mkdir -p $(dir $@)
	$(kicad) pcb export gerbers --output $(dir $@) --layers $(LAYERS) --no-protel-ext $^

pcbs: $(PCBS)
	echo "PCBS: $(PCBS)"

clean:
	rm -rf build/*