# uber_driver_app

### Features
User Authentication: Users can sign up and log in to the app to access its functionalities.
Map View: Displays a map using Google Maps API, showing the user's current location and nearby landmarks.

### Installation

1- Clone this repository: git clone https://github.com/Meriem-Boussoufa/uber_driver_app

2- Navigate to the project directory: cd uber_driver_app

3- Install dependencies: flutter pub get

4- Ensure you have Google Maps API keys for both Android and iOS platforms.

5- Add your Google Maps API keys to the appropriate files:
    - For Android, add the API key to android/app/src/main/AndroidManifest.xml: <meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_ANDROID_API_KEY"/>, 
    - For iOS, add the API key to ios/Runner/AppDelegate.swift: GMSServices.provideAPIKey("YOUR_IOS_API_KEY")
    - Check: https://pub.dev/packages/google_maps_flutter

### Configuration

Firebase: This app uses Firebase for user authentication and real-time updates. Configure your Firebase project and add the necessary configuration files to the project.
    - https://console.firebase.google.com
Google Maps API: Obtain API keys for Google Maps for both Android and iOS platforms and add them to the project as mentioned in the installation steps.
    - https://developers.google.com/maps/documentation/geocoding/requests-geocoding

### ScreenShoots

![1](https://github.com/Meriem-Boussoufa/uber_driver_app/assets/93092761/fcfdaa33-aa37-4782-9055-fa2c23e2d293)
![2](https://github.com/Meriem-Boussoufa/uber_driver_app/assets/93092761/11d2ea2a-6d6a-43a1-860d-3ed5dc7fa9e7)
![3](https://github.com/Meriem-Boussoufa/uber_driver_app/assets/93092761/3c4761f7-7583-4162-9479-0c3974bbb07e)
![4](https://github.com/Meriem-Boussoufa/uber_driver_app/assets/93092761/4e301364-a4db-4870-84a9-ef94f75cefe9)
![5](https://github.com/Meriem-Boussoufa/uber_driver_app/assets/93092761/ca202e99-5399-4e33-baa2-e7243642743d)
