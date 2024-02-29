import { GCode } from '@oneisland/gcode';
console.log("Hello!")

const code = new GCode({

    // Define the script name
    name: 'My gcode script',

    // Define the scale to use (default is mm)
    units: 'mm',

    // Define the starting x and y position
    start: [0, 0],

    // Set the clearance height to 10cm
    clearance: 10,
});

code.startSpindle()

console.log(String(code))