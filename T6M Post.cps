/**
  Copyright (C) 2017 bu Connor Philpott
  All rights reserved

  Colchester T6M Lathe post processor configuration

  $Revision$
  $Date$

  FORKID {C7A4BD6C-CF7A-4299-BF94-3C18351E8FA7}
*/

///////////////////////////////////////////////////////////////////////////////
//                        MANUAL NC COMMANDS
//
// The following ACTION commands are supported by this post.
//
//     partEject                  - Manually eject the part
//     transferType:phase,speed   - Phase or Speed spindle synchronization for stock-transfer
//     transferUseTorque:yes,no   - Use torque control for stock-transfer
//     useXZCMode                 - Force XZC mode for next operation
//     usePolarMode               - Force Polar mode for next operation
//
///////////////////////////////////////////////////////////////////////////////

description = "Colchester T6M Mill/Turn with Fanuc 21i control";
vendor = "Colchester";
vendorUrl = "https://www.colchester.co.uk";
legal = "Copyright (C) 2017 by Connor Philpott";
certificationLevel = 2;
minimumRevision = 24000;

longDescription = "Colchester Mill-Turn lathe (Fanuc 21i control)";

extension = "nc";
programNameIsInteger = true;
setCodePage("ascii");

capabilities = CAPABILITY_MILLING | CAPABILITY_TURNING;
tolerance = spatial(0.002, MM);

minimumChordLength = spatial(0.01, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(120); // reduced sweep due to G112 support
allowHelicalMoves = true;
allowedCircularPlanes = undefined; // allow any circular motion
allowSpiralMoves = false;
highFeedrate = (unit == IN) ? 470 : 12000;


// user-defined properties
properties = {
  writeMachine: true, // write machine
  writeTools: true, // writes the tools
  maxTool: 12,  // maximum tool number
  showSequenceNumbers: true, // show sequence numbers
  sequenceNumberStart: 1, // first sequence number
  sequenceNumberIncrement: 1, // increment for sequence numbers
  sequenceNumberToolOnly: false, // output sequence numbers on tool change only
  optionalStop: true, // optional stop
  separateWordsWithSpace: true, // specifies that the words should be separated with a white space
  useRadius: false, // specifies that arcs should be output using the radius (R word) instead of the I, J, and K words.
  maximumSpindleSpeed: 6000, // specifies the maximum spindle speed
  useParametricFeed: false, // specifies that feed should be output using Q values
  showNotes: false, // specifies that operation notes should be output.
  useCycles: true, // specifies that drilling cycles should be used.
  gotPartCatcher: true, // specifies if the machine has a part catcher
  autoEject: false, // specifies if the part should be automatically ejected at end of program
  useTailStock: false, // specifies to use the tailstock or not
  gotChipConveyor: false, // specifies to use a chip conveyor Y/N
  useG28Zhome: true, // use G28 to move Z to its home position
  zHomePosition: 0, // home position for Z when useG28Zhome is false
  transferType: "Phase", // Phase, Speed, or Stop synchronization for stock-transfer
  optimizeCaxisSelect: false, // optimize output of enable/disable C-axis codes
  transferUseTorque: false, // use torque control for stock-transfer
  looping: false, //output program for M98 looping
  numberOfRepeats: 1, //how many times to loop program
  cutoffConfirmation: false, // use G350 after cutoff for parting confirmation
  writeVersion: true // include version info
};


var permittedCommentChars = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,=_-";

var gFormat = createFormat({prefix:"G", decimals:0});
var g1Format = createFormat({prefix:"G", decimals:1});
var mFormat = createFormat({prefix:"M", decimals:0});

var spatialFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
var xFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true, scale:2}); // diameter mode & IS SCALING POLAR COORDINATES
var yFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
var zFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
var rFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true}); // radius
var abcFormat = createFormat({decimals:3, forceDecimal:true, scale:DEG});
var cFormat = createFormat({decimals:3, forceDecimal:true, scale:DEG, cyclicLimit:Math.PI*2});
var feedFormat = createFormat({decimals:(unit == MM ? 2 : 3), forceDecimal:true});
var pitchFormat = createFormat({decimals:6, forceDecimal:true});
var toolFormat = createFormat({decimals: 0, width: 4, zeropad: true});
var rpmFormat = createFormat({decimals:0});
var secFormat = createFormat({decimals:3, forceDecimal:true}); // seconds - range 0.001-99999.999
var milliFormat = createFormat({decimals:0}); // milliseconds // range 1-9999
var taperFormat = createFormat({decimals:1, scale:DEG});
var qFormat = createFormat({decimals:0, forceDecimal:false, trim:false, width:4, zeropad:true, scale:10000});
var threadP1Format = createFormat({decimals:0, forceDecimal:false, trim:false, width:6, zeropad:true});
var threadPQFormat = createFormat({decimals:0, forceDecimal:false, trim:true, scale:10000});
var threadRFormat = createFormat({decimals:0, forceDecimal:false, trim:true});
var dwellFormat = createFormat({prefix:"U", decimals:3});

var xOutput = createVariable({prefix:"X"}, xFormat);
var yOutput = createVariable({prefix:"Y"}, yFormat);
var zOutput = createVariable({prefix:"Z"}, zFormat);
var aOutput = createVariable({prefix:"A"}, abcFormat);
var bOutput = createVariable({prefix:"B"}, abcFormat);
var cOutput = createVariable({prefix:"C"}, cFormat);
var barOutput = createVariable({prefix:"B", force:true}, spatialFormat);
var feedOutput = createVariable({prefix:"F"}, feedFormat);
var pitchOutput = createVariable({prefix:"F", force:true}, pitchFormat);
var sOutput = createVariable({prefix:"S", force:true}, rpmFormat);
var pOutput = createVariable({prefix:"P", force:true}, rpmFormat);
var qOutput = createVariable({prefix:"Q", force:true}, qFormat);
var rOutput = createVariable({prefix:"R", force:true}, rFormat);
var threadP1Output = createVariable({prefix:"P", force:true}, threadP1Format);
var threadP2Output = createVariable({prefix:"P", force:true}, threadPQFormat);
var threadQOutput = createVariable({prefix:"Q", force:true}, threadPQFormat);
var threadROutput = createVariable({prefix:"R", force:true}, threadRFormat);

// circular output
var iOutput = createReferenceVariable({prefix:"I", force:true}, spatialFormat);
var jOutput = createReferenceVariable({prefix:"J", force:true}, spatialFormat);
var kOutput = createReferenceVariable({prefix:"K", force:true}, spatialFormat);

var g92IOutput = createVariable({prefix:"I"}, zFormat); // no scaling

var gMotionModal = createModal({}, gFormat); // modal group 1 // G0-G3, ...
var gPlaneModal = createModal({onchange:function () {gMotionModal.reset();}}, gFormat); // modal group 2 // G17-19
var gFeedModeModal = createModal({}, gFormat); // modal group 5 // G98-99
var gSpindleModeModal = createModal({}, gFormat); // modal group 5 // G96-97
var gSpindleModal = createModal({}, mFormat); // M176/177 SPINDLE MODE
var gUnitModal = createModal({}, gFormat); // modal group 6 // G20-21
var gCycleModal = createModal({}, gFormat); // modal group 9 // G81, ...
var gPolarModal = createModal({}, g1Format); // G12.1, G13.1
var cAxisEngageModal = createModal({}, mFormat);
var cAxisBrakeModal = createModal({}, mFormat);
var mInterferModal = createModal({}, mFormat);
var cAxisEnableModal = createModal({}, mFormat);

// fixed settings
var firstFeedParameter = 100;

var gotYAxis = false;
var yAxisMinimum = toPreciseUnit(gotYAxis ? -50.8 : 0, MM); // specifies the minimum range for the Y-axis
var yAxisMaximum = toPreciseUnit(gotYAxis ? 50.8 : 0, MM); // specifies the maximum range for the Y-axis
var xAxisMinimum = toPreciseUnit(0, MM); // specifies the maximum range for the X-axis (RADIUS MODE VALUE)
var gotBAxis = false; // B-axis always requires customization to match the machine specific functions for doing rotations
var gotMultiTurret = false; // specifies if the machine has several turrets

var gotPolarInterpolation = true; // specifies if the machine has XY polar interpolation capabilities
var gotSecondarySpindle = false;
var gotDoorControl = false;
var airCleanChuck = false; // use air to clean off chuck at part transfer and part eject

var WARNING_WORK_OFFSET = 0;
var WARNING_REPEAT_TAPPING = 1;

var SPINDLE_MAIN = 0;
var SPINDLE_SUB = 1;
var SPINDLE_LIVE = 2;

var POSX = 0;
var POXY = 1;
var POSZ = 2;
var NEGZ = -2;

var TRANSFER_PHASE = 0;
var TRANSFER_SPEED = 1;
var TRANSFER_STOP = 2;

// collected state
var sequenceNumber;
var currentWorkOffset;
var optionalSection = false;
var forceSpindleSpeed = false;
var activeMovements; // do not use by default
var currentFeedId;
var previousSpindle;
var activeSpindle=0;
var currentRPM = 0;
var partCutoff = false;
var transferType;
var transferUseTorque;
var reverseTap = false;
var showSequenceNumbers;
var stockTransferIsActive = false;
var forceXZCMode = false; // forces XZC output, activated by Action:useXZCMode
var forcePolarMode = false; // force Polar output, activated by Action:usePolarMode
var tapping = false;
var ejectRoutine = false;

var machineState = {
  liveToolIsActive: undefined,
  cAxisIsEngaged: undefined,
  machiningDirection: undefined,
  mainSpindleIsActive: undefined,
  subSpindleIsActive: undefined,
  mainSpindleBrakeIsActive: undefined,
  subSpindleBrakeIsActive: undefined,
  tailstockIsActive: undefined,
  usePolarMode: undefined,
  useXZCMode: undefined,
  axialCenterDrilling: undefined,
  currentBAxisOrientationTurning: new Vector(0, 0, 0)
};


function getCode(code, spindle) {
  switch(code) {
  case "PART_CATCHER_ON":
    return 34;
  case "PART_CATCHER_OFF":
    return 35;
  case "TAILSTOCK_ON":
    machineState.tailstockIsActive = true;
    return 78;
  case "TAILSTOCK_OFF":
    machineState.tailstockIsActive = false;
    return 79;
  case "SET_SPINDLE_FRAME":
    return (spindle == SPINDLE_MAIN) ? 80 : 83;
  case "ENABLE_C_AXIS":
    machineState.cAxisIsEngaged = true;
    return (spindle == SPINDLE_MAIN) ? 109 : 135;
  case "DISABLE_C_AXIS":
    machineState.cAxisIsEngaged = true;
    return (spindle == SPINDLE_MAIN) ? 110 : 134;
  case "POLAR_INTERPOLATION_ON":
    return 12.1;
  case "POLAR_INTERPOLATION_OFF":
    return 13.1;
  case "STOP_SPINDLE":
    return 5;
  case "ORIENT_SPINDLE":
    return (spindle == SPINDLE_MAIN) ? 19 : 119;
  case "START_SPINDLE_CW":
    return 3;
  case "START_SPINDLE_CCW":
    return 4;
  case "FEED_MODE_MM_REV":
    return 99;
  case "FEED_MODE_MM_MIN":
    return 98;
  case "CONSTANT_SURFACE_SPEED_ON":
    return 96;
  case "CONSTANT_SURFACE_SPEED_OFF":
    return 97;
  case "AUTO_AIR_ON":
    return 14;
  case "AUTO_AIR_OFF":
    return 15;
  case "LOCK_MULTI_AXIS":
    return (spindle == SPINDLE_MAIN) ? 89 : 189;
  case "UNLOCK_MULTI_AXIS":
    return (spindle == SPINDLE_MAIN) ? 90 : 190;
  case "CLAMP_CHUCK":
    return (spindle == SPINDLE_MAIN) ? 68 : 168;
  case "UNCLAMP_CHUCK":
    return (spindle == SPINDLE_MAIN) ? 69 : 169;
  case "SPINDLE_SYNCHRONIZATION_PHASE":
    return 213;
  case "SPINDLE_SYNCHRONIZATION_SPEED":
    return 203;
  case "SPINDLE_SYNCHRONIZATION_OFF":
    return 205;
  case "TORQUE_SKIP_ON":
    return 86;
  case "TORQUE_SKIP_OFF":
    return 87;
  case "SELECT_SPINDLE":
    switch (spindle) {
    case SPINDLE_MAIN:
      machineState.mainSpindleIsActive = true;
      machineState.subSpindleIsActive = false;
      machineState.liveToolIsActive = false;
      return 11;
    case SPINDLE_LIVE:
      machineState.mainSpindleIsActive = false;
      machineState.subSpindleIsActive = false;
      machineState.liveToolIsActive = true;
      return 12;
    case SPINDLE_SUB:
      machineState.mainSpindleIsActive = false;
      machineState.subSpindleIsActive = true;
      machineState.liveToolIsActive = false;
      return 13;
    }
    break;
  case "RIGID_TAPPING":
    return 84
  case "INTERLOCK_BYPASS":
    return (spindle == SPINDLE_MAIN) ? 31 : 131;
  case "INTERFERENCE_CHECK_OFF":
    return 1;
  case "INTERFERENCE_CHECK_ON":
    return 1;
  case "CYCLE_PART_EJECTOR":
    return 116;
  // coolant codes
  case "COOLANT_FLOOD_ON":
    return 8;
  case "COOLANT_FLOOD_OFF":
    return 9;
  case "COOLANT_MIST_ON":
    return 138;
  case "COOLANT_MIST_OFF":
    return 139;
  case "COOLANT_AIR_ON":
    return (spindle == SPINDLE_MAIN) ? 14 : 114;
  case "COOLANT_AIR_OFF":
    return (spindle == SPINDLE_MAIN) ? 15 : 115;
  case "COOLANT_THROUGH_TOOL_ON":
    return (spindle == SPINDLE_MAIN) ? 8 : 108;
  case "COOLANT_THROUGH_TOOL_OFF":
    return (spindle == SPINDLE_MAIN) ? 9 : 109;
  case "COOLANT_SUCTION_ON":
    return 7;
  case "COOLANT_OFF":
    return 9;
  default:
    error(localize("Command " + code + " is not defined."));
    return 0;
  }
  return 0;
}

