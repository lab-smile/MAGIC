# -*- coding: utf-8 -*-
"""
Created on Mon Feb 26 17:52:07 2024

@author: kylebsee
"""

import os, sys, shutil
from sklearn.model_selection import train_test_split



# Setting parameters 
partitionPath=r"C:\Users\kylebsee\Dropbox (UFL)\Quick Coding Scripts\fstroke\partition_py"
test_size = 0.2
random_state = 42


def check_stratification(train_slices, test_slices, train_dir, test_dir):
    # Extract subject IDs from filenames
    train_subjects = set([int(f.split('_')[0]) for f in train_slices])
    test_subjects = set([int(f.split('_')[0]) for f in test_slices])

    # Check if subjects are present in both train and test
    overlapping_subjects = train_subjects.intersection(test_subjects)
    if overlapping_subjects:
        print("Error: Subjects present in both train and test sets:", overlapping_subjects)
        sys.exit()
    else:
        print("Subjects are stratified.")

    # Check if all images are successfully copied
    train_files = set(os.listdir(train_dir))
    test_files = set(os.listdir(test_dir))
    if set(train_slices) == train_files and set(test_slices) == test_files:
        print("All images are successfully copied.")
    else:
        print("Error: Some images are not copied.")
        sys.exit()

# Function to check if images are already partitioned
def check_partitioned(train_dir, test_dir):
    if os.path.exists(train_dir) and os.path.exists(test_dir):
        train_files = set(os.listdir(train_dir))
        test_files = set(os.listdir(test_dir))
        if train_files and test_files:
            print("Images are already partitioned.")
            check_stratification(train_files, test_files, train_dir, test_dir)
        else:
            print("Error: Train or test directories are empty.")
            sys.exit()
    else:
        print("Creating train and test directories.")

# Create directory paths
train_dir = os.path.join(partitionPath,'train')
test_dir = os.path.join(partitionPath,'test')

# Check if images are already partitioned
check_partitioned(train_dir, test_dir)


# List all image files in the listed directory
image_files = [f for f in os.listdir(partitionPath) if os.path.isfile(os.path.join(partitionPath, f))]

# Extract all unique subject IDs
subject_ids = list(set([int(f.split('_')[0]) for f in image_files]))

# Separate subjects with train and test
train_subjects, test_subjects = train_test_split(subject_ids, test_size=test_size, random_state=random_state)

# Initialize slices
train_slices = []
test_slices = []

# Loop through each subject ID
for subject_id in subject_ids:
    
    # Get all slices belonging to subject ID
    subject_slices = [f for f in image_files if int(f.split('_')[0]) == subject_id]
    
    # Determine whether to add slices to train or test set
    if subject_id in train_subjects:
        train_slices.extend(subject_slices)
    else:
        test_slices.extend(subject_slices)
        




if not os.path.exists(train_dir) or not os.path.exists(test_dir):
    # Make directories if necessary
    os.makedirs(train_dir, exist_ok=True)
    os.makedirs(test_dir, exist_ok=True)
    
    for file in train_slices:
        src_path = os.path.join(partitionPath, file)
        dst_path = os.path.join(train_dir, file)
        shutil.copyfile(src_path, dst_path)
    
    for file in test_slices:
        src_path = os.path.join(partitionPath, file)
        dst_path = os.path.join(test_dir, file)
        shutil.copyfile(src_path, dst_path)
        
# Check if subjects are stratified and all images are copied
check_stratification(train_slices, test_slices, train_dir, test_dir)

print("Successfully partitioned stratified train and test directories.")