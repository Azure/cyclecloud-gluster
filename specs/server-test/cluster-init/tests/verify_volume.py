import jetpack
import subprocess
import time


def test_verify_volume():
    volume_name = jetpack.config.get("glusterfs.volume.name")
    volume_deadline = jetpack.config.get("glusterfs.volume.test.deadline")
    if not volume_deadline:
        volume_deadline = 10
    deadline = int(volume_deadline) * 60 + time.time()

    while True:
        try:
            subprocess.check_call(["gluster", "volume", "info", volume_name])
            return
        except subprocess.CalledProcessError:
            if time.time() < deadline:
                time.sleep(5)
            else:
                raise