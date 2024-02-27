PCBS := $(wildcard ol-synth-teensy-board/*.kicad_pcb)
GERBERS_FRONT := $(addprefix build/,$(addsuffix .gbr,$(basename $(PCBS))))
LAYERS := F.Cu,B.Cu,F.Silkscreen,B.Silkscreen,Edge.Cuts
kicad := /Applications/KiCad/KiCad.app/Contents/MacOS/kicad-cli

.PHONY := clean pcbs

all: gerbers

gerbers: $(GERBERS_FRONT)

build/%.gbr: %.kicad_pcb
	echo "Generate gerbers: $@ from $^ with $(kicad)"
	mkdir -p $(dir $@)
	$(kicad) pcb export gerbers --output $(dir $@)  --layers $(LAYERS) $^

pcbs: $(PCBS)
	echo "PCBS: $(PCBS)"

clean:
	rm -rf build/*