/** Returns the modulus. */
function getModulus(x, y) {
  return Math.sqrt(x * x + y * y);
}

/**
  Returns the C rotation for the given X and Y coordinates.
*/
function getC(x, y) {
  var direction;
  if (Vector.dot(machineConfiguration.getAxisU().getAxis(), new Vector(0, 0, 1)) != 0) {
    direction = (machineConfiguration.getAxisU().getAxis().getCoordinate(2) >= 0) ? 1 : -1; // C-axis is the U-axis
  } else {
    direction = (machineConfiguration.getAxisV().getAxis().getCoordinate(2) >= 0) ? 1 : -1; // C-axis is the V-axis
  }

  return Math.atan2(y, x) * direction;
}

/**
  Returns the C rotation for the given X and Y coordinates in the desired rotary direction.
*/
function getCClosest(x, y, _c, clockwise) {
  if (_c == Number.POSITIVE_INFINITY) {
    _c = 0; // undefined
  }
  if (!xFormat.isSignificant(x) && !yFormat.isSignificant(y)) { // keep C if XY is on center
    return _c;
  }
  var c = getC(x, y);
  if (clockwise != undefined) {
    if (clockwise) {
      while (c < _c) {
        c += Math.PI * 2;
      }
    } else {
      while (c > _c) {
        c -= Math.PI * 2;
      }
    }
  } else {
    min = _c - Math.PI;
    max = _c + Math.PI;
    while (c < min) {
      c += Math.PI * 2;
    }
    while (c > max) {
      c -= Math.PI * 2;
    }
  }
  return c;
}

/**
  Returns the desired tolerance for the given section.
*/
function getTolerance() {
  var t = tolerance;
  if (hasParameter("operation:tolerance")) {
    if (t > 0) {
      t = Math.min(t, getParameter("operation:tolerance"));
    } else {
      t = getParameter("operation:tolerance");
    }
  }
  return t;
}

function formatSequenceNumber() {
  if (sequenceNumber > 99999) {
    sequenceNumber = properties.sequenceNumberStart;
  }
  var seqno = "N" + sequenceNumber;
  sequenceNumber += properties.sequenceNumberIncrement;
  return seqno;
}

/**
  Writes the specified block.
*/
function writeBlock() {
  var seqno = "";
  var opskip = "";
  if (showSequenceNumbers) {
    seqno = formatSequenceNumber();
  }
  if (optionalSection) {
    opskip = "/";
  }
  var text = formatWords(arguments);
  if (text) {
    writeWords(opskip, seqno, text);
  }
}

function writeDebug(_text) {
    writeComment("DEBUG - " + _text);
}

function formatComment(text) {
  return "(" + String(filterText(String(text).toUpperCase(), permittedCommentChars)).replace(/[\(\)]/g, "") + ")";
}

/**
  Output a comment.
*/
function writeComment(text) {
  writeln(formatComment(text));
}

function getB(abc, section) {
  if (section.spindle == SPINDLE_PRIMARY) {
    return abc.y;
  } else {
    return Math.PI - abc.y;
  }
}

function writeCommentSeqno(text) {
  writeln(formatSequenceNumber() + formatComment(text));
}

var machineConfigurationMainSpindle;
var machineConfigurationSubSpindle;

var machineConfigurationZ;
var machineConfigurationXC;
var machineConfigurationXB;

function onOpen() {
  if (properties.useRadius) {
    maximumCircularSweep = toRad(90); // avoid potential center calculation errors for CNC
  }

  // Copy certain properties into global variables
  showSequenceNumbers = properties.sequenceNumberToolOnly ? false : properties.showSequenceNumbers;
  transferType = parseToggle(properties.transferType, "PHASE", "SPEED");
  if (transferType == undefined) {
    error(localize("TransferType must be Phase or Speed"));
    return;
  }
  transferUseTorque = properties.transferUseTorque;

  // Setup default M-codes
  mInterferModal.format(getCode("INTERFERENCE_CHECK_ON", SPINDLE_MAIN));

  if (true) {
    var bAxisMain = createAxis({coordinate:1, table:false, axis:[0, -1, 0], range:[-0.001, 90.001], preference:0});
    var cAxisMain = createAxis({coordinate:2, table:true, axis:[0, 0, 1], cyclic:true, preference:0}); // C axis is modal between primary and secondary spindle

    var bAxisSub = createAxis({coordinate:1, table:false, axis:[0, -1, 0], range:[-0.001, 180.001], preference:0});
    var cAxisSub = createAxis({coordinate:2, table:true, axis:[0, 0, 1], cyclic:true, preference:0}); // C axis is modal between primary and secondary spindle

    machineConfigurationMainSpindle = gotBAxis ? new MachineConfiguration(bAxisMain, cAxisMain) : new MachineConfiguration(cAxisMain);
    machineConfigurationSubSpindle =  gotBAxis ? new MachineConfiguration(bAxisSub, cAxisSub) : new MachineConfiguration(cAxisSub);
  }

  machineConfiguration = new MachineConfiguration(); // creates an empty configuration to be able to set eg vendor information
  
  machineConfiguration.setVendor("Colchester");
  machineConfiguration.setModel("T6M");
  
  if (!gotYAxis) {
    yOutput.disable();
  }
  aOutput.disable();
  if (!gotBAxis) {
    bOutput.disable();
  }

  if (highFeedrate <= 0) {
    error(localize("You must set 'highFeedrate' because axes are not synchronized for rapid traversal."));
    return;
  }

  if (!properties.separateWordsWithSpace) {
    setWordSeparator("");
  }

  sequenceNumber = properties.sequenceNumberStart;
  writeln("%");

  if (programName) {
    var programId;
    try {
      programId = getAsInt(programName);
    } catch(e) {
      error(localize("Program name must be a number."));
      return;
    }
    if (!((programId >= 1) && (programId <= 9999))) {
      error(localize("Program number is out of range."));
      return;
    }
    var oFormat = createFormat({width:4, zeropad:true, decimals:0});
    if (programComment) {
      writeln("O" + oFormat.format(programId) + " (" + filterText(String(programComment).toUpperCase(), permittedCommentChars) + ")");
    } else {
      writeln("O" + oFormat.format(programId));
    }
  } else {
    error(localize("Program name has not been specified."));
    return;
  }

  if (properties.writeVersion) {
    if ((typeof getHeaderVersion == "function") && getHeaderVersion()) {
      writeComment(localize("post version") + ": " + getHeaderVersion());
    }
    if ((typeof getHeaderDate == "function") && getHeaderDate()) {
      writeComment(localize("post modified") + ": " + getHeaderDate());
    }
  }
  writeln("");
  writeln("XX.XXMM Stick Out");
  writeln("");
  writeComment("Posted using custom post processor written by Connor Philpott");
  writeComment("Copyright (C) 2017 by Connor Philpott")
  writeln("");

  // dump machine configuration
  var vendor = machineConfiguration.getVendor();
  var model = machineConfiguration.getModel();
  var description = machineConfiguration.getDescription();

  if (properties.writeMachine && (vendor || model || description)) {
    writeComment(localize("Machine setup"));
    if (vendor) {
      writeComment(localize(vendor));
    }
    if (model) {
      writeComment(localize(model));
    }
    writeComment(localize("Colchester Mill-Turn lathe - Fanuc 21i control"));
  }

  // dump tool information

  writeln("");
  writeComment("Program Tool Data");

  if (properties.writeTools) {
  	var zRanges = {};
  	if (is3D()) {
  		var numberOfSections = getNumberOfSections();
  		for (var i = 0; i < numberOfSections; ++i) {
  			var section = getSection(i);
  			var zRange = section.getGlobalZRange();
  			var tool = section.getTool();
  			if (zRanges[tool.number]) {
  				zRanges[tool.number].expandToRange(zRange);
  			} else {
  				zRanges[tool.number] = zRange;
  			}
  		}
  	}

  	var tools = getToolTable();
  	if (tools.getNumberOfTools() > 0) {
  		for (var i = 0; i < tools.getNumberOfTools() ; ++i) {
  			var tool = tools.getTool(i);
  			var compensationOffset = tool.isTurningTool() ? tool.compensationOffset : tool.lengthOffset;
  			var comment = "T" + toolFormat.format(tool.number * 100 + compensationOffset % 100) + " " +
			  "D=" + spatialFormat.format(tool.diameter) + " " +
			  localize("CR") + "=" + spatialFormat.format(tool.cornerRadius);
  			if ((tool.taperAngle > 0) && (tool.taperAngle < Math.PI)) {
  				comment += " " + localize("TAPER") + "=" + taperFormat.format(tool.taperAngle) + localize("deg");
  			}
  			if (zRanges[tool.number]) {
  				comment += " - " + localize("ZMIN") + "=" + spatialFormat.format(zRanges[tool.number].getMinimum());
  			}
  			comment += " - " + getToolTypeName(tool.type);
  			writeComment(comment);
  		}
  		writeln("");
        writeComment("start main program");
        writeln("");
    }
  }

  if (false) {
    // check for duplicate tool number
    for (var i = 0; i < getNumberOfSections(); ++i) {
      var sectioni = getSection(i);
      var tooli = sectioni.getTool();
      for (var j = i + 1; j < getNumberOfSections(); ++j) {
        var sectionj = getSection(j);
        var toolj = sectionj.getTool();
        if (tooli.number == toolj.number) {
          if (spatialFormat.areDifferent(tooli.diameter, toolj.diameter) ||
              spatialFormat.areDifferent(tooli.cornerRadius, toolj.cornerRadius) ||
              abcFormat.areDifferent(tooli.taperAngle, toolj.taperAngle) ||
              (tooli.numberOfFlutes != toolj.numberOfFlutes)) {
            error(
              subst(
                localize("Using the same tool number for different cutter geometry for operation '%1' and '%2'."),
                sectioni.hasParameter("operation-comment") ? sectioni.getParameter("operation-comment") : ("#" + (i + 1)),
                sectionj.hasParameter("operation-comment") ? sectionj.getParameter("operation-comment") : ("#" + (j + 1))
              )
            );
            return;
          }
        }
      }
    }
  }
  
  // support program looping for bar work
  if (properties.looping) {
    if (properties.numberOfRepeats < 1) {
      error(localize("numberOfRepeats must be greater than 0."));
      return;
    }
    if (sequenceNumber == 1) {
      sequenceNumber++;
    }
    writeln("");
    writeln("");
    writeComment(localize("Local Looping"));
    writeln("");
    writeBlock(mFormat.format(98), "Q1", "L" + properties.numberOfRepeats);
    writeBlock(mFormat.format(30));
    writeln("");
    writeln("");
    writeln("N1 (START MAIN PROGRAM)");
  }

  switch (unit) {
  case IN:
    writeBlock(gUnitModal.format(20));
    break;
  case MM:
    writeBlock(gUnitModal.format(21));
    break;
  }

  if (properties.gotChipConveyor) {
    onCommand(COMMAND_START_CHIP_TRANSPORT);
  }
  
  // automatically eject part at end of program
  if (properties.autoEject) {
    ejectRoutine = true;
  }
}

function onComment(message) {
  writeComment(message);
}

/** Force output of X, Y, and Z. */
function forceXYZ() {
  xOutput.reset();
  yOutput.reset();
  zOutput.reset();
}

/** Force output of A, B, and C. */
function forceABC() {
  aOutput.reset();
  bOutput.reset();
  cOutput.reset();
}

function forceFeed() {
  currentFeedId = undefined;
  feedOutput.reset();
}

/** Force output of X, Y, Z, A, B, C, and F on next output. */
function forceAny() {
  forceXYZ();
  forceABC();
  forceFeed();
}

function forceUnlockMultiAxis() {
  cAxisBrakeModal.reset();
}

function FeedContext(id, description, feed) {
  this.id = id;
  this.description = description;
  this.feed = feed;
}

function getFeed(f) {
  if (activeMovements) {
    var feedContext = activeMovements[movement];
    if (feedContext != undefined) {
      if (!feedFormat.areDifferent(feedContext.feed, f)) {
        if (feedContext.id == currentFeedId) {
          return ""; // nothing has changed
        }
        forceFeed();
        currentFeedId = feedContext.id;
        return "F#" + (firstFeedParameter + feedContext.id);
      }
    }
    currentFeedId = undefined; // force Q feed next time
  }
  return feedOutput.format(f); // use feed value
}

