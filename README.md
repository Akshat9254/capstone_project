## Getting Started

Follow the steps below to set up and run the project.

### Prerequisites

Make sure you have the following installed:

- [Node.js](https://nodejs.org/) (which includes npm)
- [Expo CLI](https://docs.expo.dev/get-started/installation/) (for running the React Native app)

### Installation and Running the Project

1. **Clone the repository:**

2. **Install Arduino IDE:**

3. **Upload the Code in dht-11-sensor into the dht-11 from arduino IDE:**
    
    Make sure to update the <Network-Name> and <Network-password> to the network to which you are connected.

4. **Run the Dht-11-sensor by plugging in the power:**

5. **Navigate to the `api` directory:**

   ```bash
   cd api
   ```

6. **Install dependencies and run the Express app:**

   ```bash
   npm install
   node app.js
   ```

7. **Open a new terminal and navigate to the `ui` directory:**

   ```bash
   cd ../ui
   ```

8. **Install dependencies and start the Expo development server:**
   ```bash
   npm install
   npx expo start
   ```

### Additional Information

- The Express backend will typically run on [http://localhost:3000](http://localhost:3001) by default.
- The Expo development server will provide a QR code that you can scan with the Expo Go app on your mobile device to run the React Native app.
