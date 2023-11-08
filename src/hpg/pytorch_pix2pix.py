import os, time, pickle, argparse, network, util, sys
# use specific gpu cores
#os.environ["CUDA_DEVICE_ORDER"] = "PCI_BUS_ID"
#os.environ["CUDA_VISIBLE_DEVICES"] = "2" or "3"
import torch
import torch.nn as nn
import torch.optim as optim
from torchvision import transforms
from torch.autograd import Variable
from tqdm import tqdm
import cv2
from skimage.metrics import structural_similarity
import numpy as np
from prettytable import PrettyTable
import random
from torchvision import datasets
import torchvision.transforms.functional as F

parser = argparse.ArgumentParser()

parser.add_argument('--dataset', required=False, default='sample_data',  help='dataset path')
parser.add_argument('--model_name', required=False, default='sample_data', help='model name')
parser.add_argument('--train_subfolder', required=False, default='train',  help='')
parser.add_argument('--val_subfolder', required=False, default='val',  help='')
parser.add_argument('--save_root', required=False, default='results', help='results save path')

parser.add_argument('--batch_size', type=int, default=1, help='train batch size')
parser.add_argument('--val_batch_size', type=int, default=5, help='test batch size')
parser.add_argument('--ngf', type=int, default=64, help='number of generator features')
parser.add_argument('--ndf', type=int, default=64, help='number of discriminator features')
parser.add_argument('--input_size', type=int, default=256, help='input size')
parser.add_argument('--train_epoch', type=int, default=100, help='number of train epochs')
parser.add_argument('--lrD', type=float, default=0.0002, help='learning rate, default=0.0002')
parser.add_argument('--lrG', type=float, default=0.0002, help='learning rate, default=0.0002')

parser.add_argument('--gen_lambda', type=float, default=100, help='scaling factor for generator loss')
parser.add_argument('--ext_lambda', type=float, default=100, help='scaling factor for extrema loss')
parser.add_argument('--mml_lambda', type=float, default=100, help='scaling factor for multimodal loss')
parser.add_argument('--dsc_mode',default='bce',help='[ bce | wasserstein ] loss used for discriminator')
parser.add_argument('--gen_mode',default='L1',help='[ L1 | ssim ] loss used for generator')
parser.add_argument('--mml_mode',default='L1',help='[ L1 | ssim | correlation ] loss used for multimodal loss')
parser.add_argument('--use_extrema_loss',default=True)
parser.add_argument('--use_multimodal_loss',default=True) # fix for ssim and corr, l1 is fine

parser.add_argument('--beta1', type=float, default=0.5, help='beta1 for Adam optimizer')
parser.add_argument('--beta2', type=float, default=0.999, help='beta2 for Adam optimizer')
parser.add_argument('--n_epochs', type=int, default=75, help='number of epochs with the initial learning rate')
parser.add_argument('--n_epochs_decay', type=int, default=25, help='number of epochs to linearly decay learning rate to zero')
parser.add_argument('--epoch_count', type=int, default=1, help='the starting epoch count, we save the model by <epoch_count>, <epoch_count>+<save_latest_freq>, ...')
parser.add_argument('--seed', type=int,default=0,help='seed')

parser.add_argument('--use_checkpoint',default=True, help='save the model at a specified checkpoint')
parser.add_argument('--save_freq', type=int, default=10, help='save the model after n epochs as a checkpoint')
parser.add_argument('--save_fig_freq', type=int, default=10, help='how often to save loss histogram')
parser.add_argument('--num_show', type=int, default=5, help='how many validation images to show per slide after each epoch')
parser.add_argument('--use_augmentations',default=True)

parser.add_argument('--num_workers',type=int,default=1)

# Just testing the training portion
# module load conda
# conda activate magic_env
# cd /blue/ruogu.fang/kylebsee/MAGIC/hpg

def get_folder_name(path_or_folder):
    # Handles both relative and absolute paths for the model name.
    folder_name = os.path.basename(path_or_folder)
    return folder_name

def make_dir(dirname):
    if not os.path.isdir(dirname):
        os.makedirs(dirname)

# Parse arguments
opt = parser.parse_args()
print("Parsed Arguments:")
for arg, value in vars(opt).items():
    print(f"{arg}: {value}")
print("\n")
random.seed(opt.seed)
num_show = opt.num_show

# Set batch normalization if batch size is greater than 1
bn = None
if opt.batch_size == 1:
	bn = False
else:
    bn = True

# Results save path
root = opt.dataset + '_model_' + opt.save_root + '/' # dataset_NAME + _model_ + EXPERIMENT + / --> [dataset_NAME_model_EXPERIMENT/]
model = get_folder_name(opt.dataset) + '_'
make_dir(root)
make_dir(root + 'validation_results')
make_dir(root + 'training_histograms')
make_dir(root + 'model_weights')
make_dir(root + 'test_results')
    
print("Dataset: " + opt.dataset)
print("Experiment: " + opt.save_root)
print("\n")

# Open file to write into output
file_output = open(root + 'output.txt','w+')
sys.stdout = file_output

