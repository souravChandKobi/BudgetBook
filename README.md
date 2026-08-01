# Budget Book 

So, Story Time, I spent around ₹9000 in a week, and I had no idea where it went. So I decided "I'm going to track my budget from now on", BUT turns out it's a hassle using the 'Notes App', and other budget management apps are not "automatic" enough.
So here comes the idea:

An Android app for budget management that works with Google Pay.

Basically, I wanted an app that would automatically open when I complete a transaction, since it's a hassle to manually open an app and make an entry.
This app pops up an overlay bubble after a transaction, and all you have to do is enter the item name, quantity & price, and it will create a new entry.


<p align="center">
  <img src="/assets/homescreen.jpg" width="30%" />
  <img src="/assets/entry.jpg" width="30%" />
  <img src="/assets/topexpenses.jpg" width="30%" />
</p>


## Installation Instructions

Download the APK.

Install the app with 'Google Play Services' disabled, because Google Play flags it as Suspicious for asking for Accessibility permissions.

Or Adb sideload if you can.

Go to settings and give the necessary permissions.

For the automatic overlay pop-up and notification on Google Pay transactions, you need to give Accessibility permission.

Log in for online cloud save.

⚠️ NOTE: On brands like Oppo, Realme, etc (the non-stock phones), the system tries to kill app Foreground services, so unrestricting battery optimization might help and do a quick reboot. 

 
