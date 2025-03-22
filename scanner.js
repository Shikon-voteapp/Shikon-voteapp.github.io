document.addEventListener("DOMContentLoaded", () => {
    const scanner = new Instascan.Scanner({ video: document.getElementById("preview") });
    
    scanner.addListener("scan", function(content) {
        console.log("Scanned UUID: ", content);
        localStorage.setItem("uuid", content);
        window.location.href = "confirm.html"; // 確認画面へ
    });

    Instascan.Camera.getCameras().then(cameras => {
        if (cameras.length > 0) {
            scanner.start(cameras[0]);
        } else {
            alert("カメラが見つかりません");
        }
    }).catch(err => console.error(err));
});
