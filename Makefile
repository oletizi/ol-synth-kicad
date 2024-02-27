PCBS := $(wildcard ol-synth-teensy-board/*.kicad_pcb)
GERBERS_FRONT := $(addprefix build/,$(addsuffix -F_Cu.gbr,$(basename $(PCBS))))
GERBERS_BACK := $(addprefix build/,$(addsuffix -B_Cu.gbr,$(basename $(PCBS))))
GERBERS_EDGE_CUTS := $(addprefix build/,$(addsuffix -Edge_Cuts.gbr,$(basename $(PCBS))))
GERBERS_ALL := $(GERBERS_FRONT) $(GERBERS_BACK) $(GERBERS_EDGE_CUTS)

LAYERS := F.Cu,B.Cu,F.Silkscreen,B.Silkscreen,Edge.Cuts

kicad := /Applications/KiCad/KiCad.app/Contents/MacOS/kicad-cli
pcb2gcode := pcb2gcode

.PHONY := clean pcbs

all: gcode

gcode: gerbers

%.nc: %.gbl
	echo "Render gcode from $^ with $(pcb2gcode)"

gerbers: $(GERBERS_ALL)

build/%-F_Cu.gbr: %.kicad_pcb
	echo "Generate gerbers: $@ from $^ with $(kicad)"
	mkdir -p $(dir $@)
	$(kicad) pcb export gerbers --output $(dir $@) --layers $(LAYERS) --no-protel-ext $^

pcbs: $(PCBS)
	echo "PCBS: $(PCBS)"

clean:
	rm -rf build/*