# -*- coding: utf-8 -*-
"""
Created on Mon Feb 26 17:52:07 2024

@author: kylebsee
"""

import os

partitionPath=r"C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\fstroke\partition_py"

# List all image files in the directory
image_files = [f for f in os.listdir(partitionPath) if os.path.isfile(os.path.join(partitionPath, f))]

# Extract unique subject IDs
subject_ids = set([int(f.split('_')[0]) for f in image_files])