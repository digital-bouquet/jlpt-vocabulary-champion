#!/usr/bin/env python3
"""
Parse JLPT vocabulary data from Wiktionary HTML files.
Extracts ALL words, readings, and meanings into JSON format.
"""

import re
import json
from pathlib import Path
from html import unescape

def parse_html_file(filepath):
    """Parse a single Wiktionary HTML file and extract ALL vocabulary."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    words = []

    # Find all tables in the document
    table_pattern = r'<table class="wikitable sortable">(.*?)</table>'
    tables = re.findall(table_pattern, content, re.DOTALL)

    for table in tables:
        # Extract all table rows (except header)
        row_pattern = r'<tr>(.*?)</tr>'
        rows = re.findall(row_pattern, table, re.DOTALL)

        for row in rows:
            # Skip header row
            if '<th>' in row:
                continue

            # Extract cells
            cell_pattern = r'<td[^>]*>(.*?)</td>'
            cells = re.findall(cell_pattern, row, re.DOTALL)

            if len(cells) >= 3:
                # Extract kanji/word from first cell
                kanji_match = re.search(r'title="([^"]*)"', cells[0])
                kanji_link_match = re.search(r'href="[^"]*" title="([^"]*)"', cells[0])
                if kanji_link_match:
                    kanji = kanji_link_match.group(1)
                elif kanji_match:
                    kanji = kanji_match.group(1)
                else:
                    # Try to get text content
                    kanji_text = re.sub(r'<[^>]+>', '', cells[0])
                    kanji = kanji_text.strip()

                # Extract reading from second cell
                reading_match = re.search(r'title="([^"]*)"', cells[1])
                reading_link_match = re.search(r'href="[^"]*" title="([^"]*)"', cells[1])
                if reading_link_match:
                    reading = reading_link_match.group(1)
                elif reading_match:
                    reading = reading_match.group(1)
                else:
                    reading_text = re.sub(r'<[^>]+>', '', cells[1])
                    reading = reading_text.strip()

                # Extract meaning from third cell
                meaning_text = re.sub(r'<[^>]+>', '', cells[2])
                meaning = meaning_text.strip()

                # Clean up meaning - remove numbered definitions like [1] xxx [2] yyy
                meaning = re.sub(r'\[\d+\]', '', meaning)
                meaning = re.sub(r'\s+', ' ', meaning)
                meaning = meaning.strip()

                # Clean up any HTML entities
                meaning = unescape(meaning)

                if kanji and reading and meaning and len(kanji) > 0:
                    words.append({
                        "word": kanji,
                        "reading": reading,
                        "meaning": meaning,
                        "level": ""
                    })

    return words


def main():
    base_dir = Path(".")

    levels = ["N5", "N4", "N3", "N2", "N1"]

    all_words_by_level = {}

    for level in levels:
        html_file = base_dir / f"{level}.html"

        if not html_file.exists():
            print(f"Warning: {html_file} not found, skipping...")
            continue

        print(f"Parsing {level}...")
        words = parse_html_file(html_file)
        print(f"  Found {len(words)} words")

        # Add level to each word
        for word in words:
            word["level"] = level.lower()

        all_words_by_level[level.lower()] = words

        # Write individual level JSON
        json_file = base_dir / f"vocabulary_{level.lower()}.json"
        with open(json_file, 'w', encoding='utf-8') as f:
            json.dump(words, f, ensure_ascii=False, indent=2)
        print(f"  Saved to {json_file}")

    # Write combined file
    all_words = []
    for level in levels:
        all_words.extend(all_words_by_level.get(level.lower(), []))

    combined_file = base_dir / "vocabulary_all.json"
    with open(combined_file, 'w', encoding='utf-8') as f:
        json.dump(all_words, f, ensure_ascii=False, indent=2)

    print(f"\nTotal words across all levels: {len(all_words)}")
    print(f"Combined file saved to {combined_file}")

    # Print breakdown by level
    print("\nBreakdown by level:")
    for level in levels:
        count = len(all_words_by_level.get(level.lower(), []))
        print(f"  {level}: {count} words")


if __name__ == "__main__":
    main()
