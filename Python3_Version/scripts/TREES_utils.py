# Written by Matt Cook
# Created July 11, 2016
# mattheworion.cook@gmail.com

import os.path as path
import pickle
import tkinter
from tkinter import filedialog as fd
from tkinter import Label, Button, Entry, Frame
from tkinter.constants import BOTH, LEFT
from tkinter import StringVar, E, W

import matplotlib.pyplot as plt

import mbox
import blue_stain_xylem_scaling_module as xsmod
import water_stress_module as wsmod
import gsv0
import gs_ref_module as gsr

class WorkSpace(object):
    """Stores current workspace to save"""
    def __init__(self, StrVar, opts):
        self.toSave = {}
        self.toSave['opts'] = opts
        self.toSave['fields'] = StrVar
        
        
    def save(self):
         """Saves data from workspace"""    
         pickle.dump(self.toSave, open( "workspace.p", "wb" ) )

        
def makeMain(root, fields, calcs, exists=False, **opts):
   """
   Populates main window.
   
   Args:
       root(tkinter object): 
           main window
       
       titles(array):
           Titles of rows to populate.  Used to determine button functions too.
           
       calcs(array):
           Titles of calculations to perform.  Used to determine button
           functionality.
           
       exists(boolean):
           If a workspace exists already, load from there. Default = False.
       
       opts(dictionary):
           Stores options for filename and directory selection buttons.
   
   Returns:
       Populated main window.
       
   TO DO:
       Make the workspace loadable. And improve documentation/flow.
       
   """
   entries = []
   row = 0
   dirOpt = opts['dirOpts']
   fileOpt = opts['fileOpts']
   # initialize array for stringVariables
   StrVar = []
   
   #add menu bar to window
   __makeMenuBar(root)
   
   #create a Frame to hold the widgets
   frame = Frame(root)
   frame.pack(expand=True,
              fill=BOTH)
   frame.columnconfigure(1, weight=1)
   
   #create a Frame to hold the calculate buttons
   frame2 = Frame(root)
   frame2.pack(expand=True,
               fill=BOTH)
   frame2.columnconfigure(0, weight=1)
   
   for field in fields:
      # initialize textVariable for the entry
      StrVar.insert(row, StringVar(''))
      

      lab = Label(frame,
                  text=field)
      ent = Entry(frame,
                  textvariable=StrVar[row])
      lab.grid(row=row,
               column=0,
               sticky=W)
      ent.grid(row = row, 
               column = 1,
               sticky=W+E)
      if "Directory" in field:
          btn = Button(frame,
                       text = 'Select the directory',
                       command = lambda row=row : __dir2Ent(StrVar[row],
                                                                **dirOpt))
          fileOpt['initialdir'] = btn   
      else:
          btn = Button(frame,
                       text = 'Select the file',
                       command = lambda row=row : __filename_2_ent(StrVar[row],
                                                                   **fileOpt))
      btn.grid(row = row,
               column = 3,
               sticky = E)
      entries.append((field, ent, btn))
      row += 1
      if row == len(fields):
          for calc in calcs:
              runBtn = Button(frame2,
                              text = "Calculate " + calc,
                              command = lambda field=calc : calculate(StrVar,
                                                                      field))
              runBtn.pack(side = LEFT, padx = 2)
   ws = WorkSpace(StrVar, opts)
   ws.save()


def calculate(StrVar, title):
    """
    Button function to calculate the Xylem Scalar or Water Stress.
    
    Args:
       StrVar(tuple):
           String Variables holding modifiable names of directory and files

       title(string):
           Title of calculation to perform. Used for selection of function.
    
    TO DO:
        Make scalable with regards to button creation.
        
    """
    
    # Set working directory in which to look for files
    work_dir = StrVar[4].get()
    work_dir = str(work_dir)
    
    # check the directory (make more robust later)        
    __checkDir(work_dir)
    
    # Get and store filenames in local variables
    xs_obs = StrVar[0].get()
    sf_obs = StrVar[1].get()
    ws_obs = StrVar[2].get()
    atm = StrVar[3].get()
       
    # Convert from String Variable to built-in String
    xs_obs = str(xs_obs)
    sf_obs = str(sf_obs)
    ws_obs = str(ws_obs)
    atm = str(atm)    
    
    # Choose the calculation to do using name of button
    if title == 'Gsv0' and __checkFile(atm):
        
        if(__checkFile(ws_obs, tag = 'c') and __checkFile(xs_obs, tag = 'c')
           and __checkFile(sf_obs, tag = 'c') and __checkFile(atm, tag = 'c')):
            
            # Store object containing Xylem Scalar
            xs = xsmod.XylemScalar(work_dir, xs_obs, sf_obs)
            
            # Store object containig Water Stress
            ws = wsmod.WaterStress(work_dir, ws_obs)
                        
            # calculate and store gs_ref and the results 
            gs = gsr.GsRef(work_dir, 'PICO_atm_demand_data.csv')  
            
            # Unpack and store values needed for gsv_0 calculation
            gsv_0 = gsv0.Gsv_0(xs, ws, gs)
            
            # Calculate gsv0                     
            gsv_0.calculate()
        
            
    elif title == 'Water Stress' and __checkFile(ws_obs, tag = 'c'):
        ws = wsmod.WaterStress(work_dir, ws_obs)
        plot(ws, title)
        
    elif (title == 'Xylem Scalar' and __checkFile(xs_obs, tag = 'c') 
            and __checkFile(sf_obs, tag = 'c')):
        xs = xsmod.XylemScalar(work_dir, xs_obs, sf_obs)
        plot(xs, title)


