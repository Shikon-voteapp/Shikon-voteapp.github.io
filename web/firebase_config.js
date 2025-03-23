import { initializeApp } from "https://www.gstatic.com/firebasejs/11.5.0/firebase-app.js";

  import { getAnalytics } from "https://www.gstatic.com/firebasejs/11.5.0/firebase-analytics.js";

  // TODO: Add SDKs for Firebase products that you want to use

  // https://firebase.google.com/docs/web/setup#available-libraries


  // Your web app's Firebase configuration

  // For Firebase JS SDK v7.20.0 and later, measurementId is optional

  const firebaseConfig = {

    apiKey: "AIzaSyBqQj6Caacy8Eq2LqBYnvSn05SKPDOpOUg",

    authDomain: "shikonfes-voteapp.firebaseapp.com",

    databaseURL: "https://shikonfes-voteapp-default-rtdb.firebaseio.com",

    projectId: "shikonfes-voteapp",

    storageBucket: "shikonfes-voteapp.firebasestorage.app",

    messagingSenderId: "897950724981",

    appId: "1:897950724981:web:8829feeabab8a00bab993c",

    measurementId: "G-N3VW7JQ8H1"

  };


  // Initialize Firebase

  const app = initializeApp(firebaseConfig);

  const analytics = getAnalytics(app);
