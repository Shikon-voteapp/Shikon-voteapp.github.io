import { initializeApp } from "https://www.gstatic.com/firebasejs/11.5.0/firebase-app.js";

import { getAnalytics } from "https://www.gstatic.com/firebasejs/11.5.0/firebase-analytics.js";


const firebaseConfig = {

    apiKey: "AIzaSyAI78wy0WlWn4YdgVi_rEI5Wl1Ul5hgNic",

    authDomain: "shikon-1762e.firebaseapp.com",

    databaseURL: "https://shikon-1762e-default-rtdb.firebaseio.com",

    projectId: "shikon-1762e",

    storageBucket: "shikon-1762e.firebasestorage.app",

    messagingSenderId: "781969568564",

    appId: "1:781969568564:web:972da5d9d9f5f466b92b61",

    measurementId: "G-37KZEEGZ70"

  };


  const app = initializeApp(firebaseConfig);

  const analytics = getAnalytics(app);


firebase.initializeApp(firebaseConfig);
