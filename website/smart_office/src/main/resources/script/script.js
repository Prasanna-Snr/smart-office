// Gas Detection
const gasAlert = document.getElementById("gasAlert");
document.getElementById("simulateGas").addEventListener("click", () => {
  gasAlert.classList.remove("hidden");
});
function dismissGas() {
  gasAlert.classList.add("hidden");
}

// Dynamic Demo Updates
setTimeout(() => {
  document.getElementById("doorStatus").innerText = "🚪 Door: Open";
  document.getElementById("garbageLevel").innerText = "🗑 Garbage: 80% Full (Warning)";
  document.getElementById("userCount").innerText = "👥 Users: 18";
  document.getElementById("temperature").innerText = "🌡 Temp: 27°C";
}, 3000);
