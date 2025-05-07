# Originally copied from https://github.com/SilentNightSound/SR-Model-Importer/tree/main
# Modified to better meet our needs.
import os.path
import subprocess
import psutil
from pyinjector import inject
import time

# 获取当前脚本的绝对路径
current_file_path = os.path.abspath(__file__)

# 获取当前脚本所在的目录
current_dir = os.path.dirname(current_file_path) + "\\"
print(current_dir)

def inject_loop():
    print("正在等待游戏启动中...")
    target_exe = ""
    if os.path.exists(current_dir + "d3dx.ini"):
        target_path = ""
        launch_path = ""

        with open(current_dir + "d3dx.ini", 'r') as file:
            for line in file:
                if line.strip().startswith("target"):
                    target_path = line.split("=")[1].strip()
                if line.strip().startswith("launch"):
                    launch_path = line.split("=")[1].strip()

        if target_path != "":
            print("target路径：" + target_path)
            target_exe = os.path.basename(target_path)
            print("target进程名称：" + target_exe)
        if launch_path != "":
            print("检测到已设置launch路径：" + launch_path)
            print("已自动调起launch路径.")
            subprocess.Popen(launch_path)

    # Iterate over all running process
    while True:
        for proc in psutil.process_iter():
            try:
                if proc.name() == target_exe:
                    print("已加载成功，现在可以进游戏按下小键盘0键来开启Hunting界面了。: ")
                    print(proc.name(), proc.pid)
                    inject(proc.pid, current_dir + "d3d11.dll")
                    time.sleep(3)
                    return
            except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                pass


if __name__ == "__main__":
    inject_loop()
