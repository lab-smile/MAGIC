# Private MAGIC README
### For SMILE Lab Internal Documentation
## Pretrained Models and Data
The pretrained generator model can be downloaded from [Dropbox](https://www.dropbox.com/s/ow2ztqn4fxyo0fp/MAGIC_Generator_FINAL-v2.pkl?dl=0).

The environment .yml file can be downloaded from [Dropbox](https://www.dropbox.com/s/hfu1p4cs4lcdyys/magic_env.yml?dl=0).

Training & Testing Data:
- Download [testing data](https://www.dropbox.com/s/uxaphpt7efjy5i2/test.zip?dl=0)
- Download [training data](https://www.dropbox.com/s/35ois248z60sxnj/train.zip?dl=0)
- __Data path on HiPerGator:__ (/blue/ruogu.fang/gfullerton/pytorch-pix2pix/new_augmented_data)
    + Contains "train" and "test" subdirectories

## Process the Dataset
### Creating dataset
The code to prepare the 5-image montages only works on the **UF Health** dataset. Three separate MATLAB files are ran to acquire z-slices, reorganize slices into train/val/test splits, and creating the 5-image montages.

- **findSliceMatch_RAPID.m** - Goes from deidentified to z-slices. Acquires slice volumes from all z-slice locations. Separates volumes into image types (NCCT, MTT, TTP, CBF, and CBF)
- **splitData.m** - Reorganizes the data from above into train/val/test within each image type. The NCCT folder will have a train/val/test subfolder. Same to other perfusion maps.
- **newp2pdataset.m** - Goes from train/val/test single images to train/val/test montages. You now just have separate train/val/test folders instead of image type folders.