# Transformations
if opt.use_augmentations:
    transform = transforms.Compose([
        transforms.RandomVerticalFlip(),
        transforms.RandomHorizontalFlip(),
        transforms.GaussianBlur(9),
        transforms.ToTensor(),
        transforms.Normalize(mean=(0.5, 0.5, 0.5), std=(0.5, 0.5, 0.5))
    ])
else:
    transform = transforms.Compose([
        transforms.ToTensor(),
        transforms.Normalize(mean=(0.5, 0.5, 0.5), std=(0.5, 0.5, 0.5))
    ])

# Data Loader
train_loader = util.data_load(opt.dataset, opt.train_subfolder, transform, opt.batch_size, shuffle=True, num_workers=opt.num_workers)
val_loader = util.data_load(opt.dataset, opt.val_subfolder, transform, opt.val_batch_size, shuffle=True)

val = val_loader.__iter__().__next__()[0]
img_size = val.size()[2]
fixed_x_ = val[:num_show, :, :, 0:img_size] # [num_show, 3, 256, 256]
fixed_x_ = Variable(fixed_x_.cuda())
fixed_y_store = val[:num_show, 0, :, img_size:5*img_size] # [num_show, 256, 1024]
fixed_y_store = torch.unsqueeze(fixed_y_store, 1) # [num_show, 1, 256, 1024]
fixed_y_1 = val[:num_show, 0, :, 1*img_size:2*img_size] 
fixed_y_1 = torch.unsqueeze(fixed_y_1, 1)# [num_show, 1, 256, 256]
fixed_y_2 = val[:num_show, 0, :, 2*img_size:3*img_size] 
fixed_y_2 = torch.unsqueeze(fixed_y_2, 1)# [num_show, 1, 256, 256]
fixed_y_3 = val[:num_show, 0, :, 3*img_size:4*img_size] 
fixed_y_3 = torch.unsqueeze(fixed_y_3, 1)# [num_show, 1, 256, 256]
fixed_y_4 = val[:num_show, 0, :, 4*img_size:5*img_size] 
fixed_y_4 = torch.unsqueeze(fixed_y_4, 1)# [num_show, 1, 256, 256]

valid_dset = util.data_load(opt.dataset, opt.val_subfolder, transform, opt.val_batch_size, shuffle=True, return_dset=True)
valid_indices = random.sample(range(len(valid_dset)), opt.val_batch_size)
valid_loader = torch.utils.data.DataLoader(dataset=torch.utils.data.Subset(valid_dset, valid_indices), batch_size=1, shuffle=False)

if img_size != opt.input_size:
    fixed_x_ = util.imgs_resize(fixed_x_, opt.input_size)
    fixed_y_1 = util.imgs_resize(fixed_y_1, opt.input_size)
    fixed_y_2 = util.imgs_resize(fixed_y_2, opt.input_size)
    fixed_y_3 = util.imgs_resize(fixed_y_3, opt.input_size)
    fixed_y_4 = util.imgs_resize(fixed_y_4, opt.input_size)

# Set networks (network.py)
G = network.generator(opt.ngf, opt.batch_size, bn)
G.cuda()
D = network.discriminator(opt.ndf, opt.batch_size)
D.cuda()

# Set training mode
G.train()
D.train()

# Define BCE, L1, L2 (MSE) and SSIM losses
BCE_loss = nn.BCELoss().cuda()
L1_loss = nn.L1Loss().cuda()
L2_loss = nn.MSELoss().cuda()

def SSIM_loss(img_1, img_2):
    # Fake, Real
    img_1 = img_1.detach().cpu().numpy() # [bn, 1, 256, 256]
    img_1 = np.squeeze(img_1)
    img_2 = img_2.detach().cpu().numpy() # [bn, 1, 256, 256]
    img_2 = np.squeeze(img_2)
    SSIM = structural_similarity(img_1, img_2, channel_axis=0, gaussian_weights=True, sigma=1.5, use_sample_covariance=False, data_range=img_2.max())
    return SSIM

# To use as discriminator loss
def Wasserstein_loss(img_1, img_2):
    # Fake, Real
    img_1 = img_1.cpu() # [bn, 1, 256, 256]
    img_1 = np.squeeze(img_1)
    img_2 = img_2.cpu() # [bn, 1, 256, 256]
    img_2 = np.squeeze(img_2)
    return torch.mean(img_2) - torch.mean(img_1) # Real - Fake

# Define Adam optimizer
G_optimizer = optim.Adam(G.parameters(), lr=opt.lrG, betas=(opt.beta1, opt.beta2))
D_optimizer = optim.Adam(D.parameters(), lr=opt.lrD, betas=(opt.beta1, opt.beta2))

# Define learning rate scheduler
def lambda_rule(epoch):
	lr_l = 1.0 - max(0, epoch + opt.epoch_count - opt.n_epochs) / float(opt.n_epochs_decay + 1)
	return lr_l

# Define scheduler
G_optim_scheduler = optim.lr_scheduler.LambdaLR(G_optimizer, lr_lambda=lambda_rule)
D_optim_scheduler = optim.lr_scheduler.LambdaLR(D_optimizer, lr_lambda=lambda_rule)

