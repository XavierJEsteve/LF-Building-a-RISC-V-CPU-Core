# Building a RISC-V CPU Core

The purpose of this repository is to demonstrate some of my understanding of the RISC-V ISA, starting with RISCV 32I. The makerchip IDE and some guidance were provided by the owner of the repo I've forked, stevehoover/LF-Building-a-RISC-V-CPU-Core. I found the course to be worthwhile, making me refer to my RISC-V texts (The RISC-V Reader) as well as pushing me to re-enter the world of HDL in a sleeker web-based IDE than I'm used to. TL-Verilog is a cool effort by the Redwood EDA team to make prototyping FPGA designs easier while I'm working from a macbook. Highly recommend giving both the course and the IDE a chance if you have previous experience or interest in this area of programming.

### Contents
My finished code that models a RISCV-32I core. 
Within /lib, some library files created by Steve Hoover that aid in testing and visualization in the Makerchip IDE.

Accompanying resources for the [Building a RISC-V CPU Core](https://www.edx.org/course/building-a-risc-v-cpu-core) [EdX](https://edx.org/) course by [Steve Hoover](https://www.linkedin.com/in/steve-hoover-a44b607/) of [Redwood EDA, LLC](https://redwoodeda.com), [Linux Foundation](https://www.linuxfoundation.org/), and [RISC-V International](https://riscv.org).

![VIZ](LF_VIZ.png)

## Getting Started

- Clone repo

- Install the makerchip ide using python via 

```bash
pip3 install makerchip-ide
```

- Launch makerchip ide in your browser
```bash
makerchip <filename>.tlv
```

### Final Core
![Final Core](lib/riscv.svg)


After completing this course, consider visiting the following.
  - Try the tutorials in [Makerchip](https://makerchip.com).
  - Learn more about [TL-Verilog](https://redwoodeda.com/tl-verilog).