function initializeActiveFeeds() {
  activeMovements = new Array();
  var movements = currentSection.getMovements();
  var feedPerRev = currentSection.feedMode == FEED_PER_REVOLUTION;

  var id = 0;
  var activeFeeds = new Array();
  if (hasParameter("operation:tool_feedCutting")) {
    if (movements & ((1 << MOVEMENT_CUTTING) | (1 << MOVEMENT_LINK_TRANSITION) | (1 << MOVEMENT_EXTENDED))) {
      var feedContext = new FeedContext(id, localize("Cutting"), feedPerRev ? getParameter("operation:tool_feedCuttingRel") : getParameter("operation:tool_feedCutting"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_CUTTING] = feedContext;
      activeMovements[MOVEMENT_LINK_TRANSITION] = feedContext;
      activeMovements[MOVEMENT_EXTENDED] = feedContext;
    }
    ++id;
    if (movements & (1 << MOVEMENT_PREDRILL)) {
      feedContext = new FeedContext(id, localize("Predrilling"), feedPerRev ? getParameter("operation:tool_feedCuttingRel") : getParameter("operation:tool_feedCutting"));
      activeMovements[MOVEMENT_PREDRILL] = feedContext;
      activeFeeds.push(feedContext);
    }
    ++id;
  }

  if (hasParameter("operation:finishFeedrate")) {
    if (movements & (1 << MOVEMENT_FINISH_CUTTING)) {
      var finishFeedrateRel;
      if (hasParameter("operation:finishFeedrateRel")) {
        finishFeedrateRel = getParameter("operation:finishFeedrateRel");
      } else if (hasParameter("operation:finishFeedratePerRevolution")) {
        finishFeedrateRel = getParameter("operation:finishFeedratePerRevolution");
      }
      var feedContext = new FeedContext(id, localize("Finish"), feedPerRev ? finishFeedrateRel : getParameter("operation:finishFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_FINISH_CUTTING] = feedContext;
    }
    ++id;
  } else if (hasParameter("operation:tool_feedCutting")) {
    if (movements & (1 << MOVEMENT_FINISH_CUTTING)) {
      var feedContext = new FeedContext(id, localize("Finish"), feedPerRev ? getParameter("operation:tool_feedCuttingRel") : getParameter("operation:tool_feedCutting"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_FINISH_CUTTING] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:tool_feedEntry")) {
    if (movements & (1 << MOVEMENT_LEAD_IN)) {
      var feedContext = new FeedContext(id, localize("Entry"), feedPerRev ? getParameter("operation:tool_feedEntryRel") : getParameter("operation:tool_feedEntry"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LEAD_IN] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:tool_feedExit")) {
    if (movements & (1 << MOVEMENT_LEAD_OUT)) {
      var feedContext = new FeedContext(id, localize("Exit"), feedPerRev ? getParameter("operation:tool_feedExitRel") : getParameter("operation:tool_feedExit"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LEAD_OUT] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:noEngagementFeedrate")) {
    if (movements & (1 << MOVEMENT_LINK_DIRECT)) {
      var feedContext = new FeedContext(id, localize("Direct"), feedPerRev ? getParameter("operation:noEngagementFeedrateRel") : getParameter("operation:noEngagementFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LINK_DIRECT] = feedContext;
    }
    ++id;
  } else if (hasParameter("operation:tool_feedCutting") &&
             hasParameter("operation:tool_feedEntry") &&
             hasParameter("operation:tool_feedExit")) {
    if (movements & (1 << MOVEMENT_LINK_DIRECT)) {
      var feedContext = new FeedContext(
        id,
        localize("Direct"),
        Math.max(
          feedPerRev ? getParameter("operation:tool_feedCuttingRel") : getParameter("operation:tool_feedCutting"),
          feedPerRev ? getParameter("operation:tool_feedEntryRel") : getParameter("operation:tool_feedEntry"),
          feedPerRev ? getParameter("operation:tool_feedExitRel") : getParameter("operation:tool_feedExit")
        )
      );
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LINK_DIRECT] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:reducedFeedrate")) {
    if (movements & (1 << MOVEMENT_REDUCED)) {
      var feedContext = new FeedContext(id, localize("Reduced"), feedPerRev ? getParameter("operation:reducedFeedrateRel") : getParameter("operation:reducedFeedrate"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_REDUCED] = feedContext;
    }
    ++id;
  }

  if (hasParameter("operation:tool_feedRamp")) {
    if (movements & ((1 << MOVEMENT_RAMP) | (1 << MOVEMENT_RAMP_HELIX) | (1 << MOVEMENT_RAMP_PROFILE) | (1 << MOVEMENT_RAMP_ZIG_ZAG))) {
      var feedContext = new FeedContext(id, localize("Ramping"), feedPerRev ? getParameter("operation:tool_feedRampRel") : getParameter("operation:tool_feedRamp"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_RAMP] = feedContext;
      activeMovements[MOVEMENT_RAMP_HELIX] = feedContext;
      activeMovements[MOVEMENT_RAMP_PROFILE] = feedContext;
      activeMovements[MOVEMENT_RAMP_ZIG_ZAG] = feedContext;
    }
    ++id;
  }
  if (hasParameter("operation:tool_feedPlunge")) {
    if (movements & (1 << MOVEMENT_PLUNGE)) {
      var feedContext = new FeedContext(id, localize("Plunge"), feedPerRev ? getParameter("operation:tool_feedPlungeRel") : getParameter("operation:tool_feedPlunge"));
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_PLUNGE] = feedContext;
    }
    ++id;
  }
  if (true) { // high feed
    if (movements & (1 << MOVEMENT_HIGH_FEED)) {
      var feedContext = new FeedContext(id, localize("High Feed"), this.highFeedrate);
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_HIGH_FEED] = feedContext;
    }
    ++id;
  }

  for (var i = 0; i < activeFeeds.length; ++i) {
    var feedContext = activeFeeds[i];
    writeBlock("#" + (firstFeedParameter + feedContext.id) + "=" + feedFormat.format(feedContext.feed), formatComment(feedContext.description));
  }
}

var currentWorkPlaneABC = undefined;

function forceWorkPlane() {
  currentWorkPlaneABC = undefined;
}

function setWorkPlane(abc) {
  // milling only

  if (!machineConfiguration.isMultiAxisConfiguration()) {
    return; // ignore
  }

  if (!((currentWorkPlaneABC == undefined) ||
        abcFormat.areDifferent(abc.x, currentWorkPlaneABC.x) ||
        abcFormat.areDifferent(abc.y, currentWorkPlaneABC.y) ||
        abcFormat.areDifferent(abc.z, currentWorkPlaneABC.z))) {
    return; // no change
  }

  onCommand(COMMAND_UNLOCK_MULTI_AXIS);

  writeBlock(
    gMotionModal.format(0),
    conditional(machineConfiguration.isMachineCoordinate(0), "A" + abcFormat.format(abc.x)),
    conditional(machineConfiguration.isMachineCoordinate(1), "B" + abcFormat.format(abc.y)),
    conditional(machineConfiguration.isMachineCoordinate(2), "C" + abcFormat.format(abc.z))
  );

  onCommand(COMMAND_LOCK_MULTI_AXIS);

  currentWorkPlaneABC = abc;
}

var closestABC = false; // choose closest machine angles
var currentMachineABC;

function getWorkPlaneMachineABC(workPlane) {
  var W = workPlane; // map to global frame

  var abc = machineConfiguration.getABC(W);
  if (closestABC) {
    if (currentMachineABC) {
      abc = machineConfiguration.remapToABC(abc, currentMachineABC);
    } else {
      abc = machineConfiguration.getPreferredABC(abc);
    }
  } else {
    abc = machineConfiguration.getPreferredABC(abc);
  }

  try {
    abc = machineConfiguration.remapABC(abc);
    currentMachineABC = abc;
  } catch (e) {
    error(
      localize("Machine angles not supported") + ":"
      + conditional(machineConfiguration.isMachineCoordinate(0), " A" + abcFormat.format(abc.x))
      + conditional(machineConfiguration.isMachineCoordinate(1), " B" + abcFormat.format(abc.y))
      + conditional(machineConfiguration.isMachineCoordinate(2), " C" + abcFormat.format(abc.z))
    );
    return abc;
  }

  var direction = machineConfiguration.getDirection(abc);
  if (!isSameDirection(direction, W.forward)) {
    error(localize("Orientation not supported."));
    return abc;
  }

  if (!machineConfiguration.isABCSupported(abc)) {
    error(
      localize("Work plane is not supported") + ":"
      + conditional(machineConfiguration.isMachineCoordinate(0), " A" + abcFormat.format(abc.x))
      + conditional(machineConfiguration.isMachineCoordinate(1), " B" + abcFormat.format(abc.y))
      + conditional(machineConfiguration.isMachineCoordinate(2), " C" + abcFormat.format(abc.z))
    );
    return abc;
  }

  var tcp = false;
  if (tcp) {
    setRotation(W); // TCP mode
  } else {
    var O = machineConfiguration.getOrientation(abc);
    var R = machineConfiguration.getRemainingOrientation(abc, W);
    setRotation(R);
  }

  return abc;
}

function getBAxisOrientationTurning(section) {
  // THIS CODE IS NOT TESTED.
  var toolAngle = hasParameter("operation:tool_angle") ? getParameter("operation:tool_angle") : 0;
  var toolOrientation = section.toolOrientation;
  if (toolAngle && toolOrientation != 0) {
    error(localize("You cannot use tool angle and tool orientation together in operation " + "\"" + (getParameter("operation-comment")) + "\""));
  }

  var angle = toRad(toolAngle) + toolOrientation;

  var direction;
  if (Vector.dot(machineConfiguration.getAxisU().getAxis(), new Vector(0, 1, 0)) != 0) {
    direction = (machineConfiguration.getAxisU().getAxis().getCoordinate(1) >= 0) ? 1 : -1; // B-axis is the U-axis
  } else {
    direction = (machineConfiguration.getAxisV().getAxis().getCoordinate(1) >= 0) ? 1 : -1; // B-axis is the V-axis
  }
  var mappedWorkplane = new Matrix(new Vector(0, direction, 0), Math.PI/2 - angle);
  var abc = getWorkPlaneMachineABC(mappedWorkplane);

  return abc;
}

function getSpindle(partSpindle) {
  // safety conditions
  if (getNumberOfSections() == 0) {
    return SPINDLE_MAIN;
  }
  if (getCurrentSectionId() < 0) {
    return getSection(getNumberOfSections() - 1).spindle;
  }

  // Turning is active or calling routine requested which spindle part is loaded into
  if (machineState.isTurningOperation || machineState.axialCenterDrilling || partSpindle) {
    return currentSection.spindle;
  //Milling is active
  } else {
    return SPINDLE_LIVE;
  }
}

function getSecondarySpindle() {
  var spindle = getSpindle(true);
  return (spindle == SPINDLE_MAIN) ? SPINDLE_SUB : SPINDLE_MAIN;
}

function getSpindleAxis() {
  if (getSpindle(false) != SPINDLE_LIVE) {
    return POSX;
  }
  if (isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, 1))) {
    return POSZ;
  } else if (isPerpto(currentSection.workPlane.forward, new Vector(0, 0, 1))) {
    return POSX;
  } else {
    error(localize("Work plane must be Positive-X or Positive-Z."));
    return -1;
  }
}

function isPerpto(a, b) {
  return Math.abs(Vector.dot(a, b)) < (1e-7);
}

function setSpindleOrientationTurning(section) {
  var J; // cutter orientation
  var R; // cutting quadrant
  var leftHandTool = (hasParameter("operation:tool_hand") && (getParameter("operation:tool_hand") == "L" || getParameter("operation:tool_holderType") == 0));
  if (hasParameter("operation:machineInside")) {
    if (getParameter("operation:machineInside") == 0) {
      R = (currentSection.spindle == SPINDLE_PRIMARY) ? 3 : 4;
    } else {
      R = (currentSection.spindle == SPINDLE_PRIMARY) ? 2 : 1;
    }
  } else {
    if ((hasParameter("operation-strategy") && getParameter("operation-strategy") == "turningFace") ||
      (hasParameter("operation-strategy") && getParameter("operation-strategy") == "turningPart")) {
      R = (currentSection.spindle == SPINDLE_PRIMARY) ? 3 : 4;
    } else {
      error(subst(localize("Failed to identify spindle orientation for operation " + "\"" + "%1" + "\"" + "."), getOperationComment()));
      return;
    }
  }
  if (leftHandTool) {
    J = (currentSection.spindle == SPINDLE_PRIMARY) ? 2 : 1;
  } else {
    J = (currentSection.spindle == SPINDLE_PRIMARY) ? 1 : 2;
  }
  writeComment("Post processor is not customized, add code for cutter orientation and cutting quadrant here if needed.");
}

var bAxisOrientationTurning = new Vector(0, 0, 0);

function onSection() {
  // Detect machine configuration
  machineConfiguration = (currentSection.spindle == SPINDLE_PRIMARY) ? machineConfigurationMainSpindle : machineConfigurationSubSpindle;
  if (!gotBAxis) {
    if ((getMachiningDirection(currentSection) == MACHINING_DIRECTION_AXIAL) && !currentSection.isMultiAxis()) {
      machineConfiguration.setSpindleAxis(new Vector(0, 0, 1));
    } else {
      machineConfiguration.setSpindleAxis(new Vector(1, 0, 0));
    }
  } else {
    machineConfiguration.setSpindleAxis(new Vector(0, 0, 1)); // set the spindle axis depending on B0 orientation
  }

  setMachineConfiguration(machineConfiguration);
  currentSection.optimizeMachineAnglesByMachine(machineConfiguration, 0); // map tip mode
  
  // Define Machining modes
  tapping = hasParameter("operation:cycleType") &&
    ((getParameter("operation:cycleType") == "tapping") ||
     (getParameter("operation:cycleType") == "right-tapping") ||
     (getParameter("operation:cycleType") == "left-tapping") ||
     (getParameter("operation:cycleType") == "tapping-with-chip-breaking"));

  var forceToolAndRetract = optionalSection && !currentSection.isOptional();
  optionalSection = currentSection.isOptional();

  machineState.isTurningOperation = (currentSection.getType() == TYPE_TURNING);
  if (machineState.isTurningOperation && gotBAxis) {
    bAxisOrientationTurning = getBAxisOrientationTurning(currentSection);
  }
  var insertToolCall = forceToolAndRetract || isFirstSection() ||
    currentSection.getForceToolChange && currentSection.getForceToolChange() ||
    (tool.number != getPreviousSection().getTool().number) ||
    (tool.compensationOffset != getPreviousSection().getTool().compensationOffset) ||
    (tool.diameterOffset != getPreviousSection().getTool().diameterOffset) ||
    (tool.lengthOffset != getPreviousSection().getTool().lengthOffset);

  var retracted = false; // specifies that the tool has been retracted to the safe plane
  
  var newWorkOffset = isFirstSection() ||
    (getPreviousSection().workOffset != currentSection.workOffset); // work offset changes
  var newWorkPlane = isFirstSection() ||
    !isSameDirection(getPreviousSection().getGlobalFinalToolAxis(), currentSection.getGlobalInitialToolAxis()) ||
    (machineState.isTurningOperation &&
      abcFormat.areDifferent(bAxisOrientationTurning.x, machineState.currentBAxisOrientationTurning.x) ||
      abcFormat.areDifferent(bAxisOrientationTurning.y, machineState.currentBAxisOrientationTurning.y) ||
      abcFormat.areDifferent(bAxisOrientationTurning.z, machineState.currentBAxisOrientationTurning.z));

  partCutoff = hasParameter("operation-strategy") &&
    (getParameter("operation-strategy") == "turningPart");

  updateMachiningMode(currentSection); // sets the needed machining mode to machineState (usePolarMode, useXZCMode, axialCenterDrilling)
  
  // Get the active spindle
  var newSpindle = true;
  var tempSpindle = getSpindle(false);
  if (isFirstSection()) {
    previousSpindle = tempSpindle;
  }
  newSpindle = tempSpindle != previousSpindle;
  
  // End the previous section if a new tool is selected
  if (!isFirstSection() && insertToolCall &&
      !(stockTransferIsActive && partCutoff)) {
    if (stockTransferIsActive) {
      writeBlock(mFormat.format(getCode("SPINDLE_SYNCHRONIZATION_OFF", getSpindle(true))),
        pOutput.format(getCode("SELECT_SPINDLE", SPINDLE_MAIN)));
    } else {
      if (previousSpindle == SPINDLE_LIVE) {
        onCommand(COMMAND_STOP_SPINDLE);
        forceUnlockMultiAxis();
        onCommand(COMMAND_UNLOCK_MULTI_AXIS);
        if ((tempSpindle != SPINDLE_LIVE) && !properties.optimizeCaxisSelect) {
          cAxisEnableModal.reset();
          writeBlock(cAxisEnableModal.format(getCode("DISABLE_C_AXIS", getSpindle(true))));
        }
      }
      onCommand(COMMAND_COOLANT_OFF);
    }
    goHome();
    mInterferModal.reset();
    writeBlock(mInterferModal.format(getCode("INTERFERENCE_CHECK_OFF", getSpindle(true))));
    if (properties.optionalStop) {
      onCommand(COMMAND_OPTIONAL_STOP);
      gMotionModal.reset();
    }
  }
  // Consider part cutoff as stockTransfer operation
  if (!(stockTransferIsActive && partCutoff)) {
    stockTransferIsActive = false;
  }

  // Cancel the reverse spindle code used in tapping
  if (reverseTap) {
    writeBlock(mFormat.format(177));
    reverseTap = false;
  }

  // Output the operation description
  writeln("");
  if (hasParameter("operation-comment")) {
    var comment = getParameter("operation-comment");
    if (comment) {
      if (insertToolCall && properties.sequenceNumberToolOnly) {
        writeCommentSeqno(comment);
      } else {
        writeComment(comment);
      }
    }
  }

  // Position all axes at home
  if (insertToolCall && !stockTransferIsActive) {
    if (gotSecondarySpindle) {
      writeBlock(gMotionModal.format(0), gFormat.format(28), gFormat.format(53), "B" + abcFormat.format(0)); // retract Sub Spindle if applicable
    }
    goHome();

    // Stop the spindle
    if (newSpindle) {
      onCommand(COMMAND_STOP_SPINDLE);
    }
  }

  // Setup WCS code
  if (insertToolCall) { // force work offset when changing tool
    currentWorkOffset = undefined;
  }
  var workOffset = currentSection.workOffset;
  if (workOffset == 0) {
    warningOnce(localize("Work offset has not been specified. Using G54 as WCS."), WARNING_WORK_OFFSET);
    workOffset = 1;
  }
  var wcsOut = "";
  if (workOffset > 0) {
    if (workOffset > 6) {
         error(localize("Work offset out of range."));
        return;
    } else {
      if (workOffset != currentWorkOffset) {
        forceWorkPlane();
        wcsOut = gFormat.format(53 + workOffset); // G54->G59
        currentWorkOffset = workOffset;
      }
    }
  }

  // Get active feedrate mode
  if (insertToolCall) {
    gFeedModeModal.reset();
  }
  var feedMode;
  if ((currentSection.feedMode == FEED_PER_REVOLUTION) || tapping) {
    feedMode = gFeedModeModal.format(getCode("FEED_MODE_MM_REV", getSpindle(false)));
  } else {
    feedMode = gFeedModeModal.format(getCode("FEED_MODE_MM_MIN", getSpindle(false)));
  }

  // Live Spindle is active
  if (tempSpindle == SPINDLE_LIVE) {
    if (insertToolCall || wcsOut || feedMode) {
      forceUnlockMultiAxis();
      onCommand(COMMAND_UNLOCK_MULTI_AXIS);
      var plane = getSpindleAxis() == POSZ ? 17 : 18;
      gPlaneModal.reset();
      if (!properties.optimizeCaxisSelect) {
        cAxisEnableModal.reset();
      }
      writeBlock(wcsOut, mFormat.format(getCode("SET_SPINDLE_FRAME", getSpindle(true))));
      writeBlock(feedMode, gPlaneModal.format(plane), cAxisEnableModal.format(getCode("ENABLE_C_AXIS", getSpindle(true))));
      writeBlock(gMotionModal.format(0), gFormat.format(28), "H" + abcFormat.format(0)); // unwind c-axis
      if (!machineState.usePolarMode && !machineState.useXZCMode && !currentSection.isMultiAxis()) {
        onCommand(COMMAND_LOCK_MULTI_AXIS);
      }
    }

  // Turning is active
  } else {
    if ((insertToolCall || wcsOut || feedMode) && !stockTransferIsActive) {
      forceUnlockMultiAxis();
      onCommand(COMMAND_UNLOCK_MULTI_AXIS);
      gPlaneModal.reset();
      if (!properties.optimizeCaxisSelect) {
        cAxisEnableModal.reset();
      }
      writeBlock(wcsOut, mFormat.format(getSpindle(true) == SPINDLE_SUB ? 83 : 80));
      writeBlock(feedMode, gPlaneModal.format(18), cAxisEnableModal.format(getCode("DISABLE_C_AXIS", getSpindle(true))));
    } else {
      writeBlock(feedMode);
    }
  }

  // Write out maximum spindle speed
  if (insertToolCall && !stockTransferIsActive) {
    if ((tool.maximumSpindleSpeed > 0) && (currentSection.getTool().getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED)) {
      var maximumSpindleSpeed = (tool.maximumSpindleSpeed > 0) ? Math.min(tool.maximumSpindleSpeed, properties.maximumSpindleSpeed) : properties.maximumSpindleSpeed;
      writeBlock(gFormat.format(50), sOutput.format(maximumSpindleSpeed));
      sOutput.reset();
    }
  }

  // Write out notes
  if (properties.showNotes && hasParameter("notes")) {
    var notes = getParameter("notes");
    if (notes) {
      var lines = String(notes).split("\n");
      var r1 = new RegExp("^[\\s]+", "g");
      var r2 = new RegExp("[\\s]+$", "g");
      for (line in lines) {
        var comment = lines[line].replace(r1, "").replace(r2, "");
        if (comment) {
          writeComment(comment);
        }
      }
    }
  }

  switch (getMachiningDirection(currentSection)) {
  case MACHINING_DIRECTION_AXIAL:
    // writeBlock(gPlaneModal.format(getG17Code()));
    break;
  case MACHINING_DIRECTION_RADIAL:
    if (gotBAxis) {
      // writeBlock(gPlaneModal.format(getG17Code()));
    } else {
      // writeBlock(gPlaneModal.format(getG17Code())); // RADIAL
    }
    break;
  case MACHINING_DIRECTION_INDEXING:
    // writeBlock(gPlaneModal.format(getG17Code())); // INDEXING
    break;
  default:
    error(subst(localize("Unsupported machining direction for operation " +  "\"" + "%1" + "\"" + "."), getOperationComment()));
    return;
  }
  
  var abc;
  if (machineConfiguration.isMultiAxisConfiguration()) {
    if (machineState.isTurningOperation) {
      if (gotBAxis) {
        cancelTransformation();
        // handle B-axis support for turning operations here
        abc = bAxisOrientationTurning;
        //setSpindleOrientationTurning();
      } else {
        abc = getWorkPlaneMachineABC(currentSection.workPlane);
      }
    } else {
      if (currentSection.isMultiAxis()) {
        forceWorkPlane();
        cancelTransformation();
        onCommand(COMMAND_UNLOCK_MULTI_AXIS);
        abc = currentSection.getInitialToolAxisABC();
      } else {
        abc = getWorkPlaneMachineABC(currentSection.workPlane);
      }
    }
  } else { // pure 3D
    var remaining = currentSection.workPlane;
    if (!isSameDirection(remaining.forward, new Vector(0, 0, 1))) {
      error(localize("Tool orientation is not supported by the CNC machine."));
      return;
    }
    setRotation(remaining);
  }
  
  if (insertToolCall) {
    forceWorkPlane();
    cAxisEngageModal.reset();
    retracted = true;
    onCommand(COMMAND_COOLANT_OFF);

    /** Handle multiple turrets. */
    if (gotMultiTurret) {
      var activeTurret = tool.turret;
      if (activeTurret == 0) {
        warning(localize("Turret has not been specified. Using Turret 1 as default."));
        activeTurret = 1; // upper turret as default
      }
      switch (activeTurret) {
      case 1:
        // add specific handling for turret 1
        break;
      case 2:
        // add specific handling for turret 2, normally X-axis is reversed for the lower turret
        //xFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true, scale:-1}); // inverted diameter mode
        //xOutput = createVariable({prefix:"X"}, xFormat);
        break;
      default:
        error(localize("Turret is not supported."));
        return;
      }
    }

    var compensationOffset = tool.isTurningTool() ? tool.compensationOffset : tool.lengthOffset;
    if (compensationOffset > 99) {
      error(localize("Compensation offset is out of range."));
      return;
    }

    if (tool.number > properties.maxTool) {
      warning(localize("Tool number exceeds maximum value."));
    }
    
    if (tool.number == 0) {
      error(localize("Tool number cannot be 0"));
      return;
    }

    gMotionModal.reset();
    writeBlock("T" + toolFormat.format(tool.number * 100 + compensationOffset));
    if (tool.comment) {
      writeComment(tool.comment);
    }

    // Turn on coolant
    setCoolant(tool.coolant);

    // Disable/Enable Spindle C-axis switching
    // The Lynx machine does not support C-axis switching
    // It automatically performs this function when the secondary spindle is enabled
/*
    if (getSpindle(false) == SPINDLE_LIVE) {
      if (gotSecondarySpindle) {
        switch (currentSection.spindle) {
        case SPINDLE_PRIMARY: // main spindle
          writeBlock(gSpindleModal.format(177));
          break;
        case SPINDLE_SECONDARY: // sub spindle
          writeBlock(gSpindleModal.format(176));
          break;
        }
      }
    }
*/

    // Engage tailstock
    if (properties.useTailStock && !machineState.axialCenterDrilling) {
      if (getSpindle(true) == "SPINDLE_MAIN" && (getSpindleAxis() != POSZ)) {
        writeBlock(mFormat.format(currentSection.tailstock ? getCode("TAILSTOCK_ON", SPINDLE_MAIN) : getCode("TAILSTOCK_OFF", SPINDLE_MAIN)));
      } else {
        error(localize("Tail stock is not supported for secondary spindle or Z-axis milling."));
        return;
      }
    }
  }

  // Activate part catcher for part cutoff section
  if (properties.gotPartCatcher && partCutoff && currentSection.partCatcher) {
    engagePartCatcher(true);
  }

  // command stop for manual tool change, useful for quick change live tools
  if (insertToolCall && tool.manualToolChange) {
    onCommand(COMMAND_STOP);
    writeBlock("(" + "MANUAL TOOL CHANGE TO T" + toolFormat.format(tool.number * 100 + compensationOffset) + ")");
  }

  // Output spindle codes
  if (newSpindle) {
    // select spindle if required
  }

  if ((insertToolCall ||
      newSpindle ||
      isFirstSection() ||
      (rpmFormat.areDifferent(tool.spindleRPM, currentRPM)) ||
      (tool.clockwise != getPreviousSection().getTool().clockwise)) &&
      !stockTransferIsActive) {
    currentRPM = tool.spindleRPM;
    if (machineState.isTurningOperation) {
      if (tool.spindleRPM > 99999) {
        warning(subst(localize("Spindle speed exceeds maximum value for operation " + "\"" + "%1" + "\"" + "."), getOperationComment()));
      }
    } else {
      if (tool.spindleRPM > 6000) {
        warning(subst(localize("Spindle speed exceeds maximum value for operation " + "\"" + "%1" + "\"" + "."), getOperationComment()));
      }
    }


    // Turn spindle on
    if (!tapping) {
      setSpindle(false);
    }
  }

  // Turn off interference checking with secondary spindle
  if (getSpindle(true) == SPINDLE_SUB) {
    writeBlock(mInterferModal.format(getCode("INTERFERENCE_CHECK_OFF", getSpindle(true))));
  }

  forceAny();
  gMotionModal.reset();

  if (currentSection.isMultiAxis()) {
    forceWorkPlane();
    cancelTransformation();
  } else {
    if (machineState.isTurningOperation || machineState.axialCenterDrilling) {
      writeBlock(conditional(gotBAxis, gMotionModal.format(0), bOutput.format(getB(abc, currentSection))));
      machineState.currentBAxisOrientationTurning = abc;
    } else if (!machineState.useXZCMode && !machineState.usePolarMode) {
      setWorkPlane(abc);
    }
  }
  forceAny();
  if (abc !== undefined) {
    cOutput.format(abc.z); // make C current - we do not want to output here
  }
  gMotionModal.reset();
  var initialPosition = getFramePosition(currentSection.getInitialPosition());

  if (insertToolCall || retracted) {
    // gPlaneModal.reset();
    gMotionModal.reset();
    if (machineState.useXZCMode || machineState.usePolarMode) {
      // writeBlock(gPlaneModal.format(getG17Code()));
      writeBlock(gMotionModal.format(0), zOutput.format(initialPosition.z));
      writeBlock(
        gMotionModal.format(0),
        xOutput.format(getModulus(initialPosition.x, initialPosition.y)),
        conditional(gotYAxis, yOutput.format(0)),
        cOutput.format(getC(initialPosition.x, initialPosition.y))
      );
    } else {
      writeBlock(gMotionModal.format(0), zOutput.format(initialPosition.z));
      writeBlock(gMotionModal.format(0), xOutput.format(initialPosition.x), yOutput.format(initialPosition.y));
    }
  }

  if (machineState.usePolarMode) {
    setPolarMode(true); // enable polar interpolation mode
  }
  if (properties.useParametricFeed &&
      hasParameter("operation-strategy") &&
      (getParameter("operation-strategy") != "drill") && // legacy
      !(currentSection.hasAnyCycle && currentSection.hasAnyCycle())) {
    if (!insertToolCall &&
        activeMovements &&
        (getCurrentSectionId() > 0) &&
        ((getPreviousSection().getPatternId() == currentSection.getPatternId()) && (currentSection.getPatternId() != 0))) {
      // use the current feeds
    } else {
      initializeActiveFeeds();
    }
  } else {
    activeMovements = undefined;
  }
  
  previousSpindle = tempSpindle;
  activeSpindle = tempSpindle;

  if (false) { // DEBUG
    for (var key in machineState) {
      writeComment(key + " : " + machineState[key]);
    }
    writeComment("Machining direction = " + getMachiningDirection(currentSection));
    writeComment("Tapping = " + tapping);
    // writeln("(" + (getMachineConfigurationAsText(machineConfiguration)) + ")");
  }
}

/** Returns true if the toolpath fits within the machine XY limits for the given C orientation. */
function doesToolpathFitInXYRange(abc) {
  var c = 0;
  if (abc) {
    c = abc.z;
  }

  var dx = new Vector(Math.cos(c), Math.sin(c), 0);
  var dy = new Vector(Math.cos(c + Math.PI/2), Math.sin(c + Math.PI/2), 0);

  if (currentSection.getGlobalRange) {
    var xRange = currentSection.getGlobalRange(dx);
    var yRange = currentSection.getGlobalRange(dy);

    if (false) { // DEBUG
      writeComment("toolpath X min: " + xFormat.format(xRange[0]) + ", " + "Limit " + xFormat.format(xAxisMinimum));
      writeComment("X-min within range: " + (xFormat.getResultingValue(xRange[0]) >= xFormat.getResultingValue(xAxisMinimum)));
      writeComment("toolpath Y min: " + spatialFormat.getResultingValue(yRange[0]) + ", " + "Limit " + yAxisMinimum);
      writeComment("Y-min within range: " + (spatialFormat.getResultingValue(yRange[0]) >= yAxisMinimum));
      writeComment("toolpath Y max: " + (spatialFormat.getResultingValue(yRange[1]) + ", " + "Limit " + yAxisMaximum));
      writeComment("Y-max within range: " + (spatialFormat.getResultingValue(yRange[1]) <= yAxisMaximum));
    }

    if (getMachiningDirection(currentSection) == MACHINING_DIRECTION_RADIAL) { // G19 plane
      if ((spatialFormat.getResultingValue(yRange[0]) >= yAxisMinimum) &&
          (spatialFormat.getResultingValue(yRange[1]) <= yAxisMaximum)) {
        return true; // toolpath does fit in XY range
      } else {
        return false; // toolpath does not fit in XY range
      }
    } else { // G17 plane
      if ((xFormat.getResultingValue(xRange[0]) >= xFormat.getResultingValue(xAxisMinimum)) &&
          (spatialFormat.getResultingValue(yRange[0]) >= yAxisMinimum) &&
          (spatialFormat.getResultingValue(yRange[1]) <= yAxisMaximum)) {
        return true; // toolpath does fit in XY range
      } else {
        return false; // toolpath does not fit in XY range
      }
    }
  } else {
    if (revision < 40000) {
      warning(localize("Please update to the latest release to allow XY linear interpolation instead of polar interpolation."));
    }
    return false; // for older versions without the getGlobalRange() function
  }
}

var MACHINING_DIRECTION_AXIAL = 0;
var MACHINING_DIRECTION_RADIAL = 1;
var MACHINING_DIRECTION_INDEXING = 2;

function getMachiningDirection(section) {
  var forward = section.workPlane.forward;
  if (isSameDirection(forward, new Vector(0, 0, 1))) {
    return MACHINING_DIRECTION_AXIAL;
  } else if (Vector.dot(forward, new Vector(0, 0, 1)) < 1e-7) {
    return MACHINING_DIRECTION_RADIAL;
  } else {
    return MACHINING_DIRECTION_INDEXING;
  }
}

function updateMachiningMode(section) {
  machineState.axialCenterDrilling = false; // reset
  machineState.usePolarMode = false; // reset
  machineState.useXZCMode = false; // reset

  if ((section.getType() == TYPE_MILLING) && !section.isMultiAxis()) {
    if (getMachiningDirection(section) == MACHINING_DIRECTION_AXIAL) {
      if (section.hasParameter("operation-strategy") && (section.getParameter("operation-strategy") == "drill")) {
        // drilling axial
        if ((section.getNumberOfCyclePoints() == 1) &&
            !xFormat.isSignificant(getGlobalPosition(section.getInitialPosition()).x) &&
            !yFormat.isSignificant(getGlobalPosition(section.getInitialPosition()).y) &&
            (spatialFormat.format(section.getFinalPosition().x) == 0) &&
            !doesCannedCycleIncludeYAxisMotion()) { // catch drill issue for old versions
          // single hole on XY center
          if (section.getTool().isLiveTool && section.getTool().isLiveTool()) {
            // use live tool
          } else {
            // use main spindle for axialCenterDrilling
            machineState.axialCenterDrilling = true;
          }
        } else {
          // several holes not on XY center, use live tool in XZCMode
          machineState.useXZCMode = true;
        }
      } else { // milling
        if (doesToolpathFitInXYRange(machineConfiguration.getABC(section.workPlane))) {
          if (section.isPatterned()) {
            // enable interpolation mode for patterned operations
            if (gotPolarInterpolation && !forceXZCMode) {
              machineState.usePolarMode = true;
            } else {
              machineState.useXZCMode = true;
            }
          } else if (forcePolarMode) {
            machineState.usePolarMode = true;
          } else {
            // toolpath matches XY ranges, keep false
          }
        } else {
          // toolpath does not match XY ranges, enable interpolation mode
          if (gotPolarInterpolation && !forceXZCMode) {
            machineState.usePolarMode = true;
          } else {
            machineState.useXZCMode = true;
          }
        }
      }
    } else if (getMachiningDirection(section) == MACHINING_DIRECTION_RADIAL) { // G19 plane
      if (!gotYAxis) {
        if (!section.isMultiAxis() && !doesToolpathFitInXYRange(machineConfiguration.getABC(section.workPlane)) && doesCannedCycleIncludeYAxisMotion()) {
          error(subst(localize("Y-axis motion is not possible without a Y-axis for operation " + "\"" + "%1" + "\"" + "."), getOperationComment()));
          return;
        }
      } else {
        if (!doesToolpathFitInXYRange(machineConfiguration.getABC(section.workPlane)) || forceXZCMode) {
          error(subst(localize("Toolpath exceeds the maximum ranges for operation " + "\"" + "%1" + "\"" + "."), getOperationComment()));
          return;
        }
      }
      // C-coordinates come from setWorkPlane or is within a multi axis operation, we cannot use the C-axis for non wrapped toolpathes (only multiaxis works, all others have to be into XY range)
    } else {
      // useXZCMode & usePolarMode is only supported for axial machining, keep false
    }
  } else {
    // turning or multi axis, keep false
  }

  if (machineState.axialCenterDrilling) {
    cOutput.disable();
  } else {
    cOutput.enable();
  }

  var checksum = 0;
  checksum += machineState.usePolarMode ? 1 : 0;
  checksum += machineState.useXZCMode ? 1 : 0;
  checksum += machineState.axialCenterDrilling ? 1 : 0;
  validate(checksum <= 1, localize("Internal post processor error."));
}

function doesCannedCycleIncludeYAxisMotion() {
  // these cycles have Y axis motions which are not detected by getGlobalRange()
  var hasYMotion = false;
  if (hasParameter("operation:strategy") && (getParameter("operation:strategy") == "drill")) {
    switch (getParameter("operation:cycleType")) {
    case "thread-milling":
    case "bore-milling":
    case "circular-pocket-milling":
      hasYMotion = true; // toolpath includes Y-axis motion
      break;
    case "back-boring":
    case "fine-boring":
      var shift = getParameter("operation:boringShift");
      if (shift != spatialFormat.format(0)) {
        hasYMotion = true; // toolpath includes Y-axis motion
      }
      break;
    default:
      hasYMotion = false; // all other cycles don´t have Y-axis motion
    }
  } else {
    hasYMotion = true;
  }
  return hasYMotion;
}

function getOperationComment() {
  var operationComment = hasParameter("operation-comment") && getParameter("operation-comment");
  return operationComment;
}

function setPolarMode(activate) {
  if (activate) {
    cOutput.reset();
    writeBlock(gMotionModal.format(0), cOutput.format(0)); // set C-axis to 0 to avoid G112 issues
    writeBlock(gPolarModal.format(getCode("POLAR_INTERPOLATION_ON", getSpindle(false)))); // command for polar interpolation
    writeBlock(gPlaneModal.format(18));
    yOutput = createVariable({prefix:"C"}, yFormat);
    yOutput.enable(); // required for G12.1
    cOutput.disable();
  } else {
    writeBlock(gPolarModal.format(getCode("POLAR_INTERPOLATION_OFF", getSpindle(false))));
    yOutput = createVariable({prefix:"Y"}, yFormat);
    if (!gotYAxis) {
      yOutput.disable();
    }
    cOutput.enable();
  }
}

function goHome() {
  var yAxis = "";
  if (gotYAxis) {
    yAxis = "V" + yFormat.format(0);
  }
  writeBlock(gMotionModal.format(0), gFormat.format(28), "U" + xFormat.format(0), yAxis);
  if (properties.useG28Zhome) {
    writeBlock(gMotionModal.format(0), gFormat.format(28), "W" + zFormat.format(0));
  } else {
    gMotionModal.reset();
    zOutput.reset();
    writeBlock(gMotionModal.format(0), zOutput.format(properties.zHomePosition));
  }
}

function onDwell(seconds) {
  if (seconds > 99999.999) {
    warning(localize("Dwelling time is out of range."));
  }
  writeBlock(gFormat.format(4), dwellFormat.format(seconds));
}

var pendingRadiusCompensation = -1;

function onRadiusCompensation() {
  pendingRadiusCompensation = radiusCompensation;
}

var resetFeed = false;

function getHighfeedrate(radius) {
  if (currentSection.feedMode == FEED_PER_REVOLUTION) {
    if (toDeg(radius) <= 0) {
      radius = toPreciseUnit(0.1, MM);
    }
    var rpm = tool.spindleRPM; // rev/min
    if (currentSection.getTool().getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED) {
      var O = 2 * Math.PI * radius; // in/rev
      rpm = tool.surfaceSpeed/O; // in/min div in/rev => rev/min
    }
    return highFeedrate/rpm; // in/min div rev/min => in/rev
  }
  return highFeedrate;
}

function onRapid(_x, _y, _z) {
  if (machineState.useXZCMode) {
    var start = getCurrentPosition();
    var dxy = getModulus(_x - start.x, _y - start.y);
    if (true || (dxy < getTolerance())) {
      var x = xOutput.format(getModulus(_x, _y));
      var c = cOutput.format(getCClosest(_x, _y, cOutput.getCurrent()));
      var z = zOutput.format(_z);
      if (pendingRadiusCompensation >= 0) {
        error(localize("Radius compensation mode cannot be changed at rapid traversal."));
        return;
      }
      writeBlock(gMotionModal.format(0), x, c, z);
      forceFeed();
      return;
    }

    onLinear(_x, _y, _z, highFeedrate);
    return;
  }

  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  if (x || y || z) {
    var useG1 = (((x ? 1 : 0) + (y ? 1 : 0) + (z ? 1 : 0)) > 1) || machineState.usePolarMode;
    var highFeed = machineState.usePolarMode ? toPreciseUnit(1500, MM) : getHighfeedrate(_x);
    if (pendingRadiusCompensation >= 0) {
      pendingRadiusCompensation = -1;
      if (useG1) {
        switch (radiusCompensation) {
        case RADIUS_COMPENSATION_LEFT:
          writeBlock(gMotionModal.format(1), gFormat.format(41), x, y, z, getFeed(highFeed));
          break;
        case RADIUS_COMPENSATION_RIGHT:
          writeBlock(gMotionModal.format(1), gFormat.format(42), x, y, z, getFeed(highFeed));
          break;
        default:
          writeBlock(gMotionModal.format(1), gFormat.format(40), x, y, z, getFeed(highFeed));
        }
      } else {
        switch (radiusCompensation) {
        case RADIUS_COMPENSATION_LEFT:
          writeBlock(gMotionModal.format(0), gFormat.format(41), x, y, z);
          break;
        case RADIUS_COMPENSATION_RIGHT:
          writeBlock(gMotionModal.format(0), gFormat.format(42), x, y, z);
          break;
        default:
          writeBlock(gMotionModal.format(0), gFormat.format(40), x, y, z);
        }
      }
    }
    if (useG1) {
      // axes are not synchronized
      writeBlock(gMotionModal.format(1), x, y, z, getFeed(highFeed));
      resetFeed = false;
    } else {
      writeBlock(gMotionModal.format(0), x, y, z);
      // forceFeed();
    }
  }
}

/** Returns the U-coordinate along the 2D line for the projection of point p. */
function getLineProjectionU(start, end, p) {
  var ax = p.x - start.x;
  var ay = p.y - start.y;
  var deltax = end.x - start.x;
  var deltay = end.y - start.y;
  var squareModulus = deltax * deltax + deltay * deltay;
  var d = ax * deltax + ay * deltay; // dot
  return (squareModulus > 0) ? d/squareModulus : 0;
}

function onLinear(_x, _y, _z, feed) {
  if (machineState.useXZCMode) {
    if (pendingRadiusCompensation >= 0) {
      error(subst(localize("Radius compensation is not supported for operation " + "\"" + "%1" + "\"" + "."), getOperationComment()));
      return;
    }
    if (maximumCircularSweep > toRad(179)) {
      error(localize("Maximum circular sweep must be below 179 degrees."));
      return;
    }

    var localTolerance = getTolerance()/2;
    var startXYZ = getCurrentPosition();
    var endXYZ = new Vector(_x, _y, _z);
    var splitXYZ = endXYZ;

    // check if we should split line segment at the closest point to the rotary
    var split = false;
    var rotaryXYZ = new Vector(0, 0, 0);
    var pu = getLineProjectionU(startXYZ, endXYZ, rotaryXYZ); // from rotary
    if ((pu > 0) && (pu < 1)) { // within segment start->end
      var p = Vector.lerp(startXYZ, endXYZ, pu);
      var d = Math.sqrt(sqr(p.x - rotaryXYZ.x) + sqr(p.y - rotaryXYZ.y)); // distance to rotary
      if (d < toPreciseUnit(0.1, MM)) { // we get very close to rotary
        split = true;
        var lminor = Math.sqrt(sqr(p.x - startXYZ.x) + sqr(p.y - startXYZ.y));
        var lmajor = Math.sqrt(sqr(endXYZ.x - startXYZ.x) + sqr(endXYZ.y - startXYZ.y));
        splitXYZ = new Vector(p.x, p.y, startXYZ.z + (endXYZ.z - startXYZ.z) * lminor/lmajor);
      }
    }

    var currentXYZ = splitXYZ;
    var turnFirst = false;

    while (true) { // repeat if we need to split
      var radius = Math.min(getModulus(startXYZ.x, startXYZ.y), getModulus(currentXYZ.x, currentXYZ.y));
      var radial = !xFormat.isSignificant(radius); // used to avoid noice in C-axis
      var length = Vector.diff(startXYZ, currentXYZ).length; // could measure in XY only
      // we cannot control feed of C-axis so we have to force small steps
      var numberOfSegments = Math.max(Math.ceil(length/toPreciseUnit(0.05, MM)), 1);

      var cc = getCClosest(currentXYZ.x, currentXYZ.y, cOutput.getCurrent());
      if (radial && (currentXYZ.x == 0) && (currentXYZ.y == 0)) {
        cc = getCClosest(startXYZ.x, startXYZ.y, cOutput.getCurrent());
      }
      var sweep = Math.abs(cc - cOutput.getCurrent()); // dont care for radial
      if (radius > localTolerance) {
        var stepAngle = 2 * Math.acos(1 - localTolerance/radius);
        numberOfSegments = Math.max(Math.ceil(sweep/stepAngle), numberOfSegments);
      }
      if (radial || !abcFormat.areDifferent(cc, cOutput.getCurrent())) {
        numberOfSegments = 1; // avoid linearization if there is no turn
      }

      for (var i = 1; i <= numberOfSegments; ++i) {
        var p = Vector.lerp(startXYZ, currentXYZ, i * 1.0/numberOfSegments);
        var c = cOutput.format(radial ? cc : getCClosest(p.x, p.y, cOutput.getCurrent()));
        if (c && turnFirst) { // turn before moving along X after rotary has been reached
          turnFirst = false;
          writeBlock(gMotionModal.format(1), c, getFeed(feed));
          c = undefined; // dont output again
        }
        writeBlock(gMotionModal.format(1), xOutput.format(getModulus(p.x, p.y)), c, zOutput.format(p.z), getFeed(feed));
      }

      if (!split) {
        break;
      }

      startXYZ = splitXYZ;
      currentXYZ = endXYZ;
      // writeComment("XC: restart at rotary");
      split = false;
      turnFirst = true;
    }
    return;
  }

  if (isSpeedFeedSynchronizationActive()) {
    resetFeed = true;
    var threadPitch = getParameter("operation:threadPitch");
    var threadsPerInch = 1.0/threadPitch; // per mm for metric
    writeBlock(gMotionModal.format(32), xOutput.format(_x), yOutput.format(_y), zOutput.format(_z), pitchOutput.format(1/threadsPerInch));
    return;
  }
  if (resetFeed) {
    resetFeed = false;
    forceFeed();
  }
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var f = getFeed(feed);
  if (x || y || z) {
    if (pendingRadiusCompensation >= 0) {
      pendingRadiusCompensation = -1;
      if (machineState.isTurningOperation) {
        writeBlock(gPlaneModal.format(18));
      } else if (isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, 1))) {
        writeBlock(gPlaneModal.format(getG17Code()));
      } else if (Vector.dot(currentSection.workPlane.forward, new Vector(0, 0, 1)) < 1e-7) {
        writeBlock(gPlaneModal.format(19));
      } else {
        error(localize("Tool orientation is not supported for radius compensation."));
        return;
      }
      switch (radiusCompensation) {
      case RADIUS_COMPENSATION_LEFT:
        writeBlock(gMotionModal.format(isSpeedFeedSynchronizationActive() ? 32 : 1), gFormat.format(41), x, y, z, f);
        break;
      case RADIUS_COMPENSATION_RIGHT:
        writeBlock(gMotionModal.format(isSpeedFeedSynchronizationActive() ? 32 : 1), gFormat.format(42), x, y, z, f);
        break;
      default:
        writeBlock(gMotionModal.format(isSpeedFeedSynchronizationActive() ? 32 : 1), gFormat.format(40), x, y, z, f);
      }
    } else {
      writeBlock(gMotionModal.format(isSpeedFeedSynchronizationActive() ? 32 : 1), x, y, z, f);
    }
  } else if (f) {
    if (getNextRecord().isMotion()) { // try not to output feed without motion
      forceFeed(); // force feed on next line
    } else {
      writeBlock(gMotionModal.format(isSpeedFeedSynchronizationActive() ? 32 : 1), f);
    }
  }
}

function onRapid5D(_x, _y, _z, _a, _b, _c) {
  if (!currentSection.isOptimizedForMachine()) {
    error(localize("Multi-axis motion is not supported for XZC mode."));
    return;
  }
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation mode cannot be changed at rapid traversal."));
    return;
  }
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var a = aOutput.format(_a);
  var b = bOutput.format(_b);
  var c = cOutput.format(_c);
  if (true) {
    // axes are not synchronized
    writeBlock(gMotionModal.format(1), x, y, z, a, b, c, getFeed(highFeedrate));
  } else {
    writeBlock(gMotionModal.format(0), x, y, z, a, b, c);
    forceFeed();
  }
}

function onLinear5D(_x, _y, _z, _a, _b, _c, feed) {
  if (!currentSection.isOptimizedForMachine()) {
    error(localize("Multi-axis motion is not supported for XZC mode."));
    return;
  }
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for 5-axis move."));
    return;
  }
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var a = aOutput.format(_a);
  var b = bOutput.format(_b);
  var c = cOutput.format(_c);
  var f = getFeed(feed);

  if (x || y || z || a || b || c) {
    writeBlock(gMotionModal.format(1), x, y, z, a, b, c, f);
  } else if (f) {
    if (getNextRecord().isMotion()) { // try not to output feed without motion
      forceFeed(); // force feed on next line
    } else {
      writeBlock(gMotionModal.format(1), f);
    }
  }
}

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  var directionCode = clockwise ? 2 : 3;
  if (machineState.useXZCMode) {
    switch (getCircularPlane()) {
    case PLANE_ZX:
      if (!isSpiral()) {
        var c = getCClosest(x, y, cOutput.getCurrent());
        if (!cFormat.areDifferent(c, cOutput.getCurrent())) {
          validate(getCircularSweep() < Math.PI, localize("Circular sweep exceeds limit."));
          var start = getCurrentPosition();
          writeBlock(gPlaneModal.format(18), gMotionModal.format(directionCode), xOutput.format(getModulus(x, y)), cOutput.format(c), zOutput.format(z), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
          return;
        }
      }
      break;
    case PLANE_XY:
      var d2 = center.x * center.x + center.y * center.y;
      if (d2 < 1e-18) { // center is on rotary axis
        writeBlock(gMotionModal.format(1), xOutput.format(getModulus(x, y)), cOutput.format(getCClosest(x, y, cOutput.getCurrent(), clockwise)), zOutput.format(z), getFeed(feed));
        return;
      }
      break;
    }
    
    linearize(getTolerance());
    return;
  }

  if (isSpeedFeedSynchronizationActive()) {
    error(localize("Speed-feed synchronization is not supported for circular moves."));
    return;
  }

  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for a circular move."));
    return;
  }

  var start = getCurrentPosition();

  if (isFullCircle()) {
    if (properties.useRadius || isHelical()) { // radius mode does not support full arcs
      linearize(tolerance);
      return;
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gPlaneModal.format(getG17Code()), gMotionModal.format(directionCode), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), getFeed(feed));
      break;
    case PLANE_ZX:
       if (machineState.usePolarMode) {
        linearize(tolerance);
        return;
      }
      writeBlock(gPlaneModal.format(18), gMotionModal.format(directionCode), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    case PLANE_YZ:
      if (machineState.usePolarMode) {
        linearize(tolerance);
        return;
      }
      writeBlock(gPlaneModal.format(19), gMotionModal.format(directionCode), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    default:
      linearize(tolerance);
    }
  } else if (!properties.useRadius) {
    if (isHelical() && ((getCircularSweep() < toRad(30)) || (getHelicalPitch() > 10))) { // avoid G112 issue
      linearize(tolerance);
      return;
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gPlaneModal.format(getG17Code()), gMotionModal.format(directionCode), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), getFeed(feed));
      break;
    case PLANE_ZX:
      if (machineState.usePolarMode) {
        linearize(tolerance);
        return;
      }
      writeBlock(gPlaneModal.format(18), gMotionModal.format(directionCode), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    case PLANE_YZ:
      if (machineState.usePolarMode) {
        linearize(tolerance);
        return;
      }
      writeBlock(gPlaneModal.format(19), gMotionModal.format(directionCode), xOutput.format(x), yOutput.format(y), zOutput.format(z), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), getFeed(feed));
      break;
    default:
      linearize(tolerance);
    }
  } else { // use radius mode
    if (isHelical() && ((getCircularSweep() < toRad(30)) || (getHelicalPitch() > 10))) {
      linearize(tolerance);
      return;
    }
    var r = getCircularRadius();
    if (toDeg(getCircularSweep()) > (180 + 1e-9)) {
      r = -r; // allow up to <360 deg arcs
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gPlaneModal.format(getG17Code()), gMotionModal.format(directionCode), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), getFeed(feed));
      break;
    case PLANE_ZX:
      if (machineState.usePolarMode) {
        linearize(tolerance);
        return;
      }
      writeBlock(gPlaneModal.format(18), gMotionModal.format(directionCode), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), getFeed(feed));
      break;
    case PLANE_YZ:
      if (machineState.usePolarMode) {
        linearize(tolerance);
        return;
      }
      writeBlock(gPlaneModal.format(19), gMotionModal.format(directionCode), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), getFeed(feed));
      break;
    default:
      linearize(tolerance);
    }
  }
}

