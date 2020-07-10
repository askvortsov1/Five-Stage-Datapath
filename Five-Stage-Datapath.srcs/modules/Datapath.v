`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Module Name: Datapath
//
// Description: Module that combines together all other individual datapath
//              modules. This module will expose all important signals (mostly
//              the pipeline saved data signals) to the testbench for simplified
//              waveform analysis.
////////////////////////////////////////////////////////////////////////////////


module Datapath(
    // Inputs
    input clock,
    // Outputs
    output [31:0] currentPC,
    output [31:0] savedInstruction,
    output eregisterWrite,
    output ememoryToRegister,
    output ememoryWrite,
    output [3:0] ealuControl,
    output ealuImmediate,
    output [4:0] edestination,
    output [31:0] eregisterQA,
    output [31:0] eregisterQB,
    output [31:0] eimmediateExtended
    );
    
    // Wire instantiation //////////////////////////////////////////////////////

    // Pipeline
    wire [31:0] nextPC;
    wire [31:0] immediateExtended;
    wire registerWrite;
    wire memoryToRegister;
    wire memoryWrite;
    wire [3:0] aluControl;
    wire aluImmediate;
    wire destinationRegisterRT;
    wire [31:0] registerQA;
    wire [31:0] registerQB;
    wire [4:0] destination;

    // Instruction Fetch
    wire [31:0] loadedInstruction;

    // Instruction Decode
    wire [5:0] opCode;
    assign opCode = savedInstruction[31:26];
    wire [5:0] funct;
    assign funct = savedInstruction[5:0];
    wire [4:0] rs;
    assign rs = savedInstruction[25:21];
    wire [4:0] rt;
    assign rt = savedInstruction[20:16];
    wire [4:0] rd;
    assign rd = savedInstruction[15:11];
    wire [4:0] shamt;
    assign shamt = savedInstruction[10:6];
    wire [15:0] immediate;
    assign immediate = savedInstruction[15:0];

    // Module instantiation ////////////////////////////////////////////////////

    // Pipeline
    ProgramCounter ProgramCounter(clock, nextPC, currentPC);
    IF_ID IF_ID(clock, loadedInstruction, savedInstruction);
    ID_EXE ID_EXE(
        clock,
        registerWrite,
        memoryToRegister,
        memoryWrite,
        aluControl,
        aluImmediate,
        destination,
        registerQA,
        registerQB,
        immediateExtended,
        eregisterWrite,
        ememoryToRegister,
        ememoryWrite,
        ealuControl,
        ealuImmediate,
        edestination,
        eregisterQA,
        eregisterQB,
        eimmediateExtended
    );

    // Instruction Fetch
    PCAdder PCAdder(currentPC, nextPC);
    InstructionMemory InstructionMemory(currentPC, loadedInstruction);

    // Instruction Decode
    ControlUnit ControlUnit(
        opCode,
        funct,
        registerWrite,
        memoryToRegister,
        memoryWrite,
        aluControl,
        aluImmediate,
        destinationRegisterRT
        );
    DestinationMux DestinationMux(rd, rt, destinationRegisterRT, destination);
    RegistryMemory RegistryMemory(clock, rs, rt, registerQA, registerQB);
    SignExtension SignExtension(immediate, immediateExtended);
endmodule
