import os
import shutil

files = [
    'icons.lua',
    'source-dev.lua',
    'test.lua'
]

# Build state
release = True

script_dir = os.path.dirname(os.path.abspath(__file__))
output_dir = os.path.join(script_dir, 'out')
output_file = os.path.join(output_dir, 'source.lua')

if os.path.exists(output_dir):
    shutil.rmtree(output_dir)
os.makedirs(output_dir, exist_ok=True)

if release:
    files = [f for f in files if f != 'test.lua']

raw_files = [os.path.join(script_dir, 'build', fname) for fname in files]

merged_content = ''
for fname in raw_files:
    if not os.path.isfile(fname):
        print(f'File not found: {fname}')
        exit(1)
    with open(fname, 'r', encoding='utf-8') as infile:
        merged_content += infile.read() + '\n'

if release:
    merged_content += '\nreturn GUI'

with open(output_file, 'w', encoding='utf-8') as outfile:
    outfile.write(merged_content)

print(f'Output: {output_file}')