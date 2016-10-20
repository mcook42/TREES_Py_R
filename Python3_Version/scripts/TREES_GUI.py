# Written by Matt Cook
# Created July 8, 2016
# mattheworion.cook@gmail.com

import os.path
import pickle
import tkinter

import TREES_utils as utils



class MainMenu(object):

    def __init__(self):
        
        root = self.root = tkinter.Tk()
        root.title('Welcome to the TREES Graphical User Interface')
        
        # width x height + x_offset + y_offset:
        root.minsize(width=800, height=100)
        
        # Look for a pickle of previous setup in current directory
        curr_dir = os.path.curdir
        filename = curr_dir + 'prev_ws.p'
        if os.path.isfile(filename):
            wSpace = pickle.load(filename)
            opts = wSpace['opts']
            
        # if no previous workspace, initialize
        else:
            # defining options for opening a directory
            self.dirOpt = dirOpt = {}
            dirOpt['mustexist'] = False
            dirOpt['parent'] = root
            dirOpt['title'] = 'Please choose your working directory' 
            
            # define options for opening or saving a csv file
            self.fileOpt = fileOpt= {}
            fileOpt['defaultextension'] = '.csv'
            fileOpt['filetypes'] = [('csv files', '*.csv'),
                                    ('text files', '*.txt')]
            fileOpt['initialdir'] = '\\'
            fileOpt['parent'] = root
            fileOpt['title'] = 'Please select your file'
            
            # Store opts as one dicitionary to pass into make
            self.opts = opts = {}
            opts['dirOpts'] = dirOpt
            opts['fileOpts'] = fileOpt
            
        # defining titles for frames
        self.frame_titles = titles = []
        
        titles.insert(0, 'Blue Stain Xylem data:                    ')
        titles.insert(1, 'Daily Sap Flux Decline data:              ')
        titles.insert(2, 'Water Stress data:                        ')
        titles.insert(3, 'Gsref data:                               ')
        titles.insert(4, 'Directory containing data files:          ')
        
        # Hard code this for now, come back and changelater
        calcs = ['Xylem Scalar', 'Water Stress', 'Gsv0']
        
        # populate window with widgets
        utils.makeMain(root, titles, calcs, **opts)




mainGUI = MainMenu()
root = mainGUI.root
root.bind('<Escape>', lambda e: utils.__closeWindow(root))

root.mainloop()