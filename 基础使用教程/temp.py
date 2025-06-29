import os
import re
import shutil

# 匹配 Markdown 图像语法：![](image.png) 或 ![描述](image-1.png)
IMAGE_PATTERN = re.compile(r'!\[.*?\]\((image(?:-\d+)?\.png)\)')

def process_markdown_file(md_path):
    md_dir = os.path.dirname(md_path)
    figures_dir = os.path.join(md_dir, 'figures')
    os.makedirs(figures_dir, exist_ok=True)

    with open(md_path, 'r', encoding='utf-8') as f:
        content = f.read()

    changed = False
    matches = set(IMAGE_PATTERN.findall(content))
    for image_name in matches:
        src_image_path = os.path.join(md_dir, image_name)
        dst_image_path = os.path.join(figures_dir, image_name)
        if os.path.exists(src_image_path):
            shutil.move(src_image_path, dst_image_path)
            print(f"Moved: {src_image_path} -> {dst_image_path}")
        else:
            print(f"Warning: {src_image_path} not found")

        # 替换 Markdown 中的路径
        content = content.replace(f']({image_name})', f'](figures/{image_name})')
        changed = True

    if changed:
        with open(md_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated: {md_path}")
    else:
        print(f"No images to update in: {md_path}")

def walk_and_process(root_dir):
    for dirpath, _, filenames in os.walk(root_dir):
        for filename in filenames:
            if filename.lower().endswith('.md'):
                md_path = os.path.join(dirpath, filename)
                process_markdown_file(md_path)

if __name__ == "__main__":
    root = os.path.abspath(".")  # 当前目录
    walk_and_process(root)
