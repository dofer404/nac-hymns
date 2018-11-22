# ar_nac_hymns

A simple Android/Flutter app to generate the hymns tables for the NAC services.

## How to install

  - Quick answer: "flutter run" inside the ar_nac_hymns folder
  - Longer answer:
    - Pre-requisites:
        - An Android phone, [enable debug mode](https://www.howtogeek.com/129728/how-to-access-the-developer-options-menu-and-enable-usb-debugging-on-android-4.2/). (in theory an Apple phone will also do)
        - A computer with [Flutter](https://flutter.io/docs/get-started/install) installed 
    - Clone [this project](https://github.com/dofer404/nac_hymns) on your computer
    - Connect your Android phone to your computer for development.
        - Accept the USB Debug related dialog that the phone shows.
    - Get a terminal into the cloned repository, cd into the ar_nac_hymns directory
    - Execute the command "flutter run"
        - The app will be installed and opened on your phone
    - Enjoy

Note: This app is not currently published in any app store (that I know)

## VSCode Workspace

This repository is a VSCode workspace containing two flutter projects:
  - ar_nac_hymns: Flutter app that let's you print your NAC Hymns. Uses the other project.
  - extended_pdf_page: A flutter package project that adds margin and orientation 'management' plus a dashed line drawing function over pdf/pdf.dart from the printing package.