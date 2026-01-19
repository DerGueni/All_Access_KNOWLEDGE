with open('msdl.html','r',encoding='utf-8') as f:\n    for line in f:\n        if 'AccessDatabaseEngine' in line:\n            print(line.strip())
