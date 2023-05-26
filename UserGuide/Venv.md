# Setting up a virtual environment

<div style='text-align: justify;'>

Working in a virtual environment is not necessary to run the different scripts of this project. However, it remains a good practice when working with Python as it ensures that you are working with the correct version of each library. 

In the following pages, we will present how to create and activate a virtual environment in VS code (installation guides for other editor can be easily found on the internet). 

## Create a virtual environment

In VS code, virtual environments can be easily created by using the shortcut **Ctrl+shift+p** and entering *Python: Create Environment..." in the prompt. 

After this first action, the editor will immediately suggest to create a *Venv* or *.venv* virtual environment in the current workspace. 

<p align="center">
    <img src="/UserGuide/Figures/venv1.png" width = 640 height = 135>
</p>

Then, VS code will ask for the interpreter path, i.e., the path to the location where Python has been installed. One can either type the path directly in the prompt, or select **Enter interpreter path...** and click on **Find...** to search for Python application in the file system. 

<p align="center">
    <img src="/UserGuide/Figures/venv2.png" width = 640 height = 135>
</p>

<p align="center">
    <img src="/UserGuide/Figures/venv3.png" width = 640 height = 135>
</p>

<p align="center">
    <img src="/UserGuide/Figures/venv4.png" width = 328 height = 230>
</p>

Finally, one will have the possibility to add dependencies (*requirements.txt*) to the virtual environment. This action is not required. It will simply allow to install all the packages needed to run this project. Yet this can also be done afterwards using: 
```
pip install -r requirements.txt
``` 
in the terminal window.

Once this has been done, the virtual environment (*.venv*) will be added to the *SEMIC_PLEDGES* folder.  

<p align="center">
    <img src="/UserGuide/Figures/venv5.png" width = 640 height = 135>
</p>

<p align="center">
    <img src="/UserGuide/Figures/venv6.png" width = 214 height = 340>
</p>

## Activate the virtual environment

Before starting to play with different scripts of this project, a last action to take will be to activate the virtual environment *.venv*.

This can be done by opening a terminal window (**Ctrl+shift+ù**) and entering the following command (for windows):
```
.venv\Scripts\activate
```

This is what that terminal window should look like after the activation command: 
```
PS <path of current directory> .venv\Scripts\activate

(.venv) PS <path of current directory> 
``` 

Once the virtual environment has been activated, all the packages from *requirements.txt* can be installed (if not already done) using: 
```
pip install -r requirements.txt
``` 

For desactivating *.venv*, simply enter **deactivate** in the terminal window.
</div>