function onCycle() {
  if ((typeof isSubSpindleCycle == "function") && isSubSpindleCycle(cycleType)) {
    writeln("");
    if (hasParameter("operation-comment")) {
      var comment = getParameter("operation-comment");
      if (comment) {
        writeComment(comment);
      }
    }

    // Start of stock transfer operation(s)
    if (!stockTransferIsActive) {
      if (cycleType != "secondary-spindle-return") {
        writeBlock(gMotionModal.format(0), gFormat.format(28), gFormat.format(53), "B" + abcFormat.format(0)); // retract Sub Spindle
        goHome();
      }
      onCommand(COMMAND_STOP_SPINDLE);
      onCommand(COMMAND_COOLANT_OFF);
      onCommand(COMMAND_OPTIONAL_STOP);
      forceUnlockMultiAxis();
      onCommand(COMMAND_UNLOCK_MULTI_AXIS);
      if (cycle.stopSpindle) {
        writeBlock(gMotionModal.format(0), gFormat.format(28), "H" + abcFormat.format(0));
      }
      gFeedModeModal.reset();
      var feedMode;
      if (currentSection.feedMode == FEED_PER_REVOLUTION) {
        feedMode = gFeedModeModal.format(getCode("FEED_MODE_MM_REV", getSpindle(false)));
      } else {
        feedMode = gFeedModeModal.format(getCode("FEED_MODE_MM_MIN", getSpindle(false)));
      }
      gPlaneModal.reset();
      if (!properties.optimizeCaxisSelect) {
        cAxisEnableModal.reset();
      }
      writeBlock(feedMode, gPlaneModal.format(18), cAxisEnableModal.format(getCode("DISABLE_C_AXIS", getSpindle(true))));
      writeBlock(mFormat.format(getCode("DISABLE_C_AXIS", getSecondarySpindle())));
    }
    
    switch (cycleType) {
    case "secondary-spindle-return":
      var secondaryPull = false;
      var secondaryHome = false;
      // Transfer part to secondary spindle
      if (cycle.unclampMode != "keep-clamped") {
        secondaryPull = true;
        secondaryHome = true;
      } else {
        // pull part only (when offset!=0), Return secondary spindle to home (when offset=0)
        if (hasParameter("operation:feedPlaneHeight_offset")) { // Inventor
          secondaryPull = getParameter("operation:feedPlaneHeight_offset") != 0;
        }
        if (hasParameter("operation:feedPlaneHeightOffset")) { // HSMWorks
          secondaryPull = getParameter("operation:feedPlaneHeightOffset") != 0;
        }
        secondaryHome = !secondaryPull;
      }

      if (secondaryPull) {
        writeBlock(mFormat.format(getCode("UNCLAMP_CHUCK", getSpindle(true))), formatComment("UNCLAMP MAIN CHUCK"));
        onDwell(cycle.dwell);
        writeBlock(
          conditional(cycle.useMachineFrame == 1, gFormat.format(53)),
          gMotionModal.format(1),
          barOutput.format(cycle.feedPosition),
          getFeed(cycle.feedrate),
          formatComment("BAR PULL")
        );
      }
      if (secondaryHome) {
        if (cycle.unclampMode == "unclamp-secondary") { // simple bar pulling operation
          writeBlock(mFormat.format(getCode("CLAMP_CHUCK", getSpindle(true))), formatComment("CLAMP MAIN CHUCK"));
          onDwell(cycle.dwell);
          writeBlock(mFormat.format(getCode("UNCLAMP_CHUCK", getSecondarySpindle())), formatComment("UNCLAMP SUB CHUCK"));
          onDwell(cycle.dwell);
        }
        writeBlock(gMotionModal.format(0), gFormat.format(28), gFormat.format(53), barOutput.format(0), formatComment("SUB SPINDLE RETURN"));
      } else {
        writeBlock(mFormat.format(getCode("CLAMP_CHUCK", getSpindle(true))), formatComment("CLAMP MAIN CHUCK"));
        onDwell(cycle.dwell);
        writeBlock(mFormat.format(getCode("COOLANT_THROUGH_TOOL_OFF", getSecondarySpindle())));
        mInterferModal.reset();
        writeBlock(mInterferModal.format(getCode("INTERFERENCE_CHECK_OFF", getSpindle(true))));
      }
      stockTransferIsActive = true;
      break;

    /*case "secondary-spindle-pull":
      writeBlock(
        gMotionModal.format(1), barOutput.format(cycle.pullingDistance), getFeed(cycle.feedrate));
      writeBlock(mFormat.format(getCode("CLAMP_CHUCK", getSpindle(true))));
      stockTransferIsActive = true;
      break;
    */

    case "secondary-spindle-grab":
      if (currentSection.partCatcher) {
        engagePartCatcher(true);
      }
      writeBlock(mFormat.format(getCode("INTERLOCK_BYPASS", getSecondarySpindle())), formatComment("INTERLOCK BYPASS"));
      writeBlock(mFormat.format(getCode("UNCLAMP_CHUCK", getSecondarySpindle())), formatComment("UNCLAMP SUB CHUCK"));
      onDwell(cycle.dwell);
      gSpindleModeModal.reset();

      if (cycle.stopSpindle) { // no spindle rotation
/*
        writeBlock(mFormat.format(getCode("STOP_MAIN_SPINDLE")));
        writeBlock(mFormat.format(getCode("STOP_SUB_SPINDLE")));
        gMotionModal.reset();
        writeBlock(cAxisEngageModal.format(getCode("ENABLE_C_AXIS")));
        writeBlock(gMotionModal.format(0), "C" + abcFormat.format(cycle.spindleOrientation));
*/
      } else { // spindle rotation
        var transferCodes = getSpindleTransferCodes(transferType);
        
        // Write out maximum spindle speed
        if (transferCodes.spindleMode == SPINDLE_CONSTANT_SURFACE_SPEED) {
          var maximumSpindleSpeed = (transferCodes.maximumSpindleSpeed > 0) ? Math.min(transferCodes.maximumSpindleSpeed, properties.maximumSpindleSpeed) : properties.maximumSpindleSpeed;
          writeBlock(gFormat.format(50), sOutput.format(maximumSpindleSpeed));
          sOutput.reset();
        }
        // write out spindle speed
        var spindleSpeed;
        var spindleMode;
        if (transferCodes.spindleMode == SPINDLE_CONSTANT_SURFACE_SPEED) {
          spindleSpeed = transferCodes.surfaceSpeed * ((unit == MM) ? 1/1000.0 : 1/12.0);
          spindleMode = getCode("CONSTANT_SURFACE_SPEED_ON", getSpindle(true));
        } else {
          spindleSpeed = cycle.spindleSpeed;
          spindleMode = getCode("CONSTANT_SURFACE_SPEED_OFF", getSpindle(true));
        }
        var comment;
        if (transferType == TRANSFER_PHASE) {
          comment = "PHASE SYNCHRONIZATION";
        } else {
          comment = "SPEED SYNCHRONIZATION";
        }
        writeBlock(
          gSpindleModeModal.format(spindleMode),
          sOutput.format(spindleSpeed),
          mFormat.format(transferCodes.direction),
          pOutput.format(getCode("SELECT_SPINDLE", getSpindle(true))),
          formatComment(comment)
        );
      }
      
      // clean out chips
      if (airCleanChuck) {
        writeBlock(mFormat.format(getCode("COOLANT_AIR_ON", SPINDLE_MAIN)), formatComment("CLEAN OUT CHIPS"));
        writeBlock(mFormat.format(getCode("COOLANT_AIR_ON", SPINDLE_SUB)));
        onDwell(5.5);
        writeBlock(mFormat.format(getCode("COOLANT_AIR_OFF", SPINDLE_MAIN)));
        writeBlock(mFormat.format(getCode("COOLANT_AIR_OFF", SPINDLE_SUB)));
      }

      writeBlock(mInterferModal.format(getCode("INTERFERENCE_CHECK_OFF", getSpindle(true))));
      gMotionModal.reset();
      writeBlock(gMotionModal.format(0), conditional(cycle.useMachineFrame == 1, gFormat.format(53)), barOutput.format(cycle.feedPosition));
            
      if (transferUseTorque) {
        writeBlock(mFormat.format(getCode("TORQUE_SKIP_ON", getSpindle(true))), formatComment("TORQUE SKIP ON"));
        writeBlock(
          gFormat.format(31), pOutput.format(99),
          conditional(cycle.useMachineFrame == 1, gFormat.format(53)), barOutput.format(cycle.chuckPosition),
          getFeed(cycle.feedrate)
        );
        writeBlock(mFormat.format(getCode("TORQUE_SKIP_OFF", getSpindle(true))), formatComment("TORQUE SKIP OFF"));
      } else {
        writeBlock(
          conditional(cycle.useMachineFrame == 1, gFormat.format(53)), gMotionModal.format(1), barOutput.format(cycle.chuckPosition),
          getFeed(cycle.feedrate)
        );
      }
      writeBlock(mFormat.format(getCode("CLAMP_CHUCK", getSecondarySpindle())), formatComment("CLAMP SUB SPINDLE"));
      writeBlock(mFormat.format(getCode("INTERLOCK_BYPASS", getSpindle(true))), formatComment("INTERLOCK BYPASS"));
      
      onDwell(cycle.dwell);
      stockTransferIsActive = true;
      break;
    }
  }

  if (cycleType == "stock-transfer") {
    warning(localize("Stock transfer is not supported. Required machine specific customization."));
    return;
  } else if (!properties.useCycles && tapping) {
    setSpindle(false);
  }
}

