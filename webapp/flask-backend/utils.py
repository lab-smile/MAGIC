import hashlib
import os
import random
import shutil
import threading
import time


def cleanup(tmp_dir, dir_hash):
    time.sleep(600)  # wait for 10 minutes

    dir_path = f'{tmp_dir}/uploaded_{dir_hash}'
    result_dir_path = f'{tmp_dir}/uploaded_{dir_hash}_results'
    generate_series_dir_path = f'{tmp_dir}/uploaded_{dir_hash}_generate_series_results'

    shutil.rmtree(dir_path, ignore_errors=True)
    shutil.rmtree(result_dir_path, ignore_errors=True)
    shutil.rmtree(generate_series_dir_path, ignore_errors=True)


class TemporaryWorkingDirectory:
    """
    A context manager that creates a hashed temporary working directory and clean up 10 minutes after use.

    Usage:
    with TemporaryWorkingDirectory() as (upload_dir, dir_hash):
        # do something with the upload_dir

    temporary working directories clean up by this context manager:
    - {tmp_dir}/uploaded_{dir_hash}
    - {tmp_dir}/uploaded_{dir_hash}_results
    - {tmp_dir}/uploaded_{dir_hash}_generate_series_results
    """

    def __init__(self, tmp_dir):
        self.tmp_dir = tmp_dir
        # Get current timestamp and a random number
        current_time = str(time.time())
        random_num = str(random.randint(1, 1e6))

        # Combine the timestamp and random number, and generate a hash
        hash_input = (current_time + random_num).encode('utf-8')
        self.dir_hash = hashlib.md5(hash_input).hexdigest()

    def __enter__(self):
        # create hashed directory
        upload_dir = f'{self.tmp_dir}/uploaded_{self.dir_hash}'
        os.makedirs(f"{upload_dir}/test", exist_ok=True)
        return upload_dir, self.dir_hash

    def __exit__(self, type, value, traceback):
        # Schedule cleanup
        cleanup_thread = threading.Thread(target=cleanup, args=(self.tmp_dir, self.dir_hash,))
        cleanup_thread.start()