# Training histograms
train_hist = {}
train_hist_epoch = {}
train_hist['G_losses'] = []
train_hist_epoch['G_loss_epoch'] = []
train_hist['D_losses'] = []
train_hist_epoch['D_loss_epoch'] = []
train_hist_epoch['val_loss_epoch'] = []
train_hist_epoch['Extrema_loss_epoch'] = []
train_hist_epoch['Multimodal_loss_epoch'] = []
train_hist_epoch['Overall_G_loss'] = []

# Print out values for record in output.txt
print("Parsed Arguments:")
for arg, value in vars(opt).items():
    print(f"{arg}: {value}")
print("\n")

# Record start and stop time
print('Starting training!')
start_time = time.time()

epoch_progress = tqdm(total=opt.train_epoch, desc='Training Progress', ncols=100)

for epoch in range(opt.train_epoch):
    
    #########################################
    # (0) Initialization and Data Preparation
    #########################################
    # 1-MTT, 2-TTP, 3-CBF, 4-CBV
    D_losses_1 = []
    D_losses_2 = []
    D_losses_3 = []
    D_losses_4 = []
    
    G_losses_1 = []
    G_losses_2 = []
    G_losses_3 = []
    G_losses_4 = []
    
    G_extrema_losses_1 = []
    G_extrema_losses_2 = []
    G_extrema_losses_3 = []
    G_extrema_losses_4 = []
    
    multimodal_losses = []
    
    epoch_start_time = time.time()
    num_iter = 0
    total_iter = len(train_loader)
    
    for item, _ in train_loader:
        #print('Iteration {} of {}'.format(num_iter, total_iter), end="\r")
        #print('Iteration {} of {}'.format(num_iter,total_iter))
        
        # Splitting up 1x5 image montage into input (x) and labels (y)
        x_ = item[:, :, :, 0:img_size] # NCCT # [bn, 3, 256, 256]
        y_1 = item[:, 0, :, img_size:2*img_size] # MTT # [bn, 256, 256]
        y_2 = item[:, 0, :, 2*img_size:3*img_size] # TTP
        y_3 = item[:, 0, :, 3*img_size:4*img_size] # CBF
        y_4 = item[:, 0, :, 4*img_size:5*img_size] # CBV
        
        # ???
        y_1 = torch.unsqueeze(y_1, 1)  # [bn, 1, 256, 256]
        y_2 = torch.unsqueeze(y_2, 1)  # [bn, 1, 256, 256]
        y_3 = torch.unsqueeze(y_3, 1)  # [bn, 1, 256, 256]
        y_4 = torch.unsqueeze(y_4, 1)  # [bn, 1, 256, 256]
    
        # Concatenating labels
        y_ = torch.cat((y_1, y_2, y_3, y_4), dim=3) # [bn, 1, 256, 1024]
        
        # ???
        x_ = Variable(x_.cuda())
        y_ = Variable(y_.cuda())
        
        ######################
        # (1) Update D network
        ######################
        
        # Initializes gradients of discriminator
        D.zero_grad()
        
        # Use discriminator on REAL data
        D_result_real = D(x_, y_)   # D(input, label), D([1, 3, 256, 256], [1, 1, 256, 1024])
        
        # Use discriminator on FAKE data
        G_result = G(x_) # [bn, 1, 256, 1024]
        D_result_fake = D(x_, G_result)
        
        # Grab maps from real data
        D_result_r1 = D_result_real[:, 0, :, :] # [1, 30, 30]
        D_result_r2 = D_result_real[:, 1, :, :]
        D_result_r3 = D_result_real[:, 2, :, :]
        D_result_r4 = D_result_real[:, 3, :, :]
            
        # Grab maps from fake data
        D_result_f1 = D_result_fake[:, 0, :, :] # [1, 30, 30]
        D_result_f2 = D_result_fake[:, 1, :, :]
        D_result_f3 = D_result_fake[:, 2, :, :]
        D_result_f4 = D_result_fake[:, 3, :, :]
        
        if 'bce' in opt.dsc_mode:
            # Real loss
            D_real_loss_1 = BCE_loss(D_result_r1, Variable(torch.ones(D_result_r1.size()).cuda()))
            D_real_loss_2 = BCE_loss(D_result_r2, Variable(torch.ones(D_result_r2.size()).cuda()))
            D_real_loss_3 = BCE_loss(D_result_r3, Variable(torch.ones(D_result_r3.size()).cuda()))
            D_real_loss_4 = BCE_loss(D_result_r4, Variable(torch.ones(D_result_r4.size()).cuda()))
            # Fake loss
            D_fake_loss_1 = BCE_loss(D_result_f1, Variable(torch.zeros(D_result_f1.size()).cuda()))
            D_fake_loss_2 = BCE_loss(D_result_f2, Variable(torch.zeros(D_result_f2.size()).cuda()))
            D_fake_loss_3 = BCE_loss(D_result_f3, Variable(torch.zeros(D_result_f3.size()).cuda()))
            D_fake_loss_4 = BCE_loss(D_result_f4, Variable(torch.zeros(D_result_f4.size()).cuda()))
            #------------------------------------------------
            # Averages discriminator loss (real+fake)
            D_train_loss_1 = (D_real_loss_1 + D_fake_loss_1) * 0.5
            D_train_loss_2 = (D_real_loss_2 + D_fake_loss_2) * 0.5
            D_train_loss_3 = (D_real_loss_3 + D_fake_loss_3) * 0.5
            D_train_loss_4 = (D_real_loss_4 + D_fake_loss_4) * 0.5
            # Averages all perfusion map losses
            D_train_loss = (D_train_loss_1 + D_train_loss_2 + D_train_loss_3 + D_train_loss_4) * 0.25
        elif 'wasserstein' in opt.dsc_mode:
            # Take Wasserstein loss
            D_train_loss_1 = Wasserstein_loss(D_result_f1, D_result_r1)
            D_train_loss_2 = Wasserstein_loss(D_result_f2, D_result_r2)
            D_train_loss_3 = Wasserstein_loss(D_result_f3, D_result_r3)
            D_train_loss_4 = Wasserstein_loss(D_result_f4, D_result_r4)
            # Averages all perfusion map losses
            D_train_loss = (D_train_loss_1 + D_train_loss_2 + D_train_loss_3 + D_train_loss_4) * 0.25
        else:
            print('This generator loss mode is not supported')
            quit()
        
        # Backpropogate discriminator loss
        D_train_loss.backward(retain_graph=True)
        D_optimizer.step()
        
        
        ######################
        # (2) Update G network
        ######################
        
        # Initializes gradients of discriminator
        G.zero_grad()
        
        # Pass input through generator
        G_result = G(x_) # [bn, 1, 256, 1024]
        D_result = D(x_, G_result) # [bn, 4, 30, 30]
        
        D_result_1 = D_result[:, 0, :, :] # [bn, 30, 30]
        D_result_2 = D_result[:, 1, :, :]
        D_result_3 = D_result[:, 2, :, :]
        D_result_4 = D_result[:, 3, :, :]
        
        G_result_1 = G_result[:, :, :, 0:256] # [bn, 1, 256, 256]
        G_result_2 = G_result[:, :, :, 256:512]
        G_result_3 = G_result[:, :, :, 512:768]
        G_result_4 = G_result[:, :, :, 768:1024]
        
        # Split Labels
        y_1 = y_[:, :, :, 0:256] # [bn, 1, 256, 256]
        y_2 = y_[:, :, :, 256:512]
        y_3 = y_[:, :, :, 512:768]
        y_4 = y_[:, :, :, 768:1024]

        # Adversarial loss against real only + L1 (MAE) loss btwn fake and real imgs
        G_train_loss_1 = BCE_loss(D_result_1, Variable(torch.ones(D_result_1.size()).cuda()))
        G_train_loss_2 = BCE_loss(D_result_2, Variable(torch.ones(D_result_2.size()).cuda()))
        G_train_loss_3 = BCE_loss(D_result_3, Variable(torch.ones(D_result_3.size()).cuda()))
        G_train_loss_4 = BCE_loss(D_result_4, Variable(torch.ones(D_result_4.size()).cuda()))
        
        if 'L1' in opt.gen_mode:
            G_train_loss_1 += opt.gen_lambda * L1_loss(G_result_1,y_1)
            G_train_loss_2 += opt.gen_lambda * L1_loss(G_result_2,y_2)
            G_train_loss_3 += opt.gen_lambda * L1_loss(G_result_3,y_3)
            G_train_loss_4 += opt.gen_lambda * L1_loss(G_result_4,y_4)
        elif 'ssim' in opt.gen_mode:
            G_train_loss_1 += opt.gen_lambda * (1 - SSIM_loss(G_result_1,y_1)) # Fake - Real
            G_train_loss_2 += opt.gen_lambda * (1 - SSIM_loss(G_result_2,y_2))
            G_train_loss_3 += opt.gen_lambda * (1 - SSIM_loss(G_result_3,y_3))
            G_train_loss_4 += opt.gen_lambda * (1 - SSIM_loss(G_result_4,y_4))
        else:
            print('This generator loss mode is not supported')
            quit()
        
        # Averages all perfusion map losses
        G_train_loss = (G_train_loss_1 + G_train_loss_2 + G_train_loss_3 + G_train_loss_4) * 0.25
        
        #######################
        # (2.1) Multimodal Loss
        #######################
        '''
        (1-MTT), 2-TTP, (3-CBF), 4-CBV
        We calculate rCBV based on physiological relationship to MTT and rCBF.
        rCBF = rCBV / MTT can be re-written as rCBV = MTT * rCBF.
        '''
        if opt.use_multimodal_loss:
            cbv_pred = (G_result_1+1) * (G_result_3+1) / 2 # +1 to avoid zero division
            if 'L1' in opt.mml_mode:
                multimodal_loss = L1_loss(cbv_pred, (y_4+1)/2) * opt.mml_lambda
            elif 'ssim' in opt.mml_mode: #fix
                ssim_val = SSIM_loss(cbv_pred,y_4)
                multimodal_loss = (1 - ssim_val) * opt.mml_lambda
            elif 'correlation' in opt.mml_mode: #fix
                corr_val = util.corr2(cbv_pred, y_4)
                multimodal_loss = (1 - corr_val) * opt.mml_lambda
            else:
                print('This multimodal loss mode is not supported')
                quit()
          
            # Update generator loss with multimodal          
            G_train_loss = G_train_loss + multimodal_loss 
        
        ####################
        # (2.2) Extrema Loss
        ####################
        '''
        Normalize between 0 and 1.
        
        Extrema loss measures loss between generated and ground truth with focus on extrema values.
        (y_img_1 - 0.5)**2 > Calculates squared difference between each pixel - between ground truth y and 0.5.
        (G_img_1-y_img_1)**2) > Calculates squared difference between each pixel - between generated G and ground truth y.
        np.nanmean() > Calculates mean but ignores NaN background pixels.
        '''
        if opt.use_extrema_loss:

            # Prepare generated images
            G_img_1 = (G_result_1.cpu().detach().numpy().squeeze().astype('float') + 1) / 2
            #G_img_1 = cv2.normalize(G_result_1_copy.astype('float'), None, 0.0, 1.0, cv2.NORM_MINMAX)          
            G_img_2 = (G_result_2.cpu().detach().numpy().squeeze().astype('float') + 1) / 2
            #G_img_2 = cv2.normalize(G_result_2_copy.astype('float'), None, 0.0, 1.0, cv2.NORM_MINMAX)          
            G_img_3 = (G_result_3.cpu().detach().numpy().squeeze().astype('float') + 1) / 2
            #G_img_3 = cv2.normalize(G_result_3_copy.astype('float'), None, 0.0, 1.0, cv2.NORM_MINMAX)          
            G_img_4 = (G_result_4.cpu().detach().numpy().squeeze().astype('float') + 1) / 2
            #G_img_4 = cv2.normalize(G_result_4_copy.astype('float'), None, 0.0, 1.0, cv2.NORM_MINMAX)
          
            # Prepare labels
            y_1_copy = y_1.cpu().detach().numpy().squeeze()
            y_img_1 = cv2.normalize(y_1_copy.astype('float'), None, 0.0, 1.0, cv2.NORM_MINMAX)
            #y_img_1[y_img_1==0]=np.nan # Set black background to nans. We only want to encode tissue information with extrema loss   
            y_2_copy = y_2.cpu().detach().numpy().squeeze()
            y_img_2 = cv2.normalize(y_2_copy.astype('float'), None, 0.0, 1.0, cv2.NORM_MINMAX)
            #y_img_2[y_img_2==0]=np.nan          
            y_3_copy = y_3.cpu().detach().numpy().squeeze()
            y_img_3 = cv2.normalize(y_3_copy.astype('float'), None, 0.0, 1.0, cv2.NORM_MINMAX)
            #y_img_3[y_img_3==0]=np.nan
            y_4_copy = y_4.cpu().detach().numpy().squeeze()
            y_img_4 = cv2.normalize(y_4_copy.astype('float'), None, 0.0, 1.0, cv2.NORM_MINMAX)
            #y_img_4[y_img_4==0]=np.nan
          
            # Cal
            G_extrema_loss_1 = opt.ext_lambda * np.nanmean(((y_img_1 - 0.5)**2 * (G_img_1-y_img_1)**2))
            G_extrema_loss_2 = opt.ext_lambda * np.nanmean(((y_img_2 - 0.5)**2 * (G_img_2-y_img_2)**2))
            G_extrema_loss_3 = opt.ext_lambda * np.nanmean(((y_img_3 - 0.5)**2 * (G_img_3-y_img_3)**2))
            G_extrema_loss_4 = opt.ext_lambda * np.nanmean(((y_img_4 - 0.5)**2 * (G_img_4-y_img_4)**2))
                    
            # Averages all extrema losses
            G_extrema_loss = (G_extrema_loss_1 + G_extrema_loss_2 + G_extrema_loss_3 + G_extrema_loss_4) * 0.25
            
            # Updates generator loss with extrema
            G_train_loss = G_train_loss + G_extrema_loss
        
        # Backprops loss
        G_train_loss.backward()
        G_optimizer.step()
        
        ########################
        # (3) Sorting out losses
        ########################
        
        # Store loss values at each iteration
        train_hist['G_losses'].append(G_train_loss.item())
        train_hist['D_losses'].append(D_train_loss.item())
        
        G_losses_1.append(G_train_loss_1.item())
        G_losses_2.append(G_train_loss_2.item())
        G_losses_3.append(G_train_loss_3.item())
        G_losses_4.append(G_train_loss_4.item())
        
        if opt.use_multimodal_loss:
            multimodal_losses.append(multimodal_loss.item())
        
        if opt.use_extrema_loss:
            G_extrema_losses_1.append(G_extrema_loss_1)
            G_extrema_losses_2.append(G_extrema_loss_2)
            G_extrema_losses_3.append(G_extrema_loss_3)
            G_extrema_losses_4.append(G_extrema_loss_4)
          
        D_losses_1.append(D_train_loss_1.item())
        D_losses_2.append(D_train_loss_2.item())
        D_losses_3.append(D_train_loss_3.item())
        D_losses_4.append(D_train_loss_4.item())
        
        
        
        num_iter += 1

    epoch_end_time = time.time()
    per_epoch_ptime = epoch_end_time - epoch_start_time
    
    ########################
    # (4) PrettyTable Output
    ########################
    
    # Initialize prettytable and align left
    results_table = PrettyTable()
    results_table.align = "l"
    
    # Add losses [Current Epoch | Max Epochs | NaN | Time of Epoch (seconds)]
    results_table.add_column("Epoch Number & Time", [epoch+1, opt.train_epoch, float('nan'), util.truncate(per_epoch_ptime,3)])
    results_table.add_column("Discrim Losses", [util.truncate(torch.mean(torch.FloatTensor(D_losses_1)).item(),5), util.truncate(torch.mean(torch.FloatTensor(D_losses_2)).item(),5), \
    util.truncate(torch.mean(torch.FloatTensor(D_losses_3)).item(),5), util.truncate(torch.mean(torch.FloatTensor(D_losses_4)).item(),5)])
    results_table.add_column("Train Losses", [util.truncate(torch.mean(torch.FloatTensor(G_losses_1)).item(),5), util.truncate(torch.mean(torch.FloatTensor(G_losses_2)).item(),5), \
    util.truncate(torch.mean(torch.FloatTensor(G_losses_3)).item(),5), util.truncate(torch.mean(torch.FloatTensor(G_losses_4)).item(),5)])

    if opt.use_multimodal_loss:
        results_table.add_column("Multimodal Loss", [util.truncate(torch.mean(torch.FloatTensor(multimodal_losses)).item(),5), float('nan'), float('nan'), float('nan')])
    
    if opt.use_extrema_loss:
        results_table.add_column("Extrema Losses", [util.truncate(torch.mean(torch.FloatTensor(G_extrema_losses_1)).item(),5), util.truncate(torch.mean(torch.FloatTensor(G_extrema_losses_2)).item(),5), \
      util.truncate(torch.mean(torch.FloatTensor(G_extrema_losses_3)).item(),5), util.truncate(torch.mean(torch.FloatTensor(G_extrema_losses_4)).item(),5)])
    
    results_table.add_column("G & D Learning Rates",[util.truncate(G_optimizer.param_groups[0]['lr'],5), float('nan'), util.truncate(D_optimizer.param_groups[0]['lr'],5), float('nan')])
    print(results_table)
    
    ###################
    # (5) Miscellaneous
    ###################
    
    # Per epoch validation outputs
    fixed_p = root + 'validation_results/' + model + str(epoch + 1) + '.png'
    print("fixed_p: "+fixed_p)
    
    # Store loss values at the end of each epoch
    G_losses_avg = torch.mean(torch.Tensor([torch.mean(torch.FloatTensor(G_losses_1)), torch.mean(torch.FloatTensor(G_losses_2)), \
    torch.mean(torch.FloatTensor(G_losses_3)), torch.mean(torch.FloatTensor(G_losses_4))]))
    D_losses_avg = torch.mean(torch.Tensor([torch.mean(torch.FloatTensor(D_losses_1)), torch.mean(torch.FloatTensor(D_losses_2)), \
    torch.mean(torch.FloatTensor(D_losses_3)), torch.mean(torch.FloatTensor(D_losses_4))]))
    G_extrema_losses_avg = torch.mean(torch.Tensor([torch.mean(torch.FloatTensor(G_extrema_losses_1)), torch.mean(torch.FloatTensor(G_extrema_losses_2)), \
    torch.mean(torch.FloatTensor(G_extrema_losses_3)), torch.mean(torch.FloatTensor(G_extrema_losses_4))]))
    G_multimodal_losses_avg = torch.mean(torch.FloatTensor(multimodal_losses))
    #print(G_losses_avg)
    #print(D_losses_avg)
    #print(G_extrema_losses_avg)
    #print(G_multimodal_losses_avg)
    
    # Append to training history
    train_hist_epoch['G_loss_epoch'].append(G_losses_avg.item())
    train_hist_epoch['D_loss_epoch'].append(D_losses_avg.item())
    train_hist_epoch['Extrema_loss_epoch'].append(G_extrema_losses_avg.item())
    train_hist_epoch['Multimodal_loss_epoch'].append(G_multimodal_losses_avg.item())
    train_hist_epoch['Overall_G_loss'].append(G_losses_avg.item() + G_extrema_losses_avg.item() + G_multimodal_losses_avg.item())
    

    ####################
    # (6) Validation Set
    ####################
    # Repeats same processes as in training.
    
    # Set to validation mode and freeze gradient changes
    with torch.no_grad():
        G.eval()
        D.eval()
      
        try:
            util.show_result(G, fixed_x_, fixed_y_store, (epoch+1), num_show=num_show, save=True, path=fixed_p)
        except:
            print('Unable to generate validation image')
        
        # Set validation loss
        val_loss_total = 0
        
        # Iterate through each validation file.
        for item_val, _ in valid_loader:
            x_val = item_val[:, :, :, 0:img_size] # NCCT
            y_1_val = item_val[:, 0, :, img_size:2*img_size] # MTT
            y_1_val = torch.unsqueeze(y_1_val, 1)
            y_2_val = item_val[:, 0, :, 2*img_size:3*img_size] # TTP
            y_2_val = torch.unsqueeze(y_2_val, 1)
            y_3_val = item_val[:, 0, :, 3*img_size:4*img_size] # CBF
            y_3_val = torch.unsqueeze(y_3_val, 1)
            y_4_val = item_val[:, 0, :, 4*img_size:5*img_size] # CBV
            y_4_val = torch.unsqueeze(y_4_val, 1)

            y_val = torch.cat((y_1_val, y_2_val, y_3_val, y_4_val), dim=3)
            x_val = Variable(x_val.cuda()) # input
            y_val = Variable(y_val.cuda()) # ground truth
            g_image_val = G(x_val) # generated image

            D_result = D(x_val, g_image_val).squeeze()
            D_result_1 = D_result[0, :, :]
            D_result_2 = D_result[1, :, :]
            D_result_3 = D_result[2, :, :]
            D_result_4 = D_result[3, :, :]

            G_result_1 = g_image_val[:, :, :, 0:256]
            G_result_2 = g_image_val[:, :, :, 256:512]
            G_result_3 = g_image_val[:, :, :, 512:768]
            G_result_4 = g_image_val[:, :, :, 768:1024]

            y_1 = y_val[:, :, :, 0:256]
            y_2 = y_val[:, :, :, 256:512]
            y_3 = y_val[:, :, :, 512:768]
            y_4 = y_val[:, :, :, 768:1024]

            G_val_loss_1 = BCE_loss(D_result_1, Variable(torch.ones(D_result_1.size()).cuda()))
            G_val_loss_2 = BCE_loss(D_result_2, Variable(torch.ones(D_result_2.size()).cuda()))
            G_val_loss_3 = BCE_loss(D_result_3, Variable(torch.ones(D_result_3.size()).cuda()))
            G_val_loss_4 = BCE_loss(D_result_4, Variable(torch.ones(D_result_4.size()).cuda()))

            if 'L1' in opt.gen_mode:
                G_val_loss_1 += opt.gen_lambda * L1_loss(G_result_1, y_1)
                G_val_loss_2 += opt.gen_lambda * L1_loss(G_result_2, y_2)
                G_val_loss_3 += opt.gen_lambda * L1_loss(G_result_3, y_3)
                G_val_loss_4 += opt.gen_lambda * L1_loss(G_result_4, y_4)
            elif 'ssim' in opt.gen_mode:
                G_val_loss_1 += opt.gen_lambda * (1 - SSIM_loss(G_result_1, y_1))
                G_val_loss_2 += opt.gen_lambda * (1 - SSIM_loss(G_result_2, y_2))
                G_val_loss_3 += opt.gen_lambda * (1 - SSIM_loss(G_result_3, y_3))
                G_val_loss_4 += opt.gen_lambda * (1 - SSIM_loss(G_result_4, y_4))
            else:
                print('This generator loss mode is not supported')
                quit()
            
            G_val_loss = (G_val_loss_1 + G_val_loss_2 + G_val_loss_3 + G_val_loss_4) * 0.25
            
            #######################
            # (6.1) Multimodal Loss
            #######################
            if opt.use_multimodal_loss:
                cbv_pred = ((G_result_1+1) * (G_result_3+1)) / 2
                if 'L1' in opt.mml_mode:
                    multimodal_loss = L1_loss(cbv_pred, (y_4+1)/2) * opt.mml_lambda
                elif 'ssim' in opt.mml_mode: #fix
                    ssim_val = SSIM_loss(cbv_pred,y_4)
                    multimodal_loss = (1 - ssim_val) * opt.mml_lambda
                elif 'correlation' in opt.mml_mode: #fix
                    corr_val = util.corr2(cbv_pred, y_4)
                    multimodal_loss = (1 - corr_val) * opt.mml_lambda
                else:
                    print('This multimodal loss mode is not supported')
                    quit()


                G_val_loss = G_val_loss + multimodal_loss 

            ####################
            # (6.2) Extrema Loss
            ####################
            if opt.use_extrema_loss:
                G_img_1 = (G_result_1.cpu().detach().numpy().squeeze().astype('float') + 1) / 2
                #G_img_1 = cv2.normalize(G_result_1_copy.astype('float'), None, 0.0, 1.0, cv2.NORM_MINMAX)
                G_img_2 = (G_result_2.cpu().detach().numpy().squeeze().astype('float') + 1) / 2
                #G_img_2 = cv2.normalize(G_result_2_copy.astype('float'), None, 0.0, 1.0, cv2.NORM_MINMAX)
                G_img_3 = (G_result_3.cpu().detach().numpy().squeeze().astype('float') + 1) / 2
                #G_img_3 = cv2.normalize(G_result_3_copy.astype('float'), None, 0.0, 1.0, cv2.NORM_MINMAX)
                G_img_4 = (G_result_4.cpu().detach().numpy().squeeze().astype('float') + 1) / 2
                #G_img_4 = cv2.normalize(G_result_4_copy.astype('float'), None, 0.0, 1.0, cv2.NORM_MINMAX)
                y_1_copy = y_1.cpu().detach().numpy().squeeze()
                
                y_img_1 = cv2.normalize(y_1_copy.astype('float'), None, 0.0, 1.0, cv2.NORM_MINMAX)
                #y_img_1[y_img_1==0]=np.nan 
                y_2_copy = y_2.cpu().detach().numpy().squeeze()
                y_img_2 = cv2.normalize(y_2_copy.astype('float'), None, 0.0, 1.0, cv2.NORM_MINMAX)
                #y_img_2[y_img_2==0]=np.nan
                y_3_copy = y_3.cpu().detach().numpy().squeeze()
                y_img_3 = cv2.normalize(y_3_copy.astype('float'), None, 0.0, 1.0, cv2.NORM_MINMAX)
                #y_img_3[y_img_3==0]=np.nan
                y_4_copy = y_4.cpu().detach().numpy().squeeze()
                y_img_4 = cv2.normalize(y_4_copy.astype('float'), None, 0.0, 1.0, cv2.NORM_MINMAX)
                #y_img_4[y_img_4==0]=np.nan

                G_extrema_loss_1 = opt.ext_lambda * np.nanmean(((y_img_1 - 0.5)**2 * (G_img_1-y_img_1)**2))
                G_extrema_loss_2 = opt.ext_lambda * np.nanmean(((y_img_2 - 0.5)**2 * (G_img_2-y_img_2)**2))
                G_extrema_loss_3 = opt.ext_lambda * np.nanmean(((y_img_3 - 0.5)**2 * (G_img_3-y_img_3)**2))
                G_extrema_loss_4 = opt.ext_lambda * np.nanmean(((y_img_4 - 0.5)**2 * (G_img_4-y_img_4)**2))
                G_extrema_loss = (G_extrema_loss_1 + G_extrema_loss_2 + G_extrema_loss_3 + G_extrema_loss_4) * 0.25

                G_val_loss = G_val_loss + G_extrema_loss

            val_loss_total += G_val_loss
      
      
        # Averages loss across all samples and print losses
        val_loss_total = val_loss_total / len(valid_loader)
        print('-----------------------------------------------')
        print('----Training loss: ' + str(G_train_loss.item()))
        print('--Validation loss: ' + str(val_loss_total.item()))
        print('-----------------------------------------------')
      
        # Add validation losses to graph history
        train_hist_epoch['val_loss_epoch'].append(val_loss_total.item())
        
        # Set back to training mode.
        G.train()
        D.train()
      
    
    ############################
    # (7) Save Model Checkpoints
    ############################
    
    if opt.use_checkpoint:
        if ((epoch+1) % opt.save_freq == 0) and ((epoch+1) != opt.train_epoch):
            print('saving model for checkpoint')
            torch.save(G.state_dict(), root + 'model_weights/' + 'generator_param_epoch' + str(epoch+1) + '.pkl')
        
        if ((epoch+1) % opt.save_fig_freq == 0) and ((epoch+1) != opt.train_epoch):  
            with open(root + 'training_histograms/' + 'train_hist_epoch' + str(epoch+1) + '.pkl', 'wb') as f:
                pickle.dump(train_hist_epoch, f)
    
        util.show_train_hist_epoch(train_hist_epoch, save=True, path=root + 'training_histograms/' + 'train_hist_epoch' + str(epoch+1) + '.png')
    
    # Update learning rates
    G_optim_scheduler.step()
    D_optim_scheduler.step()
    
    # Update the progress bar
    epoch_progress.set_description(f'Epoch {epoch + 1}/{opt.train_epoch}')
    epoch_progress.update(1)

print("Done with training! Saving results")
    
# Close output file
file_output.close()
    
# Close progress bar
epoch_progress.close()

# Save generator and discriminator weights
torch.save(G.state_dict(), root + 'model_weights/' + 'generator_param_final.pkl')
torch.save(D.state_dict(), root + 'model_weights/' + 'discriminator_param.pkl')

# Save training history
with open(root + 'training_histograms/' + 'train_hist.pkl', 'wb') as f:
    pickle.dump(train_hist, f)

# Visualize training history
util.show_train_hist(train_hist, save=True, path=root + 'training_histograms/' + 'train_hist.png')

# Save epoch-wise training history
with open(root + 'training_histograms/' + 'train_hist_epoch_final.pkl', 'wb') as f:
    pickle.dump(train_hist_epoch, f)

# Visualize epoch-wise training history
util.show_train_hist_epoch(train_hist_epoch, save=True, path=root + 'training_histograms/' + 'train_hist_epoch_final.png')