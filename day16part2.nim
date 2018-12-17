import strscans
import strutils
import sets
import tables


type Instruction = enum
    ADDR,
    ADDI,
    MULR,
    MULI,
    BANR,
    BANI,
    BORR,
    BORI,
    SETR,
    SETI,
    GTIR,
    GTRI,
    GTRR,
    EQIR,
    EQRI,
    EQRR

# contents of the data registers
type RegisterData = array[0..3, int]

# a command that can be executed on the VM
type InstructionData = tuple[instruction: Instruction, a: int, b: int, c: int]

# Sample input data, we don't know the instruction yet
type RawInstructionData = array[0..3, int]
type Sample = tuple[rawinst: RawInstructionData, before: RegisterData, after: RegisterData]
type SampleResult = tuple[rawinst: int, possible: HashSet[Instruction]]

# mapping from opcode to Instruction
type InstructionMapping = Table[int, Instruction]


proc firstValue[T](input: HashSet[T]): T =
    # returns the value in a HashSet
    for value in input.items:
        return value


proc readRegisterData(line: string): RegisterData =
    if(scanf(line.strip(), "Before: [$i, $i, $i, $i]", result[0], result[1], result[2], result[3])):
        return result
    if(scanf(line.strip(), "After:  [$i, $i, $i, $i]", result[0], result[1], result[2], result[3])):
        return result


proc readInstruction(line: string): RawInstructionData =
    if(scanf(line.strip(), "$i $i $i $i", result[0], result[1], result[2], result[3])):
        return result


proc runInstruction(inst: InstructionData, registers: RegisterData): RegisterData =
    # the VM itself
    result = registers

    case inst.instruction:
        of ADDR:
            result[inst.c] = registers[inst.a] + registers[inst.b]
        of ADDI:
            result[inst.c] = registers[inst.a] + inst.b
        of MULR:
            result[inst.c] = registers[inst.a] * registers[inst.b]
        of MULI:
            result[inst.c] = registers[inst.a] * inst.b
        of BANR:
            result[inst.c] = registers[inst.a] and registers[inst.b]
        of BANI:
            result[inst.c] = registers[inst.a] and inst.b
        of BORR:
            result[inst.c] = registers[inst.a] or registers[inst.b]
        of BORI:
            result[inst.c] = registers[inst.a] or inst.b
        of SETR:
            result[inst.c] = registers[inst.a]
        of SETI:
            result[inst.c] = inst.a
        of GTIR:
            result[inst.c] = 0
            if inst.a > registers[inst.b]:
                result[inst.c] = 1
        of GTRI:
            result[inst.c] = 0
            if registers[inst.a] > inst.b:
                result[inst.c] = 1
        of GTRR:
            result[inst.c] = 0
            if registers[inst.a] > registers[inst.b]:
                result[inst.c] = 1
        of EQIR:
            result[inst.c] = 0
            if inst.a == registers[inst.b]:
                result[inst.c] = 1
        of EQRI:
            result[inst.c] = 0
            if registers[inst.a] == inst.b:
                result[inst.c] = 1
        of EQRR:
            result[inst.c] = 0
            if registers[inst.a] == registers[inst.b]:
                result[inst.c] = 1


proc runSampleInstructions(sample: Sample): SampleResult =
    result.rawinst = sample.rawinst[0]
    result.possible = initSet[Instruction]()

    for instruction in ord(low(Instruction))..ord(high(Instruction)):
        var inst: InstructionData
        inst.instruction = Instruction(instruction)
        inst.a = sample.rawinst[1]
        inst.b = sample.rawinst[2]
        inst.c = sample.rawinst[3]
        var actual = runInstruction(inst, sample.before)
        if sample.after == actual:
            result.possible.incl(inst.instruction)


iterator readInputPartOne(lines: seq[string]): Sample =
    var i = 0
    while i < lines.len:
        if lines[i].len == 0:
            break

        var before = readRegisterData(lines[i])
        var instructions = readInstruction(lines[i+1])
        var after = readRegisterData(lines[i+2])
        i += 4

        yield (rawinst: instructions, before: before, after: after)


proc partOne(input: string): int =
    var lines = input.splitLines()
    for sample in readInputPartOne(lines):
        var r: SampleResult = sample.runSampleInstructions()
        if card(r.possible) >= 3:
            result += 1


proc partTwoMapping(input: string): InstructionMapping =
    # works out mapping from opcode to Instruction

    var instMapping: Table[int, HashSet[Instruction]] = initTable[int, HashSet[Instruction]]()

    # any opcode could be any instruction
    for i in countup(0, 15):
        instMapping[i] = initSet[Instruction]()
        for instruction in items(Instruction):
            instMapping[i].incl(Instruction(instruction))

    # after running sample instructions, remove any that do not match
    for sample in readInputPartOne(input.splitLines()):
        var r = runSampleInstructions(sample)
        instMapping[r.rawinst] = instMapping[r.rawinst] * r.possible

    # deduce any opcodes that only match a single instruction
    result = initTable[int, Instruction]()
    while len(result) < 16:
        for instruction, possibilities in instMapping.pairs:
            if len(possibilities) == 1:
                result[instruction] = firstValue(possibilities)

        # remove any found opcodes from other possibilities
        for f in result.values:
            for instruction, possibilities in instMapping.mpairs:
                if len(possibilities) > 1:
                    possibilities.excl(f)


    for instruction, possibilities in instMapping.pairs:
        result[instruction] = firstValue(possibilities)


proc toInstruction(rawinst: RawInstructionData, mapping: InstructionMapping): InstructionData =
    result.instruction = mapping[rawinst[0]]
    result.a = rawinst[1]
    result.b = rawinst[2]
    result.c = rawinst[3]


proc partTwo(mapping: InstructionMapping, code: string): RegisterData =
    var registers: RegisterData
    for line in code.splitLines():
        var inst = line.readInstruction().toInstruction(mapping)
        registers = runInstruction(inst, registers)
    return registers


var testData = """Before: [3, 2, 1, 1]
9 2 1 2
After:  [3, 2, 2, 1]"""
assert(partOne(testData) == 1)

echo partOne(readFile("day16part1.input"))

var mapping = partTwoMapping(readFile("day16part1.input"))
echo partTwo(mapping, readFile("day16part2.input"))