def plot(mod, title):
    """
    Plots the simulated and observed models using matplotlib.  Window
    will popup and user has option to save the plot.
    
    Args:
        mod = class to store graph with
        title = title of the graph
        
    Returns:
        Pyplot graph which can be saved by the user.
    
    """
    # Popup window to ask user if they wish to plot the model
    toPlot = mbox.mbox("Do you want to plot the models?",
                         ('Yes','yes'),
                         ('No','no'))
                         
    if toPlot == 'yes' :
        mod.graph = plt.figure()
        plt.plot()
        plt.plot(mod.sim, 'r-', label='simulated')
        plt.plot(mod.obs, 'b.', label='observed')
        plt.title(title)
        plt.legend()     
        plt.show() 
         
    
def __closeWindow(window): 
    """Function to save workspace and close window."""
    WorkSpace.save()    
    window.destroy()


def __makeMenuBar(window):
    """Create a menu bar with an Exit command"""
    menubar = tkinter.Menu(window)
    filemenu = tkinter.Menu(menubar, tearoff = 0)
    filemenu.add_command(label = "Exit", command = window.destroy)
    filemenu.add_command(label = "Save Workspace", command = WorkSpace.save())
    menubar.add_cascade(label = "File", menu = filemenu)
    window.config(menu = menubar)
 

def __checkDir(working_dir):
    """
    Check if a working directory has been chosen
    
    Args:
        working_dir(string):
            A string containing name of the directory
        
    Returns:
        True if directory has been chosen and is valid
        False if directory not chosen or invalid
        
    """
    if working_dir == '':
        # show popup to alert user of mistake
        mbox.mbox(msg = "Please choose a directory in which to work", b2=None)
        return False
    else:
        return True


def __checkFile(filename, tag = None):
    """
    Check a file has been chosen and is a .csv or .txt file
    
    Args:
        working_dir(string):
            A string containing name of the file
        
        tag(char):
            A character indicating further instructions needed on error.
            
    Returns:
        True if filename ends in .csv or .txt
        False otherwise
    """
    try:
       if tag == 'c':
           message = "Please correct your the following errors"
           message += "before calculating: \n"
       filename = filename.lower()
       if filename.endswith('.csv') or filename.endswith('.txt'):
           return True
           
       elif filename == '':
           message = "You are missing a file."
           # Show popup with message to alert user
           mbox.mbox(msg = message, b2=None)
           return False
           
       else:
           message = "Your file : " 
           message += filename + " is not in the correct format."
           message += "\nAccepted filetypes are .csv and .txt"
           # Show popup with message to alert user
           mbox.mbox(msg = message, b2=None)
           return False
           
    except Exception as e:
        print("The following error has occured: ")   
        print(e)


def __dir2Ent(var, **dirOpt):
    """
    Sets the entry's textvariable to selected working dir
    """
    var.set(__select_workdir(**dirOpt))

    
def __filename_2_ent(var, **fileOpt):
    """ Sets the entry's textvariable to selected working dir"""
    filename = __select_filename(**fileOpt)
    filename = path.basename(filename)
    var.set(filename)

    
def __select_workdir(**dirOpt):
    """
    Opens directory browser and warns user if no directory is chosen.
    Used to set working directory
    
    Args:
        dirOpt(dictionary): A list of directory options
            
    Returns:
        work_dir(string):  Path of working directory
    
    """
    working_dir = fd.askdirectory(**dirOpt)
    # check if directory was chosen
    if not __checkDir(working_dir):
        working_dir = fd.askdirectory(**dirOpt)
    return working_dir

def __select_filename(**fileOpt):
    """
    Opens file browser and checks chosen file is .csv. If not .csv, show
    warning popup
    
    Args:
        fileOpt(dictionary):
            A list of directory options and acceptable filetypes
        
    Returns:
        filename:
            Filename in string format
    """
    filename = fd.askopenfilename(**fileOpt)
    # check file type is correct
    if not __checkFile(filename) :                                            
        filename = fd.askopenfilename(**fileOpt)
    return filename

