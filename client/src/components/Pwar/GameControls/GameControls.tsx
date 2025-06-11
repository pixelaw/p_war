import { FC } from "react";
import styles from "./GameControls.module.css";

interface GameControlsProps {
  onStartGame: () => void;
  onPayFee: () => void;
  gameStarted: boolean;
}

export const GameControls: FC<GameControlsProps> = ({
  onStartGame,
  onPayFee,
  gameStarted,
}) => {
  return (
    <div className={styles.gameControls}>
      <h3>Game Controls</h3>

      {!gameStarted ? (
        <button className={styles.startGameButton} onClick={onStartGame}>
          Start New Game
        </button>
      ) : (
        <div className={styles.gameActions}>
          <button className={styles.actionButton} onClick={onPayFee}>
            Pay Participation Fee
          </button>
        </div>
      )}
    </div>
  );
};
