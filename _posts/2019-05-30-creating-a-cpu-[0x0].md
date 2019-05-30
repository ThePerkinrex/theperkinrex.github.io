---
layout: post
title:  "Creating a CPU [0x0]"
date:   2019-05-30 15:09:07 +0200
categories: design CPU_create
description: "I'll be designing & creating a simulator for a CPU"
---
This is the start of a series of posts where I'll be trying to design & create a simulator for a CPU. The only experience I have doing this is from creating the [Armes CPU](https://github.com/theperkinrex/armescpu), so don't expect an expert, just someone trying to learn a bit. The [Ben Eater](https://www.youtube.com/channel/UCS0N5baNlQWJCUrhCEo8WlA) series on creating a CPU helped a lot with this process.

I'll be designing a simple CPU:
 * 16 general purpose registers allocated in the first 16 addresses
 * 8 bit ram addresses
 * 8 bit data (For each register/ram address and bus)
 * 8 bit instructions
 * ROM with microinstructions assigned for each instruction cycle
 * 3 bit (8) microinstruction cycles per instruction

This will give me 256 bytes of memory to work with and 256 instructions. The first 16 addresses of the ram will be allocated for the registers, therefore unusable for storing the program or constants.

The CPU will also have an ALU (Arithmetic logic unit), a program counter, setting the instruction address, an instruction register for the instruction in question, and two data registers for storing intruction data

# *CPU layout*
<img src="/assets/posts/CPU_layout.png" alt="CPU layout image" style="width: 30vw">

# *Memory layout*
<img src="/assets/posts/memlayout.png" alt="Memory layout image" style="width: 30vw">

The program will expand downwards onto the empty space, and the data will expand upwards onto the empty space.

Intructions may use 1, 2, or 3 memory addresses depending on the instruction. The first address will always be the instruction, and the second and third may be used as arguments (RAM addresses for data).

The ROM is going to be for now:
 * 11 bit addresses (8 bit instruction + 3 bit microinstruction cycle)
 * X bit data, depending on how many microinstructions there are

Later I might add a flags register, but it isn't important for now. That would enable the CPU to be turing complete,as there would be conditionals. That would be added to the ROM address for more control over the microinstructions.

## Hey, you're talking about microinstructions, what are they?
They are the little flags that set components on the CPU to do stuff, for example, `RCO` (RAM contents out) would put whatever is on the address of the RAM Address register and put it on the bus. There would be a lot more of this, one for each action a component can do