function getCommonCycle(x, y, z, r, includeRcode) {

  // R-value is incremental position from current position
  var raptoS = "";
  if ((r !== undefined) && includeRcode) {
    raptoS = "R" + spatialFormat.format(r);
  }

  if (machineState.useXZCMode) {
    cOutput.reset();
    return [xOutput.format(getModulus(x, y)), cOutput.format(getCClosest(x, y, cOutput.getCurrent())),
      zOutput.format(z),
      raptoS];
  } else {
    return [xOutput.format(x), yOutput.format(y),
      zOutput.format(z),
      raptoS];
  }
}

function writeCycleClearance(plane, clearance) {
  var currentPosition = getCurrentPosition();
  if (true) {
    onCycleEnd();
    switch (plane) {
    case 17:
      writeBlock(gMotionModal.format(0), zOutput.format(clearance));
      break;
    case 18:
      writeBlock(gMotionModal.format(0), yOutput.format(clearance));
      break;
    case 19:
      writeBlock(gMotionModal.format(0), xOutput.format(clearance));
      break;
    default:
      error(localize("Unsupported drilling orientation."));
      return;
    }
  }
}

function onCyclePoint(x, y, z) {

  if (!properties.useCycles || currentSection.isMultiAxis()) {
    expandCyclePoint(x, y, z);
    return;
  }

  var plane = gPlaneModal.getCurrent();
  var localZOutput = zOutput;
  if (isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, 1)) ||
      isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, -1))) {
    plane = 17; // XY plane
    localZOutput = zOutput;
  } else if (Vector.dot(currentSection.workPlane.forward, new Vector(0, 0, 1)) < 1e-7) {
    plane = 19; // YZ plane
    localZOutput = xOutput;
  } else {
    expandCyclePoint(x, y, z);
    return;
  }

  switch (cycleType) {
  case "thread-turning":
    var chamferWidth = 10; // Pullout-width is 1*thread-lead in 1/10's;
    var materialAllowance = 0; // Material allowance for finishing pass
    var repeatPass = 0; // cycle.repeatPass is not defined
    var pcode = repeatPass * 10000 + chamferWidth * 100 + 60; // Angle is not stored with tool. toDeg(tool.getTaperAngle());
    var i = -cycle.incrementalX; // positive if taper goes down - delta radius
    if (!F) {
      F = (gFeedModeModal.getCurrent() == 99) ? cycle.pitch : cycle.pitch * tool.spindleRPM;
    }
    var f = (gFeedModeModal.getCurrent() == 99) ? pitchOutput.format(F) : feedOutput.format(F);
    // Most parameters from HSM are either not specified or
    // contain the same value (clearance, retract, bottom, stock, etc.)
    // May have to first position to X-level of thread prior to issuing the cycle command

    gCycleModal.reset();
    writeBlock(
      gCycleModal.format(76),
      threadP1Output.format(pcode),
      conditional(threadPQFormat.isSignificant(cycle.minimumIncrementalDepth), threadQOutput.format(cycle.minimumIncrementalDepth)),
      conditional(threadRFormat.isSignificant(materialAllowance), threadROutput.format(materialAllowance))
    );
    gCycleModal.reset();
    writeBlock(gCycleModal.format(76),
      xOutput.format(x-cycle.incrementalX),
      zOutput.format(z),
      conditional(threadPQFormat.isSignificant(cycle.depth), threadP2Output.format(cycle.depth)),
      conditional(threadPQFormat.isSignificant(cycle.incrementalDepth), threadQOutput.format(cycle.incrementalDepth)),
      conditional(rFormat.isSignificant(i), rOutput.format(i)), f
    );
    forceFeed();
    return;
  }

  // clamp the C-axis if necessary
  // the C-axis is automatically unclamped by the controllers during cycles
  var lockCode = "";
  if (!machineState.axialCenterDrilling && !machineState.isTurningOperation) {
    lockCode = mFormat.format(getCode("LOCK_MULTI_AXIS", getSpindle(true)));
  }

  var rapto = 0;
  if (isFirstCyclePoint()) { // first cycle point
    rapto = cycle.retract - cycle.clearance;

    var F = (gFeedModeModal.getCurrent() == 99 ? cycle.feedrate/tool.spindleRPM : cycle.feedrate);
    var P = (cycle.dwell == 0) ? 0 : clamp(1, cycle.dwell * 1000, 99999999); // in milliseconds
    
    switch (cycleType) {
    case "drilling":
      writeCycleClearance(plane, cycle.clearance);
      localZOutput.reset();
      writeBlock(
        gCycleModal.format(plane == 19 ? 87 : 83),
        getCommonCycle(x, y, z, rapto, true),
        conditional(P > 0, pOutput.format(P)),
        feedOutput.format(F),
        lockCode
      );
      break;
    case "chip-breaking":
    case "deep-drilling":
      writeCycleClearance(plane, cycle.clearance);
      localZOutput.reset();
      writeBlock(
        gCycleModal.format(plane == 19 ? 87 : 83),
        getCommonCycle(x, y, z, rapto, true),
        conditional(cycle.incrementalDepth > 0, qOutput.format(cycle.incrementalDepth)),
        conditional(P > 0, pOutput.format(P)),
        feedOutput.format(F),
        lockCode
      );
      break;
    case "tapping":
    case "right-tapping":
    case "left-tapping":
      writeCycleClearance(plane, cycle.clearance);
      localZOutput.reset();
      if (!F) {
        F = tool.getTappingFeedrate();
      }
      setSpindle(true);
      reverseTap = tool.type == TOOL_TAP_LEFT_HAND;
      if (reverseTap) {
        writeBlock(mFormat.format(176));
      }
      writeBlock(
        gCycleModal.format(plane == 19 ? 88 : 84),
        getCommonCycle(x, y, z, rapto, true),
        pitchOutput.format(F)
      );
      break;
    case "boring":
      writeCycleClearance(plane, cycle.clearance);
      localZOutput.reset();
      writeBlock(
        gCycleModal.format(plane == 19 ? 89 : 85),
        getCommonCycle(x, y, z, rapto, true),
        conditional(P > 0, pOutput.format(P)),
        feedOutput.format(F),
        lockCode
      );
      break;
    default:
      expandCyclePoint(x, y, z);
    }
  } else { // position to subsequent cycle points
    if (cycleExpanded) {
      expandCyclePoint(x, y, z);
    } else {
      var step = 0;
      if (cycleType == "chip-breaking" || cycleType == "deep-drilling") {
        step = cycle.incrementalDepth;
      }
      writeBlock(getCommonCycle(x, y, z, rapto, false), conditional(step > 0, qOutput.format(step)), lockCode);
    }
  }
}

