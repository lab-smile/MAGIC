import torch, network, argparse, os
import matplotlib.pyplot as plt
from torchvision import transforms
from torch.autograd import Variable
import util
import numpy as np

from torchinfo import summary

parser = argparse.ArgumentParser()
parser.add_argument('--dataset', required=True, default='sample_data',  help='')
parser.add_argument('--model_path', required=True, help='path to generator PKL file')
parser.add_argument('--batch_norm', required=True, default=False, help='true when batch_size > 1 during training, false otherwise')
parser.add_argument('--save_root', required=True, default='results', help='results save path')
parser.add_argument('--test_subfolder', required=False, default='test',  help='')

parser.add_argument('--ngf', type=int, default=64)
parser.add_argument('--input_size', type=int, default=256, help='input size')
parser.add_argument('--scale', required=False, default=0.5, help='scale factor for PILO parameter')
parser.add_argument('--batch_size', required=False, default=1, type=int)

class BatchSizeExceed(Exception):
    def __init__(self,message):
        super().__init__(message)

def get_folder_name(path_or_folder):
    # Handles both relative and absolute paths for the model name.
    folder_name = os.path.basename(path_or_folder)
    return folder_name

# Parse arguments
opt = parser.parse_args()
print("Parsed Arguments:")
for arg, value in vars(opt).items():
    print(f"{arg}: {value}")
print("\n")


# Data_loader
transform = transforms.Compose([
    transforms.ToTensor(),
    transforms.Normalize(mean=(0.5, 0.5, 0.5), std=(0.5, 0.5, 0.5))
])
test_loader = util.data_load(opt.dataset, opt.test_subfolder, transform, batch_size=1, shuffle=False)
results_folder = opt.dataset + '_results/' + 'results'

# Check batch size
if opt.batch_size > len(test_loader):
    raise BatchSizeExceed("Batch size should not be greater than the number of test samples")

# Create results folder if not created
if not os.path.isdir(results_folder):
    os.makedirs(results_folder)

# Set the generator
G = network.generator(opt.ngf,opt.batch_size,opt.batch_norm)

# Generator parameter summary
#batch_size = 1
#channels=3
#height=256
#width=256
#sample_input = torch.randn(batch_size, channels, height, width)
#summary(G, input_data=sample_input)
#print("\n")

G.cuda()
G.load_state_dict(torch.load(opt.model_path))
G.eval()

# set scale to 0.5 if no PILO scaling
scale = float(opt.scale)

G.deconv9_1.weight.data[0][0] = 2 * (1 - scale) * G.deconv9_1.weight.data[0][0].item()
G.deconv9_2.weight.data[0][0] = 2 * (1 - scale) * G.deconv9_2.weight.data[0][0].item()
G.deconv9_3.weight.data[0][0] = 2 * (1 - scale) * G.deconv9_3.weight.data[0][0].item()
G.deconv9_4.weight.data[0][0] = 2 * (1 - scale) * G.deconv9_4.weight.data[0][0].item()

for j in range(2):
    G.deconv9_1.weight.data[0][j+1] = 2 * scale * G.deconv9_1.weight.data[0][j+1].item()
    G.deconv9_2.weight.data[0][j+1] = 2 * scale * G.deconv9_2.weight.data[0][j+1].item()
    G.deconv9_3.weight.data[0][j+1] = 2 * scale * G.deconv9_3.weight.data[0][j+1].item()
    G.deconv9_4.weight.data[0][j+1] = 2 * scale * G.deconv9_4.weight.data[0][j+1].item()


n = 0
print('Starting testing!')

with torch.no_grad():
    for item, _ in test_loader:
        img_size = 256
        x_ = item[:, :, :, 0:img_size] # NCCT

        x_ = Variable(x_.cuda())
        test_image = G(x_)

        s = test_loader.dataset.imgs[n][0][::-1]
        s_ind = len(s) - s.find('/')
        e_ind = len(s) - s.find('.')
        ind = test_loader.dataset.imgs[n][0][s_ind:e_ind-1]
        path = results_folder + '/' + ind + '_output.png'
        testimg = test_image[0].cpu().data.numpy().squeeze()
        img = (np.stack((testimg,)*3,0).transpose(1, 2, 0) + 1) / 2

        plt.imsave(path, img)

        n += 1

    print('%d images generation complete!' % n)
