# Flutter-One2One


## Installation

======================

Open the below link, and select “Operating System” for the installation of Flutter:  
<br/>
https://flutter.dev/docs/get-started/install 

#### Note:

Now run <b>"flutter doctor"</b> in <b>Terminal/Command Prompt</b>, and make sure all tick-marks appear green, as shown in the below screenshot. 

<img width="603" alt="MicrosoftTeams-image" src="https://user-images.githubusercontent.com/86484384/139054351-32baf182-20d3-476a-b73e-df1927210ffe.png">

## Repo Clone:	

1. Open Github URL of VdoTok’s Flutter one2one Audio/Video Call " https://github.com/vdotok/Flutter-one2one "
2. Click on <b>Code</b> button, appearing on R.H.S
3. A toast for <b>Clone</b> will appear, containing HTTPS, SSH, and GitHub CLI  information
4. On HTTPS section, copy repository <b>URL</b> 
5. Open <b>Terminal/Command Prompt</b> and go to the <b>Directory</b> where you want to clone the project
6. Write git clone and <b>Paste</b> copied repository URL and press <b>Enter</b> 

## VS Code Installation: 

1. Install the latest version of <b>VS Code</b>
2. Open your Project in <b>VS Code</b>

## Project Run Steps:

1. Open Project in <b>VS Code</b>
2. Open <b>Terminal</b> and go to <b>Project Directory</b> and run <b>“flutter pub get”</b>. If this command runs successfully, then a success message <b>(exit code 0)</b> will display, as shown below:</b>

