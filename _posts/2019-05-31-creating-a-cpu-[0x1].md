---
layout: post
title:  "Creating a CPU [0x1]"
date:   2019-07-29 11:00:07 +0200
categories: code javascript CPU_create
description: "We'll be creating the first elements of the CPU. In Javascript."
---

In this second post about the creation of a CPU, we'll be creating the basic building blocks for the CPU, the little components, such as the memory or the ALU.

The bus is a little complicated, because it has to act as 8 wires, just holding a value as long as it is outputed to it, so creating it has been holding me back a bit. And I still haven't found a solution to this problem, but anyways I'm posting about the other stuff.

# Registers
Lets talk about how we can address them, and use them.
As well as the normal registers, the ALU is going to need two registers, A & B for example, A is going to hold the value to add (or anything) & B is going to hold the result.
So in our imaginary assembly language we could say:

```
MOV 0xff R0 ; here R0 = 0x0, just an alias
LDA R0 ; loads the value in R0 into the a register
ADD 0xfe ; Adds the value in the A register with the one in 0xfe
STB R1 ; stores the result in R1
```

# Let's code!
### Memory
The memory is just 8 bit numbers with 8 bit addresses. The thing is JS already has something that does this, it's called an array. What we should do is create a wrapper class that limits it to 8 bit:
```js
class RAM {
	constructor() {
		this._arr = new Array(256).fill(0) // Make it a byte in length, filled with 0s
	}

	get(index) {
		return this._arr[index & 255] // Limit the index to 8 bit
	}

	set(index, value) {
		this._arr[index & 255] = value & 255 // Limit the index & the value to 8 bit
	}
}
```
### ALU
We need to code each register & the alu itself
```js
class ALU {
	class Register {
		constructor() {
			this._val = 0;
		}

		set(val) {
			this._val = val & 255
		}

		get() {
			return this._val
		}
	}


	constructor() {
		this.aRegister = new Register()
		this.bRegister = new Register()
	}

	setA(val) {
		this.aRegister.set(val)
	}

	getB() {
		return this.bRegister.get()
	}

	add(val) {
		this.bRegister.set(val + this.aRegister.get())
	}
}
```

For now everything that comes from the bus is an argument, but it would be better if it took it from an object.

This post hasn't been much, but we've written some code for this CPU. Next post I'll be talking about the instructions and how to handle them.