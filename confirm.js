document.addEventListener("DOMContentLoaded", async () => {
    const selectedVote = localStorage.getItem("selectedVote");
    const uuid = localStorage.getItem("uuid");

    if (!selectedVote || !uuid) {
        alert("エラー: UUIDまたは投票先が見つかりません");
        window.location.href = "index.html";
        return;
    }

    const response = await fetch("data.json");
    const groups = await response.json();
    const group = groups.find(g => g.id === selectedVote);

    document.getElementById("selected-vote").innerHTML = `
        <h2>${group.name}</h2>
        <img src="${group.image}" alt="${group.name}">
        <p>${group.description}</p>
    `;

    document.getElementById("submit-vote").addEventListener("click", async () => {
        await submitVote(uuid, selectedVote);
    });
});

async function submitVote(uuid, vote) {
    const db = firebase.firestore();
    const docRef = db.collection("votes").doc(uuid);

    const doc = await docRef.get();
    if (doc.exists) {
        alert("すでに投票済みです");
        return;
    }

    await docRef.set({
        uuid: uuid,
        vote: vote,
        timestamp: firebase.firestore.FieldValue.serverTimestamp()
    });

    alert("投票が完了しました！");
    localStorage.clear();
    window.location.href = "index.html";
}