function onCycleEnd() {
  if (!cycleExpanded) {
    writeBlock(gCycleModal.format(80));
    gMotionModal.reset();
  }
}

function onPassThrough(text) {
  writeBlock(text);
}

function onParameter(name, value) {
  var invalid = false;
  switch (name) {
  case "action":
    if (String(value).toUpperCase() == "PARTEJECT") {
      ejectRoutine = true;
    } else if (String(value).toUpperCase() == "USEXZCMODE") {
      forceXZCMode = true;
      forcePolarMode = false;
    } else if (String(value).toUpperCase() == "USEPOLARMODE") {
      forcePolarMode = true;
      forceXZCMode = false;
    } else {
      var sText1 = String(value);
      var sText2 = new Array();
      sText2 = sText1.split(":");
      if (sText2.length != 2) {
        error(localize("Invalid action command: ") + value);
        return;
      }
      if (sText2[0].toUpperCase() == "TRANSFERTYPE") {
        transferType = parseToggle(sText2[1], "PHASE", "SPEED");
        if (transferType == undefined) {
          error(localize("TransferType must be Phase or Speed"));
          return;
        }
      } else if (sText2[0].toUpperCase() == "TRANSFERUSETORQUE") {
        transferUseTorque = parseToggle(sText2[1], "YES", "NO");
        if (transferUseTorque == undefined) {
          invalid = true;
        }
      } else {
        invalid = true;
      }
    }
  }
  if (invalid) {
    error(localize("Invalid action parameter: ") + sText2[0] + ":" + sText2[1]);
    return;
  }
}

