#BASENAME="ol-synth-midi-board"
BASENAME=$1
SOURCEDIR="gerber"
OUTDIR="gcode"
FRONT=${SOURCE_DIR}/${BASENAME}-F_Cu.gbr
BACK=${SOURCE_DIR}/${BASENAME}-B_Cu.gbr
MILL_DIAMETER=0.1
ISOLATION_WIDTH=1
ZWORK=0.1
MILL_FEED=200
MILL_VERTFEED=50
MILL_SPEED=5600 #spindle speed
ZSAFE=10
ZCHANGE=10

pcb2gcode \
    --metric \
    --basename ${BASENAME} \
    --output-dir ${OUTDIR} \
    --front ${FRONT} \
    --back ${BACK}\
    --mill-diameters=${MILL_DIAMETER} \
    --isolation-width=${ISOLATION_WIDTH} \
    --zwork ${ZWORK} \
    --mill-feed ${MILL_FEED} \
    --mill-vertfeed ${MILL_VERTFEED} \
    --mill-speed ${MILL_SPEED} \
    --zsafe ${ZSAFE} \
    --zchange ${ZCHANGE}
