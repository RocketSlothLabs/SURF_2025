import re
import pandas as pd
import argparse

# Fields we want to extract and their regex
regex_patterns = {
    "Particles Inserted": r"Particles inserted\s+= (\d+)",
    "DSMC Particles": r"Number of dsmc particles\s+= (\d+)",
    "Molecules": r"Number of molecules\s+= ([\deE\+\-\.]+)",
    "Mass": r"Mass in system\s+= ([\deE\+\-\.]+)",
    "Momentum Mag": r"\|Average linear momentum\|\s+= ([\deE\+\-\.]+)",
    "Kinetic Energy": r"Average linear kinetic energy\s+= ([\deE\+\-\.]+)",
    "Internal Energy": r"Average internal energy\s+= ([\deE\+\-\.]+)",
    "Total Energy": r"Average total energy\s+= ([\deE\+\-\.]+)",
}

# Match only valid "Time = ..." headers (not ExecutionTime etc.)
time_block_re = re.compile(r"\nTime = ([\deE\+\-\.]+)\n")

def parse_dsmc_log(log_text):
    data = []

    # Find all valid time blocks
    time_blocks = list(time_block_re.finditer(log_text))

    for i, match in enumerate(time_blocks):
        time_val = float(match.group(1))
        start = match.end()
        end = time_blocks[i + 1].start() if i + 1 < len(time_blocks) else None
        block = log_text[start:end]

        row = {"Time": time_val}
        for key, pattern in regex_patterns.items():
            found = re.search(pattern, block)
            row[key] = float(found.group(1)) if found else None

        data.append(row)

    return pd.DataFrame(data)

def main():
    parser = argparse.ArgumentParser(description="Parse OpenFOAM dsmcFoam log file.")
    parser.add_argument("logfile", help="Path to log.dsmcFoam file")
    parser.add_argument("-o", "--output", default="parsed_dsmc_log.csv",
                        help="Output CSV filename (default: parsed_dsmc_log.csv)")
    args = parser.parse_args()

    with open(args.logfile, "r") as f:
        log_text = f.read()

    df = parse_dsmc_log(log_text)
    df.to_csv(args.output, index=False)
    print(f"✅ Parsed data written to: {args.output}")

if __name__ == "__main__":
    main()