function parseToggle() {
  var stat = undefined;
  for (i=1; i<arguments.length; i++) {
    if (String(arguments[0]).toUpperCase() == String(arguments[i]).toUpperCase()) {
      if (String(arguments[i]).toUpperCase() == "YES") {
        stat = true;
      } else if (String(arguments[i]).toUpperCase() == "NO") {
        stat = false;
      } else {
        stat = i - 1;
        break;
      }
    }
  }
  return stat;
}

var currentCoolantMode = COOLANT_OFF;

function setCoolant(coolant) {
  if (coolant == currentCoolantMode) {
    return; // coolant is already active
  }

  var m = undefined;
  if (coolant == COOLANT_OFF) {
    if (currentCoolantMode == COOLANT_THROUGH_TOOL) {
      m = getCode("COOLANT_THROUGH_TOOL_OFF", getSpindle(true));
    } else if (currentCoolantMode == COOLANT_AIR) {
      m = getCode("COOLANT_AIR_OFF", getSpindle(true));
    } else if (currentCoolantMode == COOLANT_MIST) {
      m = getCode("COOLANT_MIST_OFF", getSpindle(true));
    } else {
      m = getCode("COOLANT_OFF", getSpindle(true));
    }
    writeBlock(mFormat.format(m));
    currentCoolantMode = COOLANT_OFF;
    return;
  }

  if ((currentCoolantMode != COOLANT_OFF) && (coolant != currentCoolantMode)) {
    setCoolant(COOLANT_OFF);
  }

  switch (coolant) {
  case COOLANT_FLOOD:
    m = 8;
    break;
  case COOLANT_THROUGH_TOOL:
    m = getCode("COOLANT_THROUGH_TOOL_ON", getSpindle(true));
    break;
  case COOLANT_AIR:
    m = getCode("COOLANT_AIR_ON", getSpindle(true));
    break;
  case COOLANT_MIST:
    m = getCode("COOLANT_MIST_ON", getSpindle(true));
    break;
  case COOLANT_SUCTION:
    m = getCode("COOLANT_SUCTION_ON", getSpindle(true));
    break;
  default:
    warning(localize("Coolant not supported."));
    if (currentCoolantMode == COOLANT_OFF) {
      return;
    }
    coolant = COOLANT_OFF;
    m = getCode("COOLANT_OFF", getSpindle(true));
  }

  writeBlock(mFormat.format(m));
  currentCoolantMode = coolant;
}

