import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar.js";
import GameHook from "./hooks/game";

// Set up game socket first
let gameSocket = new Socket("/socket", { params: { token: window.userToken } });
gameSocket.connect();

// Make socket available globally for our hooks
window.gameSocket = gameSocket;

// Set up game lobby channel for matchmaking
let gameLobbyChannel = gameSocket.channel("game:lobby", {});

// Join the channel when the page loads
gameLobbyChannel.join()
  .receive("ok", () => {
    console.log("Joined game lobby channel successfully.");
  })
  .receive("error", (reason) => {
    console.error("Failed to join game lobby channel:", reason);
  });

// Add event listener for the "Play Classic" button
document.getElementById("playClassic")?.addEventListener("click", () => {
  const playerId = generateUniquePlayerID(); // Replace with actual user ID

  // Notify the server that the player wants to join a game
  gameLobbyChannel.push("join_game", { player_id: playerId });

  // Handle status updates from the server
  gameLobbyChannel.on("status", (payload) => {
    console.log(payload.message);
    alert(payload.message); // Optional: Display a status message to the user
  });

  // Handle match_found event
  gameLobbyChannel.on("match_found", (payload) => {
    if (payload.player1 === playerId || payload.player2 === playerId) {
      console.log("Match found! Redirecting to the game...");
      window.location.href = `/play/${payload.game_id}`;
    }
  });
});

// Generate a unique player ID (use a real identifier in a real app)
function generateUniquePlayerID() {
  return `player-${Math.random().toString(36).substr(2, 9)}`;
}

// CSRF Token and LiveSocket setup
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: { Game: GameHook },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (info) => topbar.show());
window.addEventListener("phx:page-loading-stop", (info) => topbar.hide());

// Connect if there are any LiveViews on the page
liveSocket.connect();

// Expose liveSocket on window for web console debug logs and latency simulation:
window.liveSocket = liveSocket;
