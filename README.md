# Example Powershell App Deploy Toolkit Deployment

This is an example script with resources to install applications via the Powershell App Deploy Toolkit.

The deployment uses the new version 4 release, which can be found here: https://psappdeploytoolkit.com/docs

It is designed to be used to install base applications onto a computer after installing Windows for a university environment. 

By default, it is set to install:
* Google Chrome Enterprise
* Mozilla Firefox
* Adobe Acrobat Reader
* Microsoft Office
    * The sample configuration file assumes there is a device-based license for the Office applications
* Dell Command Update
* Zoom Workplace 
* Cisco Webex 
* VLC Media Player

Installation files will need to be provided for each application.

It also can remove bloat applications from Windows if you are installing from the base Windows installation media.

## How to run
1. You must be in an administrative session to run this deployment. Log into Windows using an administrator account or run the application as an administrator.
2. Clone this repository to any directory. C:\Temp is a good place to store these files.
3. Make modifications to the deployment by adding installation files to the Files directory and adding code to the Invoke-AppDeployToolkit.ps1 file.
4. [Optional] Add your logos to the Assets folder to customize the look of the App Deploy Toolkit window. Information about assets can be found [<ins>here</ins>](https://psappdeploytoolkit.com/docs/usage/customizing-deployments#assets).
5. Run the Invoke-AppDeployToolkit.exe file.

## Repository Management
There are no promises that any pull requests for this repository will be reviewed. This is provided "as is" and should be forked/downloaded and modified for your specific needs.
