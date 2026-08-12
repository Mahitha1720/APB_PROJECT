# APB Master Verification Project

## Overview

This project focuses on the **verification of an AMBA APB Master** using a SystemVerilog-based verification environment.

The testbench generates constrained-random APB transactions, drives them to the APB Master DUT, monitors the DUT inputs and outputs, and checks the results using a scoreboard.

## DUT

- `apb_master.sv` – APB Master DUT

The verification environment checks APB Master functionality including:
- Read and write transfers
- APB SETUP and ACCESS phases
- PREADY wait states
- PSLVERR error responses
- Address and data transfers
- Transfer completion

## Testbench Components

- `apb_top.sv` – Top-level testbench
- `apb_interface.sv` – Interface and clocking blocks
- `apb_transaction.sv` – Transaction class and constraints
- `apb_generator.sv` – Generates randomized APB transactions
- `apb_driver.sv` – Drives transactions to the DUT
- `apb_input_monitor.sv` – Monitors input-side transactions and collects functional coverage
- `apb_output_monitor.sv` – Monitors APB Master outputs and collects functional coverage
- `apb_scoreboard.sv` – Checks expected versus actual DUT behavior
- `apb_environment.sv` – Instantiates and connects testbench components
- `apb_test.sv` – Test class
- `apb_package.sv` – Packages the verification components
- `defines.sv` – Common parameters and macros

## Verification Features

- Constrained-random stimulus generation
- APB Master read/write verification
- APB protocol phase verification
- PREADY wait-state verification
- PSLVERR error-response verification
- Functional coverage using covergroups, coverpoints and crosses
- DUT code coverage
- Scoreboard-based result checking

## Compilation

```bash
vlog -sv +incdir+. defines.sv apb_package.sv apb_top.sv
