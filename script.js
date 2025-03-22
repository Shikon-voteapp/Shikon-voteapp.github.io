document.addEventListener("DOMContentLoaded", async () => {
    const response = await fetch("data.json");
    const groups = await response.json();
    const container = document.getElementById("vote-options");
    let selected = null;

    groups.forEach(group => {
        const div = document.createElement("div");
        div.classList.add("vote-option");
        div.dataset.id = group.id;
        div.innerHTML = `
            <img src="${group.image}" alt="${group.name}">
            <h3>${group.name}</h3>
            <p>${group.description}</p>
        `;

        div.addEventListener("click", () => {
            document.querySelectorAll(".vote-option").forEach(el => el.classList.remove("selected"));
            div.classList.add("selected");
            selected = group.id;
            document.getElementById("confirm-btn").disabled = false;
        });

        container.appendChild(div);
    });

    document.getElementById("confirm-btn").addEventListener("click", () => {
        if (selected) {
            localStorage.setItem("selectedVote", selected);
            window.location.href = "scanner.html";
        }
    });
});