![18](https://user-images.githubusercontent.com/87179594/184533024-3a4eb249-4ab0-41a2-b55e-27d42c66df89.jpg)

## SDK Authentication: 

* Every User is required to authenticate SDK before using VdoTok application. 
* When a User connects with an application using SDK, the application will require a Project_ID. (A Project_ID is a string that uniquely identifies a project). 
* To generate a Project_ID, perform the following steps: 

1. Run this link -> https://vdotok.com/ in Chrome. A screen will appear. Please click on the Login link, as shown below: 

![1](https://user-images.githubusercontent.com/87179594/184070841-f9b91f46-93df-4047-acfb-4739fd207aaa.jpg)

* This will navigate to Login page, where the User is required to enter the following information: <b>Email > Password. </b> If User does not have any account then follow Sign up here link, as shown below </b>

![2](https://user-images.githubusercontent.com/87179594/184070980-92e4ef0e-923f-4597-a118-dd2d661a99dc.jpg) 

* This will navigate to Sign Up page, where the User is required to enter the following information: <b>First Name > Last Name > Email > Country > Password. </b>Select <b>Sign Up For Free</b> button </b>

![3](https://user-images.githubusercontent.com/87179594/184070989-e8b26d85-6e64-4ef3-b6d7-56449738236c.jpg) 

* This will navigate to Verify your email address page, where the User is required to enter the code which is sent to the registered email </b>

![4](https://user-images.githubusercontent.com/87179594/184070997-3247f0e0-3f6a-42fb-90cd-2d087bb25e1e.jpg) 

* After verifing email address ,user will navigate to Verify your Phone Number where the User is required to enter the his/her Phone number and press <b>SEND CODE</b> button </b>

* Else press <b>Skip for now</b> button </b>

![5](https://user-images.githubusercontent.com/87179594/184071006-9dc41271-1455-4215-99f8-14921dbe181a.jpg)

* After this, User will navigate to Tell us more about yourself where the User is required to select <b>Type of Business</b> and <b>Organization name</b> and press <b>DONE</b> button </b>

![6](https://user-images.githubusercontent.com/87179594/184071015-17165a2f-607a-4f9f-9dc5-1ba5fd3b935a.jpg)

* After this, a screen will display in which User has to enter some details about Project: <b>Project name > Your role?</b> and press <b>TAKE ME TO THE DASHBOARD</b>

![7](https://user-images.githubusercontent.com/87179594/184071023-8c9c02f9-c473-48e5-89b6-43399c26fa6f.jpg)

* Now User is on Dashboard screen. Follow the link <b>API TOKENS</b>, as shown below</b>

![8](https://user-images.githubusercontent.com/87179594/184071053-df6bd93e-ed00-46fe-9495-8d990a0ac5e9.jpg) 

* Copy <b>Tenant Testing Server</b> and <b>Project ID</b>

![9](https://user-images.githubusercontent.com/87179594/184071060-9909513b-f880-4de8-9481-6ab91ae2be95.jpg)

2. Open Project in <b>VS Code</b>
3. Go to <b>lib</b> folder > <b> src > core > config > </b> open <b>config.dart</b> file, add <b>API Service URL</b> in const URL as <b>http:// Paste Url Here Which You Copied/API/</b> and <b>Project ID</b> against project_id String in config.dart file

![6](https://user-images.githubusercontent.com/87179594/158434303-53a0a655-607d-402d-bc9b-7e8dd0242b5f.jpg)

4. Save <b>config.dart</b> file 

## iOS Setup: 

* Make sure that you have the latest <b>Xcode</b> installed in your MacBook 
* For pod installation: 

1. Open <b>Terminal</b>
2. Go to <b>Project Directory</b>
3. Run <b>cd ios</b>
4. Run <b>Pod Install</b>

![MicrosoftTeams-image (1)](https://user-images.githubusercontent.com/86484384/139202518-daeb9b97-fa18-476b-bc5f-d48020131d92.jpg)

* <b>To Open a Project in Xcode:</b>

1. Go to your <b>Project Folder</b>
2. Go to <b>ios folder</b> in your project 
3. Double click on the <b>Runner.xcworkspace</b>

![8](https://user-images.githubusercontent.com/86484384/139203776-bf1fe5fd-2530-4d4b-b30e-199468429449.jpg)

* <b>To Configure Developer Account after Opening a Project in Xcode:</b>

1. Select <b>File Folder</b> icon, appearing on top LHS in blue color 
2. Select <b>Runner</b> of Xcode 
3. Select <b>Runner</b> of your application 
4. Select <b>Signing and Capabilities</b>
5. Select <b>All</b>
6. Select <b>Teams</b> dropdown 
7. Select <b>Add an Account</b> option 
![9](https://user-images.githubusercontent.com/86484384/139213606-e091c899-d631-44d2-95d7-a41542a17d61.jpg)

* <b>To Add Apple Account:</b>

1. Enter <b>Apple ID</b>
2. Select <b>Next</b> button
![MicrosoftTeams-image (5)](https://user-images.githubusercontent.com/86484384/139230893-a99c0476-ea9d-4df3-bcf2-ee163bf702d7.jpg)

3. Enter <b>Password</b>
4. Select <b>Next</b> button
![MicrosoftTeams-image (2)](https://user-images.githubusercontent.com/86484384/139231712-f94b1e76-fda8-435a-9284-ccc09e4d9d96.jpg)

5. Enter <b>Verification Code</b>
6. Select <b>Continue</b> button
<img width="442" alt="MicrosoftTeams-image (3)" src="https://user-images.githubusercontent.com/86484384/139232081-ba1d8eed-2075-4cac-84f0-b1c3083e3079.png">

7. The end-product will look like below screenshot. Make sure it contains no error box 
![MicrosoftTeams-image (4)](https://user-images.githubusercontent.com/86484384/139232686-8c872744-db54-4785-bc1b-b22ae0691dd3.jpg)

* <b>To Run Code on a Physical Device:</b>

1. Attach iOS device with your machine 
2. Select your <b>device</b> from Xcode 
![14](https://user-images.githubusercontent.com/86484384/139233823-ea67475a-d919-4945-88da-5a205a86bac0.jpg)

![15](https://user-images.githubusercontent.com/86484384/139233996-d47eee74-33f8-42fc-96f2-b157da018e67.jpg)

3. Select <b>Run</b> button
![16](https://user-images.githubusercontent.com/86484384/139234426-e5a54b59-b050-4038-83d2-592b0dbc3343.jpg)

## Android Setup: 

### Project Run Steps: 

1. Open Project in <b>VS Code</b>
2. Open <b>Terminal/Command Prompt</b> and go to <b>Project Directory</b> and run <b>“flutter pub get”</b>

### Device Setting: 

To connect a device, enable <b>Developer Mode</b> and <b>USB Debug</b> by following the device-specific steps given on the below link:  
https://developer.android.com/studio/debug/dev-options 

## Build Project:

After connecting your phone, run the following command in <b>Project Directory -> "flutter run"</b>. If this command runs successfully, then following screen will display on mobile phone.

![New Project (23)](https://user-images.githubusercontent.com/87179594/184534873-b6c1836a-89a3-4567-98ae-913ea0a97d8d.jpg)