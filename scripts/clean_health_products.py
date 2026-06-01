#!/usr/bin/env python3
"""
Task 2: Production-Grade Python (Data Cleaning)
Goal: Process health_products.txt into a clean CSV.
"""

import os
import pandas as pd

INPUT_FILE = "data_files/health_products.txt"
OUTPUT_FILE = "data_files/health_products_clean.csv"

def clean_health_products(input_file: str, output_file: str) -> None:
    """
    Reads a pipe-delimited text file with a metadata header,
    discovers schema dynamically, and writes a clean CSV.
    Idempotent: safe to run multiple times.
    """

    # Step 1: Read all lines
    with open(input_file, "r", encoding="utf-8") as f:
        lines = f.readlines()

    # Step 2: Skip metadata header (first line starts with --- CONFIDENTIAL)
    data_lines = [line for line in lines if not line.strip().startswith("---")]

    # Step 3: Discover schema programmatically
    # Use the first valid record to infer number of columns
    sample_fields = data_lines[0].strip().split("|")
    num_cols = len(sample_fields)
    header = ["product_id", "product_name", "tier", "status"]

    # Step 4: Parse records
    records = [line.strip().split("|") for line in data_lines]

    # Step 5: Build DataFrame
    df = pd.DataFrame(records, columns=header)

    # Step 6: Clean data
    df = df.applymap(lambda x: x.strip() if isinstance(x, str) else x)
    df = df.drop_duplicates()
    df = df.fillna("")

    # Normalize product_id casing
    df["product_id"] = df["product_id"].str.upper()

    # Step 7: Idempotent write (overwrite safely)
    df.to_csv(output_file, index=False)

    print(f" Clean CSV written to {output_file}")


if __name__ == "__main__":
    if not os.path.exists(INPUT_FILE):
        raise FileNotFoundError(f"Input file not found: {INPUT_FILE}")
    clean_health_products(INPUT_FILE, OUTPUT_FILE)
