#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Creates map of 4-step policy space with associated lifetimes

Peter Attia
Last modified June 25, 2018
"""

import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import sys

##############################################################################

# PARAMETERS TO CREATE POLICY SPACE
C1list = [3.6, 4.0, 4.4, 4.8, 5.2, 5.6, 6, 8]
C2list = [3.6, 4.0, 4.4, 4.8, 5.2, 5.6, 6, 7]
C3list = [3.6, 4.0, 4.4, 4.8, 5.2, 5.6]

C4_LIMITS = [0.1, 4.81] # Lower and upper limits specifying valid C4s
FILENAME = 'D:\Data_Matlab\Result_tables\\25-Jun-2018_oed1_predictions.csv'

############################################################################## 
plt.close('all')
colormap = 'plasma_r'   

path_table = sys.argv[1]
path_images = sys.argv[2]
batch_name = sys.argv[3]

one_step = 4.8
margin = 0.2 # plotting margin

## IMPORT POLICIES
data = np.genfromtxt(FILENAME, delimiter=',',skip_header=1)
policies = data[:,:4]
lifetime = data[:,4]

## CREATE CONTOUR PLOT
# Calculate C4(CC1, CC2) values for contour lines
C1_grid = np.arange(min(C1list)-margin,max(C1list) + margin,0.01)
C2_grid = np.arange(min(C1list)-margin,max(C1list) + margin,0.01)
[X,Y] = np.meshgrid(C1_grid,C2_grid)

# Initialize plot
fig = plt.figure() # x = C1, y = C2, cuts = C3, contours = C4
plt.style.use('classic')
plt.rcParams.update({'font.size': 16})
plt.set_cmap(colormap)
manager = plt.get_current_fig_manager() # Make full screen
manager.window.showMaximized()
minn, maxx = min(lifetime), max(lifetime)

## MAKE PLOT
for k, c3 in enumerate(C3list):
    plt.subplot(2,3,k+1)
    plt.axis('square')
    
    C4 = 0.2/(1/6 - (0.2/X + 0.2/Y + 0.2/c3))
    C4[np.where(C4<C4_LIMITS[0])]  = float('NaN')
    C4[np.where(C4>C4_LIMITS[1])] = float('NaN')
    
    ## PLOT CONTOURS
    levels = np.arange(2.5,4.8,0.25)
    C = plt.contour(X,Y,C4,levels,zorder=1,colors='k')
    plt.clabel(C,fmt='%1.1f')
    
    ## PLOT POLICIES
    idx_subset = np.where(policies[:,2]==c3)
    policy_subset = policies[idx_subset,:][0]
    lifetime_subset = lifetime[idx_subset]
    plt.scatter(policy_subset[:,0],policy_subset[:,1],vmin=minn,vmax=maxx,
                c=lifetime_subset.ravel(),zorder=2,s=100)
    
    plt.title('C3=' + str(c3) + ': ' + str(len(policy_subset)) + ' policies',fontsize=16)
    plt.xlabel('C1')
    plt.ylabel('C2')
    plt.xlim((min(C1list)-margin, max(C1list)+margin))
    plt.ylim((min(C1list)-margin, max(C1list)+margin))

# Add colorbar
fig.set_size_inches((15,8.91), forward=False)
plt.tight_layout()

fig.subplots_adjust(right=0.8)
cbar_ax = fig.add_axes([0.85, 0.15, 0.05, 0.7])
norm = matplotlib.colors.Normalize(minn, maxx)
m = plt.cm.ScalarMappable(norm=norm, cmap=colormap)
m.set_array([])
cbar = fig.colorbar(m, cax=cbar_ax)
#plt.clim(min(lifetime),max(lifetime))
cbar.ax.set_title('Cycle life')

## SAVE FIGURE
plt.savefig(path_images + '\\' + batch_name + '\\' + 'summary3_predictions.png', bbox_inches='tight')