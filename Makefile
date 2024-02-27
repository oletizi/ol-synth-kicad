PCBS := $(wildcard ol-synth-teensy-board/*.kicad_pcb)
GERBERS_FRONT := $(addprefix build/,$(addsuffix .gbr,$(basename $(PCBS))))
#GERBERS_FRONT := $(addsuffix .gbr,$(basename $(PCBS)))

gerbers: $(GERBERS_FRONT)

build/%.gbr: %.kicad_pcb
	echo "Generate gerbers: $@ from $^"


pcbs: $(PCBS)
	echo "PCBS: $(PCBS)"