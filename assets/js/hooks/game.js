const GameHook = {
  mounted() {
    console.log("Game hook mounted");
    this.setupGame();
  },

  setupGame() {
    const gameId = this.el.dataset.gameId;
    if (!gameId) return;

    console.log("Setting up game:", gameId);
    
    // Determine game type from URL
    const isCrazyChess = window.location.pathname.startsWith('/crazy');
    const channelTopic = isCrazyChess ? `crazy_game:${gameId}` : `game:${gameId}`;
    
    console.log(`Joining channel: ${channelTopic}`);
    
    // Join the appropriate game channel
    this.channel = window.gameSocket.channel(channelTopic);
    
    this.channel.join()
      .receive("ok", resp => {
        console.log("Joined game channel successfully", resp);
      })
      .receive("error", resp => {
        console.error("Unable to join game channel", resp);
      });

    // Listen for moves broadcast by the other player
    this.channel.on("move_made", payload => {
      console.log("Received move from other player:", payload);
      this.pushEvent("handle_remote_move", payload);
    });

    // Listen for local moves that need to be broadcast
    this.handleEvent("broadcast_move", payload => {
      console.log("Broadcasting move to other player:", payload);
      this.channel.push("move_made", payload);
    });
  },

  destroyed() {
    if (this.channel) {
      console.log("Leaving game channel");
      this.channel.leave();
    }
  }
};

export default GameHook;
