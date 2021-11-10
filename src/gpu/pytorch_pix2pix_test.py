import torch, network, argparse, os
import matplotlib.pyplot as plt
from torchvision import transforms
from torch.autograd import Variable
import util
import numpy as np

parser = argparse.ArgumentParser()
parser.add_argument('--dataset', required=False, default='sample_data',  help='')
parser.add_argument('--test_subfolder', required=False, default='test',  help='')
parser.add_argument('--ngf', type=int, default=64)
parser.add_argument('--input_size', type=int, default=256, help='input size')
parser.add_argument('--save_root', required=False, default='results', help='results save path')
parser.add_argument('--scale', required=False, default=0.5, help='scale factor for pitl')
parser.add_argument('--batch_size', required=False, default=16, type=int)
opt = parser.parse_args()
print(opt)

# data_loader
transform = transforms.Compose([
        transforms.ToTensor(),
        transforms.Normalize(mean=(0.5, 0.5, 0.5), std=(0.5, 0.5, 0.5))
])
test_loader = util.data_load(opt.dataset, opt.test_subfolder, transform, batch_size=1, shuffle=False)

if not os.path.isdir(opt.dataset + '_results/test_results_lr5e-5'):
    os.mkdir(opt.dataset + '_results/test_results_lr5e-5')
    

G = network.generator(opt.ngf,batch_size=opt.batch_size)
print(G)
G.cuda()
G.load_state_dict(torch.load(opt.dataset + '_results/' + 'new_augmented_data_generator_param_final_lr_5e-5.pkl'))
G.eval()
"""
# Scaling PITL
print('before:')
print(G.deconv9_1.weight.data)
print(G.deconv9_2.weight.data)
print(G.deconv9_3.weight.data)
print(G.deconv9_4.weight.data)
#print(G.deconv9_1.bias)
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
 


#exit()
print('after:')
print(G.deconv9_1.weight.data)
print(G.deconv9_2.weight.data)
print(G.deconv9_3.weight.data)
print(G.deconv9_4.weight.data)
#exit()
"""
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
      path = opt.dataset + '_results/test_results_lr5e-5/' + ind + '_output.png'
      testimg = test_image[0].cpu().data.numpy().squeeze()
      #print((np.stack((testimg,)*3,0)).shape)
      img = (np.stack((testimg,)*3,0).transpose(1, 2, 0) + 1) / 2
      #print(img.shape)
      #print(img[0:3,0:3])
      plt.imsave(path, img)
  
      n += 1
  
  print('%d images generation complete!' % n)
