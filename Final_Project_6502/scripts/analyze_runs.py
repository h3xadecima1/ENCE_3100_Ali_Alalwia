#!/usr/bin/env python3
"""
====================================================================
6502 RUN ANALYZER + OPCODE CATEGORY PROFILER
====================================================================
Adds:
  • Opcode histogram grouped by functional category
  • Color-coded visualization
  • Extended CSV with per-category counts
====================================================================
"""

import os, re, json, csv
from collections import Counter, defaultdict
import matplotlib.pyplot as plt

RUNS_DIR = "./runs"
CSV_EXPORT = "./runs_summary.csv"

# ---------------------------------------------------------------------
# 1. Opcode category map (standard 6502 + illegal)
# ---------------------------------------------------------------------
CATEGORY_MAP = {
    # Arithmetic / Logic
    **{k: "Arithmetic" for k in [
        "69","65","75","6D","7D","79","61","71",   # ADC
        "E9","E5","F5","ED","FD","F9","E1","F1",   # SBC
        "29","25","35","2D","3D","39","21","31",   # AND
        "09","05","15","0D","1D","19","01","11",   # ORA
        "49","45","55","4D","5D","59","41","51",   # EOR
        "C9","C5","D5","CD","DD","D9","C1","D1"    # CMP
    ]},
    # Memory / Load / Store
    **{k: "Memory" for k in [
        "A9","A5","B5","AD","BD","B9","A1","B1",   # LDA
        "85","95","8D","9D","99","81","91",       # STA
        "A2","A6","B6","AE","BE",                 # LDX
        "86","96","8E",                           # STX
        "A0","A4","B4","AC","BC",                 # LDY
        "84","94","8C"                            # STY
    ]},
    # Stack
    **{k: "Stack" for k in ["48","68","08","28","9A","BA","40","60"]},
    # Branch
    **{k: "Branch" for k in [
        "10","30","50","70","90","B0","D0","F0","4C","6C","20"
    ]},
    # Flags / System
    **{k: "System" for k in [
        "18","38","58","78","B8","D8","F8","EA","00"
    ]},
    # Illegal (undocumented)
    **{k: "Illegal" for k in [
        "02","12","22","32","42","52","62","72","92","B2","C2","E2",
        "44","54","D4","F4","5A","DA","7A","FA","80","CB","EB"
    ]}
}

COLORS = {
    "Arithmetic":"#4e79a7",
    "Memory":"#59a14f",
    "Stack":"#f28e2b",
    "Branch":"#edc948",
    "System":"#b07aa1",
    "Illegal":"#e15759",
    "Other":"#bab0ac"
}

# ---------------------------------------------------------------------
# 2. Load run JSONs
# ---------------------------------------------------------------------
def load_runs():
    runs=[]
    for root,_,files in os.walk(RUNS_DIR):
        for f in files:
            if f.startswith("run_summary_") and f.endswith(".json"):
                p=os.path.join(root,f)
                try:
                    d=json.load(open(p))
                    d["json_path"]=p; d["run_dir"]=root
                    runs.append(d)
                except: pass
    runs.sort(key=lambda x:x.get("timestamp",""))
    return runs

# ---------------------------------------------------------------------
# 3. Extract opcodes from log
# ---------------------------------------------------------------------
def parse_opcodes(logfile):
    r=re.compile(r"opcode\s*[:=]?\s*([0-9A-Fa-f]{2})")
    c=Counter()
    if not os.path.exists(logfile): return c
    for line in open(logfile):
        m=r.search(line)
        if m: c[m.group(1).upper()]+=1
    return c

# ---------------------------------------------------------------------
# 4. Categorize opcodes
# ---------------------------------------------------------------------
def categorize(freqs):
    cat_count=defaultdict(int)
    for op,count in freqs.items():
        cat=CATEGORY_MAP.get(op,"Other")
        cat_count[cat]+=count
    return cat_count

# ---------------------------------------------------------------------
# 5. CSV Export
# ---------------------------------------------------------------------
def export_csv(runs,cat_counts):
    keys=["timestamp","cpi","frequency_mhz","delta_opcodes","total_cycles","sim_time_us"]
    all_cats=sorted({c for r in cat_counts for c in r.keys()})
    with open(CSV_EXPORT,"w",newline="") as f:
        w=csv.writer(f)
        w.writerow(keys+all_cats)
        for run,cc in zip(runs,cat_counts):
            row=[run.get(k,"") for k in keys]+[cc.get(c,0) for c in all_cats]
            w.writerow(row)
    print(f"[+] Exported CSV: {CSV_EXPORT}")

# ---------------------------------------------------------------------
# 6. Plots
# ---------------------------------------------------------------------
def plot_trends(runs):
    if not runs: return
    idx=range(1,len(runs)+1)
    ts=[r["timestamp"] for r in runs]
    cpi=[float(r["cpi"]) if r["cpi"]!="N/A" else 0 for r in runs]
    mhz=[r["frequency_mhz"] for r in runs]
    dop=[r["delta_opcodes"] for r in runs]
    fig,axs=plt.subplots(3,1,figsize=(10,10)); plt.subplots_adjust(hspace=0.4)
    axs[0].plot(idx,cpi,'o-',color='tab:blue'); axs[0].set_title("CPI per Run")
    axs[1].plot(idx,mhz,'s-',color='tab:green'); axs[1].set_title("Effective MHz")
    axs[2].bar(idx,dop,color='tab:orange'); axs[2].set_title("Δ Opcodes per Run")
    for a in axs: a.grid(True); a.set_xticks(list(idx)); a.set_xticklabels(ts,rotation=45,ha="right",fontsize=8)
    plt.tight_layout(); plt.show()

def plot_categories(cat_total):
    labels=list(cat_total.keys()); counts=[cat_total[k] for k in labels]
    colors=[COLORS.get(k,COLORS["Other"]) for k in labels]
    plt.figure(figsize=(8,6))
    plt.bar(labels,counts,color=colors)
    plt.title("Opcode Category Distribution (Latest Run)")
    plt.ylabel("Instruction Count")
    plt.grid(True,axis="y"); plt.tight_layout(); plt.show()

# ---------------------------------------------------------------------
# 7. Main
# ---------------------------------------------------------------------
def main():
    runs=load_runs()
    if not runs:
        print("No runs found.")
        return
    print(f"Analyzing {len(runs)} run(s)...")

    cat_counts=[]
    for r in runs:
        op=parse_opcodes(r["current_log"])
        cat_counts.append(categorize(op))

    export_csv(runs,cat_counts)
    plot_trends(runs)

    latest_cat=cat_counts[-1]
    total=sum(latest_cat.values())
    print("\nOpcode Categories (latest run):")
    for k,v in latest_cat.items():
        pct=(v/total*100) if total else 0
        print(f"  {k:<10}: {v:>6} ({pct:5.1f}%)")
    plot_categories(latest_cat)

if __name__=="__main__":
    main()
