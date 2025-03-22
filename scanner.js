document.addEventListener("DOMContentLoaded", () => {
    const scanner = new Html5Qrcode("reader");

    function onScanSuccess(decodedText) {
        localStorage.setItem("uuid", decodedText);
        scanner.stop().then(() => {
            window.location.href = "vote.html"; // 投票画面へ移動
        }).catch(err => console.error(err));
    }

    function onScanFailure(error) {
        console.warn(error);
    }

    scanner.start(
        { facingMode: "environment" }, // 背面カメラ
        { fps: 10, qrbox: 250 },
        onScanSuccess,
        onScanFailure
    );
});
