# Kigali City Services & Places Directory

This project is a Flutter mobile application designed to help residents and visitors of Kigali find important public services and lifestyle locations. The app allows users to browse a shared directory of places such as hospitals, police stations, restaurants, parks, libraries, and tourist attractions.

Users can also create their own listings and add useful information about different locations in Kigali.

The goal of this project is to demonstrate how a Flutter application can connect to a backend service using Firebase Authentication and Cloud Firestore while maintaining a clean application architecture using state management.

---

# Features

## Authentication
The application supports user authentication using Firebase Authentication.

Users can:
- Create an account using email and password
- Log in to the application
- Log out of the application
- Verify their email address before accessing the app

Each authenticated user also has a corresponding user profile stored in Firestore.

---

## Listings Management (CRUD)

Users can manage location listings stored in Firestore.

Users can:
- Create a new listing
- View all listings in the directory
- Edit listings they created
- Delete listings they created

Each listing contains the following information:

- Place or Service Name
- Category
- Address
- Contact Number
- Description
- Geographic Coordinates (Latitude and Longitude)
- User who created the listing
- Timestamp

---

## Directory Search and Filtering

Users can easily search and filter listings.

The application allows users to:
- Search listings by name
- Filter listings by category (Hospital, Restaurant, Café, Park, etc.)

The results update dynamically as the user types or changes the category filter.

---

## Map Integration

Each listing includes geographic coordinates that are used to display the location on a map.

The application includes:
- An embedded Google Map on the listing detail page
- A marker showing the exact location of the service or place
- A button that opens Google Maps for navigation directions

---

## Map View Screen

The application includes a Map View tab that displays all available listings on a map.

Each listing is represented as a marker on the map.

Users can visually see where different services and places are located around Kigali.

---

## Settings Screen

The Settings screen displays basic user information and preferences.

The screen includes:

- The authenticated user’s email
- A toggle switch for enabling or disabling location-based notifications
- A logout button

The notification toggle is implemented as a local preference simulation.

---

# Technologies Used

The following technologies were used in this project:

- Flutter
- Firebase Authentication
- Cloud Firestore
- Riverpod (State Management)
- Google Maps Flutter
- URL Launcher

---

# Project Architecture

The application follows a layered architecture that separates the UI from backend logic.
