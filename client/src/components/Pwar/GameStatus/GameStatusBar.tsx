import { FC, useEffect, useState } from "react";
import styles from "./GameStatusBar.module.css";
import { usePwarProvider } from "@/provider/PwarContext";
import WalletPickerButton from "@/components/GamePage/WalletPicker/WalletPickerButton.tsx";
import { WalletPicker } from "@/components/GamePage/WalletPicker/WalletPicker";
import { usePixelawProvider } from "@pixelaw/react";

interface GameStatusBarProps {
  gameStarted: boolean;
  gameId: number | null;
}

export const GameStatusBar: FC<GameStatusBarProps> = ({
  gameStarted,
  gameId,
}) => {
  const [timeRemaining, setTimeRemaining] = useState<number | null>(null);
  const { world, account } = usePwarProvider();

  // Fetch game status/time remaining
  useEffect(() => {
    if (!gameStarted || !gameId) return;

    const fetchGameTime = async () => {
      try {
        // Implement according to your contract structure
        const gameData = await world.p_war_game.get_game(account, gameId);
        if (gameData && gameData.end_time) {
          const currentTime = Math.floor(Date.now() / 1000);
          const remaining = gameData.end_time - currentTime;
          setTimeRemaining(remaining > 0 ? remaining : 0);
        }
      } catch (error) {
        console.error("Failed to fetch game time:", error);
      }
    };

    fetchGameTime();
    const interval = setInterval(fetchGameTime, 10000); // Update every 10 seconds

    return () => clearInterval(interval);
  }, [gameId, gameStarted, world]);

  const formatTime = (seconds: number): string => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, "0")}`;
  };

  const playerIcon = "⭐";
  const [activeChooser, setActiveChooser] = useState<"wallet" | null>(null);
  const { app, setApp } = usePixelawProvider();

  const handleWalletPickerClick = () => {
    if (app === "player") {
      setActiveChooser((prev) => (prev === "wallet" ? null : "wallet"));
    } else {
      setApp("player");
    }
  };

  const handleWalletPickerSecondaryClick = () => {
    setActiveChooser((prev) => (prev === "wallet" ? null : "wallet"));
  };

  return (
    <div className={styles.statusBar}>
      {!gameStarted ? (
        <div className={styles.statusMessage}>
          No active game. Start a new game to play!
        </div>
      ) : (
        <div className={styles.gameInfo}>
          <div className={styles.gameIdLabel}>Game #{gameId}</div>
          {timeRemaining !== null && (
            <div className={styles.timeRemaining}>
              Time Remaining: {formatTime(timeRemaining)}
            </div>
          )}
        </div>
      )}
      <WalletPickerButton
        playerEmoji={playerIcon}
        onClick={handleWalletPickerClick}
        onSecondary={handleWalletPickerSecondaryClick}
        selected={app === "player"}
      />
      {activeChooser === "wallet" && (
        <WalletPicker onClose={() => setActiveChooser(null)} />
      )}
    </div>
  );
};