function setSpindle(tappingMode) {
  var spindleDir;
  var spindleSpeed;
  var spindleMode;
  gSpindleModeModal.reset();
  
  if ((getSpindle(true) == SPINDLE_SUB) && !gotSecondarySpindle) {
    error(localize("Secondary spindle is not available."));
    return;
  }
  
  if (tappingMode) {
    spindleDir = mFormat.format(getCode("RIGID_TAPPING", getSpindle(false)));
  } else {
    spindleDir = mFormat.format(tool.clockwise ? getCode("START_SPINDLE_CW", getSpindle(false)) : getCode("START_SPINDLE_CCW", getSpindle(false)));
  }

  if (tool.getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED) {
    spindleSpeed = tool.surfaceSpeed * ((unit == MM) ? 1/1000.0 : 1/12.0);
    spindleMode = getCode("CONSTANT_SURFACE_SPEED_ON", getSpindle(false));
  } else {
    spindleSpeed = tool.spindleRPM;
    spindleMode = getCode("CONSTANT_SURFACE_SPEED_OFF", getSpindle(false));
  }

  writeBlock(
    gSpindleModeModal.format(spindleMode),
    sOutput.format(spindleSpeed),
    spindleDir,
    pOutput.format(getCode("SELECT_SPINDLE", getSpindle(false)))
  );
  // wait for spindle here if required
}

function onCommand(command) {
  switch (command) {
  case COMMAND_COOLANT_OFF:
    setCoolant(COOLANT_OFF);
    break;
  case COMMAND_COOLANT_ON:
    setCoolant(COOLANT_FLOOD);
    break;
  case COMMAND_LOCK_MULTI_AXIS:
    writeBlock(cAxisBrakeModal.format(getCode("LOCK_MULTI_AXIS", getSpindle(true))));
    break;
  case COMMAND_UNLOCK_MULTI_AXIS:
    writeBlock(cAxisBrakeModal.format(getCode("UNLOCK_MULTI_AXIS", getSpindle(true))));
    break;
  case COMMAND_START_CHIP_TRANSPORT:
    writeBlock(mFormat.format(24));
    break;
  case COMMAND_STOP_CHIP_TRANSPORT:
    writeBlock(mFormat.format(25));
    break;
  case COMMAND_OPEN_DOOR:
    if (gotDoorControl) {
      writeBlock(mFormat.format(52)); // optional
    }
    break;
  case COMMAND_CLOSE_DOOR:
    if (gotDoorControl) {
      writeBlock(mFormat.format(53)); // optional
    }
    break;
  case COMMAND_BREAK_CONTROL:
    break;
  case COMMAND_TOOL_MEASURE:
    break;
  case COMMAND_ACTIVATE_SPEED_FEED_SYNCHRONIZATION:
    break;
  case COMMAND_DEACTIVATE_SPEED_FEED_SYNCHRONIZATION:
    break;
  case COMMAND_STOP:
    writeBlock(mFormat.format(0));
    forceSpindleSpeed = true;
    break;
  case COMMAND_OPTIONAL_STOP:
    writeBlock(mFormat.format(1));
    break;
  case COMMAND_END:
    writeBlock(mFormat.format(2));
    break;
  case COMMAND_STOP_SPINDLE:
    writeBlock(
      mFormat.format(getCode("STOP_SPINDLE", activeSpindle)),
      pOutput.format(getCode("SELECT_SPINDLE", activeSpindle))
    );
    sOutput.reset();
    break;
  case COMMAND_ORIENTATE_SPINDLE:
    if (machineState.isTurningOperation || machineState.axialCenterDrilling) {
      writeBlock(mFormat.format(getCode("ORIENT_SPINDLE", getSpindle(true))));
    } else {
      error(localize("Spindle orientation is not supported for live tooling."));
      return;
    }
    break;
  case COMMAND_SPINDLE_CLOCKWISE:
    writeBlock(mFormat.format(getCode("START_SPINDLE_CW", getSpindle(false))),
      pOutput.format(getCode("SELECT_SPINDLE", getSpindle(false)))
    );
    break;
  case COMMAND_SPINDLE_COUNTERCLOCKWISE:
    writeBlock(mFormat.format(getCode("START_SPINDLE_CCW", getSpindle(false))),
      pOutput.format(getCode("SELECT_SPINDLE", getSpindle(false)))
    );
    break;
  // case COMMAND_CLAMP: // add support for clamping
  // case COMMAND_UNCLAMP: // add support for clamping
  default:
    onUnsupportedCommand(command);
  }
}

/** Get synchronization/transfer code based on part cutoff spindle direction. */
function getSpindleTransferCodes(_transferType) {
  var transferCodes = {direction:0, spindleMode:0, surfaceSpeed:0, maximumSpindleSpeed:0};
  if (_transferType == TRANSFER_PHASE) {
    transferCodes.direction = getCode("SPINDLE_SYNCHRONIZATION_PHASE", getSecondarySpindle());
  } else {
    transferCodes.direction = getCode("SPINDLE_SYNCHRONIZATION_SPEED", getSecondarySpindle());
  }
  var numberOfSections = getNumberOfSections();
  for (var i = getNextSection().getId(); i < numberOfSections; ++i) {
    var section = getSection(i);
    if (section.hasParameter("operation-strategy")) {
      if (section.getParameter("operation-strategy") == "turningPart") {
        var tool = section.getTool();
        if (!tool.clockwise) {
          transferCodes.direction += 1;
        }
        transferCodes.spindleMode = tool.getSpindleMode();
        transferCodes.surfaceSpeed = tool.surfaceSpeed;
        transferCodes.maximumSpindleSpeed = tool.maximumSpindleSpeed;
        break;
      } else if (!(section.getParameter("operation-strategy") == "turningSecondarySpindleReturn")) {
        break;
      }
    } else {
      break;
    }
  }
  return transferCodes;
}

function getG17Code() {
  return machineState.usePolarMode ? 18 : 17;
}

function ejectPart() {
  writeln("");
  if (properties.sequenceNumberToolOnly) {
    writeCommentSeqno(localize("PART EJECT"));
  } else {
    writeComment(localize("PART EJECT"));
  }
  gMotionModal.reset();
  writeBlock(gMotionModal.format(0), gFormat.format(28), gFormat.format(53), "B" + abcFormat.format(0)); // retract bar feeder
  goHome(); // Position all axes to home position
  writeBlock(mFormat.format(getCode("UNLOCK_MULTI_AXIS", getSpindle(true))));
  if (!properties.optimizeCaxisSelect) {
    cAxisEnableModal.reset();
  }
  writeBlock(
    gFeedModeModal.format(getCode("FEED_MODE_MM_MIN", getSpindle(false))),
    gFormat.format(53 + currentWorkOffset),
    gPlaneModal.format(17),
    cAxisEnableModal.format(getCode("DISABLE_C_AXIS", getSpindle(true)))
  );
  setCoolant(COOLANT_THROUGH_TOOL);
  gSpindleModeModal.reset();
  writeBlock(
    gSpindleModeModal.format(getCode("CONSTANT_SURFACE_SPEED_OFF", getSpindle(true))),
    sOutput.format(50),
    mFormat.format(getCode("START_SPINDLE_CW", getSpindle(true))),
    pOutput.format(getCode("SELECT_SPINDLE", getSpindle(true)))
  );
  writeBlock(mFormat.format(getCode("INTERLOCK_BYPASS", getSpindle(true))));
  if (properties.gotPartCatcher) {
    writeBlock(mFormat.format(getCode("PART_CATCHER_ON", getSpindle(true))));
  }
  writeBlock(mFormat.format(getCode("UNCLAMP_CHUCK", getSpindle(true))));
  onDwell(1.5);
  writeBlock(mFormat.format(getCode("CYCLE_PART_EJECTOR")));
  onDwell(0.5);
  if (properties.gotPartCatcher) {
    writeBlock(mFormat.format(getCode("PART_CATCHER_OFF", getSpindle(true))));
    onDwell(1.1);
  }
  
  // clean out chips
  if (airCleanChuck) {
    writeBlock(mFormat.format(getCode("COOLANT_AIR_ON", getSpindle(true))));
    onDwell(2.5);
    writeBlock(mFormat.format(getCode("COOLANT_AIR_OFF", getSpindle(true))));
  }
  writeBlock(mFormat.format(getCode("STOP_SPINDLE", getSpindle(true))), pOutput.format(getCode("SELECT_SPINDLE", getSpindle(true))));
  setCoolant(COOLANT_OFF);
  writeComment(localize("END OF PART EJECT"));
  writeln("");
}

function engagePartCatcher(engage) {
  if (properties.gotPartCatcher) {
    if (engage) { // engage part catcher
      writeBlock(mFormat.format(getCode("PART_CATCHER_ON", true)), formatComment(localize("PART CATCHER ON")));
    } else { // disengage part catcher
      onCommand(COMMAND_COOLANT_OFF);
      writeBlock(mFormat.format(getCode("PART_CATCHER_OFF", true)), formatComment(localize("PART CATCHER OFF")));
    }
  }
}

function onSectionEnd() {

  if (machineState.usePolarMode) {
    setPolarMode(false); // disable polar interpolation mode
  }
  if (properties.gotPartCatcher && partCutoff && currentSection.partCatcher) {
    engagePartCatcher(false);
  }
  if (properties.cutoffConfirmation && partCutoff) {
    writeBlock(gFormat.format(350), formatComment("CONFIRM CUTOFF"));
    onDwell(0.5);
  }
  
/*
  // Handled in start of onSection
  if (!isLastSection()) {
    if ((getLiveToolingMode(getNextSection()) < 0) && !currentSection.isPatterned() && (getLiveToolingMode(currentSection) >= 0)) {
      writeBlock(cAxisEngageModal.format(getCode("DISABLE_C_AXIS", getSpindle(true))));
    }
  }
*/
  
  if (((getCurrentSectionId() + 1) >= getNumberOfSections()) ||
      (tool.number != getNextSection().getTool().number)) {
    onCommand(COMMAND_BREAK_CONTROL);
  }

/*
  // Handled in onSection
  if ((currentSection.getType() == TYPE_MILLING) &&
      (!hasNextSection() || (hasNextSection() && (getNextSection().getType() != TYPE_MILLING)))) {
    // exit milling mode
    if (isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, 1))) {
      // +Z
    } else if (isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, -1))) {
      // -Z
    } else {
      onCommand(COMMAND_STOP_SPINDLE);
    }
  }
*/

  forceXZCMode = false;
  forcePolarMode = false;
  partCutoff = false;
  forceAny();
}

function onClose() {

  optionalSection = false;
  if (stockTransferIsActive) {
    writeBlock(
      mFormat.format(getCode("SPINDLE_SYNCHRONIZATION_OFF", getSpindle(true))),
      pOutput.format(getCode("SELECT_SPINDLE", SPINDLE_MAIN))
    );
  } else {
    onCommand(COMMAND_STOP_SPINDLE);
    setCoolant(COOLANT_OFF);
  }

  // Cancel the reverse spindle code used in tapping
  if (reverseTap) {
    writeBlock(mFormat.format(177));
    reverseTap = false;
  }

  writeln("");

  if (properties.gotChipConveyor) {
    onCommand(COMMAND_STOP_CHIP_TRANSPORT);
  }

  gMotionModal.reset();
  if (gotSecondarySpindle) {
    writeBlock(gMotionModal.format(0), gFormat.format(28), gFormat.format(53), "B" + abcFormat.format(0)); // retract Sub Spindle if applicable
  }

  // Move to home position
  goHome();

  if (getSpindle(false) == SPINDLE_LIVE) {
    writeBlock(gFormat.format(28), "H" + abcFormat.format(0)); // unwind
    cAxisEngageModal.reset();
  }
  writeBlock(cAxisEngageModal.format(getCode("DISABLE_C_AXIS", getSpindle(true))));
  
  // Automatically eject part
  if (ejectRoutine) {
    ejectPart();
  }

  writeBlock(gFormat.format(54), mFormat.format(80));

  writeln("");
  onImpliedCommand(COMMAND_END);
  writeBlock(mInterferModal.format(getCode("INTERFERENCE_CHECK_ON", getSpindle(true))));
  if (properties.looping) {
    writeBlock(mFormat.format(54), formatComment(localize("Increment part counter"))); //increment part counter
    writeBlock(mFormat.format(99));
  } else {
    writeBlock(mFormat.format(30)); // stop program, spindle stop, coolant off
  }
  writeln("%");
}
