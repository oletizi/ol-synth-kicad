
#PCBS := $(basename $(wildcard ol-synth-teensy-board/*.kicad_pcb)-B_CU.gbr)
PCBS := $(wildcard ol-synth-teensy-board/*.kicad_pcb)
GERBERS := $(addsuffix -F_Cu.gbr,$(basename $(PCBS)))

thingy:
	echo "PCBS: $(PCBS)"
	echo "GERBERS: $(GERBERS)"

%-F_Cu.gbr: %.kicad_pcb
	echo "Generate gerber file"

pcbs: $(PCBS)
	echo "PCBS: $(PCBS)"

gerbers: $(GERBERS)
	echo "GERBERS: $(GERBERS)"