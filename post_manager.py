import time, os, subprocess

def get_fname(title, dir):
    ls = os.listdir(dir)
    for f in ls:
        if f.endswith(title + '.md'):
            return f
    raise FileNotFoundError

status = 0
print('What do you want to do:')
print('[0] Create a new post')
print('[1] Update the time of a post')
print('[2] Upload your changes')

action = input('>> ')
while True:
    try:
        status = int(action)
        if status > 2 or status < 0:
            print('The input isn\'t a valid number')
            action = input('>> ')
        else:
            break
    except:
        print('The input isn\'t a number')
        action = input('>> ')

if status == 0:
    name = input("Name of the post: ")
    desc = input("Description: ")
    categories = input("Categories (separated by spaces): ")
    fname = "%s-%s.md" % (time.strftime("%Y-%m-%d"), name.lower().replace(' ', '-'))
    time_f = time.strftime('%Y-%m-%d %H:%M:%S +0200')
    draft_s = input("Create it as draft [Y/n]: ").lower()
    draft = (draft_s != 'n')
    f = open(('_drafts/'+fname) if draft else ('_posts/'+fname),'w')
    print(f.name)
    f.write('---\nlayout: post\n')
    f.write('title:  "%s"\n' % name)
    f.write('date:   %s\n' % time_f)
    f.write('categories: %s\n' % categories)
    f.write('description: "%s"\n' % desc)
    f.write("---\n")
    f.close()

if status == 1:
    name = input("Name of the post: ")
    
    time_f = time.strftime('%Y-%m-%d %H:%M:%S +0200')
    draft_s = input("Is it a draft [Y/n]: ").lower()
    draft = (draft_s != 'n')
    fname = get_fname(name.lower().replace(' ', '-'), '_drafts' if draft else '_posts')
    fr = open(('_drafts/'+fname) if draft else ('_posts/'+fname), 'r')
    move = False
    if draft:
        draft_s = input("Move to posts [Y/n]: ").lower()
        move = (draft_s != 'n')
    lines = fr.readlines()
    
    i = 0
    for line in lines:
        if i!=0:
            line = line.strip()
            if line == '---':
                break
            if line.startswith('date: '):
                lines[i] = 'date:   %s\n' % time_f
        i+=1
    fw = open(('_drafts/'+fname) if (draft and not move) else ('_posts/'+fname), 'w')
    fw.writelines(lines)
    fw.close()
    if move:
        os.remove('_drafts/'+fname)

if status  == 2:
    commitname = input("Enter the commit message: ")
    subprocess.run(['git', 'add', '*'])
    subprocess.run(['git', 'commit', '-m', '%s' % commitname])
    subprocess.run(['git', 'push'])
    print('Pushed the changes')
        