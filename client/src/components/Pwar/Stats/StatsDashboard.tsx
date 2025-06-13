import { useState, useEffect, useCallback } from "react";
import { usePixelawProvider } from "@pixelaw/react";
import { usePwarProvider } from "@/provider/PwarContext";
import styles from "./StatsDashboard.module.css";

export const StatsDashboard = () => {
  const { pixelawCore } = usePixelawProvider();
  const { wallet, world, account } = usePwarProvider();
  const [_clickCount, setClickCount] = useState(0);
  const [pixelsPlaced, setPixelsPlaced] = useState(0);
  const [playerCommit, setPlayerCommit] = useState<number | null>(null);
  const [playerOwns, setPlayerOwns] = useState<number | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  // Track clicks
  const handleCellClick = useCallback(() => {
    setClickCount((prev) => prev + 1);
  }, []);

  // Simulate successful pixel placement
  const incrementPixelsPlaced = useCallback(() => {
    setTimeout(() => {
      if (Math.random() > 0.3) {
        setPixelsPlaced((prev) => prev + 1);
      }
    }, 500);
  }, []);

  // Fetch player data from the contract
  const fetchPlayerData = useCallback(async () => {
    if (!account || !world) return;
    console.log(wallet.address);

    setIsLoading(true);
    try {
      // Get player commit data
      const commitResponse = await world.guild_actions.getPlayerCommit(wallet.address);

      // Get player owns data
      const ownsResponse = await world.guild_actions.getPlayerOwns(wallet.address);

      console.log("commitResponse", commitResponse);
      console.log("ownsResponse", ownsResponse);
      // Update state with fetched data
      setPlayerCommit(Number(commitResponse));
      setPlayerOwns(Number(ownsResponse));
    } catch (error) {
      console.error("Failed to fetch player stats:", error);
    } finally {
      setIsLoading(false);
    }
  }, [account, world, wallet.address]);

  // Set up click listener
  useEffect(() => {
    pixelawCore.events.on("cellClicked", handleCellClick);
    pixelawCore.events.on("cellClicked", incrementPixelsPlaced);

    return () => {
      pixelawCore.events.off("cellClicked", handleCellClick);
      pixelawCore.events.off("cellClicked", incrementPixelsPlaced);
    };
  }, [pixelawCore, handleCellClick, incrementPixelsPlaced]);

  // Fetch player data on component mount and when wallet changes
  useEffect(() => {
    if (wallet && world) {
      fetchPlayerData();

      // Set up periodic refresh (every 30 seconds)
      const intervalId = setInterval(fetchPlayerData, 30000);

      return () => clearInterval(intervalId);
    }
  }, [wallet, world, fetchPlayerData]);

  return (
    <div className={styles.statsDashboard}>
      <h3>Player Stats</h3>

      <div className={styles.statsSection}>
        <div className={styles.statRow}>
          <span className={styles.statLabel}>Address:</span>
          <span className={styles.statValue}>
            {wallet
              ? `${wallet.address.slice(0, 6)}...${wallet.address.slice(-4)}`
              : "Not connected"}
          </span>
        </div>

        <div className={styles.statRow}>
          <span className={styles.statLabel}>Pixels Placed:</span>
          <span className={styles.statValue}>{pixelsPlaced}</span>
        </div>

        <div className={styles.statRow}>
          <span className={styles.statLabel}>Pixels Committed:</span>
          <span className={`${styles.statValue} ${styles.commitValue}`}>
            {isLoading ? "..." : playerCommit !== null ? playerCommit : "N/A"}
          </span>
        </div>

        <div className={styles.statRow}>
          <span className={styles.statLabel}>Pixels Owned:</span>
          <span className={`${styles.statValue} ${styles.ownsValue}`}>
            {isLoading ? "..." : playerOwns !== null ? playerOwns : "N/A"}
          </span>
        </div>

        <button
          type="button"
          className={styles.refreshButton}
          onClick={fetchPlayerData}
          disabled={isLoading}
        >
          {isLoading ? "Loading..." : "Refresh Stats"}
        </button>
      </div>
    </div>
  );
};
