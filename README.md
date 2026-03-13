# INT8 MAC Processing Element — Full ASIC Flow on SKY130 PDK

A pipelined INT8 Multiply-Accumulate (MAC) Processing Element taken through 
the complete open-source ASIC flow — RTL to GDSII — targeting GlobalFoundries 
SKY130 HD standard cell library using open-source EDA tools.

---

## Key Results

| Metric | Value |
|--------|-------|
| Target Frequency | 200 MHz |
| Setup WNS (TT/25°C/1.8V) | +0.69 ns |
| Critical Path (pre-pipeline) | 5.56 ns |
| Critical Path (post-pipeline) | 4.60 ns |
| Core Area | 20,822 µm² |
| Total Power (TT corner) | 2.61 mW |
| DRC Violations | 0 |
| LVS Violations | 0 |
| Antenna Violations | 0 |

---

## ASIC Flow
```
RTL (SystemVerilog)
      │
      ▼
Synthesis — Yosys + SKY130 liberty
      │
      ▼
Static Timing Analysis — OpenSTA
      │
      ▼
Place & Route — OpenLane 2 + OpenROAD
      │
      ▼
Signoff — Magic DRC, Netgen LVS, Antenna check
      │
      ▼
GDSII Layout
```

---

## Pipeline Optimization

The initial single-cycle MAC had a 5.56 ns critical path — failing 200 MHz timing.

**Root cause:** Combinational multiply and accumulate in one clock cycle created 
a 17-gate deep path through the 32-bit adder chain.

**Fix:** Split into 2-stage pipeline:
```
Stage 1 (Cycle N)   : product_reg <= a_in * b_in
Stage 2 (Cycle N+1) : psum        <= psum + product_reg
```

**Result:** Critical path reduced from 5.56 ns to 4.60 ns — 200 MHz timing closure achieved.

---

## Regression Results

Perl-based regression across 4 OpenLane configurations:

| Run | Period | Density | Area (µm²) | Power (mW) | WNS (ns) | DRC |
|-----|--------|---------|------------|------------|----------|-----|
| reg_run1 | 5ns | 0.45 | 20822 | 2.608 | 0.00 | 0 |
| reg_run2 | 6ns | 0.45 | 20822 | 2.128 | 0.00 | 0 |
| reg_run3 | 5ns | 0.55 | 20822 | 2.779 | 0.00 | 0 |
| reg_run4 | 4ns | 0.45 | 20822 | 3.449 | 0.00 | 0 |

**Optimal:** reg_run1 — 200 MHz target met, lowest power among 200 MHz runs.

**Key finding:** Tighter timing constraints increase power due to faster cell 
selection by the synthesis tool. Higher placement density increases switching 
power due to longer interconnect wires.

---

## Repository Structure
```
pe_asic/
├── rtl/
│   └── PE.sv              # Pipelined MAC PE — SystemVerilog
├── tb/
│   └── PE_tb.sv           # Self-checking testbench — randomized inputs
├── syn/
│   └── scripts/
│       └── syn_pe.ys      # Yosys synthesis script — SKY130 liberty mapping
├── sta/
│   ├── constraints/
│   │   └── pe.sdc         # SDC timing constraints — 200 MHz clock
│   ├── run_sta.tcl        # OpenSTA script
│   └── reports/
│       └── sta_report.txt # Setup/Hold timing report
├── pnr/
│   └── config/
│       ├── PE.sv          # RTL copy for OpenLane
│       └── config.json    # OpenLane 2 configuration
└── perl/
    ├── parse_syn.pl       # Parses Yosys synthesis report
    ├── clean_netlist.pl   # Removes duplicate declarations for OpenSTA
    ├── parse_metrics.pl   # Extracts PPA from OpenLane metrics.csv
    └── regression.pl      # Runs multiple OpenLane configs, compares PPA
```

---

## How to Run

### Prerequisites
- OSS CAD Suite (Yosys, Icarus Verilog)
- OpenSTA (built from source)
- OpenLane 2 via Nix
- SKY130 PDK via volare

### 1. Simulation
```bash
iverilog -g2012 -o tb/sim tb/PE_tb.sv rtl/PE.sv
vvp tb/sim
```

### 2. Synthesis
```bash
yosys syn/scripts/syn_pe.ys
perl perl/parse_syn.pl
```

### 3. Static Timing Analysis
```bash
sta -exit sta/run_sta.tcl
```

### 4. Place and Route
```bash
cd pnr/config
nix run github:efabless/openlane2 -- --run-tag PE_run config.json
perl ../../perl/parse_metrics.pl
```

### 5. Regression
```bash
perl perl/regression.pl
```

---

## Tools Used

| Tool | Version | Purpose |
|------|---------|---------|
| Yosys | 0.58+74 | RTL Synthesis |
| OpenSTA | 3.0.0 | Static Timing Analysis |
| OpenLane 2 | 2.3.10 | Place & Route Flow |
| OpenROAD | — | Placement, CTS, Routing |
| Magic | — | DRC Signoff |
| Netgen | — | LVS Signoff |
| SKY130 PDK | 0fe599b2 | Target Technology |
| Icarus Verilog | 14.0 | RTL Simulation |

---

## About

This project is part of a portfolio demonstrating complete open-source ASIC 
implementation skills — from RTL design and pipeline optimization through 
physical implementation and signoff on a real process design kit.

**Author:** Anil Sanneboyina  
**LinkedIn:** [linkedin.com/in/sanneboyina-anil](https://linkedin.com/in/sanneboyina-anil)
