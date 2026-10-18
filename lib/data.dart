// Task wording is simplified from O*NET 31.0 task statements and occupation descriptions (onetonline.org).
// Each plain label keeps the O*NET statement it was based on in `onet`.

class TaskDef {
  final String label, onet;
  const TaskDef(this.label, this.onet);
}

class TradeDef {
  final String name, soc, emoji;
  final List<String> roles;
  final List<TaskDef> tasks;
  const TradeDef(this.name, this.soc, this.emoji, this.roles, this.tasks);
}

const roles = ['Helper', 'Apprentice', 'Journeyman', 'Foreman'];

const trades = <TradeDef>[
  TradeDef('Electrician', '47-2111.00', '⚡', roles, [
    TaskDef('Read blueprints and plan wiring', 'Prepare sketches or follow blueprints to determine the location of wiring or equipment and to ensure conformance to building and safety codes.'),
    TaskDef('Run conduit and pull wire', 'Place conduit, pipes, or tubing, inside designated partitions, walls, or other concealed areas, and pull insulated wires or cables through the conduit to complete circuits between boxes.'),
    TaskDef('Connect breakers and panels', 'Connect wires to circuit breakers, transformers, or other components.'),
    TaskDef('Install fixtures and devices', 'Assemble, install, test, or maintain electrical or electronic wiring, equipment, appliances, apparatus, or fixtures, using hand tools or power tools.'),
    TaskDef('Test circuits with a meter', 'Test electrical systems or continuity of circuits in electrical wiring, equipment, or fixtures, using testing devices, such as ohmmeters, voltmeters, or oscilloscopes, to ensure compatibility and safety of system.'),
    TaskDef('Work from ladders and lifts', 'Work from ladders, scaffolds, or roofs to install, maintain, or repair electrical wiring, equipment, or fixtures.'),
    TaskDef('Train or direct other workers', 'Direct or train workers to install, maintain, or repair electrical wiring, equipment, or fixtures.'),
  ]),
  TradeDef('Carpenter', '47-2031.00', '🪚', roles, [
    TaskDef('Measure and mark cuts', 'Measure and mark cutting lines on materials, using a ruler, pencil, chalk, and marking gauge.'),
    TaskDef('Cut material to size', 'Shape or cut materials to specified measurements, using hand tools, machines, or power saws.'),
    TaskDef('Frame walls, floors and roofs', 'Construct, erect, install, or repair structures and fixtures made of wood and comparable materials.'),
    TaskDef('Install doors, windows and trim', "Install structures or fixtures, such as windows, frames, floorings, trim, or hardware, using carpenters' hand or power tools."),
    TaskDef('Check plumb and level', 'Verify trueness of structure, using plumb bob and level.'),
    TaskDef('Build or repair cabinets', 'Build or repair cabinets, doors, frameworks, floors, or other wooden fixtures used in buildings, using woodworking machines, carpenter\'s hand tools, and power tools.'),
    TaskDef('Order lumber and materials', 'Select and order lumber or other required materials.'),
  ]),
  TradeDef('Plumber / Pipefitter', '47-2152.00', '🔧', roles, [
    TaskDef('Review plans and code', 'Review blueprints, building codes, or specifications to determine work details or procedures.'),
    TaskDef('Mark pipe and fixture locations', 'Locate and mark the position of pipe installations, connections, passage holes, or fixtures in structures.'),
    TaskDef('Cut and thread pipe', 'Cut, thread, or hammer pipes to specifications, using tools such as saws, cutting torches, pipe threaders, or pipe benders.'),
    TaskDef('Assemble pipe and fittings', 'Assemble pipe sections, tubing, or fittings, using couplings, clamps, screws, bolts, cement, plastic solvent, caulking, or brazing, soldering, and welding equipment.'),
    TaskDef('Install underground piping', 'Install underground storm, sanitary, or water piping systems, extending piping as needed to connect fixtures and appliances.'),
    TaskDef('Shut off and isolate lines', 'Shut off steam, water, or other gases or liquids from pipe sections, using valve keys or wrenches.'),
    TaskDef('Pressure test a system', 'Fill pipe systems with water or air and observe pressure gauges to detect and locate leaks.'),
  ]),
  TradeDef('Welder', '51-4121.00', '🔥', roles, [
    TaskDef('Weld flat, vertical or overhead', 'Weld components in flat, vertical, or overhead positions.'),
    TaskDef('Set up torches, rods and flux', 'Select and install torches, torch tips, filler rods, and flux, according to welding chart specifications or type and thickness of workpiece.'),
    TaskDef('Check fit-up and gaps', 'Check grooves, angles, or gap allowances, using micrometers, calipers, and precision measuring instruments.'),
    TaskDef('Inspect welds for defects', 'Examine workpieces for defects and measure workpieces with straightedges or templates to ensure conformance with specifications.'),
    TaskDef('Choose method and equipment', 'Determine required equipment and welding methods, applying knowledge of metallurgy, geometry, and welding techniques.'),
    TaskDef('Mark and tag material', 'Mark or tag material with proper job number, piece marks, and other identifying marks as required.'),
    TaskDef('Report faulty equipment', 'Detect faulty operation of equipment or defective materials and notify supervisors.'),
  ]),
];

const projectTypes = ['Apartments', 'Office / retail', 'School / hospital', 'Factory / plant', 'Single home', 'Road / utility'];
const vouchRoles = ['Foreman', 'Supervisor', 'Coworker', 'Instructor'];
