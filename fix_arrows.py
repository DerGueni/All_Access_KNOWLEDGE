# -*- coding: utf-8 -*-
file = r'C:\Users\guenther.siegert\Documents\0006_All_Access_KNOWLEDGE\04_HTML_Forms\forms3\frm_MA_VA_Schnellauswahl.html'

with open(file, 'rb') as f:
    content = f.read()

# Fix garbled arrow characters (found via hex analysis)
# â†' (right arrow) = c3a2 e280a0 e28099 -> &rarr;
content = content.replace(b'\xc3\xa2\xe2\x80\xa0\xe2\x80\x99', b'&rarr;')

# â† (left arrow) = c3a2 e280a0 -> &larr;
content = content.replace(b'\xc3\xa2\xe2\x80\xa0', b'&larr;')

# âœ• (x mark) - find the hex first
search = b'btnDelAll'
pos = content.find(search)
if pos > 0:
    chunk = content[pos:pos+150]
    print(f'DelAll area: {chunk}')

# Common pattern for âœ• = c3a2 c593 e280a2
content = content.replace(b'\xc3\xa2\xc5\x93\xe2\x80\xa2', b'&times;')

with open(file, 'wb') as f:
    f.write(content)

print('Arrows fixed!')

# Verify
with open(file, 'r', encoding='utf-8') as f:
    v = f.read()
print(f'&rarr; count: {v.count("&rarr;")}')
print(f'&larr; count: {v.count("&larr;")}')
