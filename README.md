# MeetingYuk Chat System

## Info

- This code is originally written by [Bimo Aji Fajrianto](https://github.com/bimoajif/meetingyuk-chat).

## How to Use
*** make sure you already has Flutter installed to your machine

### 1. Clone to your local repository
```
git clone https://github.com/bimoajif/meetingyuk-chat.git
```

### 2. Get all dependency
```
flutter pub add
```

### 3. Run project
```
flutter run
```

### ❗️❗️❗️ IMPORTANT
change endpoint Address and MongoDB address to your own which located on:
```
|-- lib/
    |-- common/
        |-- util.dart
    |-- features/
        |-- chat
            |-- chat_controller.dart
```

## Content

All feature structure are divided into 3 folders: Controller, Screen, Widget.
```
|-- Controller --> Consists of all function related to feature to be called by screen / widget
|-- Screen --> Consist of all screen related to feature
|-- Widget --> widgets / additional function of feature
```


