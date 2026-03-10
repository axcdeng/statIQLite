import re
import json
import os

def clean_text(text):
    text = re.sub(r'\n{3,}', '\n\n', text)
    text = re.sub(r'\$\{\s*\\\\?tt\s*(<[A-Z0-9]+>)\s*\}\$', r'\1', text)
    text = re.sub(r'\$\{\s*<\s*\}\s*\\\\mathsf\s*\{\s*([A-Z\s0-9]+)\s*\}\s*\{\s*>\s*\}', lambda m: f"<{m.group(1).replace(' ', '')}>", text)
    text = re.sub(r'\$\\\\mathtt\s*\{\s*(<[A-Z0-9]+>)\s*\}\$', r'\1', text)
    text = re.sub(r'\\\\mathsf\s*\{\s*([A-Z\s0-9]+)\s*\}', lambda m: m.group(1).replace(' ', ''), text)
    text = re.sub(r'\$\{\s*<\s*\}\s*([A-Z\s0-9]+)\s*>\s*\$', lambda m: f"<{m.group(1).replace(' ', '')}>", text)
    text = re.sub(r'^[\u25cf\u2022]\s+', '* ', text, flags=re.MULTILINE)
    text = re.sub(r'\n\n(\*|\d+\.) ', r'\n\1 ', text)
    
    # Fix flattened nested lists (convert 1. 2. 1. 2. to 1. 2. a. b.)
    lines = text.split("\n")
    out = []
    list_stack = []
    
    for line in lines:
        m = re.match(r"^(\d+)\.\s+(.*)", line)
        if m:
            num = int(m.group(1))
            content = m.group(2)
            
            # Start a sublist if we see '1.' and the previous line suggests a list or is text ending in colon
            if num == 1 and out and re.match(r"^(?:\s*\d+\.\s.*|.*:)$", out[-1].strip()):
                 if not list_stack:
                     list_stack.append(1)
                 list_stack.append(num)
            
            if list_stack:
                level = len(list_stack) - 1
                if num == list_stack[-1]:
                    list_stack[-1] += 1
                else:
                    while len(list_stack) > 1 and num != list_stack[-1]:
                        list_stack.pop()
                        level = len(list_stack) - 1
                    if num == list_stack[-1]:
                        list_stack[-1] += 1
                    else:
                        # Reset if it doesn't match the stack
                        list_stack = [num + 1]
                        level = 0
                    
                indent = "    " * level
                if level > 0:
                    letter = chr(ord("a") + num - 1) if num <= 26 else str(num)
                    out.append(f"{indent}{letter}. {content}")
                else:
                    out.append(f"{indent}{num}. {content}")
            else:
                 list_stack = [num + 1]
                 out.append(f"{num}. {content}")
        else:
            if line.strip() == "":
                list_stack = [] # blank line breaks list sequence
            out.append(line)
            
    text = "\n".join(out)
    return text.strip()


def parse_manual(markdown_path, output_path):
    with open(markdown_path, 'r', encoding='utf-8') as f:
        try:
            full_json = json.load(f)
            content = full_json.get('markdown', full_json.get('data', {}).get('markdown', str(full_json)))
            if isinstance(full_json, dict) and 'markdown' not in full_json and 'data' not in full_json:
                 content = str(full_json)
        except json.JSONDecodeError:
            f.seek(0)
            content = f.read()

    # If it's a JSON string output from MCP we might need to parse it cleanly.
    if content.startswith('{"markdown":'):
         match = re.search(r'"markdown":\s*"(.*)"\}?$', content, re.DOTALL)
         if match:
             content = match.group(1).encode('utf-8').decode('unicode_escape')

    content = clean_text(content)
    rules = []
    
    # 1. Extract rule basic info from Quick Reference tables. Match `| [<SC1>](url) | Title |`
    ref_table_pattern = re.compile(r'\|\s*\[?(<[A-Z0-9]+>)\]?(?:\([^)]+\))?\s*\|\s*([^|]+)\s*\|')
    for match in ref_table_pattern.finditer(content):
        rule_id, rule_title = match.groups()
        
        # strip markdown links from title if any
        rule_title = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', rule_title)

        rules.append({
            "id": rule_id.strip(),
            "title": rule_title.strip(),
            "description": "",
            "type": "rule"
        })

    # 2. Extract Definitions
    def_sections = re.split(r'# (?:General|Game-Specific) Definitions', content)
    if len(def_sections) > 1:
        for section in def_sections[1:]:
            sub_content = section.split('\n#')[0]
            definition_pattern = re.compile(r'^([A-Z][a-zA-Z\s\-]+)\s*[\-—]\s*(.*)$', re.MULTILINE)
            for match in definition_pattern.finditer(sub_content):
                term, definition = match.groups()
                if len(term.strip()) > 3 and len(definition.strip()) > 10 and not term.startswith('Figure'):
                    rules.append({
                        "id": term.strip(),
                        "title": term.strip(),
                        "description": clean_text(definition),
                        "type": "definition"
                    })

    # 3. Find rule descriptions using headers like `##### <SC4>`
    for rule in rules:
        if rule["type"] == "rule":
            id_esc = re.escape(rule["id"])
            # Match `##### <ID> \n\n (description)` up to the next `#`
            # Look for exact header `##### <ID>`
            pattern = re.compile(fr'(?:^|\n)#####\s+{id_esc}\s*(.*?)(?=\n#|\Z)', re.DOTALL | re.IGNORECASE)
            match = pattern.search(content)
            
            if match:
                desc = match.group(1).strip()
                # Remove redundant `<ID>` at the start of the description if present
                desc = re.sub(fr'^{id_esc}\s*', '', desc).strip()
                # Remove markdown links inside the description for cleaner text
                desc = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', desc)
                rule["description"] = clean_text(desc)
            else:
                # Fallback to loose search if no header was found
                pattern_fb = re.compile(fr'(?:^|\n){id_esc}\s*(.*?)(?=\n<[A-Z0-9]+>|\n#|\Z)', re.DOTALL | re.IGNORECASE)
                match_fb = pattern_fb.search(content)
                if match_fb:
                    desc_fb = match_fb.group(1).strip()
                    if not desc_fb.startswith('|'):
                        desc_fb = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', desc_fb)
                        # Also strip `<ID>` from fallback
                        desc_fb = re.sub(fr'^{id_esc}\s*', '', desc_fb).strip()
                        rule["description"] = clean_text(desc_fb)

    # Dedup and save
    seen_ids = set()
    final_data = []
    for r in rules:
        if r["id"] not in seen_ids and r["id"] and r["description"]:
            final_data.append(r)
            seen_ids.add(r["id"])

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(final_data, f, indent=2)

if __name__ == "__main__":
    parse_manual(
        "/Users/axcdeng/.gemini/antigravity/brain/28ff41cc-b856-4679-89dd-f3105bc6ec72/.system_generated/steps/1101/output.txt",
        "/Users/axcdeng/Antigravity Projects/roboscout-IQ/assets/game_manual.json"
    )
